kubectl create ns metallb-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
vi L2-range-allocation.yaml
kubectl apply -f ./L2-range-allocation.yaml

# If multi node cluster
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp

# Ref: https://blog.naver.com/sssang97/223330537493
