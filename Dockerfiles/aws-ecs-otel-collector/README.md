# otel collector (for AWS ECS)

## How to build 
```bash
docker buildx build --platform linux/amd64,linux/arm64 --push \
  -f Dockerfile \
  -t myyrakle/otel-collector:latest .
```
