# Master
curl -sfL https://get.k3s.io | K3S_NODE_NAME=노드명 sh -
sudo ufw allow 6443/tcp 
sudo ufw allow 10250/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 8472/udp 
sudo ufw allow 30000:32767/tcp

# If need join
sudo cat /var/lib/rancher/k3s/server/node-token 

# Slaves
curl -sfL https://get.k3s.io | K3S_NODE_NAME=노드명 K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
