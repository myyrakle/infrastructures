# Headlamp Setup 

install (with helm)
```bash 
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm install headlamp headlamp/headlamp --namespace kube-system
```

check
```bash
kubectl get all -l "app.kubernetes.io/name=headlamp,app.kubernetes.io/instance=headlamp" -n kube-system
```

open service
```bash
kubectl patch svc headlamp -n kube-system --type=json -p='[{"op": "replace", "path": "/spec/ports", "value": [{"name":"default", "port":17200, "targetPort": 4466, "protocol": "TCP"}]}]'
kubectl patch svc headlamp -n kube-system -p '{"spec": {"type":"ClusterIP", "externalIPs": ["192.168.0.8"]}}'
```

get ID Token 
```bash
kubectl create token headlamp --namespace kube-system
```

## Create Read-Only User

```bash
kubectl apply -f read-only-role.yaml
kubectl create serviceaccount headlamp-readonly -n kube-system
kubectl create clusterrolebinding headlamp-read-only-binding \
  --clusterrole=headlamp-readonly \
  --serviceaccount=kube-system:headlamp-readonly \
  -n kube-system

kubectl apply -f headlamp-readonly-token.yaml
kubectl get secret headlamp-readonly-token -n kube-system -o jsonpath='{.data.token}' | base64 -d
```
