# ecs-server

## 개요

- ECS Fargate룰 기반으로 구성된 서버 및 CI/CD 설정입니다.

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

## parameter

1. GithubRepository: github 레포지토리 이름입니다.
2. GithubToken: github의 로그인용 public access token입니다.
3. GithubUser: unique한 github 계정 닉네임입니다. (혹은 조직명입니다.)
4. GithubBranch: 연동할 github 브랜치입니다.
5. ServerName: 서버 이름입니다. 중복될 수 없습니다.
6. Subnet1: 가용영역 설정을 위한 서브넷입니다.
7. Subnet2: 가용영역 설정을 위한 서브넷입니다.
8. VPC: ECS 서비스에 설정할 VPC입니다.
9. EntryPoint: Docker Container의 EntryPoint입니다.
10. HealthCheckPath: health check API의 URI 경로입니다.
11. BuildSpecPath: CodeBuild에 사용될 buildspec 파일의 프로젝트 내 경로입니다.

## info

1. cloudformation 초기 구성에는 5분 정도 걸립니다.
2. code pipeline 최초 완료시에는 3분 정도 걸립니다.

## after

1. code pipeline가 아직 돌지 않은 상태라면 먼저 한번 실행시킵니다. code pipeline이 돌고 있다면 완료되기를 기다립니다.
2. 새로 ECS 탭으로 이동해 원하는 작업 개수가 0이라면 1 이상으로 설정합니다. (최초 생성 시에는 0으로 설정이 되어있습니다.)
3. 동작 확인 후 Cloudflare 등에서 로드밸런서의 도메인 레코드를 설정해줍니다. [참고](https://blog.naver.com/sssang97/222913100848)
4. 필요하다면 code pipeline에서 슬랙 알림을 추가해줍니다.

## etc

- 커스텀을 원하신다면 다음 문서를 참고합니다.
  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_ECS.html
- 오토 스케일링 설정에 대한 글
  https://ig.nore.me/2018/02/autoscaling-ecs-containers-using-cloudformation/

## Todo

- aws parameter store 적절하게 주입시킬 필요
