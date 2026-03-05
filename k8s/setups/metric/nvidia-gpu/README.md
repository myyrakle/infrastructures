# nvidia GPU Metric
- nvidia gpu-operastor
- prometheus

## Requirements 
- All nodes must already be capable of running GPU containers in Kubernetes (nvidia-container-runtime configured).

## gpu operator setup 

```bash
 helm install gpu-operator nvidia/gpu-operator \
                     --namespace gpu-operator \
                     --create-namespace \
                     --set driver.enabled=false \
                     --set toolkit.enabled=false \
                     --set devicePlugin.enabled=false \
                     --set dcgm.enabled=true \
                     --set dcgmExporter.enabled=true \
                     --set dcgmExporter.serviceMonitor.enabled=true \
                     --set dcgmExporter.serviceMonitor.additionalLabels.release=prometheus

kubectl get all -n gpu-operator
```
