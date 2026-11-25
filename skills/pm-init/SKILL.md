---
name: pm-init
argument-hint: "[answers you already know, e.g. \"tickets outside the repo, draft the glossary\"]"
allowed-tools: Read, Grep, Glob, Bash(bash ${CLAUDE_PLUGIN_ROOT}/skills/pm-init/scripts/detect.sh:*)
description: Set up ReadyGate in a workspace. Scans the folder for repos, stack and existing PM files, asks the PM only what it can't detect, then writes pm.config.yaml, the terminology and decisions files and the tickets folder. Also updates an existing setup. Run by the PM as /pm-init.
disable-model-invocation: true
---

# Set up ReadyGate

Goal: a working `pm.config.yaml` in a few minutes, with as few questions as possible. Detect first, propose defaults, ask only what's left.

## Rules

- **Never overwrite a file silently.** If a target file exists, show what would change and ask.
- **Don't write inside the product repo** except the tickets folder, and only if the PM chooses to keep tickets there.
- **Don't ask what you can detect, and don't ask what the PM already said** (in the `/pm-init` arguments or earlier in the conversation).
- **Never store secrets** in any file.
- The plugin's own files are at `${CLAUDE_PLUGIN_ROOT}`. Template: `${CLAUDE_PLUGIN_ROOT}/templates/pm.config.example.yaml`.

## 1. Detect

Run `bash ${CLAUDE_PLUGIN_ROOT}/skills/pm-init/scripts/detect.sh` from the working directory. It is read-only and runs without a permission prompt. Read files with the Read, Grep and Glob tools rather than shell commands, for the same reason. It reports:
- an existing `pm.config.yaml` (here or in a parent folder),
- every git repo here or up to 2 levels down: remote, default branch, commits and authors, uncommitted files, stack, mock-data folders, routes file, hosting, existing CLAUDE.md, glossaries, decision records and ticket-like folders,
- MCP servers and whether the GitHub CLI is logged in.

**If a config already exists → update mode.** Read it, summarize the current setup in a short table, and ask what to change. Apply only those changes, keep comments, show the diff before saving. Then go to step 5.

## 2. Work out the defaults

| Setting | How to decide |
|---|---|
| Workspace root | The folder `pm.config.yaml` goes in: the current directory. If the current directory *is* the only repo, the root is that repo. |
| Product repo | The repo with server code, the most commits, or the most authors. Several candidates → ask. A repo that only holds mock data (a prototype) is not the product repo. |
| Default branch | From the scan. If the repo has both `develop` and `main`, ask which one the developers merge into. |
| Terminology file | An existing glossary (TERMINOLOGY, DOMAIN-TERMINOLOGY, GLOSSARY, CONTEXT) → point to it, don't copy it. None → create `pm/TERMINOLOGY.md`. |
| Decisions file | An existing decisions file → point to it. ADR folder → mention it in the file. None → create `pm/DECISIONS.md`. |
| Tickets folder | `pm/tickets` next to `pm.config.yaml`. An existing ticket folder in the product repo → offer to keep using it. |
| Project name | The product repo's folder name, made readable. One-liner: from its README, if there is one. |

## 3. Ask (one round)

Show what you detected and the defaults in a compact table, then ask only the open points. Use the AskUserQuestion tool when it's available (max 4 questions; multiple choice with your recommended option first); otherwise ask in one chat message. Typical open points:

1. Which repo is the product (only if unclear)?
2. Where tickets go: next to the config (recommended) or an existing ticket folder?
3. Draft the terminology from the code now? (recommended: yes)
4. Anything wrong in the defaults table?

Then, only if needed, ask for the product one-liner (if none was found) and dev links, in one message.

If the PM skips something, use the default and list it in the final checklist. Don't block on it.

If the scan found a tracker connection (Jira, Linear) or a prototype repo, or the PM asks about them, say in one line that pushing tickets to a tracker and the prototype loop are part of ReadyGate Pro. Tickets are Markdown files they can paste into any tracker.

## 4. Write

1. **`pm.config.yaml`** at the workspace root, from the template:
   - Fill in every detected and answered value. Paths are relative to the config file.
   - Keep the template's comments. Leave `gates:` exactly as in the template.
2. **Terminology file** (if creating one): copy `templates/TERMINOLOGY.md`. If the PM agreed, draft the first rows from the code: entity and role names from the schema/models and the labels the UI shows. Mark drafted rows `(draft: check)` and list any inconsistencies you notice (the same thing labeled two ways). The PM owns this file.
3. **Decisions file** (if creating one): copy `templates/DECISIONS.md`. Add one line pointing to an ADR folder if one exists.
4. **Tickets folder**: create it with a `.gitkeep`. If it's inside the product repo, ask whether to add it to `.git/info/exclude` (local-only ignore, invisible to the team) rather than editing `.gitignore`.

## 5. Check

- Parse the YAML (`python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' pm.config.yaml`, or node). Fix and re-check on error.
- Every path in the config exists (except the tickets folder's future subfolders).
- `git -C <product repo> fetch --dry-run` works. If not, note "remote comparison unavailable" and continue.

## 6. Finish

Reply with:
1. A table of what was set up: file, created / updated / pointed-to-existing.
2. What's left for the PM, as a short list. Typical items: review the drafted terminology rows, add team decisions that aren't in the code (they matter: ReadyGate treats them as answered), add dev links.
3. How to start: "`/pm-discover <idea>` for a quick fit check, `/pm-ticket <feature>` for tickets."
