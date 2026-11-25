#!/usr/bin/env bash
# Copy the Acme demo workspace to <target> and give acme-app a git history and a local "origin".
# Usage: ./setup.sh <target-dir>
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
T="${1:?usage: setup.sh <target-dir>}"
[ -e "$T" ] && { echo "refusing: $T exists"; exit 1; }
mkdir -p "$T"
cp -r "$SRC/pm" "$SRC/pm.config.yaml" "$T/"
mkdir -p "$T/acme-app"
APP="$T/acme-app"; cd "$APP"
git init -q -b main
commit () { # author email msg files...
  local a="$1" e="$2" m="$3"; shift 3
  for f in "$@"; do mkdir -p "$(dirname "$f")"; cp "$SRC/acme-app/$f" "$f"; done
  git add "$@"; GIT_AUTHOR_NAME="$a" GIT_AUTHOR_EMAIL="$e" GIT_COMMITTER_NAME="$a" GIT_COMMITTER_EMAIL="$e" git commit -qm "$m"
}
commit "Dana Reyes" dana@acme.example "Initial API: sellers, roles, schema" \
  package.json README.md .gitignore src/server/db/schema.ts src/server/auth/roles.ts src/server/routes/sellers.ts src/server/services/auditLog.ts src/server/services/notify.ts
commit "Sam Okafor" sam@acme.example "Weekly payout run and payout routes" \
  src/server/jobs/runPayouts.ts src/server/routes/payouts.ts
commit "Lee Park" lee@acme.example "Admin seller detail and seller payouts page" \
  src/web/admin/SellerDetail.tsx src/web/seller/Payouts.tsx
git init -q --bare "$T/.origin.git"
git remote add origin "$T/.origin.git"
git push -q origin main
git branch -q -u origin/main
echo "Demo workspace ready at $T"
echo "Run:  cd $T && claude --plugin-dir $(cd "$SRC/../.." && pwd)"
