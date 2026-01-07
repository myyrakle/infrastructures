# go2:1.23.6-alpine3.20

## make

```bash
sudo docker buildx build --platform linux/amd64,linux/arm64 -t myyrakle/go2:1.25.5-alpine3.23 .
```

## Use Example

```dockerfile
FROM myyrakle/go2:1.23.6-alpine3.20 AS builder

WORKDIR /app
ADD . /app

RUN apk add alpine-sdk

RUN go build -o bin/app cmd/foo/main.go

FROM alpine

WORKDIR /app

COPY --from=builder /app/bin/app /app/app

CMD ["sh", "-c", "/app/app"]
```
