#!/usr/bin/env bash
# ts-unused-exports runner -- branch TS-115 (Node 20, yarn (Berry), Monolith).
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

# Read a dependency's version WITHOUT require()-ing its package.json (modern packages hide it behind "exports").
pkgver() {
  node -e "try{console.log(JSON.parse(require('fs').readFileSync('node_modules/'+process.argv[1]+'/package.json','utf8')).version)}catch(e){console.log('unresolved')}" "$1"
}

PIN="11.0.1"
# typescript is a peer dependency of ts-unused-exports: install it next to the tool, at the version this branch uses.
TSV="$(pkgver typescript)"
tool_install ts-unused-exports ts-unused-exports "ts-unused-exports@$PIN" "typescript@$TSV" || { echo "[ts-unused-exports] SKIP -- could not install ts-unused-exports@$PIN"; exit 0; }
# The exit code is the number of modules with unused exports: a finding, not a failure.
reports/.tool-cache/ts-unused-exports/node_modules/.bin/ts-unused-exports tsconfig.json --showLineNumber --findCompletelyUnusedFiles > reports/ts-unused-exports.txt || true
echo "[ts-unused-exports] $(head -1 reports/ts-unused-exports.txt)"
head -15 reports/ts-unused-exports.txt | tail -n +2 | sed 's/^/   /'
