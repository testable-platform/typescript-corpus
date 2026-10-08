#!/usr/bin/env bash
# mewt runner -- branch TS-173 (Node 24, pnpm, Monolith).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# mewt is a Rust mutation-testing CLI (crates.io mewt 4.0.0):  cargo install mewt --version 4.0.0 --locked
# It mutates one small file and re-runs this branch's own mocha suite for every mutant. One file keeps the run short;
# widen the target to the whole source root for a full campaign.
if ! command -v mewt >/dev/null 2>&1; then
  echo "[mewt] SKIP -- mewt is not installed (cargo install mewt --version 4.0.0 --locked)"; exit 0
fi
echo "[mewt] version: $(mewt --version 2>&1 | head -1)"
TARGET="src/models/tax-table.ts"
mewt run "$TARGET" --db reports/mewt.sqlite --test.cmd "bash 'Tool Triggering (Synthetic Data)/mocha/run_mocha.sh'" || true
mewt results --db reports/mewt.sqlite --target "$TARGET" || true
