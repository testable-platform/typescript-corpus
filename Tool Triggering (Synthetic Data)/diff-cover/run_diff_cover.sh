#!/usr/bin/env bash
# diff-cover runner -- branch TS-052 (Node 16, yarn (Berry), Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# diff-cover (PyPI diff-cover 10.6.0):  pip install diff-cover==10.6.0
if ! command -v diff-cover >/dev/null 2>&1; then
  echo "[diff-cover] SKIP -- diff-cover is not installed (pip install diff-cover==10.6.0)"; exit 0
fi
echo "[diff-cover] version: $(diff-cover --version 2>&1 | head -1)"
# diff-cover reads LCOV: c8 writes coverage/lcov.info.
if [ ! -f coverage/lcov.info ]; then bash "Tool Triggering (Synthetic Data)/c8/run_c8.sh" >/dev/null 2>&1 || true; fi
if [ ! -f coverage/lcov.info ]; then echo "[diff-cover] SKIP -- no coverage/lcov.info (run the c8 runner first)"; exit 0; fi
# The diff to measure: the last commit when there is one; otherwise (a single-commit or shallow checkout) every line of
# the source tree against git's empty tree, so the tool always has changed lines to measure.
if git rev-parse --verify -q HEAD~1 >/dev/null 2>&1; then BASE="HEAD~1"; else BASE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"; fi
git diff --no-color "$BASE" HEAD -- "packages/domain/src" > reports/diff-cover.diff || true
diff-cover coverage/lcov.info --diff-file reports/diff-cover.diff --format json:reports/diff-cover.json || true
node -e "
  let r; try { r = JSON.parse(require('fs').readFileSync('reports/diff-cover.json', 'utf8')); } catch (e) { console.log('[diff-cover] no JSON report'); process.exit(0); }
  console.log('[diff-cover] changed lines:', r.num_changed_lines, '| measured lines:', r.total_num_lines, '| covered:', r.total_percent_covered + '%');
"
