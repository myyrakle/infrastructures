# Grafana & Loki template 
- Configuration for logging

## How to use

deploy
```bash
docker compose up -d
```

enter dashboard: http://localhost:13000/ 
```
default id: admin
default password: admin
```

write log
```bash
curl -H "Content-Type: application/json" -XPOST -s "http://127.0.0.1:13100/loki/api/v1/push"  \
--data-raw "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}" \
-H X-Scope-OrgId:foo

```

![image](https://github.com/user-attachments/assets/9b6f50d9-2c6a-41d8-8344-9bf3cb8dc046)


## Reference 
- https://grafana.com/docs/loki/latest/setup/install/docker/
