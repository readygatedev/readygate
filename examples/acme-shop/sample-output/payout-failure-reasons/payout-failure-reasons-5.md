# [Bug][Admin console] Record payout Retry in the Audit log and show who retried

## Description
**User story:**
As Staff,
I want every Retry on a Payout recorded with who did it and when,
so that we meet the rule that every Staff action on a Seller is in the Audit log, and can see who retried a Payout.

Today, "Suspend seller" is written to the Audit log, but Retry is not. This breaks the compliance decision of 2026-10-02.

## Scope
- **In scope:**
  - Writing every Staff Retry to the Audit log
  - Showing "Retried by <Staff name> on <date>" in the Payout's failure history in the Admin console
- **Out of scope:**
  - An Audit log screen
  - Showing who retried to Sellers

## Business rules
1. **BR-01:** Every Retry by Staff (Admin or Support) is written to the Audit log with the Staff member, the Payout and the date and time.
2. **BR-02:** A Retry that is refused (for example, on a Payout that isn't Failed) is not recorded.

## Acceptance criteria
- **AC-01 (BR-01):** Given a Failed Payout, when Admin or Support Staff press Retry, then the Payout's failure history shows "Retried by <their name> on <date>" in the right place among the failed tries.
- **AC-02 (BR-01):** Given a Payout retried twice by two different Staff members, when Staff open its failure history, then both "Retried by" lines appear with the right names and dates.
- **AC-03 (BR-02):** Given a Payout that isn't Failed, when a Retry is sent for it, then it is refused, and no "Retried by" line appears.

## Happy path
Support Staff press Retry on a Failed Payout. When they open its failure history, they see "Retried by <their name> on <today>" above the failed try.

## Dependencies
- Show the full failure history of a Seller's payouts

## Dev notes
- Suspend seller already writes to the Audit log through a shared helper. Retry should use the same helper.
- The "Retried by" lines should come from the Audit log itself, so that showing them also proves the entry was written.
- Retries made before this release have no Audit log entry and won't show a "Retried by" line.
