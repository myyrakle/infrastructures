# Arm64 이미지
- go 1.27
- pnpm 10

## docker 말기
```bash
docker build -t ghcr.io/myyrakle/arc-runner:arm-2026.05.27-2 \
  -f arc/Dockerfile .
```

## push하기
echo '...' | docker login ghcr.io -u myyrakle --password-stdin

```
helm upgrade arc-runner-set oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
  -n arc-runners \
  -f scaleset-values.yaml \
  --force-conflicts
```
