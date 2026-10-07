# Cilium Egress Gateway (with kube-vip)

## Requirements 

cilium helm values
```yaml
kubeProxyReplacement: true

egressGateway:
  enabled: true
```

## 게이트웨이용 풀 라벨

```bash
kubectl label node 노드명 egress.myyrakle.io/pool=default --overwrite
kubectl get nodes -L egress.myyrakle.io/pool
```

## 라우터 설정 (RouterOS, microtik)

```bash
# 라우팅 테이블 만들기
/routing table add fib name=egress-wan4

# 192.168.88.222에서 시작된 연결에 마킹
/ip firewall mangle add chain=prerouting src-address=192.168.88.222 action=mark-connection new-connection-mark=egress-wan4 passthrough=yes comment="egress VIP .222 to wan4 conn"
/ip firewall mangle add chain=prerouting src-address=192.168.88.222 connection-mark=egress-wan4 action=mark-routing new-routing-mark=egress-wan4 passthrough=no comment="egress wan4 routing-mark"

# egress-wan4 라우팅 테이블에 경로 추가 => wan4로 나가도록
/ip route add dst-address=0.0.0.0/0 gateway=61.74.171.254%wan4 routing-table=egress-wan4 distance=1 comment="egress wan4 route"

# 최종 NAT 처리
/ip firewall nat add chain=srcnat out-interface=wan4 action=masquerade comment="egress SNAT via wan4"
```

## 리소스 생성

폴더 내에 있는 리소스를 전부 생성한다. 
```bash
kubectl apply -f ...
```

## 검증
```bash
kubectl run egress-test-wan4 --image=alpine:3.20 \
--labels=egress.myyrakle.io/profile=wan4 --restart=Never \
--command -- sh -c 'sleep 5; for i in 1 2 3; do wget -qO- -T 8 http://ifconfig.me/ip; echo " rc=$?"; done'

kubectl logs egress-test-wan4
```
