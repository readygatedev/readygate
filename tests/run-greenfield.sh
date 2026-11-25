#!/usr/bin/env bash
# End-to-end test of greenfield mode (no codebase): /pm-new → /pm-backlog → /pm-discover → /pm-ticket.
# Real Claude runs (about $4–6 on API pricing). Usage: tests/run-greenfield.sh [workdir]
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; PLUGIN="$(dirname "$HERE")"
W="${1:-$(mktemp -d)/plotshare}"; LOG="$W.logs"; mkdir -p "$W" "$LOG"
[ -z "$(ls -A "$W")" ] || { echo "refusing: $W is not empty"; exit 1; }
TOOLS="Read Grep Glob Write Edit Skill Bash(bash:*) Bash(python3:*) Bash(mkdir:*) Bash(touch:*) Bash(ls:*)"
SID=""; FAILS=0; COST=0
step () {
  local args=(); [ -n "$SID" ] && args=(--resume "$SID")
  (cd "$W" && claude -p "$2" "${args[@]}" --plugin-dir "$PLUGIN" --allowedTools "$TOOLS" --output-format json </dev/null >"$LOG/$1.json" 2>"$LOG/$1.err")
  SID=$(python3 -c "import json;print(json.load(open('$LOG/$1.json'))['session_id'])")
  COST=$(python3 -c "import json;print(round($COST+json.load(open('$LOG/$1.json'))['total_cost_usd'],2))")
  python3 -c "import json;print(json.load(open('$LOG/$1.json'))['result'])" > "$LOG/$1.txt"
  echo "· $1 done (total \$$COST)"
}
check () { if eval "$2"; then echo "  ok   $1"; else echo "  FAIL $1"; FAILS=$((FAILS+1)); fi; }
tickets () { find "$W/pm/tickets" -name '*.md' 2>/dev/null | wc -l; }

step 1-new "/pm-new Plotshare: a web app for our city's community gardens. Residents can see which garden plots are free, join a waitlist, and get offered a plot when one frees up. Garden coordinators manage plots, the waitlist and yearly renewals. Today it's all spreadsheets and email."
check "no brief before confirmation" "[ ! -f '$W/pm/BRIEF.md' ]"

step 2-confirm "First users: residents looking for a plot, then coordinators. The MVP won't take payments (fees stay offline) and won't have a native mobile app (mobile-friendly web only). Success: 80% of plot offers handled in the app by next spring. Constraints: one city, launch in 4 months, EU personal data. Use your suggestion for anything else. Write it."
check "brief written" "[ -f '$W/pm/BRIEF.md' ] && grep -qi 'non-goals' '$W/pm/BRIEF.md'"
check "config is greenfield and valid" "python3 -c \"import yaml;c=yaml.safe_load(open('$W/pm.config.yaml'));assert c['mode']=='greenfield' and str(c['repos']['product']['path'])=='none'\""
check "terminology drafted" "grep -q 'draft: check' '$W/pm/TERMINOLOGY.md'"
check "open questions split Before MVP / Can wait" "grep -q '### Before MVP' '$W/pm/BRIEF.md' && grep -q '### Can wait' '$W/pm/BRIEF.md'"

step 3-backlog "/pm-backlog"
check "no backlog before approval" "[ ! -f '$W/pm/BACKLOG.md' ]"
step 4-backlog-go "Looks good. Write it."
check "backlog written with ready features" "grep -q 'ready' '$W/pm/BACKLOG.md'"
check "payments not in the MVP part" "! sed -n '1,/^## Later/p' '$W/pm/BACKLOG.md' | grep -qiE 'pay (the|a) fee|online payment|checkout'"

step 5-discover "/pm-discover Can gardeners sell their produce to other residents in the app?"
check "greenfield verdict on first line" "head -3 '$LOG/5-discover.txt' | grep -qE '\*\*(In MVP scope|Fits, after MVP|Already planned|Conflicts with the brief|Needs a decision first)\.\*\*'"
check "'not covered by the brief' line" "grep -qi 'not covered by the brief' '$LOG/5-discover.txt'"
check "no tickets after discover" "[ \$(tickets) -eq 0 ]"

step 6-ticket "/pm-ticket the first ready feature in the backlog"
check "stops at questions (no tickets)" "[ \$(tickets) -eq 0 ]"
step 7-generate "Take your recommendation for every open question. Generate."
if [ "$(tickets)" -eq 0 ] || grep -qiE 'on hold|held back|until you answer|once you answer' "$LOG/7-generate.txt"; then
  step 8-generate "Take your recommendation for every remaining point. Write the remaining tickets."
fi
F=$(dirname "$(find "$W/pm/tickets" -name '*.md' | head -1)")
check "tickets written" "[ \$(tickets) -gt 0 ]"
check "tickets pass the writing rules" "python3 '$HERE/check_tickets.py' '$F' > '$LOG/check.txt'"
check "tickets cite a goal" "grep -qiE 'goal' $F/*.md"
check "backlog line marked ticketed" "grep -q 'ticketed' '$W/pm/BACKLOG.md'"

echo; cat "$LOG/check.txt" 2>/dev/null
echo; for j in "$LOG"/*.json; do python3 -c "import json;d=json.load(open('$j'));print('  %-15s turns=%-3s %4ss  \$%.2f' % ('$(basename "$j" .json)', d['num_turns'], round(d['duration_ms']/1000), d['total_cost_usd']))"; done
echo; echo "workspace: $W   logs: $LOG   cost: \$$COST"
[ $FAILS -eq 0 ] && echo "PASS" || { echo "FAILED: $FAILS check(s)"; exit 1; }
