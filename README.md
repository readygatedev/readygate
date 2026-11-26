<p align="center"><img src=".claude-plugin/icon.png" width="96" alt="ReadyGate"></p>

# ReadyGate

**Tickets your developers can build and your QA can test, without anyone guessing a product decision.**

ReadyGate is a [Claude Code](https://claude.com/claude-code) plugin for product managers. It reads your real codebase, tells you whether a feature fits, finds the gaps, asks you the questions only you can answer, and then writes Markdown tickets: user story, scope, business rules, Given/When/Then acceptance criteria, happy path and dev notes.

Most AI ticket writers fill the gaps with plausible guesses. ReadyGate has **gates** instead: it won't write a ticket while a product decision is open, and it won't claim anything about your code that it hasn't read.

## Install

Needs [Claude Code](https://claude.com/claude-code), git and python3.

```
/plugin install readygate --marketplace readygatedev/readygate
```

Or in two steps: `/plugin marketplace add readygatedev/readygate`, then `/plugin install readygate@readygate`.

## Commands

**You have a codebase:**

| Command | What it does | Writes |
|---|---|---|
| `/pm-init` | Scans your workspace (repos, stack, glossary, decisions, ticket folders), asks only what it can't detect, sets everything up | `pm.config.yaml`, `pm/TERMINOLOGY.md` (drafted from your code), `pm/DECISIONS.md`, `pm/tickets/` |
| `/pm-discover <idea>` | A fit check that opens with a verdict (**Already exists / Fits / Fits, with changes / Doesn't fit as described / Blocked**), or a plain-language "how does this work today?" | Nothing, except lasting blockers in `DECISIONS.md` |
| `/pm-ticket <feature>` | Gap analysis, one round of product questions, then tickets, only after you say "generate" | `pm/tickets/<feature>/<feature>-<n>.md` |

Your product repo is **read-only** the whole time: no commits, no branches, no edits.

**You're starting from an idea (no code yet):**

| Command | What it does | Writes |
|---|---|---|
| `/pm-new <your idea>` | Listens, asks only about what's missing (users, non-goals, success metric, constraints), confirms a summary, never invents the product | `pm/BRIEF.md`, terminology, decisions, a greenfield `pm.config.yaml` |
| `/pm-backlog` | Splits the MVP into epics and small user-facing features in build order, each `ready` or blocked by a named open question. Re-run when the brief changes | `pm/BACKLOG.md` (after you approve) |
| `/pm-discover`, `/pm-ticket` | Same gates, grounded in the brief instead of code. Verdicts: **In MVP scope / Fits, after MVP / Already planned / Conflicts with the brief / Needs a decision first**. Technical unknowns become "Question for the tech lead" | Tickets, and the backlog line is marked `ticketed` |

When code exists, run `/pm-init` and the project switches to code mode. The brief, backlog and decisions stay.

## The gates, from real runs

These are excerpts from runs on the demo project in [`examples/acme-shop`](examples/acme-shop).

**It refuses to generate when your answer contradicts the code.**
> I haven't written any tickets yet. Your answers create two decisions I can't make for you. "We will try again on &lt;next Monday&gt;" isn't true today: the weekly run only pays Pending payouts (`runPayouts.ts:7`), and nothing retries a Failed one automatically…

**It finds the problem next to the one you asked about.**
> The Payout run doesn't check the Seller at all. Setting `status: "suspended"` doesn't stop their payouts (`sellers.ts:14-20`). So suspended Sellers are still being paid today.

**It respects decisions your team already made.**
> **Blocked.** `pm/DECISIONS.md` says the payout run is weekly, Monday 06:00 UTC, a Finance decision. An early payout changes exactly that.

**It keeps tickets testable.** An acceptance criterion QA can't check from the screen is rewritten or flagged, never shipped.

## What a ticket looks like

```markdown
# [Seller dashboard] Show Sellers why a payout failed

## Business rules
1. **BR-01:** Sellers see only the reason for the latest failed try, never earlier
   tries and never the bank's raw error message.
2. **BR-02:** Once Staff press Retry, the Payout shows as a normal Pending Payout,
   with no reason.

## Acceptance criteria
- **AC-01 (BR-01):** Given a Failed Payout, when the Seller opens Payouts, then under
  "$<amount> · Failed" they see the plain reason and its next step, and no bank error text.
- **AC-02 (BR-01):** Given a Payout that failed twice for different reasons, when the
  Seller opens Payouts, then they see only the latest reason.
- **AC-04 (standard):** Given the Seller opens Payouts, when the page is loading, has
  no Payouts, or can't load, then they see a loading indicator, a "no payouts yet"
  message, or an error message with a way to try again.
```

Full examples: [`examples/acme-shop/sample-output`](examples/acme-shop/sample-output/payout-failure-reasons).

**Ticket rules:**
- Plain business language, written for developers and non-technical QA.
- No code, file paths or field names in the ticket. Code pointers go in the chat reply.
- Every acceptance criterion names the business rule it proves, or is tagged `(standard)`.
- Each fact is written once.
- 3 to 8 acceptance criteria per ticket: bigger tickets are split, tiny ones are merged.
- Gaps and risks found in the analysis always reach a ticket.

## Try it on the demo

```bash
git clone https://github.com/readygatedev/readygate
readygate/examples/acme-shop/setup.sh ~/acme-demo
cd ~/acme-demo && claude
```

Then: `/pm-discover Can Sellers see why a payout failed?` → `/pm-ticket write it up` → answer → `generate`.

## Configuration

Everything project-specific lives in `pm.config.yaml`, written by `/pm-init`: paths, branch, glossary and decisions files, ticket limits and the gates. See the [annotated template](templates/pm.config.example.yaml).

`pm/DECISIONS.md` is the project memory. Add your team's standing decisions there ("Finance owns the payout schedule") and ReadyGate treats them as answered.

## Cost

ReadyGate runs on your Claude Code plan. On API pricing, a feature from idea to tickets is typically **$1–4** (a fit check is about $0.30–0.70; tickets $1–3, depending on size and how many rounds of questions).

## ReadyGate Pro

Everything above, plus the rest of the PM loop. $49 one-time, per person.

- `/pm-push`: tickets to **Jira, Linear or GitHub Issues** after a dry run, with epics, dependency links and screenshots attached. Never pushes the same ticket twice; edited tickets become updates, with a diff.
- `/pm-board`: what needs your attention first, and tickets that are out of sync with the tracker.
- `/pm-prototype`: a mockup for your approval, then a mock-data UI and checked screenshots. Anything the screens decide becomes a proposed ticket change.
- `/pm-review`: after developers merge, a summary of what changed, graded A–D against each ticket's rules, with `file:line` evidence.
- **Hooks that enforce the gates**: the product repo stays read-only, and no ticket or tracker write happens without your own "generate" or "push".

[Get Pro at readygate.dev →](https://readygate.dev)

## Development

- `tests/run-flow.sh` replays the whole flow on a fresh copy of the demo (`/pm-init` → `/pm-discover` → `/pm-ticket` → generate) with real Claude runs, then checks the results: verdict format, the gate stopping, ticket rules, and the product repo left untouched. It costs about $3–5 per run.
- `tests/check_tickets.py <folder>` checks any ticket folder against the writing rules.
- `claude plugin validate .` checks the manifests.

## License

MIT, see [LICENSE](LICENSE).
