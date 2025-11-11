# EC2-Server

- EC2 기반의 서버 스택입니다.

## 리소스 구성

- EC2 Auto Scailing Group
- EC2 Launch Template & EC2 AMI
- Application Loadbalancer

## 특징

- Docker 대신 AMI라는 자체 이미지 규격을 통해 배포 버전을 제어합니다.
  - AMI 이미지 빌드는 Hashicorp에서 제공하는 packer라는 도구를 통해 수행합니다. (EC2 띄워서 AMI 말아주는 동작을 대신 해주는 보조도구 정도)
  - 리눅스 호스트 환경에 전적으로 의존하지는 않으며, 빌드 환경의 통일을 위해 Docker 빌드를 수행하고 이미지를 뽑아내어 서빙합니다.
  - Docker와 AMI를 별도 관리하는 것은 관리포인트가 비효율적이므로 Docker 로컬 이미지를 AMI 내부에 임베딩합니다.
  - 일반적으로 많이 사용하는 선택지는 아니라 정보가 관련 정보가 적습니다. 이 정도 개발 경험을 원하면 대부분 ECS를 쓰거나 EKS를 쓰기 때문입니다...
- Fargate 같은 컨테이너 중심 스택에 비하면 빌드 및 부팅이 매우 느립니다.
- 비용 효율적이고 Fargate 같은 여타 스택에 비하면 조정 가능성이 높습니다.
