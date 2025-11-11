# go2:1.20.14-alpine3.16

## make

```bash
sudo docker buildx build --platform linux/amd64,linux/arm64  -f ./Dockerfile -t myyrakle/go2:1.20.14-alpine3.16 .
sudo docker push myyrakle/go2:1.20.14-alpine3.16
```

## Use Example

```dockerfile
FROM myyrakle/go2:1.20.14-alpine3.16 AS builder

WORKDIR /app
ADD . /app

RUN apk add alpine-sdk

RUN go build -o bin/app cmd/foo/main.go

FROM alpine

WORKDIR /app

COPY --from=builder /app/bin/app /app/app

CMD ["sh", "-c", "/app/app"]
```
