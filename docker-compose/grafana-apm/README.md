# Grafana APM template
- Configuration for HTTP metric APM
- Loki(Log), Trace(Tempo), Metric(Prometheus)

## Dashboard template
- https://grafana.com/grafana/dashboards/22784-opentelemetry-service/

## Deploy on systemctl daemon

1
```
sudo vi /etc/systemd/system/grafana.service
```

2
```
sudo systemctl status grafana
```


## Reference 
- https://grafana.com/docs/tempo/latest/getting-started/docker-example/
- https://github.com/grafana/tempo/blob/main/example/docker-compose/local/docker-compose.yaml
- https://opentelemetry.io/docs/languages/go/getting-started/
