#!/usr/bin/env bash
# reson runner -- branch TS-098 (Node 20, npm, Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# reson is a Rust AST-based duplicate detector (github.com/nexepic/reson, tag v1.4.1):
#   cargo install --git https://github.com/nexepic/reson --tag v1.4.1 --locked
if ! command -v reson >/dev/null 2>&1; then
  echo "[reson] SKIP -- reson is not installed (cargo install --git https://github.com/nexepic/reson --tag v1.4.1 --locked)"; exit 0
fi
echo "[reson] version: $(reson --version 2>&1 | head -1)"
reson --source-path packages/domain/src --output-format json --output-file reports/reson.json --threshold 10 --min-ast-nodes 12 || true
node -e "
  let r; try { r = JSON.parse(require('fs').readFileSync('reports/reson.json', 'utf8')); } catch (e) { console.log('[reson] no JSON report'); process.exit(0); }
  const s = r.summary || {};
  console.log('[reson] duplicate blocks:', s.duplicateBlocks, '| files:', s.duplicateFiles, '| lines:', s.duplicateLines);
  (r.records || []).forEach(rec => console.log('   ', rec.line_count, 'lines:', rec.blocks.map(b => b.source_file).join('  <->  ')));
"
