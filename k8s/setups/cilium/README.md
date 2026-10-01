# Cilium Setup (k3s)

## Requiredments
1. k3s cluster
2. helm

## Start

1. disable flannel
```bash
sudo mkdir -p /etc/rancher/k3s
sudo vim /etc/rancher/k3s/config.yaml

...
flannel-backend: none
disable-network-policy: true
disable-kube-proxy: true
```
2. restart k3s
```bash
sudo systemctl restart k3s
```
3. install cilium
```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium --namespace kube-system --version 1.20.2 -f values.yaml
```
4. check
```bash
kubectl get all -A -l app.kubernetes.io/part-of=cilium
```
5. restart all pods
```bash
for ns in argocd kube-system envoy-gateway-system observability curhouse app arc-systems arc-runners default; do
  echo "=== $ns ==="
  kubectl -n $ns rollout restart deploy,ds,sts 2>/dev/null | grep -v "no resources"
done
```
