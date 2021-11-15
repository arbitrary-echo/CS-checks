const hre = require("hardhat");

async function main() {

  const routingNumber = 8675309;
  const bankName = 'ACME Bank';

  const Bank = await hre.ethers.getContractFactory("Bank");
  const bank = await Bank.deploy(routingNumber, bankName);
  await bank.deployed();

  console.log("Bank owner address: ", (await bank.bankOwner()).toString());
  console.log("Bank routing number: ", (await bank.routingNumber()).toString());
  console.log("Bank name: ", (await bank.bankName()));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
