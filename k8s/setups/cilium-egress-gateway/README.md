# Cilium Egress Gateway (with kube-vip)

## Requirements 

cilium helm values
```yaml
kubeProxyReplacement: true

egressGateway:
  enabled: true
```

## 게이트웨이용 풀 라벨

```bash
kubectl label node 노드명 egress.myyrakle.io/pool=default --overwrite
kubectl get nodes -L egress.myyrakle.io/pool
```

