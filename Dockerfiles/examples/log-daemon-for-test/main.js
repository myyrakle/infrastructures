const outputDirectory = process.env.OUTPUT_DIRECTORY || "/var/log/nodejs";

const { networkInterfaces } = require("os");
const { writeFileSync, existsSync, mkdirSync } = require("fs");

let network = networkInterfaces();
let myAddress = network?.eth0?.[0]?.address;

async function main() {
  while (true) {
    const text = `# running on: ${myAddress} at ${new Date().toISOString()}`;

    if (!existsSync(outputDirectory)) {
      mkdirSync(outputDirectory);
    }

    console.log(text);
    writeFileSync(`${outputDirectory}/nodejs.log`, `${text}\n`, { flag: "a" });
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
}

main();
