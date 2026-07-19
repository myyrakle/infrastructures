# crawler 로그 수집 — docker 로그 파일 tail (OTel Collector filelog)

crawler 앱은 로그를 **stdout(JSON, +trace_id/span_id)** 로만 남긴다. 이 콜렉터가
크롤러 컨테이너의 docker json-file 로그 파일 하나만 tail 해서 ClickStack
OTLP(logs)로 전송한다. 앱이 OTLP로 로그를 직접 보내지 않으므로 crawler 배포
`docker run`은 수정할 필요가 없다.

```
crawler container ──stdout JSON──▶ <docker inspect LogPath>  (마운트: /logs/crawler-json.log)
                                          │  (filelog tail, root로 실행)
                                   otel-log-collector ──OTLP/HTTP (authorization: <key>)──▶ http://localhost:4318
```

## 실행 (crawler와 같은 호스트)

호스트에서 실제 검증된 방식: 콜렉터는 root로 실행하고, `/var/lib/docker/containers`
전체가 아니라 `docker inspect`로 얻은 크롤러 컨테이너의 로그 파일 **하나만**
마운트한다.

```bash
export CRAWLER_LOG_PATH=$(docker inspect -f '{{.LogPath}}' <크롤러 컨테이너 이름>)
export CLICKSTACK_INGESTION_API_KEY=<ClickStack 인제스트 키>
export OTEL_SERVICE_NAME=crawler
export DEPLOY_ENV=dev   # 배포 환경(dev|qa|prod) — 로그의 deployment.environment 태그

docker compose -f otel-log-collector/docker-compose.yml up -d
```

OTLP 엔드포인트(`http://localhost:4318`)는 `config.yaml`에 하드코딩되어 있다 —
크롤러와 ClickStack이 같은 호스트에 떠 있고, 크롤러 메트릭이 이미 같은 경로로
정상 수집되고 있음을 확인했다.

## 동작 요약 (호스트에서 검증 완료)

- `filelog` 리시버가 `/logs/crawler-json.log`(크롤러 컨테이너의 docker LogPath를
  마운트한 파일) 하나만 tail → `container` operator로 docker 봉투 파싱.
  `add_metadata_from_filepath: false` — 이 방식에서는 파일 경로에 컨테이너 ID가
  없으므로 메타데이터를 파일 경로에서 끌어오지 않는다.
- 앱 로그 라인이 JSON이면 파싱해 attributes로 승격, `level`→OTel severity 매핑.
- `transform`(OTTL)으로 앱이 남긴 `trace_id`/`span_id`를 LogRecord의 TraceId/SpanId로
  승격 → ClickStack에서 trace↔log 상관.
- 필터 프로세서는 없다 — 마운트된 파일 자체가 크롤러 전용 로그이므로 컨테이너
  이름으로 걸러낼 필요가 없다(예전 `filter/only_crawler`는 docker json 로그에
  `container.name`이 채워지지 않아 전체 로그를 삭제해버렸다 — 제거함).
- `resource`로 `service.name`(ClickStack `ServiceName` 컬럼)과
  `deployment.environment`(`DEPLOY_ENV`, 예: dev/qa/prod) 부여 — ClickStack
  백엔드가 환경 공유이므로 로그를 환경별로 구분하기 위한 필수 태그.

## 왜 root(`--user 0:0` / `user: "0:0"`)로 실행하는가

docker의 json-file 로그 파일은 보통 root 소유다. 콜렉터를 비-root 사용자로
띄우면 그 파일을 열 때 permission denied가 발생해 로그가 전혀 수집되지 않는다
(호스트에서 실제로 재현/해결됨).

## 알려진 한계

- `start_at: beginning`이므로 콜렉터가 재시작(재배포)될 때마다 로그 파일을
  처음부터 다시 읽는다 — 재배포마다 로그가 중복 전송될 수 있다. `file_storage`
  익스텐션으로 읽은 오프셋을 영속화해 dedup 하는 것은 추후 과제로 남긴다.
- 로그가 실제로 흐르려면 **ClickStack OTLP 수신부가 살아 있어야** 한다. 메인
  compose의 ClickHouse 인증(`CLICKHOUSE_*_PASSWORD`)과 번들 콜렉터의 ClickHouse
  접속 자격이 불일치하면 콜렉터가 `516 Authentication failed`로 죽어 4317/4318이
  열리지 않는다 — 그 경우 먼저 그 인증을 맞춰야 한다.
- 확인 쿼리:
  ```bash
  docker exec clickstack clickhouse-client --query \
    "SELECT count() FROM default.otel_logs WHERE ServiceName='crawler'"
  ```
