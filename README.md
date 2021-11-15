# Digital Check

What we are proposing is a digital certified check - a check for which the bank has certified that the
balance of the account is sufficient to cover the amount of the check.

The bank operating the account verifies there are currently sufficient funds in the drawer's
account to honor the check.  Those funds are then set aside in the bank's internal account until
the check is cashed or returned by the payee.  A certified check cannot "bounce" and its
liquidity is similar to cash, absent failure of the bank.  The bank indicates this fact by
making a notation on the face of the check (technically called an acceptance).

## Terminology

 - Drawer (or Payor) - person or entity writing the check
 - Drafting (or drawing or cutting) - the act of writing the check
 - Drawee - bank on which the check is drawn
 - Payee - person or entity to whom the check is written

## Definitions

### Check (from Wikipedia)

  A check is a document that orders a bank to pay a specific amount of money from a person's
account to the person in whose name the check has been issued.

  A check is a negotiable instrument instructing a financial institution to pay a specific amount
of a specific currency from a specified transactional account held in the drawer's name with
that institution.  Checks are order instruments, and are not in general payable simply to the
bearer as bearer instruments are, but must be paid to the payee.

  Checks are a type of bill of exchange.

### Check (from Investopedia)

  A check is a written, dated, and signed instrument that directs a bank to pay a specific sum of
money to the bearer.


## How it works

  When the payee present a check to a bank or other financial institution to negotiate, the funds
are drawn from the payor's bank account.

## Features

 - Date of issue
 - Payee line
 - Amount (in words and numbers)
 - Currency
 - Payor's signature (endorsement)
 - Memo line
 - Payor's name
 - Payor's address
 - Payor's bank account number
 - Bank's name
 - Bank's address
 - Routing number
 - Check number
 - Beneficiary


## Ideas for Implementation

 - Whitelist addresses
 - Invalidation date
  - Time after which it becomes a stale-dated check
  - May vary based on country (US and Canada - 6 months?, Australia - 15 months?)
 - Post-dating
   - Writing an issue date after the current date
   - Checks are only valid on and after the issue date
   - May be illegal in some countries
 - Ante-dating
   - Writing an issue date before the current date
   - Does anyone do this?
 - Endorsement
   - Specify a third party to whom the check should be paid
 - Beneficiary
   - Payment made to a custodian for the benefit of another (F/B/O)
 - Multiple endorsements
   - Check made out to Party A AND Party B
 - Cancellation
   - Check is cancelled when it is approved and all accounts involved have been credited
   - Stamped with a cancellation mark, such as a "paid" stamp
   - Cancelled checks are placed in the account holder's file
   - The account holder can request a copy of a cancelled check as proof of a payment
     - This is known as the check clearing cycle
 - Dishonoring a check
   - After deposit a bank could dishonor the check
   - In the UK they instituted a six day maximum, known as the "certainty of fate" principle
 - Integration with electronic check brokers
  - The Clearing House, Viewpointe LLC, or the Federal Reserve Banks
  - Copies of checks are stored at a bank or the broker for periods up to 99 years
  - Some check archives have grown to 20 petabytes (citation?)


## Benefits of the Digital Check

 - Paper-based checks are costly for banks to process compared to electronic payments
 - No risk of bounced checks
 - Point of sale transactions are electronic
 - Third party payments are electronic
 - Can be telephone (i.e. smartphone) based, but with security of smart chip in credit cards
 - Traceability - It's on the blockchain
 - Natural progression with mobile deposit (taking pictures of checks to deposit)
 
## Challenges

 - Privacy - This is on the blockchain


## Previous Hardhat content

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
