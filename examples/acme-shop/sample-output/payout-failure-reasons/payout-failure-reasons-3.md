# [Seller dashboard] Show Sellers why a payout failed

## Description
**User story:**
As a Seller,
I want to see why a Payout failed and what happens next,
so that I know whether to contact support or wait.

Today, the Payouts page in the Seller dashboard shows only the amount and the status ("$120.00 · Failed"), with no explanation.

## Scope
- **In scope:**
  - Showing the latest reason and its next step under each Failed Payout
  - Loading, empty and error states of the Payouts page
- **Out of scope:**
  - Earlier failed tries (Staff only)
  - Letting Sellers fix anything themselves, such as their bank details
  - Linking "Contact support" to a support page or form

## Business rules
1. **BR-01:** Sellers see only the reason for the latest failed try, never earlier tries and never the bank's raw error message.
2. **BR-02:** Once Staff press Retry, the Payout shows as a normal Pending Payout, with no reason.

## Acceptance criteria
- **AC-01 (BR-01):** Given a Failed Payout, when the Seller opens Payouts, then under "$<amount> · Failed" they see the plain reason and its next step (for example "Your bank details were rejected. Contact support."), and no bank error text.
- **AC-02 (BR-01):** Given a Payout that failed twice for different reasons, when the Seller opens Payouts, then they see only the latest reason.
- **AC-03 (BR-02):** Given a Failed Payout that Staff have retried, when the Seller opens Payouts, then it shows Pending with no reason, and the "Next payout" line includes it like any other Pending Payout.
- **AC-04 (standard):** Given the Seller opens Payouts, when the page is loading, has no Payouts, or can't load, then they see a loading indicator, a "no payouts yet" message, or an error message with a way to try again.
- **AC-05 (standard):** Given a Failed Payout, when the Seller uses a screen reader, then the reason and next step are read out as text with the Payout (not conveyed by colour alone).

## Happy path
A Seller opens Payouts and sees "$120.00 · Failed", with "Your bank details were rejected. Contact support." underneath. Another Payout, which failed because of a temporary bank problem, reads "Temporary bank problem. We will try again on <next Monday>."

## Dependencies
- Give every failed payout try a Seller-facing reason, keep every try, and add the reason to the payout-failed email

## Dev notes
- The Payouts page in the Seller dashboard already turns statuses into labels (Pending, Processing, Paid, Failed). The reason goes under the Failed label.
- The server route and data hook behind this page aren't in this repository, so check what data the page receives today.
- Use the Seller's local date format, as the "Next payout" line already does.
