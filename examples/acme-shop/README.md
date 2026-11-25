# Acme Shop demo

A fictional marketplace for testing ReadyGate end to end. Nothing here is real.

## Set up

```bash
./setup.sh /tmp/acme-demo          # any empty path
cd /tmp/acme-demo && claude --plugin-dir <path-to-readygate>
```

`setup.sh` copies the workspace and gives `acme-app` a 3-commit history (3 authors) and a local `origin`, so `git fetch` works.

## Test 1: pm-ticket

Prompt: **"Write tickets for letting Admins pause a Seller's payouts without suspending the Seller."**

What the code contains on purpose, and what a good run does with it:

| Planted in the code | A good run… |
|---|---|
| `runPayouts` sends every pending payout and never checks the Seller | flags that pausing needs the run to skip held Sellers, and that **suspended** Sellers are paid today (a separate risk) |
| Roles: Admin can suspend; Support can view and retry | asks (product decision) who may pause/resume: Admin only, or Support too |
| `retry` puts a failed payout back in the next run | flags the interaction: retrying a paused Seller's payout |
| Audit log + DECISIONS.md "every Staff action is logged" | treats audit logging as decided (doesn't ask), puts it in a BR/AC |
| `notifySeller` with templates | offers to reuse it; asks whether the Seller is told (product decision) |
| Seller dashboard shows "Next payout" | asks what the Seller sees while paused |
| DECISIONS.md: payout run is weekly, Finance-owned | doesn't propose changing the schedule |
| `db/client`, `mailer`, `bank`, `hooks` are imported but **not in the repo** | says "not found" instead of describing them |
| Terminology: "Suspended" ≠ "Paused" | uses "Paused" consistently, never "Disabled" or "On hold" in UI copy unless decided |

Pass criteria:
1. Turn 1 ends with gaps, ≤ 5 questions split into product decisions and technical choices, a ticket plan, and **no files written**.
2. Answering the questions without saying "generate" still writes nothing.
3. After "generate": files at `pm/tickets/<feature>/<feature>-<n>.md`, each passing the self-check (sections in order, ≤ 8 BR / 8 AC, ACs cite BRs, no code paths, no open questions).
4. Nothing in `acme-app` changed (`git status` is clean), no commits.

## Test 2: the full free-tier flow (one conversation)

Start from a copy with **no config**: `./setup.sh <dir> && rm -rf <dir>/pm.config.yaml <dir>/pm`.

1. `/pm-init Draft the terminology from the code. Keep tickets outside the app repo.`
2. As the PM, add the two decisions from this folder's `pm/DECISIONS.md` (they're team knowledge, not in the code).
3. `/pm-discover Can Sellers see why a payout failed, on their dashboard?`
4. `/pm-ticket write it up`, then answer the questions and say "generate".

Pass criteria: init asks nothing it was told; discovery opens with a verdict and flags the raw bank error, Retry erasing the reason, and Retry missing from the Audit log; `/pm-ticket` reuses the discovery instead of starting over; it stops again if an answer contradicts the code; tickets pass the self-check; `acme-app` is unchanged.
