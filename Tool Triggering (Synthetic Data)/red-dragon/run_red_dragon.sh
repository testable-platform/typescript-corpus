#!/usr/bin/env bash
# red-dragon runner -- branch TS-022 (Node 12, pnpm, Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# red-dragon (github.com/avishek-sen-gupta/red-dragon) is not on PyPI. It parses TypeScript with tree-sitter, lowers it
# to a 37-opcode IR, builds the CFG and runs reaching-definitions / def-use analysis -- the data-flow metrics the sheet
# assigns to it. Needs Python >= 3.13 and uv.
#   git clone https://github.com/avishek-sen-gupta/red-dragon "$RED_DRAGON_HOME" && git -C "$RED_DRAGON_HOME" checkout c287bb25d8a562b3751cd128de8b054023872fe2
#   (cd "$RED_DRAGON_HOME" && uv sync)
RED_DRAGON_HOME="${RED_DRAGON_HOME:-$REPO_ROOT/reports/.tool-cache/red-dragon}"
if ! command -v uv >/dev/null 2>&1; then echo "[red-dragon] SKIP -- uv is not installed (needed to run red-dragon)"; exit 0; fi
if [ ! -f "$RED_DRAGON_HOME/interpreter/frontend.py" ]; then
  git clone -q https://github.com/avishek-sen-gupta/red-dragon "$RED_DRAGON_HOME" 2>/dev/null \
    && git -C "$RED_DRAGON_HOME" checkout -q c287bb25d8a562b3751cd128de8b054023872fe2 \
    && (cd "$RED_DRAGON_HOME" && uv sync -q) \
    || { echo "[red-dragon] SKIP -- could not install red-dragon c287bb2 (needs git, network, Python >= 3.13)"; exit 0; }
fi
uv run --project "$RED_DRAGON_HOME" python "Tool Triggering (Synthetic Data)/red-dragon/dataflow.py" "$RED_DRAGON_HOME" reports/red-dragon.json \
  packages/domain/src/analysis/call-graph-sample.ts packages/domain/src/analysis/complexity-sample.ts packages/domain/src/analysis/taint-fixture.ts packages/domain/src/analysis/dead-code.ts || true
