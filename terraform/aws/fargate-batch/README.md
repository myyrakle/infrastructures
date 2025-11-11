# Fargate Batch

## 개요

- 정해진 시간 간격으로 동작하는 Batch 서비스를 제공하기 위한 시스템입니다.
- ECR에만 새 버전을 배포하는 방식이기 때문에, 배포가 기존 프로세스에 영향을 주지 않습니다.
- 현재 제공되는 템플릿은 Node.js+Typescript 기반이나, 커스텀에는 제한이 없습니다.
- 태스크를 추가하려면 코드상에서 프로세스를 추가 구현하고, 하위 디렉터리 processors에 추가할 태스크의 작업정의와 스케줄링을 추가하면 됩니다.

## 구성요소

- AWS Batch
- Fargate
- EventBridge
- ECR
- CodePipeline

## 준비물

- 다음 명령을 사용해서 사용할 codestar 정보를 조회합니다.
  `aws codestar-connections list-connections`
- 다음 템플릿 프로젝트를 복제합니다.
  https://github.com/myyrakle/batch-processor-node

## parameter 설정

다음과 같은 형태로 환경변수를 준비해서 사용하면 됩니다.

```
region            = "ap-northeast-2"
system_name       = "foo"
environment       = "prod"
vpc_id            = "vpc-d92..."
github_user       = "myyrakle"
github_repository = "batch-processor-node"
github_branch     = "master"
codestar_arn      = "arn:aws:codestar-connections:ap-nor..."
subnet_ids        = ["subnet-f185459a", "subnet-b2f24fc9"]
buildspec_path    = "./setup/master/buildspec.yml"
```

- 자세한 것은 [](./variables.tf)에서 확인하거나 수정할 수 있습니다.

### required parameter

1. region: 리전 정보입니다. 서울이라면 ap-northeast-2 값을 넘겨줍니다.
2. vpc_id: vpc id입니다. 2개 이상의 AZ 서브넷이 있어야 합니다.
3. subnet_ids: 서브넷 목록의 배열입니다. vpc_id에 속한 서브넷이여야 하고, 2개 이상 지정해야 합니다.
4. environment: 환경 정보입니다. server_name과 조합되어 고유의 리소스 이름을 형성합니다. prod, stage, dev 등의 값을 설정하면 됩니다.
5. system_name: 시스템명입니다. environment와 조합해서 고유의 리소스 이름을 형성합니다.
6. github_user: github username or organization name입니다.
7. github_repository: 레포지토리명입니다.
8. github_branch: 트리거할 브랜치입니다.
9. codestar_arn: codestart connection ARN입니다.

### optional parameter

1. buildspec_path: 빌드에 사용할 buildspec.yml 위치입니다.
2. codebuild_compute_type: code build 컴퓨팅 타입입니다.
