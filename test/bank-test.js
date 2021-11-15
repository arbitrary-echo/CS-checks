const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bank", function () {
  let Bank;
  let bank;
  let bankOwner;
  let accountOwner1;
  let accountOwner2;

  const bankName = "First Bank of Nowhere";
  const routingNumber = 1234567890;

  beforeEach(async () => {
    Bank = await ethers.getContractFactory("Bank");
    bank = await Bank.deploy(routingNumber, bankName);
    await bank.deployed();

    [bankOwner, accountOwner1, accountOwner2] = await ethers.getSigners();
  });


  it("Should return the bank name and routing number after it's deployed", async function () {
    expect(await bank.bankOwner()).to.equal(bankOwner.address);
    expect(await bank.bankName()).to.equal(bankName);
    expect(await bank.routingNumber()).to.equal(routingNumber);
  });


  it("Should have no checkbooks after it's deployed", async function () {
    expect(await bank.numCheckbooks()).to.equal(0);
  });


  it("Should have one checkbook after issueCheckbook is called", async function () {
    await bank.issueCheckbook(accountOwner1.address, 'USD');
    expect(await bank.numCheckbooks()).to.equal(1);
  });


  it("Should not allow an address other than the bank to issue checkbooks", async function () {
    let exceptionOccurred = false;
    try {
      await bank.connect(accountOwner1).issueCheckbook(accountOwner1.address, 'USD');
    }
    catch (ex) {
      exceptionOccurred = true;
    }
    expect(exceptionOccurred).to.equal(true);
  });


  it("Should allow the accountOwner to request a check and emit a CheckRequested event", async function () {
    await bank.issueCheckbook(accountOwner1.address, 'USD');

    let results = await bank.checkbooks(accountOwner1.address);
    expect(results.nextCheckNumber).to.equal(1);

    const transaction = await bank.connect(accountOwner1).requestCheck(accountOwner2.address, 100);

    const receipt = await transaction.wait();

    // should only be one event emitted from this transaction
    expect(receipt.events.length).to.equal(1);
    expect(receipt.events[0].event).to.equal("CheckRequested");

    results = await bank.checkbooks(accountOwner1.address);
    expect(results.nextCheckNumber).to.equal(2);
  });

});

