---
name: pm-new
argument-hint: "[the product idea, in your own words]"
allowed-tools: Read, Grep, Glob, Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh:*)
description: Use when the PM is starting a new product or a big new module and has no codebase yet ("I have an idea for…", "we're starting a new product", "help me set up a project from scratch"). Interviews the PM, then writes the product brief, terminology, decisions and a greenfield pm.config.yaml so the other ReadyGate commands work without code. Not for products that already have a repo; that's /pm-init.
---

# Start a new product (greenfield)

Goal: turn the PM's idea into a short, honest **product brief** that every later answer and ticket can be grounded in. The brief replaces the codebase until there is one.

## Rules

- **Never invent the product.** Everything in the brief comes from the PM's words or answers. What they haven't decided goes under "Open questions", not into a guess. Suggestions are fine, labeled as suggestions, and only enter the brief when the PM accepts them.
- **Never overwrite a file silently.** If `pm.config.yaml` or a `pm/` file exists, show what would change and ask.
- **Don't ask what the PM already said** (in the arguments or earlier in the conversation).
- Plugin files are at `${CLAUDE_PLUGIN_ROOT}`. Templates: `templates/BRIEF.md`, `templates/TERMINOLOGY.md`, `templates/DECISIONS.md`, `templates/pm.config.example.yaml`.

## 1. Check the folder

Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh`. If it finds a product repo with code, say so and suggest `/pm-init` instead (code mode is better grounded). If a config already exists, switch to update mode: show the current brief's gaps and ask what changed.

## 2. Listen first

If the PM hasn't described the idea yet, ask for it in their own words: one open question, no form. ("Tell me about the product: who it's for, what problem it solves, and what you want the first version to do.")

## 3. Fill the gaps (one round)

Map what they said onto the brief's sections: problem, target users, MVP goals, non-goals, success metrics, constraints (deadline, platform, team, compliance, integrations). Then ask only about the **empty or vague** sections, in one round, at most 6 questions. Use AskUserQuestion when it's available (max 4 per call, recommended option first, built from what they told you); otherwise one chat message.

Questions worth asking almost every time, if not already answered:
- Who is the **first** user the MVP must satisfy (if they named several)?
- What will the MVP **not** do? (Non-goals stop scope creep later; offer 2–3 likely candidates from their description.)
- How will you know it worked (a metric and a date)?
- Any hard constraints: deadline, platform, payments or personal data, required integrations?

Then show a **one-screen summary** of the brief as you understand it, including what will go under Open questions, and stop. Write nothing until the PM confirms ("yes", "write it", corrections). Corrections → update the summary and confirm again only if something changed meaningfully.

If the PM's first message already covers every section and says to write it, skip straight to step 4 and list anything you put under Open questions.

## 4. Write

1. `pm/BRIEF.md` from the template, in the PM's language and terms. Unanswered points go under **Open questions**, numbered once (`Q1`, `Q2`… numbers never change, even when a question moves or is answered), each split into:
   - **Before MVP**: it blocks something the MVP needs (a core flow, who can use it, the data it starts with) or the launch itself (a legal, privacy or compliance answer, the launch date). Order them by how much they block, most first.
   - **Can wait**: it only affects features after the MVP, or it's planning detail (scale, team capacity) that doesn't stop anyone writing the first tickets.

   When unsure, put it under Before MVP: a question wrongly marked "can wait" lets a ticket go out on a guess. Never move a question to Can wait by assuming an answer.
2. `pm/TERMINOLOGY.md`: the user types, key objects and statuses the PM used, one row each, marked `(draft: check)`. Flag any word they used for two different things.
3. `pm/DECISIONS.md`: only standing rules the PM stated ("payments go through Stripe", "EU users only at launch"), following the Logging rules in [analysis.md](../pm-discover/references/analysis.md). Often empty at this stage, and that's fine.
4. `pm.config.yaml` from the template with `mode: greenfield`, `repos.product.path: none` (drop the branch, remote and dev links keys), `brief_file`, `backlog_file`, and the tickets folder `pm/tickets`. Keep the template's comments and gates.
5. `pm/tickets/.gitkeep`.

Validate the YAML (`python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' pm.config.yaml`).

## 5. Finish

Reply with:
1. What was written (one line per file).
2. The **Before MVP** questions, numbered, most-blocking first, so the PM knows what to answer next. Then one line with how many can wait.
3. Next step: "Run `/pm-backlog` to break the MVP into epics and features in build order. After that, `/pm-discover <idea>` checks new ideas against the brief and `/pm-ticket <feature>` writes tickets."
4. One line: when code exists, run `/pm-init` to switch to code mode. The brief and decisions stay.
