# AlertManager Setup 

## If you dont have kube-prometheus stack
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
```

## Setup

1. prepare helm values
2. apply helm values
```bash
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --reuse-values \
  -f alertmanager-values.yaml \
  --namespace default
```

3. edit rules yaml
4. apply rules
```bash
kubectl apply -f rules.yaml
```
