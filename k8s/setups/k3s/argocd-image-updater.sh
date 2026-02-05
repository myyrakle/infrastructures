helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd-image-updater argo/argocd-image-updater -n argocd

helm get values argocd-image-updater -n argocd --all > image-updater-values.yaml

# something...
vim image-updater-values.yaml

helm upgrade argocd-image-updater argo/argocd-image-updater \
  -n argocd \
  -f image-updater-values.yaml
