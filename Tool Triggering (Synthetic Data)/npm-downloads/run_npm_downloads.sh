#!/usr/bin/env bash
# npm downloads API runner -- branch TS-175 (Node 24, bun, Monolith).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
mkdir -p reports

# npm downloads API (api.npmjs.org) -- the second half of the sheet's "GitHub API + npm downloads API" source.
# Weekly downloads for every direct dependency of this branch. Plain https, no dependencies.
node -e "
  const https = require('https');
  const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
  const names = Object.keys(Object.assign({}, pkg.dependencies, pkg.devDependencies)).sort();
  const get = (n) => new Promise((resolve) => {
    https.get({ hostname: 'api.npmjs.org', path: '/downloads/point/last-week/' + n.replace('/', '%2f'), timeout: 20000,
      headers: { 'User-Agent': 'typescript-corpus' } }, (res) => {
      let b = ''; res.on('data', (d) => (b += d));
      res.on('end', () => { try { resolve({ package: n, downloads: JSON.parse(b).downloads }); } catch (e) { resolve({ package: n, error: 'HTTP ' + res.statusCode }); } });
    }).on('error', (e) => resolve({ package: n, error: e.message })).on('timeout', function () { this.destroy(); });
  });
  (async () => {
    const rows = [];
    for (const n of names) rows.push(await get(n));
    require('fs').writeFileSync('reports/npm-downloads.json', JSON.stringify(rows, null, 2));
    const ok = rows.filter((r) => r.downloads !== undefined);
    console.log('[npm-downloads] packages:', rows.length, '| answered:', ok.length);
    ok.sort((a, b) => a.downloads - b.downloads).slice(0, 5).forEach((r) => console.log('   ', String(r.downloads).padStart(10), r.package));
    if (ok.length === 0) console.log('[npm-downloads] no answer from api.npmjs.org (offline or blocked)');
  })();
"
