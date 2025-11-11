const aws = require("aws-sdk");
const client = new aws.DynamoDB.DocumentClient();
const apiGateway = new aws.ApiGatewayManagementApi({
  endpoint: process.env.GatewayEndpoint,
});

exports.handler = async (event) => {
  console.log(event);

  const connectionTableName = process.env.ConnectionTableName;

  const body = JSON.parse(event.body);

  switch (body.action) {
    case "send": {
      const list = (
        await client
          .scan({
            TableName: connectionTableName,
            /* 수신자에 대한 추가 필터링이 필요하다면 이 부분에서 */
          })
          .promise()
      ).Items;

      await Promise.all(
        list.map(async (e) => {
          const result = await apiGateway
            .postToConnection({
              ConnectionId: e.connection_id,
              Data: Buffer.from(
                JSON.stringify({
                  action: "receive",
                  name: body.name,
                  message: body.message,
                })
              ),
            })
            .promise();

          console.log(result);
        })
      );
    }
  }

  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
