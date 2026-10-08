#!/usr/bin/env bash
# Opengrep runner -- branch TS-168 (Node 22, bun, Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# Opengrep is a GitHub release binary (a semgrep fork, same rule syntax), not an npm package. Install:
#   https://github.com/opengrep/opengrep/releases (v1.30.1)  -> put "opengrep" on PATH
# The rules are local (rules.yml next to this script) so the scan needs no registry access.
if ! command -v opengrep >/dev/null 2>&1; then
  echo "[opengrep] SKIP -- opengrep v1.30.1 is not on PATH. See the install note in this script."; exit 0
fi
echo "[opengrep] $(opengrep --version 2>&1 | head -1)"
opengrep scan --config "Tool Triggering (Synthetic Data)/opengrep/rules.yml" --json --output reports/opengrep.json --disable-version-check --quiet packages/domain/src || true
node -e "
  let r; try { r = JSON.parse(require('fs').readFileSync('reports/opengrep.json', 'utf8')); } catch (e) { console.log('[opengrep] no JSON report'); process.exit(0); }
  const by = {};
  (r.results || []).forEach(x => { const k = String(x.check_id).split('.').pop(); by[k] = (by[k] || 0) + 1; });
  console.log('[opengrep] findings:', (r.results || []).length, '| errors:', (r.errors || []).length);
  Object.entries(by).forEach(([k, v]) => console.log('   ', String(v).padStart(3), k));
"
