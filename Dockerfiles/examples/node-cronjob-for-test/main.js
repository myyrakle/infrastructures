const { networkInterfaces } = require("os");

let network = networkInterfaces();
let myAddress = network?.eth0?.[0]?.address;

async function main() {
  console.log(`# running on: ${myAddress} at ${new Date().toISOString()}`);
}

main();
