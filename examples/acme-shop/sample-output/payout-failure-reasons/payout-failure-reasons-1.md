# [Task] Give every failed payout try a Seller-facing reason, keep every try, and add the reason to the payout-failed email

## Description
**User story:**
As a Seller,
I want a failed Payout to come with a reason I can understand, on screen and in the payout-failed email,
so that I know whether to contact support or wait for the next try.

Today, when a Payout fails, the system keeps only the bank's raw error message, and loses it when Staff press Retry. The payout-failed email gives no details. This ticket adds a plain reason to every failed try, keeps a record of every try, and puts the reason in the email. The Seller dashboard and Admin console tickets build on it.

## Scope
- **In scope:**
  - Sorting every failed try into one of four Seller-facing reasons
  - Keeping the bank's raw error message alongside the plain reason
  - Keeping every failed try of a Payout, including after Staff press Retry
  - Adding the plain reason to the payout-failed email
- **Out of scope:**
  - Showing the reasons on any screen (separate tickets)
  - Automatic retries (separate ticket)
  - Any other email, and changing when the payout-failed email is sent

## Business rules
1. **BR-01:** Every failed try gets exactly one of these reasons, each with its next step:
   - "Your bank details were rejected." / "Contact support."
   - "Your bank account is closed." / "Contact support."
   - "Temporary bank problem." / "We will try again on <date of the next Monday>."
   - "Payout failed." / "Contact support." (any bank error that doesn't match one of the three above)
2. **BR-02:** The bank's raw error message is kept for Staff only and never appears on the Seller dashboard or in a Seller email.
3. **BR-03:** A Staff Retry never deletes earlier failed tries or their reasons.
4. **BR-04:** Payouts that had already failed before this release get a reason from the error message already saved for them. If none was saved, they get "Payout failed."
5. **BR-05:** The payout-failed email includes the plain reason for that failed try (the reason only, without the next step).

## Acceptance criteria
- **AC-01 (BR-01):** Given the bank rejects a transfer for each of the three known reasons and for an unknown reason, when the payout run happens, then each failed Payout carries the matching plain reason and next step, and the unknown one carries "Payout failed." / "Contact support."
- **AC-02 (BR-02):** Given a failed Payout, when the Seller's payout data is loaded for the Seller dashboard, then it contains the plain reason and no bank error text.
- **AC-03 (BR-03):** Given a Payout that failed, was retried by Staff and failed again, when Staff load that Payout's data, then both failed tries are there, each with its date, plain reason and raw bank error.
- **AC-04 (BR-04):** Given a Payout that failed before this release, when its data is loaded after the release, then it carries a plain reason.
- **AC-05 (BR-02, BR-05):** Given a Payout fails with each of the four reasons, when the Seller receives the payout-failed email, then it contains the matching plain reason ("Your bank details were rejected.", "Your bank account is closed.", "Temporary bank problem." or "Payout failed."), and no bank error text.

## Happy path
A Seller's Payout fails because their bank account is closed. They receive the payout-failed email, which says "Your bank account is closed." Support Staff loading that Payout see the same reason together with the bank's raw error.

## Dependencies
None.

## Dev notes
- The bank transfer happens in the weekly payout run. Today it saves the bank's error message as raw text on the Payout, and Staff Retry erases it.
- The list of bank error codes behind each reason must come from the bank provider's documentation. The bank integration isn't in this repository.
- The payout-failed email is sent at the end of each failed try in the payout run and currently receives no data. The email templates and the mail service aren't in this repository.
- Assumption (technical): the error-to-reason mapping happens on the server, so the raw text never reaches the Seller's browser.
- Assumption (technical): failed tries are stored in a way that a Staff Retry doesn't overwrite (for example, one record per try).
- QA needs a way on dev to make the bank fail with each reason and to start a payout run on demand.
