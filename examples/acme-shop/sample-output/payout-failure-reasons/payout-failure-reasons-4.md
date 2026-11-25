# [Admin console] Show the full failure history of a Seller's payouts

## Description
**User story:**
As Staff,
I want to see every failed try of a Payout, with the plain reason and the bank's raw error,
so that I can answer a Seller who contacts support and decide whether to press Retry.

Today, the Payouts table on a Seller's page in the Admin console shows amount, status and scheduled date, with no failure information.

## Scope
- **In scope:**
  - A failure history for each Payout that has failed at least once: date of each failed try, plain reason, raw bank error
  - Loading and error states of the history
- **Out of scope:**
  - Who pressed Retry (added by the Audit log ticket)
  - Changing who can press Retry

## Business rules
1. **BR-01:** Admin and Support Staff both see the full failure history of every Payout that has failed at least once, including the raw bank error.

## Acceptance criteria
- **AC-01 (BR-01):** Given a Payout that failed twice, once with a rejected-bank-details error and once with a temporary bank problem, when Admin or Support Staff open the Seller's page, then they see both failed tries, newest first, each with its date, its plain reason and the bank's raw error.
- **AC-02 (BR-01):** Given a Payout that Staff retried and that then went through, when Staff open the Seller's page, then the Payout shows Paid and its earlier failed tries are still visible.
- **AC-03 (BR-01):** Given a Payout that never failed, when Staff open the Seller's page, then no failure history is shown for it.
- **AC-04 (standard):** Given Staff open the failure history, when it is loading or can't load, then they see a loading indicator or an error message with a way to try again.

## Happy path
A Seller contacts support about a missing Payout. Support Staff open the Seller's page in the Admin console and open that Payout's failure history. They see "Your bank details were rejected." with the bank's raw error underneath, and tell the Seller what to do.

## Dependencies
- Give every failed payout try a Seller-facing reason, keep every try, and add the reason to the payout-failed email

## Dev notes
- The Seller page in the Admin console already lists the Seller's Payouts with a Retry button on Failed ones. Add the history there (for example, an expandable row).
- Both Staff roles already have permission to view Payouts, so no permission changes are needed.
- That table shows statuses in lowercase, while the Seller dashboard capitalises them. The terminology file flags this; don't change it in this ticket.
