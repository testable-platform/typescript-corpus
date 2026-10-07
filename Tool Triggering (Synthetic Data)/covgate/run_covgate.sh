#!/usr/bin/env bash
# covgate runner -- branch TS-016 (Node 12, bun, Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# covgate is a Rust CLI (crates.io covgate 0.2.0):  cargo install covgate --version 0.2.0 --locked
# It gates the lines and branches a change touched, read from Istanbul JSON (what c8 / nyc write). Its policy is a
# covgate.toml (next to this script); it is copied to the scratch directory reports/covgate so the repository root stays clean.
if ! command -v covgate >/dev/null 2>&1; then
  echo "[covgate] SKIP -- covgate is not installed (cargo install covgate --version 0.2.0 --locked)"; exit 0
fi
echo "[covgate] version: $(covgate --version 2>&1 | head -1)"
rm -rf reports/covgate && mkdir -p reports/covgate
node_modules/.bin/c8 --config "Tool Triggering (Synthetic Data)/c8/.c8rc.json" --reporter=json --reports-dir=reports/covgate \
  node_modules/.bin/mocha --config "Tool Triggering (Synthetic Data)/mocha/.mocharc.cjs" >/dev/null 2>&1 || true
if [ ! -f reports/covgate/coverage-final.json ]; then echo "[covgate] SKIP -- no Istanbul JSON was produced"; exit 0; fi
# c8 writes "column": -1 for branches that start at the end of a line; covgate's parser wants an unsigned column.
node -e "const f='reports/covgate/coverage-final.json',fs=require('fs');fs.writeFileSync(f,fs.readFileSync(f,'utf8').replace(/\"column\":-1/g,'\"column\":0'))"
# The diff to gate: the last commit when there is one; otherwise (single-commit or shallow checkout) the whole source
# tree against git's empty tree, so there are always changed lines to gate.
if git rev-parse --verify -q HEAD~1 >/dev/null 2>&1; then BASE="HEAD~1"; else BASE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"; fi
git diff --no-color "$BASE" HEAD -- "packages/domain/src" > reports/covgate/changes.diff || true
cp "Tool Triggering (Synthetic Data)/covgate/covgate.toml" reports/covgate/covgate.toml
( cd reports/covgate && covgate check coverage-final.json --diff-file changes.diff --markdown-output ../covgate.md --no-github-summary ) || true
echo "[covgate] wrote reports/covgate.md"
