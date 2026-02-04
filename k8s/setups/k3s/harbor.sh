# 미완성 

helm repo add harbor https://helm.goharbor.io
helm repo update
kubectl create namespace harbor

helm show values harbor/harbor > helm-values.yaml
# ... Edit

helm install harbor harbor/harbor --namespace harbor -f helm-values.yaml

kubectl get all -n harbor

kubectl patch svc harbor -n harbor --type=json -p='[{"op": "replace", "path": "/spec/ports", "value": [{"name":"default", "port":20010, "targetPort": 8080, "protocol": "TCP"}]}]'
kubectl patch svc harbor -n harbor -p '{"spec": {"type":"ClusterIP", "externalIPs": ["192.168.0.12"]}}'

kubectl patch svc harbor-core -n harbor -p '{"spec": {"type":"ClusterIP"}}'

kubectl describe service harbor-core -n harbor
