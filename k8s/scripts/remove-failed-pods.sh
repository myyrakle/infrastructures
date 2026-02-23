# 실패 상태의 Pod 전부 제거
kubectl delete pods --all-namespaces --field-selector=status.phase=Failed
