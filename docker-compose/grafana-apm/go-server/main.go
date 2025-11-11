package main

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/go-resty/resty/v2"
	_ "github.com/lib/pq"
	"github.com/pkg/errors"

	"github.com/labstack/echo/v4"
	"go.opentelemetry.io/contrib/instrumentation/github.com/labstack/echo/otelecho"
	"go.opentelemetry.io/contrib/instrumentation/runtime"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.4.0"
	otelTrace "go.opentelemetry.io/otel/trace"
)

func initTracer() *trace.TracerProvider {
	ctx := context.Background()

	// Create the OTLP traceExporter
	traceExporter, err := otlptracehttp.New(ctx, otlptracehttp.WithEndpointURL(
		"http://localhost:4318",
	), otlptracehttp.WithInsecure())
	if err != nil {
		panic(err)
	}

	// Create the tracer provider
	traceProvider := trace.NewTracerProvider(
		trace.WithBatcher(traceExporter),
		trace.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceNameKey.String("go-server"),
			semconv.ServiceNamespaceKey.String("dev"),
		)),
	)

	// Set the global tracer provider
	otel.SetTracerProvider(traceProvider)

	return traceProvider
}

func initMetric() *metric.MeterProvider {
	ctx := context.Background()

	metricExporter, err := otlpmetrichttp.New(ctx, otlpmetrichttp.WithEndpointURL(
		"http://localhost:4318",
	), otlpmetrichttp.WithInsecure())
	if err != nil {
		panic(err)
	}

	meterProvider := metric.NewMeterProvider(
		metric.WithReader(metric.NewPeriodicReader(metricExporter, metric.WithInterval(3*time.Second))),
		metric.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceNameKey.String("go-server"),
			semconv.ServiceNamespaceKey.String("dev"),
		)),
	)
	if err != nil {
		panic(err)
	}
	otel.SetMeterProvider(meterProvider)

	err = runtime.Start(runtime.WithMinimumReadMemStatsInterval(time.Second))
	if err != nil {
		panic(err)
	}

	return meterProvider
}

func initDB() *sql.DB {
	connStr := "postgres://otel:otel@localhost:25432/otel?sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}

	// Test connection
	err = db.Ping()
	if err != nil {
		panic(err)
	}

	return db
}

func main() {
	traceProvider := initTracer()
	_ = initMetric()

	tracer := traceProvider.Tracer("foo")

	defer func() {
		if err := traceProvider.Shutdown(context.Background()); err != nil {
			log.Fatalf("failed to shutdown tracer: %v", err)
		}
	}()

	db := initDB()

	executeQuery := func(ctx context.Context, methodName string, query string) (*sql.Rows, error) {
		_, span := tracer.Start(ctx, "db-span", otelTrace.WithSpanKind(otelTrace.SpanKindClient))
		defer span.End()

		// https://opentelemetry.io/docs/specs/semconv/database/database-metrics/
		span.SetAttributes(attribute.String("db.database", "none"))
		span.SetAttributes(attribute.String("db.system.name", "postgresql"))
		span.SetAttributes(attribute.String("db.operation", "query"))
		span.SetAttributes(attribute.String("db.operation.name", methodName))
		span.SetAttributes(attribute.String("db.query.text", query))
		span.SetAttributes(attribute.String("span.group", "OUTBOUND-DATABASE"))

		result, err := db.Query(query)

		if err != nil {
			span.SetAttributes(attribute.String("db.error", err.Error()))
			span.RecordError(err)
			return nil, err
		}
		return result, nil
	}

	restyClient := resty.New().OnAfterResponse(func(client *resty.Client, response *resty.Response) error {
		if response == nil {
			fmt.Println("Response is nil")
		}

		if response.Request == nil {
			fmt.Println("Request is nil")
			return nil
		}

		ctx := response.Request.Context()

		if ctx == nil {
			fmt.Println("Context is nil")
			return nil
		}

		if response.Request.RawRequest == nil {
			fmt.Println("RawRequest is nil")
			return nil
		}

		if response.Request.RawRequest.URL == nil {
			fmt.Println("URL is nil")
			return nil
		}

		requestTime := response.Request.Time
		_, span := tracer.Start(
			ctx,
			"http-span",
			otelTrace.WithSpanKind(otelTrace.SpanKindClient),
			otelTrace.WithTimestamp(requestTime),
		)
		defer span.End()

		rawRequest := response.Request.RawRequest
		urlInfo := rawRequest.URL

		// https://opentelemetry.io/docs/specs/semconv/http/http-spans/
		span.SetAttributes(attribute.String("server.address", urlInfo.Hostname()))
		span.SetAttributes(attribute.String("server.port", urlInfo.Port()))
		span.SetAttributes(attribute.String("http.request.method", rawRequest.Method))
		span.SetAttributes(attribute.String("http.response.status_code", response.Status()))
		span.SetAttributes(attribute.String("network.transport", "http"))
		span.SetAttributes(attribute.String("url.template", urlInfo.Path))
		span.SetAttributes(attribute.String("url.full", urlInfo.String()))
		span.SetAttributes(attribute.String("span.group", "OUTBOUND-HTTP"))

		if rawRequest.Body != nil {
			requestBodyBytes, _ := io.ReadAll(rawRequest.Body)

			// 256 bytes limit
			requestBodyString := []rune(string(requestBodyBytes))

			if len(requestBodyString) > 256 {
				requestBodyString = requestBodyString[:256]
			}

			span.SetAttributes(attribute.Int("http.request.body.size", len(requestBodyBytes)))
			span.SetAttributes(attribute.String("http.request.body", string(requestBodyBytes)))
		}

		// 256 bytes limit
		responseBodyString := []rune(string(response.Body()))
		if len(responseBodyString) > 256 {
			responseBodyString = responseBodyString[:256]
		}
		span.SetAttributes(attribute.Int("http.response.body.size", len(response.Body())))
		span.SetAttributes(attribute.String("http.response.body", string(responseBodyString)))

		return nil
	})

	e := echo.New()

	e.Use(otelecho.Middleware("go-server"))

	e.Use(func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			err := next(c)

			span := otelTrace.SpanFromContext(c.Request().Context())

			if span != nil {
				if err != nil {
					span.SetStatus(codes.Error, err.Error())
					return err
				}

				responseStatusCode := c.Response().Status

				spanStatus := codes.Ok

				if responseStatusCode >= 400 {
					spanStatus = codes.Error
				}

				span.SetStatus(spanStatus, "")
				span.SetAttributes(attribute.Bool("primary", true))
				span.SetAttributes(attribute.String("span.group", "API-SERVER"))
			}
			return err
		}
	})

	e.GET("/trace", func(c echo.Context) error {
		_, span := tracer.Start(c.Request().Context(), "test-span")
		time.Sleep(200 * time.Millisecond)
		span.End()

		_, span = tracer.Start(c.Request().Context(), "test-span2")
		time.Sleep(500 * time.Millisecond)
		span.End()

		return c.String(http.StatusOK, "trace completed")
	})

	e.GET("/api", func(c echo.Context) error {
		// call google.com
		response, _ := http.Get("https://google.com")
		defer response.Body.Close()

		return c.String(http.StatusOK, "api called")
	})

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})

	e.GET("/foo", func(c echo.Context) error {
		time.Sleep(1 * time.Second)

		span := otelTrace.SpanFromContext(c.Request().Context())

		if span != nil {
			span.SetAttributes(attribute.KeyValue{
				Key:   "password",
				Value: attribute.StringValue("q1w2e3r4"),
			})
		}

		return c.String(http.StatusOK, "foo")
	})

	e.GET("/bar", func(c echo.Context) error {
		time.Sleep(2 * time.Second)
		return c.String(http.StatusOK, "bar")
	})

	e.GET("/not-found", func(c echo.Context) error {
		time.Sleep(2 * time.Second)
		return c.String(http.StatusNotFound, "NOT FOUND")
	})

	e.GET("/internal", func(c echo.Context) error {
		time.Sleep(2 * time.Second)
		return c.String(http.StatusInternalServerError, "INTERNAL SERVER ERROR")
	})

	e.GET("/too-slow", func(c echo.Context) error {
		time.Sleep(5 * time.Second)
		return c.String(http.StatusInternalServerError, "slow")
	})

	e.GET("/db-call", func(c echo.Context) error {
		_, err := executeQuery(c.Request().Context(), "just select 1", "SELECT 1")
		if err != nil {
			c.String(http.StatusInternalServerError, "db error")
		}

		return c.String(http.StatusOK, "db called")
	})

	e.GET("/db-error", func(c echo.Context) error {
		_, err := executeQuery(c.Request().Context(), "just error", "SELECT asdf")
		if err != nil {
			c.String(http.StatusInternalServerError, "db error")
			return nil
		}

		return c.String(http.StatusOK, "db error")
	})

	e.GET("/http-call", func(c echo.Context) error {
		request := restyClient.R()
		request = request.SetContext(c.Request().Context())

		_, err := request.Get("https://google.com")
		if err != nil {
			c.String(http.StatusInternalServerError, "http error")
		}

		return c.String(http.StatusOK, "http called")
	})

	e.GET("/event", func(c echo.Context) error {
		span := otelTrace.SpanFromContext(c.Request().Context())

		if span != nil {
			span.AddEvent("event1", otelTrace.WithAttributes(attribute.String("key1", "value1")))
			span.AddEvent("event2", otelTrace.WithAttributes(attribute.String("key2", "value2")))
		}

		return c.String(http.StatusOK, "event")
	})

	e.GET("/direct-error", func(c echo.Context) error {
		span := otelTrace.SpanFromContext(c.Request().Context())

		err := SomeError{
			Message: "direct error",
		}

		if span != nil {
			span.RecordError(err)
		}

		return c.String(http.StatusOK, "error")
	})

	e.GET("/direct-error-with-stacktrace", func(c echo.Context) error {
		span := otelTrace.SpanFromContext(c.Request().Context())

		err := SomeError{
			Message: "direct error",
		}
		wrappedErr := errors.Wrap(err, "wrapped error")

		if span != nil {
			// https://opentelemetry.io/docs/specs/otel/trace/exceptions/#attributes
			span.RecordError(
				wrappedErr,
				otelTrace.WithAttributes(attribute.String("exception.stacktrace", fmt.Sprintf("%+v", wrappedErr))),
			)
		}

		return c.String(http.StatusOK, "error")
	})

	e.Logger.Fatal(e.Start(":1323"))

}

type SomeError struct {
	Message string
}

func (e SomeError) Error() string {
	return e.Message
}
