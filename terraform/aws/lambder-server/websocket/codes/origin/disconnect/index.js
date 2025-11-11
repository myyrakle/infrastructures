const aws = require("aws-sdk");
const client = new aws.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log(event);

  const connectionTableName = process.env.ConnectionTableName;

  const connection_id = event.requestContext?.connectionId;

  await client
    .delete({ TableName: connectionTableName, Key: { connection_id } })
    .promise();

  const response = {
    statusCode: 200,
    body: JSON.stringify("Hello from Lambda!"),
  };
  return response;
};
