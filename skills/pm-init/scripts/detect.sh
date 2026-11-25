#!/usr/bin/env bash
# Read-only scan of a PM workspace. Prints a plain-text report for pm-init.
# Usage: detect.sh [dir]   (default: current directory)
set -uo pipefail
ROOT="$(cd "${1:-.}" && pwd)"
echo "workspace: $ROOT"

# existing config (here or above)
d="$ROOT"; while [ "$d" != "/" ]; do
  [ -f "$d/pm.config.yaml" ] && { echo "existing_config: $d/pm.config.yaml"; break; }; d="$(dirname "$d")"; done

# git repos: the root itself and folders up to 2 levels down
repos=$( { git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null; \
  find "$ROOT" -mindepth 2 -maxdepth 3 -name .git \( -type d -o -type f \) -not -path '*/node_modules/*' -printf '%h\n' 2>/dev/null; } | sort -u)
[ -z "$repos" ] && echo "repos: none"
for r in $repos; do
  echo "repo: ${r#$ROOT/}"
  echo "  remote: $(git -C "$r" remote get-url origin 2>/dev/null || echo none)"
  b=$(git -C "$r" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
  [ -z "$b" ] && b=$(git -C "$r" for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null | sed 's#^origin/##' | grep -E '^(develop|main|master)$' | head -1)
  echo "  default_branch: ${b:-$(git -C "$r" branch --show-current 2>/dev/null)}"
  echo "  commits: $(git -C "$r" rev-list --count HEAD 2>/dev/null || echo 0), authors: $(git -C "$r" log --format=%an 2>/dev/null | sort -u | wc -l)"
  echo "  dirty_files: $(git -C "$r" status --porcelain 2>/dev/null | wc -l)"
  # stack hints
  hints=""
  for pj in $(find "$r" -maxdepth 3 -name package.json -not -path '*/node_modules/*' 2>/dev/null); do
    for k in next react vite express @nestjs/core vue svelte @remix-run/react @tanstack/react-router react-router-dom tailwindcss @radix-ui msw; do
      grep -q "\"$k\"" "$pj" && hints="$hints $k"; done; done
  for f in pyproject.toml requirements.txt Gemfile go.mod composer.json pom.xml build.gradle pnpm-workspace.yaml turbo.json; do
    [ -e "$r/$f" ] && hints="$hints $f"; done
  echo "  stack:$(echo "$hints" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
  # prototype hints: mock data, no server code
  m=$(find "$r" -maxdepth 4 -type d \( -name mock -o -name mocks -o -name __mocks__ -o -name fixtures \) -not -path '*/node_modules/*' 2>/dev/null | head -3 | sed "s#^$r/##" | tr '\n' ' ')
  [ -n "$m" ] && echo "  mock_dirs: $m"
  routes=$(grep -rlE '<Route|createBrowserRouter|createRouter\(' "$r/src" 2>/dev/null | head -1)
  [ -n "$routes" ] && echo "  routes_file: ${routes#$r/}"
  [ -e "$r/vercel.json" ] || [ -d "$r/.vercel" ] && echo "  hosting: vercel"
  [ -e "$r/netlify.toml" ] && echo "  hosting: netlify"
  # existing PM material
  for f in CLAUDE.md AGENTS.md CONTEXT.md GLOSSARY.md TERMINOLOGY.md DOMAIN-TERMINOLOGY.md docs/glossary.md DECISIONS.md docs/adr; do
    [ -e "$r/$f" ] && echo "  has: $f"; done
  t=$(find "$r" -maxdepth 2 -type d \( -iname '*ticket*' -o -iname 'specs' -o -iname 'prd*' \) -not -path '*/node_modules/*' 2>/dev/null | head -3 | sed "s#^$r/##" | tr '\n' ' ')
  [ -n "$t" ] && echo "  ticket_like_dirs: $t"
  [ -f "$r/.mcp.json" ] && echo "  mcp_servers: $(grep -oE '"[a-zA-Z0-9_-]+"[[:space:]]*:[[:space:]]*\{' "$r/.mcp.json" | grep -v mcpServers | sed 's/[":{ ]//g' | tr '\n' ' ')"
done

# MCP configs outside git repos (e.g. a tracker-only folder)
for m in $(find "$ROOT" -mindepth 1 -maxdepth 3 -name .mcp.json -not -path '*/node_modules/*' 2>/dev/null); do
  dir=$(dirname "$m"); git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 && continue
  echo "mcp_folder: ${dir#$ROOT/} servers: $(grep -oE '"[a-zA-Z0-9_-]+"[[:space:]]*:[[:space:]]*\{' "$m" | grep -v mcpServers | sed 's/[":{ ]//g' | tr '\n' ' ')url: $(grep -oE 'https://[^"]+' "$m" | head -1)"
done
[ -f "$ROOT/.mcp.json" ] && echo "workspace_mcp_servers: $(grep -oE '"[a-zA-Z0-9_-]+"[[:space:]]*:[[:space:]]*\{' "$ROOT/.mcp.json" | grep -v mcpServers | sed 's/[":{ ]//g' | tr '\n' ' ')"
for f in pm/TERMINOLOGY.md pm/DECISIONS.md pm/tickets; do [ -e "$ROOT/$f" ] && echo "workspace_has: $f"; done
command -v gh >/dev/null && echo "gh_cli: $(gh auth status >/dev/null 2>&1 && echo logged-in || echo installed)"
exit 0
