#!/usr/bin/env bash
# End-to-end regression test of the free tier on the Acme demo:
#   /pm-init → /pm-discover → /pm-ticket (must stop) → answers + "generate" → checks.
# Uses real Claude runs (costs about $3–5 on API pricing). Usage: tests/run-flow.sh [workdir]
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; PLUGIN="$(dirname "$HERE")"
W="${1:-$(mktemp -d)/acme}"; LOG="$W.logs"; mkdir -p "$LOG"
"$PLUGIN/examples/acme-shop/setup.sh" "$W" >/dev/null || exit 1
rm -rf "$W/pm.config.yaml" "$W/pm"
TOOLS="Read Grep Glob Write Edit Skill Bash(bash:*) Bash(python3:*) Bash(git:*) Bash(mkdir:*) Bash(touch:*) Bash(ls:*) Bash(cat:*) Bash(find:*) Bash(cp:*)"
SID=""; FAILS=0; COST=0
step () { # name prompt
  local args=(); [ -n "$SID" ] && args=(--resume "$SID")
  (cd "$W" && claude -p "$2" "${args[@]}" --plugin-dir "$PLUGIN" --allowedTools "$TOOLS" --output-format json </dev/null >"$LOG/$1.json" 2>"$LOG/$1.err")
  SID=$(python3 -c "import json;print(json.load(open('$LOG/$1.json'))['session_id'])")
  COST=$(python3 -c "import json;print(round($COST+json.load(open('$LOG/$1.json'))['total_cost_usd'],2))")
  python3 -c "import json;print(json.load(open('$LOG/$1.json'))['result'])" > "$LOG/$1.txt"
  echo "· $1 done (total \$$COST)"
}
check () { if eval "$2"; then echo "  ok   $1"; else echo "  FAIL $1"; FAILS=$((FAILS+1)); fi; }
tickets () { find "$W/pm/tickets" -name '*.md' 2>/dev/null | wc -l; }

step 1-init '/pm-init Draft the terminology from the code. Keep tickets outside the app repo.'
check "config written and valid" "python3 -c \"import yaml;yaml.safe_load(open('$W/pm.config.yaml'))\""
check "terminology drafted" "grep -q 'draft: check' '$W/pm/TERMINOLOGY.md'"
check "tickets folder exists" "[ -d '$W/pm/tickets' ]"
cat "$PLUGIN/examples/acme-shop/pm/DECISIONS.md" | grep '^- ' >> "$W/pm/DECISIONS.md"   # the PM adds team decisions

step 2-discover '/pm-discover Can Sellers see why a payout failed, on their dashboard?'
check "verdict on first line" "head -3 '$LOG/2-discover.txt' | grep -qE '\*\*(Already exists|Fits|Fits, with changes|Doesn.t fit as described|Blocked)\.\*\*'"
check "'not found in repo' line" "grep -qi 'not found in repo' '$LOG/2-discover.txt'"
check "no tickets after discover" "[ \$(tickets) -eq 0 ]"

step 3-ticket '/pm-ticket write it up'
check "stops at questions (no tickets)" "[ \$(tickets) -eq 0 ]"

step 4-generate 'Take your recommendation for every open question. Generate.'
# The gate may stop once more (no tickets yet), or write some tickets and hold others on a new decision.
if [ "$(tickets)" -eq 0 ] || grep -qiE 'on hold|held back|until you answer|once you answer' "$LOG/4-generate.txt"; then
  step 5-generate 'Take your recommendation for every remaining point. Write the remaining tickets.'
fi
F=$(dirname "$(find "$W/pm/tickets" -name '*.md' | head -1)")
check "tickets written" "[ \$(tickets) -gt 0 ]"
check "tickets pass the writing rules" "python3 '$HERE/check_tickets.py' '$F' > '$LOG/check.txt'"
check "product repo untouched" "[ -z \"\$(git -C '$W/acme-app' status --porcelain)\" ] && [ \$(git -C '$W/acme-app' rev-list --count HEAD) -eq 3 ]"

echo; cat "$LOG/check.txt" 2>/dev/null
echo; for j in "$LOG"/*.json; do python3 -c "import json;d=json.load(open('$j'));print('  %-11s turns=%-3s %4ss  \$%.2f' % ('$(basename "$j" .json)', d['num_turns'], round(d['duration_ms']/1000), d['total_cost_usd']))"; done
echo; echo "workspace: $W   logs: $LOG   cost: \$$COST"
[ $FAILS -eq 0 ] && echo "PASS" || { echo "FAILED: $FAILS check(s)"; exit 1; }
