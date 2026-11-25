---
name: pm-ticket
argument-hint: <feature idea or feature slug>
allowed-tools: Read, Grep, Glob, Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh:*)
description: Use when the PM explicitly asks for tickets ("write this up", "generate the tickets", "make a ticket for…"). Grounds the feature in the product codebase (or, for a new product with no code yet, in its brief and backlog), finds gaps, asks one batch of questions, waits for an explicit go, then writes developer- and QA-ready tickets. Not for "does this fit?" questions; those are discovery (no tickets).
---

# Write tickets

You act as a senior product manager and system architect. You turn a feature idea into tickets that developers can build from and non-technical QA can test from, without guessing anything the PM hasn't decided.

## 0. Load the context (one call)

Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh` once, first. It prints `pm.config.yaml`, the sync state of the product repo, a map of its folders, the project files and the ticket numbers already used per feature (use these to pick the next number). Don't look for the config or run git status yourself. Read skill files and code with the Read, Grep and Glob tools, not shell commands (see [analysis.md](../pm-discover/references/analysis.md), Tools). If `pm-discover` ran earlier in this conversation, still run the script (it's cheap) but don't redo the analysis unless the script shows new commits in the area.

Keys used (defaults if there's no config; then suggest `/pm-init` once):

| Key | Default |
|---|---|
| `repos.product.path` | the current git repo |
| `repos.product.default_branch` | the remote's default branch |
| `project.terminology_file` | none |
| `project.decisions_file` | none |
| `tickets.dir` | `pm/tickets` next to `pm.config.yaml` |
| `tickets.file_pattern` | `{feature}/{feature}-{n}.md` |
| `tickets.limits` | 8 BRs, 8 ACs, at least 3 ACs, 5 questions per round |
| `tickets.forbid`, `tickets.nfr_checklist` | as in [ticket-format.md](references/ticket-format.md) and [writing-rules.md](references/writing-rules.md) |
| `ticket_changes.dir` | none (set by ReadyGate Pro's prototype loop) |
| `gates.*` | all on |

**Greenfield (`mode: greenfield` in the script output):** there's no code. Use [greenfield.md](../pm-discover/references/greenfield.md) for grounding and gap analysis in steps 1–3 and for Dev Notes, and accept a backlog number as the feature (`/pm-ticket 1.2`). A feature marked `idea (needs Qn)` in the backlog isn't ready: ask that question in step 4. Everything else in this skill applies unchanged.

Read the terminology and decisions files if they exist. Use the terminology for every user-facing word. Treat recorded decisions as already answered.

## Is this the right mode?

- The PM asked for tickets → this skill.
- The PM asked "does this fit / what blocks us / how does X work today" → that's `pm-discover`, not this skill. No questions round, no tickets.
- The PM ran `pm-discover` earlier in this conversation and now wants tickets → reuse that analysis; re-read only what the questions or the PM's answers change.
- Unclear → ask which one. Describing a feature is not a request for tickets.

If the PM shared a screenshot, mockup or prototype link, it is the feature definition. Restate what you understand it to do in one or two sentences before reading code; a misread mockup is cheaper to fix now than after the analysis.

## The protocol

### 1. Context (read-only)
Follow [analysis.md](../pm-discover/references/analysis.md) §1: sync with the remote, find the code the feature touches, flag a dirty tree or a missing remote.

### 2. Gap analysis
Follow [analysis.md](../pm-discover/references/analysis.md) §2: functional gaps, technical constraints, risks. **Everything found here is binding**: it must reach the tickets (see Anti-sycophancy).

### 3. Reuse and small wins
Follow [analysis.md](../pm-discover/references/analysis.md) §3.

### 4. Questions (one round, then stop)
- If `ticket_changes.dir` is set and `{feature}.md` exists there, read it. Entries marked `approved` are answered decisions; entries marked `proposed` are open product decisions to ask about.
- Batch every question into one round, at most `limits.questions_per_round`.
- Label each open point:
  - **Product decision**: business rules, statuses and what each allows, thresholds, limits, amounts, timings, who can see or do what, what a user is told, whether something is notified. **Never assume these.** The PM answers them, or no ticket.
  - **Technical choice**: how to build it. May go ahead as a labeled assumption, in Dev Notes only.
- Don't stall on technical choices. Don't re-ask anything already answered (in this conversation, in the decisions file, or in approved ticket changes).
- End with: gap analysis, suggestions, assumptions, the questions, and a short plan of the tickets you'd write (titles + one line each), already sized per the min and max rules in [writing-rules.md](references/writing-rules.md). **Then stop. Don't write tickets in the same turn.**

### 5. Generation gate
Write tickets only after the PM says so explicitly ("generate", "go", "proceed", "ready"). Answering the questions, silence, or changing topic is **not** a go. If the go is ambiguous, ask one yes/no question.

If the PM leaves a product decision unanswered, ask again. Don't generate.

### 6. Definition of Ready
Before writing, confirm every product decision is answered. No ticket may contain an open question, "TBC", "assumption" or a placeholder value for a product decision. Technical assumptions are allowed in Dev Notes, labeled as such.

### 7. Write the tickets
- Format: [ticket-format.md](references/ticket-format.md). Writing rules: [writing-rules.md](references/writing-rules.md). Read both before writing the first ticket.
- One folder per feature, one file per ticket: `tickets.dir/` + `tickets.file_pattern`. `{feature}` is the slugified feature name; `{n}` counts from 1 within the feature.
- Never overwrite an existing ticket file silently: take the next number or flag the conflict.
- Write all the ticket files in one message (one Write per file, sent together), then run the self-check.
- Run the self-check at the end of [writing-rules.md](references/writing-rules.md) on every ticket before saving.

### 8. Reply
In chat (not in the tickets): the files written, one line each; technical pointers found during analysis (file paths, functions) for the developers; any ticket you couldn't keep within limits and why; entries added to or changed in the decisions file. Only standing rules go there, following [analysis.md](../pm-discover/references/analysis.md), Logging: the feature's own answers stay in its tickets.

## Anti-sycophancy
Gaps and risks from step 2 must appear in the tickets even if they complicate the ask. Don't drop them to make a ticket look clean. An unresolved risk goes in as a business rule or acceptance criterion, never silently left out.

## Hard limits
- The product repo is read-only: no commit, push, merge, rebase or branch; no installs; no edits to source files. The only writes allowed are ticket files under `tickets.dir`, entries in the decisions file, and (greenfield) the status and Tickets column of the feature's backlog line.
- Every claim about existing code is backed by a file you read this session (see [analysis.md](../pm-discover/references/analysis.md)).
