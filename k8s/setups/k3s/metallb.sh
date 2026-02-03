kubectl create ns metallb-system
helm upgrade --install -n metallb-system metallb oci://registry-1.docker.io/bitnamicharts/metallb
vi L2-range-allocation.yaml
kubectl apply -f ./L2-range-allocation.yaml

# Ref: https://blog.naver.com/sssang97/223330537493
