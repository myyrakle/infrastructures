FROM busybox:stable-musl AS probe

FROM otel/opentelemetry-collector-contrib:0.156.0

COPY --from=probe /bin/busybox /busybox
COPY config.yaml /etc/otelcol-contrib/config.yaml
