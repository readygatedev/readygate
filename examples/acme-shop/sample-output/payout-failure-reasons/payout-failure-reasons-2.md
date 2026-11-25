# [Task] Automatically retry Payouts that failed because of a temporary bank problem

## Description
**User story:**
As a Seller,
I want a Payout that failed because of a temporary bank problem to be tried again on its own,
so that I get paid without contacting support.

Today, a Failed Payout stays Failed until Staff press Retry. The Seller dashboard will now tell Sellers "We will try again on <date>" for temporary problems, so the payout run must actually try those Payouts again.

## Scope
- **In scope:**
  - Including Payouts that failed with "Temporary bank problem." in the next Monday payout run
  - Stopping automatic tries after 3 tries in total
- **Out of scope:**
  - Changing the weekly payout schedule (Monday 06:00 UTC, set by Finance)
  - Automatic retries for any other reason

## Business rules
1. **BR-01:** A Payout whose latest try failed with "Temporary bank problem." is tried again automatically in the next Monday payout run, as long as it has been tried fewer than 3 times in total.
2. **BR-02:** Until that run, the Payout stays Failed and the Seller sees "Temporary bank problem." with "We will try again on <date of the next Monday>."
3. **BR-03:** Every try counts towards the 3, including tries that came after a Staff Retry. After the third failed try there are no more automatic tries, and the Seller sees "Payout failed." with "Contact support."
4. **BR-04:** Staff can still press Retry on any Failed Payout, including one waiting for an automatic try or one past the 3-try limit.
5. **BR-05:** The Seller gets the payout-failed email after every failed try, including automatic ones.

## Acceptance criteria
- **AC-01 (BR-01, BR-02):** Given a Payout that failed once with a temporary bank problem, when the Seller opens their Payouts, then it shows Failed, "Temporary bank problem." and "We will try again on" the next Monday's date, and when that Monday's payout run happens, the Payout is tried again and becomes Paid if the bank accepts it.
- **AC-02 (BR-01):** Given a Payout that failed with "Your bank details were rejected.", when the next Monday's payout run happens, then it is not tried again and stays Failed.
- **AC-03 (BR-03):** Given a Payout that failed 3 times in a row with a temporary bank problem, when the Seller opens their Payouts, then it shows Failed with "Payout failed." and "Contact support.", and the following Monday's payout run doesn't try it again.
- **AC-04 (BR-03, BR-04):** Given a Payout past the 3-try limit, when Staff press Retry and the next payout run fails again with a temporary bank problem, then it is not tried again automatically.
- **AC-05 (BR-05):** Given a Payout that fails on an automatic try, when the payout run ends, then the Seller receives the payout-failed email.

## Happy path
A Seller's Monday Payout fails because the bank has a temporary problem. On their Payouts page they see "Temporary bank problem. We will try again on <next Monday>." The next Monday the Payout is tried again, goes through, and shows Paid.

## Dependencies
- Give every failed payout try a Seller-facing reason, keep every try, and add the reason to the payout-failed email
- Show Sellers why a payout failed (to see the dashboard messages)

## Dev notes
- The weekly payout run currently picks up only Pending Payouts that are due. Failed Payouts need a separate path into the run.
- Automatic tries aren't Staff actions, so they aren't written to the Audit log. They show up in the Staff payout history as further tries.
- Assumption (technical): the number of tries is worked out from the record of failed tries that the reasons ticket adds.
- QA needs a way on dev to start a payout run on demand and to make the bank fail temporarily.
