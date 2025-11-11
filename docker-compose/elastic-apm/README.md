# Elasticsearch APM

- Elasticsearch, Kibana, APM Server

## How to use

1. `sudo docker compose up elasticsearch kibana`
2. Then, a password and token will be generated in the `config` directory.
3. Go to the Kibana(`http://localhost:15601`) page and log in.
4. On the Kibana page, install the 'elastic apm' and 'fleet server' integrations (for preset configuration)
5. run `sudo docker compose up apm-server` for apm server setting
6. run `sudo docker compose up sample-app`, and `curl http://localhost:8080/health`.
7. Check the trace on the Kibana apm page.

## Etc

- Alfter all, you can remove `password-setter`, `kibana-token-setter`

## Recommendation

1. set memory limit.
   example

```yaml
deploy:
  resources:
    limits:
      memory: 1G
```

2. set logging size limit. (docker log)

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "100m" # 로그 파일 하나의 최대 크기
    max-file: "5"
```

3. set journalctl log limit

```bash
sudo vi /etc/systemd/journald.conf

###
[Journal]
SystemMaxUse=100M
SystemMaxFileSize=50M
###

sudo systemctl daemon-reexec
```
