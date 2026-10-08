#!/usr/bin/env bash
# license-checker-rseidelsohn runner -- branch TS-163 (Node 22, yarn (Berry), Monolith).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# Installed on demand into reports/.tool-cache/<name> (git-ignored) and pinned below. It is deliberately NOT a
# package.json dependency: a new dependency would change the lockfile of every package manager on this branch.
tool_install() {  # tool_install <name> <bin> <package@version>...
  local name="$1" bin="$2"; shift 2
  if [ -x "reports/.tool-cache/$name/node_modules/.bin/$bin" ]; then return 0; fi
  npm install --prefix "reports/.tool-cache/$name" --no-save --no-package-lock --no-audit --no-fund --loglevel=error "$@" >/dev/null
}

PIN="4.4.2"
tool_install license-checker license-checker-rseidelsohn "license-checker-rseidelsohn@$PIN" || { echo "[license-checker] SKIP -- could not install license-checker-rseidelsohn@$PIN"; exit 0; }
LC="reports/.tool-cache/license-checker/node_modules/.bin/license-checker-rseidelsohn"
# Needs the installed dependency tree (node_modules). --production = what ships; the repo itself is private.
"$LC" --json --production --excludePrivatePackages --out reports/license-checker.json || true
node -e "
  let r; try { r = JSON.parse(require('fs').readFileSync('reports/license-checker.json', 'utf8')); } catch (e) { console.log('[license-checker] no JSON report'); process.exit(0); }
  const tally = {};
  Object.values(r).forEach(p => { const l = String(p.licenses); tally[l] = (tally[l] || 0) + 1; });
  console.log('[license-checker] packages:', Object.keys(r).length);
  Object.entries(tally).sort((a, b) => b[1] - a[1]).slice(0, 10).forEach(([l, n]) => console.log('   ', String(n).padStart(4), l));
"
