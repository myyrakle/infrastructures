helm repo add harbor https://helm.goharbor.io
helm repo update
kubectl create namespace harbor

helm install harbor harbor/harbor --namespace harbor -f helm-values.yaml

kubectl get all -n harbor
kubectl get pods -n harbor -o wide

kubectl patch svc harbor -n harbor --type=json -p='[{"op": "replace", "path": "/spec/ports", "value": [{"name":"default", "port":17000, "targetPort": 8080, "protocol": "TCP"}]}]'
kubectl patch svc harbor -n harbor -p '{"spec": {"type":"ClusterIP", "externalIPs": ["192.168.0.8"]}}'

# ... 
kubectl create secret docker-registry harbor-secret \
  --namespace default \
  --docker-server=192.168.0.8:17000 \
  --docker-username=admin \
  --docker-password=<password>
