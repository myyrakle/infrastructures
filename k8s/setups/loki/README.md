# Simple Loki stack 
- with promtail

1. helm prepare
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
2. edit loki-values.yaml
3. install loki with values yaml
```bash
helm install loki grafana/loki \
   -n logging \
   --create-namespace \
   -f loki-values.yaml
```
4. edit promtail-values.yaml
5. install promtail agent with values yaml
```bash
helm install promtail grafana/promtail \
  -n logging \
  -f promtail-values.yaml
```  
6. check
```kubectl get pods -n logging```
