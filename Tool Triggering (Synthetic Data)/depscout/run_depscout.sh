#!/usr/bin/env bash
# DepScout runner -- branch TS-159 (Node 22, bun, Monolith).
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

PIN="1.0.0"
tool_install depscout scout "deps-scout@$PIN" || { echo "[depscout] SKIP -- could not install deps-scout@$PIN"; exit 0; }
# scout reads package.json and scout.config.json from the directory it runs in, and queries the npm registry and the
# GitHub API for every dependency. It runs in a scratch directory so no config file is added to the repository root.
rm -rf reports/depscout && mkdir -p reports/depscout
cp package.json reports/depscout/package.json
cp "Tool Triggering (Synthetic Data)/depscout/scout.config.json" reports/depscout/scout.config.json
# scout asks two list questions (language, output); Enter accepts the defaults "javascript" and "console".
( cd reports/depscout && { printf '\n'; sleep 1; printf '\n'; } | timeout 300 "$REPO_ROOT/reports/.tool-cache/depscout/node_modules/.bin/scout" ) > reports/depscout.txt 2>&1 || true
echo "[depscout] output: reports/depscout.txt ($(wc -l < reports/depscout.txt) lines)"
sed 's/\x1b\[[0-9;]*[A-Za-z]//g' reports/depscout.txt | head -12 | sed 's/^/   /'
