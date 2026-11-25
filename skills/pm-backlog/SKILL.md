---
name: pm-backlog
argument-hint: "[optional: what changed, or which epic to rework]"
allowed-tools: Read, Grep, Glob, Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh:*)
description: Use when the PM wants to break a product brief into a backlog ("break the MVP down", "what should we build first?", "update the backlog") in a greenfield project. Proposes epics and user-facing features in build order with dependencies, marks which are ready for tickets, and writes pm/BACKLOG.md after the PM approves. Re-run any time the brief changes; it keeps statuses and ticket links.
---

# Build the backlog

Goal: a backlog the PM can actually plan from: the MVP split into epics, each epic into small user-facing features, in an order that can be built, with a clear status for each.

## 0. Context

Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh`. Then read, in one message, the brief, decisions, terminology and existing backlog, plus the list of ticket folders. Follow [greenfield.md](../pm-discover/references/greenfield.md) for grounding. No brief → suggest `/pm-new` and stop.

In code mode (a real repo), this skill still works, but say first that features must also be checked against the code with `/pm-discover`.

## 1. Propose (then stop)

**Epics.** One per MVP goal or major user journey, usually 3–6. Each names the goal it serves.

**Features.** Under each epic, 3–8 features. Each one is:
- **user-facing and testable**: something a user can do or see ("Seller uploads a product photo"), not a layer ("Set up the database");
- **small**: roughly one to three tickets, sized by the ticket rules (3–8 acceptance criteria per ticket);
- **ordered**: a feature comes after everything it depends on. Name dependencies by number (`1.2`).

Foundations that have no user-facing outcome (accounts, hosting, payment provider setup) are a **feature of the first epic that needs them**, phrased by what they enable ("Sellers can sign up and sign in"), with the technical work left to Dev Notes later.

**Status** for each feature:
- `ready`: every product decision it needs is answered (in the brief, decisions or the PM's words);
- `idea`: it depends on an open question. Name it: `idea (needs Q2)`;
- `ticketed`: a ticket folder already covers it (keep the existing link).

**Later (after MVP).** Everything the PM mentioned that doesn't serve an MVP goal, or that a non-goal excludes for now, goes here with the reason. Nothing they said is dropped silently.

**Check before showing:**
- Every MVP goal is served by at least one epic. A goal with no feature is a gap: say so.
- No feature contradicts a non-goal, constraint or decision.
- The first epic can be built with no dependency on a later one.

Show the proposal as a compact table per epic, then:
- which features are `ready` now (where `/pm-ticket` can start),
- the **Before MVP** questions that block the most features (answer these first),
- anything you moved to Later, and why.

**Re-sort the brief's open questions** against this backlog: a question that blocks any MVP feature (any epic above Later) belongs under **Before MVP**; one that only blocks features under Later, or no feature at all, belongs under **Can wait**. Keep the numbers. Show the moves in the proposal ("Q9 → Can wait: only affects Later items"); they're written with the backlog after approval.

**Then stop.** Write nothing until the PM approves ("write it", "go", corrections).

## 2. Write

After the go, write `project.backlog_file` from `templates/BACKLOG.md`.
- **Re-run:** keep every existing feature number, status and ticket link. Add new features at the end of their epic (`2.6`) rather than renumbering. Mark features that the new brief no longer needs as `dropped (reason)` instead of deleting them. Show what changed before writing.
- Apply the approved Before MVP / Can wait moves to the brief's Open questions (numbers unchanged).
- Answers the PM gave while reviewing: if one settles an open question in the brief, update the brief (remove it from Open questions, put the answer in the right section) and say so. Standing rules go to the decisions file under the Logging rules.

## 3. Reply

The file written, counts (epics, features, ready / idea / ticketed), the next feature to ticket, and the Before MVP questions that unblock the most `idea` features, with how many each unblocks. Suggest: "`/pm-ticket <feature number or name>` to write its tickets."
