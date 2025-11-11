const winston = require("winston");

const serviceName = process.env.SERVICE_NAME || "NONE";
const containerID = process.env.HOSTNAME || "NONE";

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format((info) => {
      info.timestamp = Date.now(); // 타임스탬프를 Unix 타임스탬프로 설정
      info.service = serviceName;
      info.containerID = containerID;
      return info;
    })(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({
      filename: `/var/log/loki/${serviceName}.log`,
    }),
  ],
});

async function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

async function main() {
  while (true) {
    logger.info({ message: "Hello, World!" });

    logger.error({ message: "Bye", error: new Error("Opps") });

    await sleep(5000);
  }
}

main();
