# Changelog

## 0.1.0 (unreleased)

First public version: the free tier.

- `/pm-init`: detects repos, stack and existing PM files; writes `pm.config.yaml`, a drafted glossary, a decisions file and the tickets folder. Update mode for later changes.
- `/pm-discover`: read-only fit check (four fixed verdicts) or "how does it work today" answer, every claim cited to the code.
- `/pm-ticket`: gap analysis, one round of product questions, an explicit "generate" gate, a Definition of Ready check, and Markdown tickets sized 3–8 acceptance criteria.
- Acme Shop demo workspace with sample output.
- Performance: one read-only context script (`scripts/context.sh`) collects the config, git sync state, repo map and existing tickets in a single call. It also has a `history` mode for who changed a file and when.
- No permission prompts during analysis: the skills declare `allowed-tools` for Read, Grep, Glob and their own scripts, and search with those tools instead of shell commands.
- Batched searches and reads. On a 1,500-file monorepo, a fit check went from 14 to 8 round trips, 61s to 46s, and $0.74 to $0.48.
- New verdict: **Already exists**, for features that are already (partly) built.
