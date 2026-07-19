-- 30-day retention for ClickStack telemetry.
-- ttl_only_drop_parts drops whole expired parts (lower merge overhead).
ALTER TABLE default.otel_logs   MODIFY SETTING ttl_only_drop_parts = 1;
ALTER TABLE default.otel_logs   MODIFY TTL Timestamp + toIntervalDay(30);

ALTER TABLE default.otel_traces MODIFY SETTING ttl_only_drop_parts = 1;
ALTER TABLE default.otel_traces MODIFY TTL Timestamp + toIntervalDay(30);

ALTER TABLE default.otel_metrics_gauge                 MODIFY TTL TimeUnix + toIntervalDay(30);
ALTER TABLE default.otel_metrics_sum                   MODIFY TTL TimeUnix + toIntervalDay(30);
ALTER TABLE default.otel_metrics_histogram             MODIFY TTL TimeUnix + toIntervalDay(30);
ALTER TABLE default.otel_metrics_exponential_histogram MODIFY TTL TimeUnix + toIntervalDay(30);
ALTER TABLE default.otel_metrics_summary               MODIFY TTL TimeUnix + toIntervalDay(30);
