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
