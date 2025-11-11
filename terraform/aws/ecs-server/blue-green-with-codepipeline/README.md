# blue-green 배포

## 구현

- target group을 blue와 green 2개를 생성하고, 이를 기반으로 배포할때마다 리스너의 target group을 green->blue, blue->green로 교체하는 식으로 동작합니다.

## 장점

- 동시 버전 충돌 문제가 발생하지 않습니다.

## 단점

- 실제 배포 완료까지 시간이 조금 더 걸리는 편입니다.
