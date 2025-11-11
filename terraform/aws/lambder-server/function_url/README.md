# Lambda web Server with function URL

- 가난한 이들을 위한 Lambda 기반의 간단한 웹서버 세팅
- 장점: 비용이 0부터 시작함. 트래픽이 한달 호출 100만건을 넘지 않으면 비용이 부과되지 않음
- 단점: 커스텀 도메인을 달 수 없음.

## 리소스 구성

1. Lambda
2. Lambda Function URL
3. Github Action (직접 구성. 예시는 아래에)
4. DynamoDB

## 프로젝트 템플릿

- 현재는 Axum 서버만 고려한 상태입니다.

### Axum(Rust)

- [템플릿](https://github.com/myyrakle/axum_serverless_template) 프로젝트를 clone하거나 fork해서 사용합니다.

## before

1. github에 레포지토리를 생성합니다.
2. github sercet에 AWS_ACCESS_KEY_ID와 AWS_SECRET_ACCESS_KEY를 추가합니다.

---

## parameter 설정

- 자세한 것은 [](./variables.tf)에서 확인하거나 수정할 수 있습니다.

### required parameter

1. region: 리전 정보입니다. 서울이라면 ap-northeast-2 값을 넘겨줍니다.
2. environment: 환경 정보입니다. server_name과 조합되어 고유의 리소스 이름을 형성합니다. prod, stage, dev 등의 값을 설정하면 됩니다.
3. server_name: 서버명입니다. environment와 조합해서 고유의 리소스 이름을 형성합니다.

### optional parameter

1. lambda_runtime: 람다 런타임. 현재는 커스텀(provided.al2)만 고려해둔 상태입니다.
2. lambda_layers: 컨테이너 포트포워딩 설정입니다.
3. cors_allow_origins: cors 설정. Frontend(브라우저)와 연동할 경우 와일드카드(\*)를 삭제하고 해당 호스트 주소를 추가합니다.
4. cors_allow_headers: cors 설정
5. cors_expose_headers: cors 설정
