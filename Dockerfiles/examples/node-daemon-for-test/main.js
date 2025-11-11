const { networkInterfaces } = require("os");

let network = networkInterfaces();
let myAddress = network?.eth0?.[0]?.address;

async function main() {
  while (true) {
    console.log(`# running on: ${myAddress} at ${new Date().toISOString()}`);
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
}

main();
