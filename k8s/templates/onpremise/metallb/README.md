# metallb 

install
```bash
kubectl create ns metallb-system
helm upgrade --install -n metallb-system metallb oci://registry-1.docker.io/bitnamicharts/metallb
```

run
```bash
kubectl apply -f ./address.yaml
```
