# cloudflared setup

```bash
kubectl create secret generic cloudflared-token \
  --from-literal=token="YOUR_COPIED_CLOUDFLARE_TOKEN" \
  --namespace=kube-system
```
