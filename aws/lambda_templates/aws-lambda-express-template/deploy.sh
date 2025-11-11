zip deploy.zip -r src/express src/index.js # 소스 압축
aws lambda update-function-code --function-name express_test --zip-file  fileb://./deploy.zip # 소스 배포
rm deploy.zip # 배포용 소스 삭제
