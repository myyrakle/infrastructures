const serverlessExpress = require("aws-serverless-express");

const app = require("./express/app");

const server = serverlessExpress.createServer(app);

exports.handler = (event, context, callback) => {
    console.log(`EVENT: ${JSON.stringify(event)}`);
    serverlessExpress.proxy(server, event, context);
};
