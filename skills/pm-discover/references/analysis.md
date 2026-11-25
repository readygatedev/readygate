# Analysis: grounding the feature in the code

## Grounding rule (every phase)

Every claim about existing code (schema fields, API routes, services, components, permissions) is backed by a file you actually read in this session. Cite `path:line-range` in chat. If you can't find something, say "not found". Never infer that code exists from naming conventions or typical project structure.

*Why: a confident claim about code that doesn't exist becomes a ticket that sends developers looking for nothing, and the PM loses trust in every other claim.*

## §1 Context and sync

1. **Sync: already done by the context script** (see the skill's step 0). Use its output; don't repeat its git commands. From it, report in one line: behind the remote (and whether the unpulled commits touch this area), uncommitted files (warn the analysis may reflect unreviewed work), or "remote comparison unavailable". Don't pull: read-only by default.
2. **Find the code, wide then deep.** The script's folder map tells you where things live.
   - First, one message with several independent searches at once: Grep for the feature's key terms (from the terminology file and the PM's words) across the likely folders, plus Glob for schema, route and screen files. Don't search one term per turn.
   - Then read the hits that matter, **several files per message**. A file you need in full: read it once, not in slices.
   - Stop searching when you can answer. You need the code path the feature touches, not the whole repo.
3. **Check whether it already exists.** Before analysing a "new" feature, search for it by name and by behavior. Teams often half-build things.
4. Nothing relevant found → say so plainly. Don't invent a plausible structure.
5. Code the feature depends on that is imported but not in the repo (a database client, a payments or email provider, shared hooks) → list it as "not found in repo" so the PM knows which behavior you couldn't check.

**Tools.** Search and read with the **Grep, Glob and Read tools**, never `grep`, `rg`, `find`, `ls`, `cat` or `head` in Bash: the tools run without permission prompts for the PM, the shell commands don't. Bash is only for the context script. For who changed something and when, use `bash ${CLAUDE_PLUGIN_ROOT}/scripts/context.sh history <file-or-folder>` (prompt-free); use `git -C <repo> show` or `blame` only when you need more than that.

**Commands.** Never `cd`: use absolute paths and `git -C <repo>`. Allowed git commands: `fetch`, `status`, `log`, `diff`, `show`, `blame`, `grep`, `ls-files`, `branch --list`. Nothing that writes.

## §2 Gap analysis

Don't validate a flawed or incomplete product idea. Name explicitly:

1. **Functional gaps**: unhandled flows, edge cases, permission rules, missing states (loading, empty, error), what happens to existing data.
2. **Technical constraints**: missing schema fields, breaking API changes, anti-patterns the feature would add to.
3. **Risks**: performance, security, regressions in flows that share the same code.

Check the `tickets.nfr_checklist` here. Note only the items this feature actually changes.

## §3 Reuse and small wins

- Existing services, endpoints or UI components that cut effort. Only ones you confirmed by reading them.
- Small UX or technical improvements that fit naturally in scope. Offer them as options; they are product decisions if they change behavior.

## Logging

`project.decisions_file` is the project's memory: standing rules every future feature must respect. Keep it short enough that the PM reads it.

**What goes in.** Apply one test: *would this change the answer for a different feature?*
- Yes: a policy that applies across features ("Sellers never see raw bank errors", "every Staff action on a Seller is audited", "payout dates are shown in UTC"), an owner or sign-off rule ("Finance owns the payout schedule"), or a constraint or bug in shared code that other work will hit ("the payout run has no guard against double-sending").
- No: anything about this feature only. That includes the PM's answers about its wording, labels, limits, screens or scope. Those already live in the tickets, which are the record for the feature.

**How.**
- One line per entry: date, the rule or finding, its source (the PM, or a `file:line` cite), and in a few words why it matters.
- Before adding, check whether an entry already covers it. Update that entry instead of adding a near-duplicate.
- A PM answer becomes a standing rule only if the PM framed it generally or agrees when you ask. Ask in one line ("Should 'sellers never see raw bank errors' apply to every feature? I'd add it to DECISIONS.md."), never silently.
- Say in the chat reply which entries you added or changed.
