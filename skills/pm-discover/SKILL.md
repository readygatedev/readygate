---
name: pm-discover
argument-hint: <feature idea or question>
allowed-tools: Read, Grep, Glob, Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh:*)
description: Use when the PM asks whether a feature fits, what would block it, what it would take, or how something works today ("does X fit?", "what would stop us doing Y?", "how does Z work now?"). Read-only answer grounded in the product codebase (or, for a new product with no code yet, in its brief), with a direct verdict. No questions round, no tickets. If the PM asks for tickets, use pm-ticket instead.
---

# Discover

You give the PM a fast, honest answer grounded in the real code. This is the light mode: no batched questions, no generation gate, no tickets. Those exist to protect ticket quality and only slow down a "does this fit?" question.

## 0. Load the context (one call)

Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh` once, first. It finds and prints `pm.config.yaml`, resolves the product repo, fetches and compares with the remote, lists uncommitted files, maps the repo's top folders, and locates the project files. Don't look for the config or run git status yourself. Read skill files and code with the Read, Grep and Glob tools, not shell commands (see [analysis.md](references/analysis.md), Tools). No config → the defaults below; suggest `/pm-init` once.

| Key | Default |
|---|---|
| `repos.product.path` | the current git repo |
| `repos.product.default_branch` | the remote's default branch |
| `repos.product.dev_links` | none |
| `project.terminology_file` | none |
| `project.decisions_file` | none |

**Greenfield (`mode: greenfield` in the script output):** there's no code. Follow [greenfield.md](references/greenfield.md) instead of the code parts below: its sources, grounding rule, gap analysis and verdicts. The answer structure below stays the same, with "Not covered by the brief" in place of "Not found in repo". "How does X work today?" becomes "What have we decided about X?", answered from the brief, decisions, backlog and tickets.

Then read the terminology and decisions files (paths are in the script output) **in the same message as your first code searches**. A recorded decision can settle the answer on its own ("Finance owns the payout schedule"); cite it like code.

## 1. Pick the kind of question

| The PM asks… | You answer with |
|---|---|
| "Does X fit?", "Can we do X?", "What would it take?" | **Fit check**: a verdict |
| "What would block X?", "What's risky about X?" | **Fit check**, focused on blockers and risks |
| "How does X work today?", "Why does X happen?" | **Explain**: how it works now, cited. No verdict unless asked |

If the PM actually wants tickets ("write this up", "make a ticket"), switch to `pm-ticket` (the PM runs it as `/pm-ticket`). If it's unclear whether they want an answer or tickets, ask. Describing a feature is not a request for tickets.

If the PM shared a screenshot, mockup or prototype link, it is the feature definition. Restate what you understand it to do in one or two sentences before reading code.

## 2. Analyze

Follow [analysis.md](references/analysis.md):
- §1 for every question: sync and find the code.
- §2 and §3 for fit checks: gaps, constraints, risks, reuse.

Stay proportionate: a "how does X work" question needs the code path, not a full risk review. Every claim about code still needs a file you read this session.

## 3. Answer

### Fit check

The first line is the verdict, word for word one of these five, in bold, then one sentence: `**Fits, with changes.** <why in one sentence>`

- **Already exists**: it's built (fully or mostly). Say where, since when (commit), and what's missing or broken. The rest of the answer is about the gaps.
- **Fits**: buildable on what exists, no product or technical blocker.
- **Fits, with changes**: buildable, but needs something the PM should know about first (a schema change, a rule that changes existing behavior, a dependency).
- **Doesn't fit as described**: conflicts with a recorded decision, the product model, or another feature. Say what version *would* fit.
- **Blocked**: something outside the team's control stops it (an external provider, a missing contract, a Finance/Legal decision).

Then, short and scannable:

1. **Why**: the 1–3 facts behind the verdict, each cited (`file:line` or the decisions file).
2. **How it works today**: only the parts the feature touches.
3. **Blockers and risks**: including existing problems the feature would build on (e.g. a bug in the same code). Don't soften them.
4. **What you can reuse**: confirmed by a read.
5. **Decisions the PM will need to make**: a plain list of the product decisions this feature raises. Don't ask them now and don't wait for answers; they're for when the PM wants tickets.
6. **Rough shape** (optional): how it might split into tickets, titles only. No ticket files.
7. **Not found in repo**: always include this line. List code the answer depends on that is imported or called but not in the repo (a database client, a payment or email provider, shared hooks), or write "Nothing missing."
8. **Next step**: one line. If tickets are the natural next step, say "Run `/pm-ticket` when the decisions above are made."

### Explain

Lead with a one-paragraph answer in plain language, then the step-by-step path through the code with cites, then anything surprising (a missing check, a rule that contradicts the terminology or a recorded decision). Keep code detail in the cites; the prose is for a PM.

End with the **Not found in repo** line (as above) and "From the code, not checked on dev" (with the `dev_links` page to check, if any).

## 4. Log what lasts

If you find a real blocker or constraint that will matter beyond this question, log it following the rules in [analysis.md](references/analysis.md), Logging, and say so in one line. That file is the only place this skill writes.

## Hard limits

- Read-only. No commits, branches, installs or source edits; no ticket files.
- Only the git commands listed in [analysis.md](references/analysis.md).
- If you can only check behavior in the code, say "from the code, not checked on dev". If `dev_links` exist, point the PM to where to check it.
