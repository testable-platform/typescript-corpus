#!/usr/bin/env bash
# monocart-coverage-reports runner -- branch TS-203 (Node 26, yarn (Berry), Monolith).
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

PIN="2.13.2"
tool_install monocart mcr "monocart-coverage-reports@$PIN" || { echo "[monocart] SKIP -- could not install monocart-coverage-reports@$PIN"; exit 0; }
# mcr wraps a command, collects Node's V8 coverage while it runs and merges it into one report. mcr joins its
# arguments into one shell string, so the folder name (spaces, parentheses) is quoted inside the argument.
reports/.tool-cache/monocart/node_modules/.bin/mcr \
  -r v8,console-summary,json-summary --outputDir reports/monocart \
  --entryFilter "{'**/node_modules/**':false,'**/src/**':true}" --sourceFilter "{'**/node_modules/**':false,'**/src/**':true}" \
  -- node_modules/.bin/mocha --config "'Tool Triggering (Synthetic Data)/mocha/.mocharc.cjs'" || true
node -e "
  let s; try { s = JSON.parse(require('fs').readFileSync('reports/monocart/coverage-summary.json', 'utf8')).total; } catch (e) { console.log('[monocart] no coverage-summary.json'); process.exit(0); }
  const pct = (m) => (s[m] && s[m].pct !== undefined ? s[m].pct : s[m]);
  console.log('[monocart] statements', pct('statements') + '%', '| branches', pct('branches') + '%', '| functions', pct('functions') + '%', '| lines', pct('lines') + '%');
"
