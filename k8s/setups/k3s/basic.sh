# Master
sudo ufw disable
curl -sfL https://get.k3s.io | K3S_NODE_NAME=노드명 sh -


# If need join
sudo cat /var/lib/rancher/k3s/server/node-token 

# Slaves
sudo ufw disable
curl -sfL https://get.k3s.io | K3S_NODE_NAME=노드명 K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
