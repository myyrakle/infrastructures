mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config

# bash shell 
vi ~/.bashrc
export KUBECONFIG=~/.kube/config

# fish shell
set -Ux KUBECONFIG ~/.kube/config
