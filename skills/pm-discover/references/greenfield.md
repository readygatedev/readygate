# Greenfield mode: grounding without a codebase

Applies when `pm.config.yaml` has `mode: greenfield` (the context script prints it). There is no code yet, so the brief replaces the code as the source of truth. Everything else in ReadyGate stays: the gates, the ticket format, the decisions rules.

## Sources of truth, in order

1. `project.decisions_file`: standing decisions win over everything else.
2. `project.brief_file`: problem, users, goals, non-goals, success metrics, constraints, open questions.
3. `project.backlog_file`: epics and features in build order, with their status and dependencies.
4. `project.terminology_file`: the words users see.
5. Tickets already written in `tickets.dir`: they're decided behavior for the features they cover.

Read all of them at the start, in one message (paths are in the context script's output).

## Grounding rule (greenfield)

- Every claim about **this product** cites one of the sources above: `BRIEF.md §Non-goals`, `DECISIONS.md (2026-11-25)`, `BACKLOG.md 2.3`, or a ticket file. If the sources don't say, write "not covered by the brief". Don't fill the gap with what products like this usually do.
- **General knowledge** (how card payments work, what app stores require, what a privacy law demands) is allowed, but always labeled: "*General knowledge, check before relying on it:* …". Never present it as a fact about this project or as a decision.
- **Technical feasibility** has no code to check. Say what it depends on, and turn each open point into a question for whoever will build it, labeled "Question for the tech lead". Never assume a stack, an architecture or an effort size.
- **Open questions** in the brief are open product decisions. A feature that depends on one can be discussed, but it can't get tickets until the PM answers it (Definition of Ready).

## Gap analysis (instead of the code-mode §2)

Check the feature against the brief and name, explicitly:
1. **Scope fit**: which goal it serves, whether a non-goal or constraint rules it out, and whether it belongs in the MVP or later.
2. **Functional gaps**: users, roles and permissions, flows, edge cases, states (loading, empty, error), what users are told, data the feature creates and what happens to it.
3. **Dependencies**: features in the backlog it needs first, and external systems or accounts (payments, email, app stores, identity providers) it can't work without.
4. **Risks**: compliance and privacy (from the brief's constraints), abuse and fraud, anything that would be expensive to change after launch (data model choices, pricing, public URLs).

Every gap found is binding, as in code mode: it reaches a ticket, a backlog line or the brief's open questions.

## Discover verdicts (greenfield)

The first line is one of these, in bold, then one sentence:
- **In MVP scope**: serves an MVP goal, no conflict.
- **Fits, after MVP**: consistent with the brief but not needed for the MVP goals. Say which backlog section it belongs in.
- **Already planned**: it's in the backlog (give the number and status) or covered by an existing ticket.
- **Conflicts with the brief**: hits a non-goal, a constraint or a decision. Say what would have to change, and who decides.
- **Needs a decision first**: depends on an open question in the brief. Name the question.

Replace the code-mode "Not found in repo" line with **"Not covered by the brief:"**, listing what the answer depended on that no source says (or "Nothing missing.").

## Tickets (greenfield)

- Same template and writing rules. **Description** cites the goal it serves ("Serves goal 2: …").
- **Dev notes** have no code to point at. Use them for: what the feature depends on (other features, external accounts), data it creates, and "Question for the tech lead: …" items. Those questions are technical; product questions never go in a ticket.
- If the feature has a backlog line, update that line's status to `ticketed` and put the ticket folder in its Tickets column. That's the only change to the backlog this skill makes.
