# Kubernetes Dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard --type=json -p='[{"op": "replace", "path": "/spec/ports", "value": [{"name":"default", "port":17100, "targetPort": 8000, "protocol": "TCP"}]}]'
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type":"ClusterIP", "externalIPs": ["192.168.0.8"]}}'
```
