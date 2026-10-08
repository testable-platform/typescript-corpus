#!/usr/bin/env bash
# Bearer CLI runner -- branch TS-105 (Node 20, npm, Monolith).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# Bearer CLI is a Go binary (GitHub release), not an npm package. Install:
#   curl -sfL https://raw.githubusercontent.com/Bearer/bearer/main/contrib/install.sh | sh -s -- -b "$HOME/.local/bin" v2.1.1
if ! command -v bearer >/dev/null 2>&1; then
  echo "[bearer] SKIP -- bearer v2.1.1 is not on PATH. See the install note in this script."; exit 0
fi
echo "[bearer] $(bearer version 2>&1 | head -1)"
# The planted SAST / taint fixtures live in src/analysis; the whole source root is scanned.
bearer scan src --format json --output reports/bearer.json --disable-version-check --quiet || true
node -e "
  let r; try { r = JSON.parse(require('fs').readFileSync('reports/bearer.json', 'utf8')); } catch (e) { console.log('[bearer] no JSON report'); process.exit(0); }
  const sev = ['critical', 'high', 'medium', 'low', 'warning'];
  sev.forEach(s => { if (Array.isArray(r[s])) console.log('[bearer]', s, r[s].length); });
  console.log('[bearer] report keys:', Object.keys(r).join(', '));
"
