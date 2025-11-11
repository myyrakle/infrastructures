const aws = require("aws-sdk");
const client = new aws.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log(event);

  const connection_id = event.requestContext?.connectionId;

  await client
    .put({ TableName: "chat_connection", Item: { connection_id } })
    .promise();

  // TODO implement
  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
