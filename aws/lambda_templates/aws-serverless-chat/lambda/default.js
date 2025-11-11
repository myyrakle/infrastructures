const aws = require("aws-sdk");
const client = new aws.DynamoDB.DocumentClient();
const apiGateway = new aws.ApiGatewayManagementApi({
  endpoint: "q4w54cu53i.execute-api.ap-northeast-2.amazonaws.com/production",
});

exports.handler = async (event) => {
  console.log(event);

  const body = JSON.parse(event.body);

  switch (body.action) {
    case "send": {
      const list = (
        await client.scan({ TableName: "chat_connection" }).promise()
      ).Items;

      await Promise.all(
        list.map(async (e) => {
          console.log(
            await apiGateway
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
              .promise()
          );
        })
      );
    }
  }

  // TODO implement
  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
