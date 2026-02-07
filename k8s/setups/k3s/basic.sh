# Master
sudo ufw disable
curl -sfL https://get.k3s.io | K3S_NODE_NAME=노드명 sh -

kubectl run curl-test --image=curlimages/curl:latest --rm -it --restart=Never \
  --overrides='{"spec":{"nodeName":"노드명"}}' \
  -- curl -o /dev/null -s -w "%{http_code}\n" https://google.com

# If need join
sudo cat /var/lib/rancher/k3s/server/node-token 

# Slaves
sudo ufw disable
curl -sfL https://get.k3s.io | K3S_NODE_NAME=노드명 K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -

kubectl run curl-test --image=curlimages/curl:latest --rm -it --restart=Never \
  --overrides='{"spec":{"nodeName":"노드명"}}' \
  -- curl -o /dev/null -s -w "%{http_code}\n" https://google.com
