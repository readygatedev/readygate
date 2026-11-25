# Ticket format

Tickets are Markdown at the source. Tracker adapters convert them (Jira, Linear, GitHub) when pushing, so write plain Markdown only.

## Template

```markdown
# [Area] Verb-first, scoped title

## Description
**User story:**
As a <user type>,
I want <action or capability>,
so that <business outcome>.

<One short paragraph of business context and user impact, if the story needs it.>

## Scope
- **In scope:**
  - <user flows and functional boundaries>
- **Out of scope:**
  - <explicit exclusions or deferred items>

## Business rules
1. **BR-01:** <policy statement>
2. **BR-02:** <...>

## Acceptance criteria
- **AC-01 (BR-01):** Given <context>, when <action>, then <observable outcome>.
- **AC-02 (BR-01, BR-02):** Given <context>, when <action>, then <outcome>, and <related outcome>.
- **AC-03 (standard):** Given <screen>, when it is loading, empty or fails to load, then <what the user sees in each case>.

## Happy path
<Short narrative of the main success flow: what the developer records as the demo.
"N/A: no user-facing flow" for backend-only tickets.>

## Dependencies
- <other ticket by title or short description, never by number>, or "None."

## Dev notes
- <plain-language pointers: which part of the product to look at, what already exists to reuse, what to watch out for>
- <labeled technical assumptions: "Assumption (technical): …">
```

## Rules for the template

- **Exactly these sections, in this order.** Don't add Open Risks, Non-functional Requirements, Context or Affected Code sections. Risks and NFR items go into Business Rules or Acceptance Criteria.
- **Title:** line 1. Optional leading tags: `[Area]` for the product area, `[Bug]` or `[Task]` for the issue type (the tracker adapter strips them from the summary). Then a verb-first title scoped to one change: "Let admins pause a seller's payouts", not "Payouts".
- **No code locations anywhere in the ticket**: no file, folder, package or component paths, no field or function names, no code. Developers find where the work goes. Code pointers you found go in the chat reply.
- **Dependencies** name other tickets by title, never by number: numbers change between the files and the tracker.
- **Forbidden** (`tickets.forbid`): checkboxes (`[ ]`, `[x]`), story points or T-shirt sizes, labels, open product questions or placeholders.
