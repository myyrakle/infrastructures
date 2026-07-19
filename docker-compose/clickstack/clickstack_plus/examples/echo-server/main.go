package main

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"go.opentelemetry.io/contrib/instrumentation/github.com/labstack/echo/otelecho"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
	"go.opentelemetry.io/otel/trace"
)

func main() {
	ctx := context.Background()
	serviceName := env("OTEL_SERVICE_NAME", "clickstack-echo-server")
	if ingestionAPIKey() == "" {
		log.Fatal("CLICKSTACK_INGESTION_API_KEY is required; paste the HyperDX Ingestion API Key into examples/echo-server/.env")
	}

	shutdownTelemetry, err := setupTelemetry(ctx, serviceName)
	if err != nil {
		log.Fatalf("setup telemetry: %v", err)
	}
	defer shutdownTelemetry(context.Background())

	e := echo.New()
	e.HideBanner = true
	e.Use(middleware.Recover())
	e.Use(middleware.Logger())
	e.Use(otelecho.Middleware(serviceName))

	e.GET("/health", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]any{
			"ok":      true,
			"service": serviceName,
		})
	})

	e.GET("/db", func(c echo.Context) error {
		result, err := checkDB(c.Request().Context())
		if logErr := emitLog(c.Request().Context(), serviceName, c.Request().Method, c.Request().URL.Path, 0); logErr != nil {
			log.Printf("emit log: %v", logErr)
		}
		if err != nil {
			return c.JSON(http.StatusServiceUnavailable, map[string]interface{}{
				"ok":    false,
				"error": err.Error(),
			})
		}
		return c.JSON(http.StatusOK, result)
	})

	e.GET("/otel-check", func(c echo.Context) error {
		result, err := checkOTLP(c.Request().Context(), serviceName)
		if err != nil {
			return c.JSON(http.StatusBadGateway, map[string]interface{}{
				"ok":    false,
				"error": err.Error(),
				"target": strings.TrimRight(
					env("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4318"),
					"/",
				) + "/v1/logs",
			})
		}
		return c.JSON(http.StatusOK, result)
	})

	e.Any("/*", func(c echo.Context) error {
		body, err := io.ReadAll(c.Request().Body)
		if err != nil {
			return err
		}

		if err := emitLog(c.Request().Context(), serviceName, c.Request().Method, c.Request().URL.Path, len(body)); err != nil {
			log.Printf("emit log: %v", err)
		}

		return c.JSON(http.StatusOK, map[string]interface{}{
			"method":     c.Request().Method,
			"path":       c.Request().URL.Path,
			"query":      c.QueryParams(),
			"headers":    c.Request().Header,
			"body":       string(body),
			"receivedAt": time.Now().UTC().Format(time.RFC3339Nano),
		})
	})

	errCh := make(chan error, 1)
	go func() {
		errCh <- e.Start(":" + env("PORT", "8080"))
	}()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	select {
	case sig := <-sigCh:
		log.Printf("received signal: %s", sig)
	case err := <-errCh:
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server: %v", err)
		}
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := e.Shutdown(shutdownCtx); err != nil {
		log.Printf("shutdown server: %v", err)
	}
}

func setupTelemetry(ctx context.Context, serviceName string) (func(context.Context), error) {
	res, err := resource.Merge(
		resource.Default(),
		resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceName(serviceName),
			attribute.String("deployment.environment", "local-test"),
		),
	)
	if err != nil {
		return nil, err
	}

	traceExporter, err := otlptracehttp.New(ctx)
	if err != nil {
		return nil, err
	}
	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(traceExporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(tracerProvider)
	otel.SetTextMapPropagator(propagation.TraceContext{})

	return func(ctx context.Context) {
		if err := tracerProvider.Shutdown(ctx); err != nil {
			log.Printf("shutdown tracer provider: %v", err)
		}
	}, nil
}

func emitLog(ctx context.Context, serviceName, method, path string, bodySize int) error {
	_, err := postOTLPLog(ctx, serviceName, method, path, bodySize)
	return err
}

func checkOTLP(ctx context.Context, serviceName string) (map[string]interface{}, error) {
	result, err := postOTLPLog(ctx, serviceName, "GET", "/otel-check", 0)
	if err != nil {
		return nil, err
	}
	return map[string]interface{}{
		"ok":           true,
		"target":       result.Target,
		"status":       result.Status,
		"responseBody": result.Body,
	}, nil
}

type otlpPostResult struct {
	Target string
	Status string
	Body   string
}

func postOTLPLog(ctx context.Context, serviceName, method, path string, bodySize int) (otlpPostResult, error) {
	endpoint := strings.TrimRight(env("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4318"), "/")
	target := endpoint + "/v1/logs"
	apiKey := ingestionAPIKey()
	if apiKey == "" {
		return otlpPostResult{Target: target}, fmt.Errorf("CLICKSTACK_INGESTION_API_KEY is empty")
	}

	spanCtx := trace.SpanContextFromContext(ctx)
	logRecord := map[string]interface{}{
		"timeUnixNano": fmt.Sprintf("%d", time.Now().UnixNano()),
		"severityText": "INFO",
		"body": map[string]interface{}{
			"stringValue": fmt.Sprintf("%s %s", method, path),
		},
		"attributes": []map[string]interface{}{
			stringAttr("http.method", method),
			stringAttr("url.path", path),
			intAttr("http.request.body.size", bodySize),
		},
	}
	if spanCtx.IsValid() {
		logRecord["traceId"] = spanCtx.TraceID().String()
		logRecord["spanId"] = spanCtx.SpanID().String()
	}

	payload := map[string]interface{}{
		"resourceLogs": []map[string]interface{}{{
			"resource": map[string]interface{}{
				"attributes": []map[string]interface{}{
					stringAttr("service.name", serviceName),
					stringAttr("deployment.environment", "local-test"),
				},
			},
			"scopeLogs": []map[string]interface{}{{
				"scope": map[string]interface{}{"name": "echo-server"},
				"logRecords": []map[string]interface{}{
					logRecord,
				},
			}},
		}},
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return otlpPostResult{Target: target}, err
	}

	requestCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(requestCtx, http.MethodPost, target, bytes.NewReader(body))
	if err != nil {
		return otlpPostResult{Target: target}, err
	}
	req.Header.Set("content-type", "application/json")
	req.Header.Set("authorization", apiKey)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return otlpPostResult{Target: target}, err
	}
	defer res.Body.Close()
	responseBody, _ := io.ReadAll(io.LimitReader(res.Body, 512))
	result := otlpPostResult{
		Target: target,
		Status: res.Status,
		Body:   string(responseBody),
	}
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return result, fmt.Errorf("otlp logs returned %s: %s", res.Status, result.Body)
	}
	return result, nil
}

func stringAttr(key, value string) map[string]interface{} {
	return map[string]interface{}{
		"key": key,
		"value": map[string]interface{}{
			"stringValue": value,
		},
	}
}

func intAttr(key string, value int) map[string]interface{} {
	return map[string]interface{}{
		"key": key,
		"value": map[string]interface{}{
			"intValue": fmt.Sprintf("%d", value),
		},
	}
}

func ingestionAPIKey() string {
	if value := os.Getenv("CLICKSTACK_INGESTION_API_KEY"); value != "" {
		return value
	}
	headers := os.Getenv("OTEL_EXPORTER_OTLP_HEADERS")
	for _, part := range strings.Split(headers, ",") {
		key, value, ok := strings.Cut(part, "=")
		if ok && strings.TrimSpace(strings.ToLower(key)) == "authorization" {
			return strings.TrimSpace(value)
		}
	}
	return ""
}

func checkDB(ctx context.Context) (map[string]interface{}, error) {
	dsn := env("DATABASE_URL", "postgres://postgres@host.docker.internal:5432/postgres?sslmode=disable")
	db, err := sql.Open("pgx", dsn)
	if err != nil {
		return nil, err
	}
	defer db.Close()

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, err
	}

	var database string
	var user string
	var version string
	if err := db.QueryRowContext(ctx, "SELECT current_database(), current_user, version()").Scan(&database, &user, &version); err != nil {
		return nil, err
	}

	return map[string]interface{}{
		"ok":       true,
		"database": database,
		"user":     user,
		"version":  version,
	}, nil
}

func env(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}
