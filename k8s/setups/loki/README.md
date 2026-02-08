# Simple Loki stack 
- with promtail

1. helm prepare
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
2. edit loki-values.yaml
3. install loki with values.yaml
```bash
helm install loki grafana/loki-stack \
  -n logging \
  --create-namespace \
  -f loki-stack-values.yaml
```
4. check
```kubectl get pods -n logging```
