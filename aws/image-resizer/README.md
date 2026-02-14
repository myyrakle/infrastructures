# Image resizer for S3

- Lambda Edge 기반의 이미지 리사이저

## 리소스 구성

1. Lambda
2. Cloudfront
3. CodePipeline(CodeBuild)
4. Lambda Edge
5. S3 (for CodeBuild)

## 프로젝트 템플릿

- 현재는 Node.js 서버만 고려한 상태입니다.

### Node.js

- [템플릿](https://github.com/myyrakle/image_resizer_template) 프로젝트를 clone하거나 fork해서 사용합니다.

## 준비물

- 다음 명령을 사용해서 사용할 codestar 정보를 조회합니다.
  `aws codestar-connections list-connections`
- github에 템플릿을 참고해서 프로젝트를 생성합니다.

---

## parameter 설정

- 자세한 것은 [](./variables.tf)에서 확인하거나 수정할 수 있습니다.

### required parameter

1. region: 리전 정보입니다. 서울이라면 ap-northeast-2 값을 넘겨줍니다.
2. environment: 환경 정보입니다. server_name과 조합되어 고유의 리소스 이름을 형성합니다. prod, stage, dev 등의 값을 설정하면 됩니다.
3. system_name: 시스템명입니다. environment와 조합해서 고유의 리소스 이름을 형성합니다.
4. github_user: github username or organization name입니다.
5. github_repository: 레포지토리명입니다.
6. github_branch: 트리거할 브랜치입니다.
7. codestar_arn: codestart connection ARN입니다.

### optional parameter

1. buildspec_path: 빌드에 사용할 buildspec.yml 위치입니다.
2. codebuild_compute_type: code build 컴퓨팅 타입입니다.
3. lambda_runtime: 람다 런타임. 현재는 node.js만 고려해둔 상태입니다.
4. lambda_layers: 레이어 목록입니다.
