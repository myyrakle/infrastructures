# SSL Disable 
sudo mkdir -p /etc/rancher/k3s

sudo vim /etc/rancher/k3s/registries.yaml

'''
mirrors:
  "192.168.0.8:17000":
    endpoint:
      - "http://192.168.0.8:17000"

configs:
  "192.168.0.8:17000":
    tls:
      insecure_skip_verify: true
'''

sudo systemctl restart k3s

sudo ls /var/lib/rancher/k3s/agent/etc/containerd/certs.d/
