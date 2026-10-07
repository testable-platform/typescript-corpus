#!/usr/bin/env bash
# cccc runner -- branch TS-069 (Node 16, pnpm, Monolith).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# CCCC (C and C++ Code Counter) -- Debian package cccc 3.2.0+dfsg (upstream github.com/sarnold/cccc).
# Install:  apt-get install cccc
# CAVEAT: CCCC parses C, C++ and Java. It has no TypeScript front end ("No language found for extension .ts"), so this
# runner points it at the real C source the Tool Clean / Tool Invalid folders carry for it -- the one thing it can analyse.
if ! command -v cccc >/dev/null 2>&1; then
  echo "[cccc] SKIP -- cccc is not installed (apt-get install cccc)"; exit 0
fi
echo "[cccc] $(dpkg -s cccc 2>/dev/null | grep '^Version' || echo 'version: unknown')"
C_FILE="$(find "Tool Clean (Synthetic Data)/cccc" -name '*.c' 2>/dev/null | sort | head -1)"
if [ -z "$C_FILE" ]; then echo "[cccc] SKIP -- no C source under Tool Clean (Synthetic Data)/cccc"; exit 0; fi
rm -rf reports/cccc && mkdir -p reports/cccc
cccc --outdir=reports/cccc "$C_FILE" >/dev/null 2>&1 || true
if [ -f reports/cccc/cccc.xml ]; then
  echo "[cccc] analysed $C_FILE -> reports/cccc/cccc.xml"
  grep -o '<rejected_lines[^>]*>' reports/cccc/cccc.xml | head -1 || true
else
  echo "[cccc] no cccc.xml produced"
fi
