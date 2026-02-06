helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# Open port
kubectl patch svc prometheus-grafana --type=json -p='[{"op": "replace", "path": "/spec/ports", "value": [{"name":"default", "port":28080, "targetPort": 3000, "protocol": "TCP"}]}]'
kubectl patch svc prometheus-grafana -p '{"spec": {"type":"ClusterIP", "externalIPs": ["192.168.0.8"]}}'

# GET ADMIN PASSWORD
kubectl --namespace default get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
