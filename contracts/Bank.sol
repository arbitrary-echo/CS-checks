//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Bank {

  // bank information
  address public bankOwner;
  uint256 public routingNumber;
  string public bankName;

  enum CheckStatus {
    Empty,                // 0 - initialized value
    Requested,            // 1
    Issued,               // 2
    // PayeeChangeRequested,
    DepositRequested,     // 3
    Cancelled             // 4
  }

  // events for the lifecycle of a check
  event CheckbookCreated(address indexed accountOwner, uint256 indexed numCheckbook);
  event CheckRequested(address indexed accountOwner, address indexed payee, uint256 indexed amount, uint256 checkNumber);
  event CheckIssued(address indexed accountOwner, uint256 indexed checkNumber);
  event CheckDepositRequested(address indexed accountOwner, address indexed payee, uint256 indexed checkNumber);
  event CheckCancelled(address indexed accountOwner, uint256 indexed checkNumber);

  /*
  // events for when the account owner would like to change the payee of an issued check
  event PayeeChangeRequested(address indexed accountOwner, uint256 indexed checkNumber, address indexed newPayee);
  event PayeeChangeRejected(address indexed accountOwner, uint256 indexed checkNumber, address indexed rejectedPayee);
  event PayeeChangeApproved(address indexed accountOwner, uint256 indexed checkNumber);
  */

  struct Check {
    CheckStatus status;
    address payee;
    address pendingPayee;
    uint256 amount;
    string memo;
  }

  struct Checkbook {
    bool exists;
    bool active;
    string currency;
    uint256 nextCheckNumber;
    mapping(uint256 => Check) checks;
  }

  uint256 public numCheckbooks;
  mapping(address => Checkbook) public checkbooks;

  modifier onlyBank {
    require(msg.sender == bankOwner);
    _;
  }

  modifier onlyAccountOwner {
    require(checkbooks[msg.sender].exists == true, "Checkbook does not exist");
    _;
  }

  constructor(uint256 _routingNumber, string memory _bankName) {
    bankOwner = msg.sender;
    routingNumber = _routingNumber;
    bankName = _bankName;
  }

  // custom getter for the checks mapping
  // ref: https://medium.com/coinmonks/solidity-tutorial-returning-structs-from-public-functions-e78e48efb378
  function getCheck(address accountOwner, uint256 checkNumber)
    public
    view
    returns(CheckStatus status, address payee, address pendingPayee, uint256 amount, string memory memo) {
      require(checkbooks[accountOwner].exists == true, "Checkbook does not exist");
      require(checkbooks[accountOwner].nextCheckNumber > checkNumber, "Check does not exist");

      // copy the data into memory
      Check memory check = checkbooks[accountOwner].checks[checkNumber];
      
      // break the struct's members into a tuple in the same order that they appear in the struct
      return (check.status, check.payee, check.pendingPayee, check.amount, check.memo);
  }

  // create a new checkbook for an account bank in the specified currency
  function issueCheckbook(address accountOwner, string memory _currency) external onlyBank {
    // verify that the checkbook does not already exist
    require(checkbooks[accountOwner].exists == false);

    // set the fields to enable the checkbook for other actions
    checkbooks[accountOwner].exists = true;
    checkbooks[accountOwner].active = true;
    checkbooks[accountOwner].currency = _currency;
    checkbooks[accountOwner].nextCheckNumber = 1;

    emit CheckbookCreated(accountOwner, numCheckbooks);

    numCheckbooks++;
  }

  // called by the account bank to request a check
  function requestCheck(address payee, uint256 amount) external onlyAccountOwner {

    // get the next check number
    uint256 nextCheckNumber = checkbooks[msg.sender].nextCheckNumber;

    // convenient variable for working with the requested check
    Check storage check = checkbooks[msg.sender].checks[nextCheckNumber];

    // mark that the check has been requested by the account bank
    check.status = CheckStatus.Requested;

    // fill in the recipient address and amount, leave the memo field blank by default
    check.payee = payee;
    check.amount = amount;

    // emit an event that the bank can monitor to perform off-chain actions
    emit CheckRequested(msg.sender, payee, amount, nextCheckNumber);

    // increment check number
    checkbooks[msg.sender].nextCheckNumber++;
  }

  // called by the bank to issue the check for the account bank
  function issueCheck(address accountOwner, uint256 checkNumber) external onlyBank {

    // verify that the checkbook exists
    require(checkbooks[accountOwner].exists == true, "Checkbook does not exist");
    
    // verify that the check number status is correct
    //  - was the check requested by the account owner?
    //  - has the check already been issued?
    //  - has the check already been redeemed?
    Check storage check = checkbooks[accountOwner].checks[checkNumber];
    require(check.status == CheckStatus.Requested, "Check status is not 'Requested'");

    // set the check status
    check.status = CheckStatus.Issued;

    // emit an event that the account owner can monitor
    emit CheckIssued(accountOwner, checkNumber);
  }

  // called by the payee of the check to request a deposit into his/her bank account
  function requestDeposit(address accountOwner, uint256 checkNumber) external {

    // verify that the checkbook exists
    require(checkbooks[accountOwner].exists == true, "Checkbook does not exist");

    // verify that the check has the correct status
    //  - was the check issued by the bank?
    Check storage check = checkbooks[accountOwner].checks[checkNumber];
    require(check.status == CheckStatus.Issued, "Check status is not 'Issued'");

    // verify that the payee (i.e. the holder of the check) is the one requesting the deposit
    require(check.payee == msg.sender, "Depositor is not the payee of the check");

    // set the check status
    check.status = CheckStatus.DepositRequested;

    // emit an event that the bank can monitor to perform off-chain actions
    emit CheckDepositRequested(accountOwner, msg.sender, checkNumber);
  }

  // called by the indicate that the check has been deposited successfully
  function approveDeposit(address accountOwner, uint256 checkNumber) external onlyBank {
    // verify that the checkbook exists
    require(checkbooks[accountOwner].exists == true, "Checkbook does not exist");

    // verify that the check has the correct status
    Check storage check = checkbooks[accountOwner].checks[checkNumber];
    require(check.status == CheckStatus.DepositRequested, "Check status is not 'DepositRequested'");

    // set the check status
    check.status = CheckStatus.Cancelled;

    // emit an event 
    emit CheckCancelled(accountOwner, checkNumber);
  }

  /*
  // called by the account owner to add a note to the check
  function addMemo(uint256 checkNumber, string calldata memo) external onlyAccountOwner {
    Check storage check = checkbooks[msg.sender].checks[checkNumber];
  }
 */

  /*
   * Payee modification methods
   */

  /*
  // called by the account owner to request a change to the payee of a check
  function requestPayeeChange(uint256 checkNumber, address newPayee) external onlyAccountOwner {
    // verify that the check has the correct status
    //  - was the check issued by the bank?
    Check storage check = checkbooks[msg.sender].checks[checkNumber];
    require(check.status == CheckStatus.Issued, "Check status is not 'Issued'");

    // fill in the field for the requested new payee
    check.pendingPayee = newPayee;

    // set the check status
    check.status = CheckStatus.PayeeChangeRequested;

    // emit an event that the bank can monitor to perform off-chain actions
    emit PayeeChangeRequested(msg.sender, checkNumber, newPayee);
  }

  // called by the bank to approve the payee change request
  function approvePayeeChange(address accountOwner, uint256 checkNumber) external onlyBank {
    // verify that the checkbook exists
    require(checkbooks[accountOwner].exists == true, "Checkbook does not exist");

    // verify that the check has the correct status
    Check storage check = checkbooks[accountOwner].checks[checkNumber];
    require(check.status == CheckStatus.PayeeChangeRequested, "Check status is not 'payeeChangeRequested'");

    // update the payee and reinitialize the pending payee address
    check.payee = check.pendingPayee;
    check.pendingPayee = address(0);

    // set the check status
    check.status = CheckStatus.Issued;

    // emit an event 
    emit PayeeChangeApproved(accountOwner, checkNumber);
  }

  // called by the bank to reject the payee change request
  function rejectPayeeChange(address accountOwner, uint256 checkNumber) external onlyBank {
    // verify that the checkbook exists
    require(checkbooks[accountOwner].exists == true, "Checkbook does not exist");

    // verify that the check has the correct status
    Check storage check = checkbooks[accountOwner].checks[checkNumber];
    require(check.status == CheckStatus.PayeeChangeRequested, "Check status is not 'payeeChangeRequested'");

    // store the rejected payee address for emitting an event
    address rejectedPayee = check.pendingPayee;

    // reinitialize the pending payee address
    check.pendingPayee = address(0);

    // set the check status
    check.status = CheckStatus.Issued;

    // emit an event 
    emit PayeeChangeRejected(accountOwner, checkNumber, rejectedPayee);
  }
  */

}
