# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm upgrade --install argocd-image-updater argo/argocd-image-updater -n argocd

# helm get values argocd-image-updater -n argocd --all > image-updater-values.yaml

# # something...
# vim image-updater-values.yaml

# helm upgrade argocd-image-updater argo/argocd-image-updater \
#   -n argocd \
#   -f image-updater-values.yaml


# kubectl patch deployment argocd-image-updater-controller -n argocd --type='json' -p='[
#   {
#     "op": "add",
#     "path": "/spec/template/spec/containers/0/envFrom",
#     "value": [
#       {
#         "secretRef": {
#           "name": "k8s-ecr-login-renew-aws-secret"
#         }
#       }
#     ]
#   },
#   {
#     "op": "add",
#     "path": "/spec/template/spec/containers/0/env/-",
#     "value": {
#       "name": "AWS_DEFAULT_REGION",
#       "value": "ap-northeast-2"
#     }
#   },
#   {
#     "op": "add",
#     "path": "/spec/template/spec/containers/0/env/-",
#     "value": {
#       "name": "AWS_REGION",
#       "value": "ap-northeast-2"
#     }
#   }
# ]'

# kubectl patch configmap argocd-image-updater-config -n argocd --type='merge' -p='
# data:
#   registries.conf: |
#     registries:
#     - name: ECR
#       prefix: *.dkr.ecr.ap-northeast-2.amazonaws.com
#       api_url: https://*.dkr.ecr.ap-northeast-2.amazonaws.com
#       credentials: pullsecret:default/k8s-ecr-login-renew-docker-secret
#       default: true
# '

# kubectl patch deployment argocd-image-updater-controller -n argocd --type='json' -p='[
#              {
#                "op": "remove",
#                "path": "/spec/template/spec/containers/0/envFrom"
#              }
#            ]'
