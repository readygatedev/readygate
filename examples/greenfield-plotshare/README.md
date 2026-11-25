# Plotshare demo (greenfield: no codebase)

A fictional product idea, for testing ReadyGate's greenfield mode. There is no code here on purpose.

## Run it

```bash
mkdir ~/plotshare && cd ~/plotshare && claude
```

1. `/pm-new` with the idea:
   > Plotshare: a web app for our city's community gardens. Residents can see which garden plots are free, join a waitlist, and get offered a plot when one frees up. Garden coordinators manage plots, the waitlist and yearly renewals. Today it's all spreadsheets and email.
2. Answer its questions (users, non-goals, metric, constraints) and confirm the summary.
3. `/pm-backlog`, review, then "write it".
4. `/pm-discover Can gardeners sell their produce to other residents in the app?`
5. `/pm-ticket <a ready feature number>`, answer, "generate".

## What a good run does

| Step | Expected |
|---|---|
| `/pm-new` | Asks only about missing brief sections, shows a summary and writes **nothing** until you confirm. Anything undecided lands under Open questions, never guessed. |
| `/pm-backlog` | Epics per MVP goal, small user-facing features in build order with dependencies, each `ready` or `idea (needs Qn)`. Writes only after approval. |
| `/pm-discover` | Opens with a greenfield verdict (e.g. **Conflicts with the brief** or **Fits, after MVP**), cites the brief, labels any general knowledge. |
| `/pm-ticket` | Same gates as code mode; Description says which goal it serves; Dev notes hold "Question for the tech lead" items, not code; the backlog line becomes `ticketed`. |

Automated version: `tests/run-greenfield.sh`.
