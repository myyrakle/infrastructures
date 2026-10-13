# Amd64 이미지
- go 1.27
- node 24
- pnpm 11

## 배포
말기
```bash
docker build -t ghcr.io/myyrakle/arc-runner:amd-2026.10.13-1 \
  -f Dockerfile .
```

push하기
echo '...' | docker login ghcr.io -u myyrakle --password-stdin

## 사용
helm 기반 교체
```
helm upgrade arc-runner-set oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
  -n arc-runners \
  -f scaleset-values.yaml \
  --force-conflicts
```
