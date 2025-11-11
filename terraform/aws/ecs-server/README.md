# ecs-server

## 개요

- ECS Fargate룰 기반으로 구성된 서버 및 CI/CD 설정입니다.
- rolling update와 blue green 배포 2가지가 제공됩니다.

## 리소스 구성

1. ECS (Fargate + Auto Scaling)
2. ECR
3. Elastic Loadbalancer
4. Code Pipeline
5. S3

## before

1. docker 디렉터리에서 원하는 환경의 buildspec.yml과 Dockerfile, run.sh를 선택하고, 그것을 배포하고자 하는 프로젝트 github 루트 경로에 저장해서 push합니다.
2. 서버에는 status code 200 응답을 반환하는 health check API가 존재해야 합니다.
3. 서버는 프로덕션 버전에서 80 포트로 실행되어야 합니다.

## info

1. 초기 구성에는 5분 정도 걸립니다.
2. code pipeline 최초 완료시에는 3분 정도 걸립니다.

## after

1. 동작 확인 후 Cloudflare 등에서 로드밸런서의 도메인 레코드를 설정해줍니다. [참고](https://blog.naver.com/sssang97/222913100848)
2. 필요하다면 code pipeline에서 슬랙 알림을 추가해줍니다.

---

## parameter 설정

- 자세한 것은 [](./variables.tf)에서 확인하거나 수정할 수 있습니다.

### required parameter

1. region: 리전 정보입니다. 서울이라면 ap-northeast-2 값을 넘겨줍니다.
2. vpc_id: vpc id입니다. 2개 이상의 AZ 서브넷이 있어야 합니다.
3. subnet_ids: 서브넷 목록의 배열입니다. vpc_id에 속한 서브넷이여야 하고, 2개 이상 지정해야 합니다.
4. environment: 환경 정보입니다. server_name과 조합되어 고유의 리소스 이름을 형성합니다. prod, stage, dev 등의 값을 설정하면 됩니다.
5. server_name: 서버명입니다. environment와 조합해서 고유의 리소스 이름을 형성합니다.
6. github_user: github username or organization name입니다.
7. github_repository: 레포지토리명입니다.
8. github_branch: 트리거할 브랜치입니다.
9. github_oauth_token: github 인증 토큰입니다.
10. certificate_arn: ACM SSL 인증서 ARN입니다.

### optional parameter

1. log_retention_in_days: 로그 삭제 대기일수입니다. 기본값은 삭제하지 않는 것입니다.
2. portforward_host_port: 컨테이너 포트포워딩 설정입니다.
3. portforward_container_port: 컨테이너 포트포워딩 설정입니다.
4. docker_release_tag: 배포에 사용할 docker 태그입니다.
5. docker_entrypoint: docker container entrypoint입니다.
6. healthcheck_uri: 헬스체크 api 경로입니다.
7. healthcheck_interval: 헬스체크 시간 간격 (초 단위)
8. buildspec_path: 빌드에 사용할 buildspec.yml 위치입니다.
9. container_memory: 컨테이너 메모리입니다. 메가바이트 단위입니다.
10. container_cpu: 컨테이너에 할당할 vcpu 개수입니다. 1024가 1vcpu입니다.
11. target_group_port: target group 포트입니다.
12. target_group_protocol
13. target_group_protocol_version
14. auto_scaling_max: 오토스케일링 최대 개수입니다.
15. cpu_scail_out_percent: 스케일아웃을 트리거할 cpu 수치입니다.
16. memory_scail_out_percent: 스케일아웃을 트리거할 메모리 수치입니다.
17. codebuild_compute_type: code build 컴퓨팅 타입입니다.
