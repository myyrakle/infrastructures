kubectl create ns argocd
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -O install.yaml​​​
kubectl apply -n argocd -f install.yaml

kubectl get all -n argocd

kubectl patch svc argocd-server -n argocd --type=json -p='[{"op": "replace", "path": "/spec/ports", "value": [{"name":"default", "port":8080, "targetPort": 8080, "protocol": "TCP"}]}]'
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type":"ClusterIP", "externalIPs": ["192.168.0.12"]}}'

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


