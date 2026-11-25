# Writing rules

## Audience and tone

- Write as the product owner. Readers are the developers doing the work and non-technical testers checking it.
- Plain business language: what the system or user does and why, not how it's built.
- Business rules read like policy ("A seller can have at most one active payout request"), not engineering constraints.
- Use the exact terms from `project.terminology_file` for anything a user sees.

## Acceptance criteria are QA's test list

- Every AC can be verified by someone with no code or database access, using the UI or observable behavior (API responses, emails, notifications). If checking it needs the code or the database, rewrite it as an observable outcome.
- Given / when / then, one AC per **test**, not per detail. Related outcomes of the same action go in one AC: "then X, and Y". Example: "the Viewer sees no edit button" and "the server rejects a Viewer's edit" are one AC.
- Each AC names the BRs it proves: `AC-04 (BR-06)`. Every BR is covered by at least one AC.
- Standard checks with no policy behind them (loading/empty/error states, accessibility) are tagged `(standard)` instead: `AC-05 (standard)`. Every AC has a tag.

## Write each fact once

A BR exists only for a policy an AC can't express alone: a limit, an amount, a timing, who may do what. If an AC already states it, don't add a BR that repeats it.

*Why: when the same fact is written as both a BR and an AC, tickets swell and QA tests the same thing twice.*

## Standard checks are one line

- Loading, empty and error states: one AC together, and only if the ticket adds or changes a screen.
- Permissions: a BR only when the ticket sets or changes who can do something.
- The rest of `tickets.nfr_checklist` (accessibility, backward compatibility, rollback or feature flag): write a line only where this ticket changes something.

## Size limit

At most `tickets.limits.business_rules` BRs and `tickets.limits.acceptance_criteria` ACs per ticket (default 8 / 8). Over that, split by concern, e.g. a feature and its audit logging become two tickets. Nothing found in the gap analysis may be dropped to fit; split instead. If a ticket really can't be split, say why in the chat reply, not in the ticket.

## Minimum size: merge tiny tickets

A ticket with fewer than `tickets.limits.min_acceptance_criteria` ACs (default 3, not counting `(standard)` ACs) is too small to plan, build and test on its own. Fold it into the ticket it belongs with:

1. **Pick the host**, in this order:
   1. a ticket for the **same screen or flow** (so each ticket stays testable in one place);
   2. a change to what a user receives (an email, a notification) joins the ticket whose action triggers it;
   3. otherwise, the ticket it depends on or that depends on it.

   If no host qualifies at all, keep the ticket and say why in the chat reply.
2. **Merge only if the host stays within the size limit.** If it would go over, keep the tiny ticket and say why in the chat reply.
3. **Keep IDs clean**: renumber the merged BRs and ACs in the host, and keep every AC's BR tags correct.
4. **Update the rest**: renumber the remaining files so numbers have no gaps, and fix any Dependencies that named the merged ticket.

**Never merge:**
- `[Bug]` tickets: they're prioritised and tracked separately.
- A ticket the PM asked to keep separate.
- Two tickets that need different decision-makers or a release gate (e.g. one waits for Finance or Legal sign-off).

Apply this when planning (the ticket plan in step 4 already shows merged tickets), and check it again before saving.

## Dev notes

Descriptive pointers only: which part of the product, what existing behavior to reuse, what to watch out for. Technical assumptions are labeled `Assumption (technical):`. No paths, fields, functions or code.

## Self-check before saving each ticket

- Sections exactly as in ticket-format.md, in order
- Title verb-first and scoped
- No paths, field names, function names or code anywhere
- No open product decision, "TBC", "assumption" or placeholder outside labeled technical assumptions in Dev Notes
- ≤ limits for BRs and ACs
- At least the minimum ACs, or merged per the minimum-size rule, or a stated exception (bug, PM asked, different sign-off)
- Every AC cites its BRs or is tagged `(standard)`; every BR is covered by an AC
- No fact stated as both a BR and an AC
- Every gap and risk from the analysis is in this ticket or another one
- Every AC testable from the UI or observable behavior
- User-facing words match the terminology file
- No checkboxes, estimates or labels in the ticket itself
- Dependencies by title, not number
