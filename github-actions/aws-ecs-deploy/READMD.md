# AWS ECS Deploy
- AWS ECS 서버 배포를 위한 워크플로 템플릿입니다. 

## Requirements
- AWS 시크릿이 필요합니다. AWS_ACCESS_KEY/AWS_SECRET_KEY라는 이름으로 ECR/ECS 접근 권한이 있는 인증 정보가 시크릿에 들어있어야 합니다.
- env에 들어가는 값을 실제로 존재하는 리소스 단위에 맞춰서 수정해줘야 합니다.  