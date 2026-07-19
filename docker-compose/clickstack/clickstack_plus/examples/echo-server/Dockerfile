FROM golang:1.22-alpine AS build

WORKDIR /src
RUN apk add --no-cache ca-certificates git
COPY go.mod go.sum ./
RUN /usr/local/go/bin/go mod download
COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux /usr/local/go/bin/go build -trimpath -ldflags="-s -w" -o /out/echo-server .

FROM alpine:3.20

WORKDIR /app
COPY --from=build /out/echo-server /app/echo-server

ENV PORT=8080
EXPOSE 8080

CMD ["/app/echo-server"]
