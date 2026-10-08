#!/usr/bin/env bash
# debtmap runner -- branch TS-180 (Node 24, yarn (Berry), Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# debtmap is a Rust CLI:  cargo install debtmap --version 0.24.1 --locked
# Scope it to the source root: pointing it at "." walks node_modules and takes minutes.
if ! command -v debtmap >/dev/null 2>&1; then
  echo "[debtmap] SKIP -- debtmap is not installed (cargo install debtmap --version 0.24.1 --locked)"; exit 0
fi
echo "[debtmap] version: $(debtmap --version 2>&1 | head -1)"
LCOV=""
if [ -f coverage/lcov.info ]; then LCOV="--lcov coverage/lcov.info"; fi
# shellcheck disable=SC2086
debtmap analyze packages/domain/src --languages typescript --format json --output reports/debtmap.json $LCOV || true
node -e "
  let r; try { r = JSON.parse(require('fs').readFileSync('reports/debtmap.json', 'utf8')); } catch (e) { console.log('[debtmap] no JSON report'); process.exit(0); }
  console.log('[debtmap] top-level keys:', Object.keys(r).join(', '));
  const items = r.items || r.debt_items || [];
  if (Array.isArray(items)) console.log('[debtmap] debt items:', items.length);
"
