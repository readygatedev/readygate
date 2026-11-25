# Changelog

## 0.3.0 (unreleased)

- No PyYAML needed: `scripts/pmconfig.py` reads `pm.config.yaml` with python3 alone (PyYAML is still used when installed).
- `pmconfig.py --check` validates the config with plain-English errors (line numbers, missing keys); `/pm-init` and `/pm-new` use it.
- The config shown by the context script no longer has trailing spaces where comments were stripped.

## 0.2.0 (2026-11-25)

- **Greenfield mode** for PMs with no codebase yet:
  - `/pm-new` interviews the PM and writes a product brief (problem, users, goals, non-goals, metrics, constraints, open questions), terminology, decisions and a greenfield config. It never invents the product: anything undecided goes under Open questions.
  - `/pm-backlog` splits the MVP into epics and user-facing features in build order with dependencies, each `ready` or blocked by a named open question. It writes only after approval and keeps statuses and ticket links on re-runs.
  - `/pm-discover` and `/pm-ticket` ground in the brief when there's no code, with greenfield verdicts, labeled general knowledge, and "Question for the tech lead" in Dev Notes.
  - `/pm-init` routes to greenfield setup when no repo is found, and switches a greenfield project to code mode once code exists.

## 0.1.0 (2026-11-25)

First public version: the free tier.

- `/pm-init`: detects repos, stack and existing PM files; writes `pm.config.yaml`, a drafted glossary, a decisions file and the tickets folder. Update mode for later changes.
- `/pm-discover`: read-only fit check (four fixed verdicts) or "how does it work today" answer, every claim cited to the code.
- `/pm-ticket`: gap analysis, one round of product questions, an explicit "generate" gate, a Definition of Ready check, and Markdown tickets sized 3–8 acceptance criteria.
- Acme Shop demo workspace with sample output.
- Performance: one read-only context script (`scripts/context.sh`) collects the config, git sync state, repo map and existing tickets in a single call. It also has a `history` mode for who changed a file and when.
- No permission prompts during analysis: the skills declare `allowed-tools` for Read, Grep, Glob and their own scripts, and search with those tools instead of shell commands.
- Batched searches and reads. On a 1,500-file monorepo, a fit check went from 14 to 8 round trips, 61s to 46s, and $0.74 to $0.48.
- New verdict: **Already exists**, for features that are already (partly) built.
