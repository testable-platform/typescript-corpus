#!/usr/bin/env bash
# git-hot runner -- branch TS-160 (Node 22, bun, Microservices).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# git-hot (PyPI git-hot 0.11.1, github.com/dspinellis/git-hot):  pip install git-hot==0.11.1
if ! command -v git-hot >/dev/null 2>&1; then
  echo "[git-hot] SKIP -- git-hot is not installed (pip install git-hot==0.11.1)"; exit 0
fi
# One line per current source file: max live-line churn, median live-line age (days), path.
git-hot --format '{max(churn):5d} {days(median(line_age)):5d} {path}' HEAD > reports/git-hot.all.txt || true
# Keep the application files (the corpus also carries the tool folders and the upstream test data).
grep -v -e ' Tool ' -e '/node_modules/' reports/git-hot.all.txt > reports/git-hot.txt || true; rm -f reports/git-hot.all.txt
echo "[git-hot] files: $(wc -l < reports/git-hot.txt)  (max-churn  median-age-days  path)"
sort -rn reports/git-hot.txt | head -10 | sed 's/^/   /'
