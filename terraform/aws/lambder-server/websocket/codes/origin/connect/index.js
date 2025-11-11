const aws = require("aws-sdk");
const client = new aws.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log(event);

  const connectionTableName = process.env.ConnectionTableName;

  const connection_id = event.requestContext?.connectionId;

  await client
    .put({
      TableName: connectionTableName,
      Item: { connection_id, user_id: "test" },
    })
    .promise();

  // TODO implement
  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
