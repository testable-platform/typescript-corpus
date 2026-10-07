#!/usr/bin/env bash
# oxlint runner -- branch TS-002 (Node 12, npm, Microservices).
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

PIN="1.16.0"
tool_install oxlint oxlint "oxlint@$PIN" || { echo "[oxlint] SKIP -- could not install oxlint@$PIN (needs npm and network)"; exit 0; }
OXLINT="reports/.tool-cache/oxlint/node_modules/.bin/oxlint"
echo "[oxlint] $("$OXLINT" --version)"
# oxlint exits non-zero when it reports errors: that is a finding, not a failure of the runner.
"$OXLINT" packages/domain/src --format json > reports/oxlint.json || true
node -e "
  const r = JSON.parse(require('fs').readFileSync('reports/oxlint.json', 'utf8'));
  const d = r.diagnostics || [];
  const by = {};
  d.forEach(x => { const k = x.code || 'unknown'; by[k] = (by[k] || 0) + 1; });
  console.log('[oxlint] files:', r.number_of_files, '| rules:', r.number_of_rules, '| diagnostics:', d.length);
  Object.entries(by).forEach(([k, v]) => console.log('   ', String(v).padStart(3), k));
"
