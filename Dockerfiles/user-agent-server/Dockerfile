FROM golang:1.25.5-alpine3.23 AS builder
WORKDIR /app
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /user-agent-server .

FROM scratch
COPY --from=builder /user-agent-server /user-agent-server
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["/user-agent-server"]
