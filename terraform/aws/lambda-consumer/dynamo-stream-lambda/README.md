# dynamo stream into lambda

- DynamoDB를 Queue로 사용하고 Lambda를 Consumer로 사용하는 형태의 템플릿

## 특징

- DynamoDB에 Message를 삽입할 경우, Dynamo Stream을 통해 INSERT를 캡쳐해서 Lambda로 전송함
- 동시 실행
  - 동시 실행 제한 개수는 1-10 (10을 넘지 못함)
  - 동시 실행 제한을 1개로 사용할 경우에는 FIFO 요구사항을 충족함. 실행중인 Lambda가 끝나야 다음 이벤트를 트리거함.
  - 동시 실행 제한을 여러개로 지정할 경우에는 FIFO를 완전히 만족하지는 못함.
- 재시도
  - 재시도 횟수를 지정하지 않는다면 무한히 재시도함.
  - 분할 재시도를 사용할 경우에는 8개->4개 2번->2개 4번 같은 형태로 분할 정복을 시도함.
