# 미완성 

helm repo add harbor https://helm.goharbor.io
helm repo update
kubectl create namespace harbor

helm install harbor harbor/harbor --namespace harbor -f helm-values.yaml

kubectl get all -n harbor
kubectl get pods -n harbor -o wide
