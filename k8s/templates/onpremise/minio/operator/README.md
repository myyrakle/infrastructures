# minio operator 

simple
```bash
kubectl apply -k "github.com/minio/operator?ref=v6.0.4"
```

if single node 
```bash
kubectl scale deployment minio-operator -n minio-operator --replicas=1
```
