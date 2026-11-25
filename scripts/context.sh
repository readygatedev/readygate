#!/usr/bin/env bash
# ReadyGate: everything a skill needs before analysis, in one read-only call.
# Finds pm.config.yaml (walking up), prints it, resolves the product repo, syncs git,
# and lists the project files and existing tickets. Usage: context.sh [start-dir]
#        context.sh history <path> [n]   (git history of one file or folder)
set -uo pipefail
# Subcommand: context.sh history <path-in-product-repo> [n]  → who changed it and when (read-only)
mode=context; if [ "${1:-}" = "history" ]; then mode=history; target="${2:?usage: context.sh history <path> [n]}"; n="${3:-10}"; set -- .; fi
start="$(cd "${1:-.}" && pwd)"; d="$start"; cfg=""
while [ "$d" != "/" ]; do [ -f "$d/pm.config.yaml" ] && { cfg="$d/pm.config.yaml"; break; }; d="$(dirname "$d")"; done

if [ -z "$cfg" ]; then
  [ "$mode" = context ] && echo "config: none (suggest /pm-init once; using defaults)"
  root="$start"; product="$(git -C "$start" rev-parse --show-toplevel 2>/dev/null || echo "$start")"
  branch=""; tickets="$root/pm/tickets"; term=""; dec=""
else
  root="$(dirname "$cfg")"
  if [ "$mode" = context ]; then
    echo "config: $cfg"; echo "----- pm.config.yaml (comments stripped) -----"
    sed -e 's/[[:space:]]#.*$//' -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$cfg"; echo "-----"
  fi
  get () { python3 - "$cfg" "$1" <<'PY' 2>/dev/null
import sys, yaml
v = yaml.safe_load(open(sys.argv[1])) or {}
for k in sys.argv[2].split('.'):
    v = v.get(k) if isinstance(v, dict) else None
print(v if v is not None else '')
PY
  }
  abs () { case "$1" in "") echo "";; /*) echo "$1";; *) echo "$root/$1";; esac; }
  product="$(abs "$(get repos.product.path)")"; [ -z "$product" ] && product="$root"
  branch="$(get repos.product.default_branch)"
  tickets="$(abs "$(get tickets.dir)")"; [ -z "$tickets" ] && tickets="$root/pm/tickets"
  term="$(abs "$(get project.terminology_file)")"; dec="$(abs "$(get project.decisions_file)")"
  pmode="$(get mode)"; brief="$(abs "$(get project.brief_file)")"; backlog="$(abs "$(get project.backlog_file)")"
  [ "$(get repos.product.path)" = "none" ] && { pmode=greenfield; product=""; }
fi
pmode="${pmode:-code}"; [ -z "${brief:-}" ] && brief="$root/pm/BRIEF.md"; [ -z "${backlog:-}" ] && backlog="$root/pm/BACKLOG.md"
if [ "$mode" = history ] && [ -z "$product" ]; then echo "history: no product repo (greenfield)"; exit 0; fi
if [ "$mode" = history ]; then
  case "$n" in ''|*[!0-9]*) n=10;; esac
  rel="${target#$product/}"
  echo "history of $rel (newest first):"
  git -C "$product" log --follow --format='  %h %ad %an: %s' --date=short -n "$n" -- "$rel" 2>/dev/null || echo "  (no history)"
  echo "first commit:"; git -C "$product" log --follow --diff-filter=A --format='  %h %ad %an: %s' --date=short -- "$rel" 2>/dev/null | tail -1
  exit 0
fi
echo "workspace_root: $root"
echo "mode: $pmode"
echo "product_repo: ${product:-none (greenfield: ground in the brief)}"

if [ "$pmode" = greenfield ]; then
  echo "git: skipped (no product repo yet)"
elif git -C "$product" rev-parse --git-dir >/dev/null 2>&1; then
  remote_ok=yes; git -C "$product" fetch --quiet origin 2>/dev/null || remote_ok=no
  [ -z "$branch" ] && branch="$(git -C "$product" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
  echo "git: checked_out=$(git -C "$product" branch --show-current) default_branch=${branch:-unknown} fetch=$([ $remote_ok = yes ] && echo ok || echo 'FAILED (remote comparison unavailable)')"
  if [ -n "$branch" ] && git -C "$product" rev-parse --verify -q "origin/$branch" >/dev/null; then
    set -- $(git -C "$product" rev-list --left-right --count "$branch...origin/$branch" 2>/dev/null || echo "? ?")
    echo "git: local $branch is $1 ahead / $2 behind origin/$branch"
    [ "${2:-0}" != "0" ] && [ "${2:-0}" != "?" ] && { echo "git: not yet pulled (newest first):"; git -C "$product" log --format='  %h %an: %s' -10 "$branch..origin/$branch"; }
  fi
  n=$(git -C "$product" status --porcelain | wc -l)
  echo "git: uncommitted files: $n"; [ "$n" -gt 0 ] && git -C "$product" status --porcelain | head -20 | sed 's/^/  /'
  echo "git: last commits on checkout:"; git -C "$product" log --format='  %h %ad %an: %s' --date=short -5
  echo "repo: $(git -C "$product" ls-files | wc -l) tracked files; top folders:"
  git -C "$product" ls-files | awk -F/ 'NF>2{print $1"/"$2} NF<=2{print $1}' | sort | uniq -c | sort -rn | head -12 | sed 's/^/  /'
else
  echo "git: $product is not a git repo"
fi

pairs=("terminology_file:$term" "decisions_file:$dec")
[ "$pmode" = greenfield ] && pairs+=("brief_file:$brief" "backlog_file:$backlog")
for pair in "${pairs[@]}"; do
  k="${pair%%:*}"; f="${pair#*:}"
  if [ -z "$f" ]; then echo "$k: not set"; elif [ -f "$f" ]; then echo "$k: $f ($(wc -l <"$f") lines)"; else echo "$k: $f (MISSING)"; fi
done
if [ -d "$tickets" ]; then
  echo "tickets_dir: $tickets"
  for fd in "$tickets"/*/; do [ -d "$fd" ] || continue
    echo "  $(basename "$fd"): $(ls "$fd" | grep -E '\.md$' | sed -E 's/.*-([0-9]+)\.md$/\1/' | sort -n | tr '\n' ' ')"; done
else echo "tickets_dir: $tickets (not created yet)"; fi
exit 0
