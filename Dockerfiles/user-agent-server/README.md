# User-Agent 서버

Go 표준 라이브러리만 사용하는 간단한 HTTP 서버입니다.
8080 포트에서 모든 경로의 요청을 받아 `User-Agent` 값을 표준 출력과 응답 본문에 한 줄로 출력합니다.
헤더가 없으면 빈 줄을 출력합니다.

## 로컬 실행

이 디렉터리에서 실행합니다.

```sh
go run .
```

## Docker 실행

이 디렉터리에서 실행합니다.

```sh
docker build -t user-agent-server .
docker run --rm -p 8080:8080 user-agent-server
```

## 요청 예시

```sh
curl -A 'my-test-client/1.0' http://localhost:8080/
```

응답 본문과 서버 표준 출력:

```text
my-test-client/1.0
```
