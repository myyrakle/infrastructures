package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/labstack/echo/v4"
	"go.opentelemetry.io/contrib/instrumentation/github.com/labstack/echo/otelecho"
	"go.opentelemetry.io/contrib/instrumentation/runtime"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
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

	err = runtime.Start(runtime.WithMinimumReadMemStatsInterval(time.Second))
	if err != nil {
		panic(err)
	}

	return traceProvider
}

func main() {
	traceProvider := initTracer()

	tracer := traceProvider.Tracer("foo")

	defer func() {
		if err := traceProvider.Shutdown(context.Background()); err != nil {
			log.Fatalf("failed to shutdown tracer: %v", err)
		}
	}()

	e := echo.New()

	e.Use(otelecho.Middleware("go-server"))

	e.Use(func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			err := next(c)

			span := otelTrace.SpanFromContext(c.Request().Context())

			if span != nil {
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

	e.Logger.Fatal(e.Start(":1323"))
}
