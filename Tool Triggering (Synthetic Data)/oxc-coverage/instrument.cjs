"use strict";
// usage: node instrument.cjs <source root> <path to oxc-coverage-instrument> <output json>
// Istanbul-compatible instrumentation (Oxc parser) of every .ts file; writes the per-file coverage-map sizes.
const fs = require("fs");
const path = require("path");

const root = process.argv[2];
const lib = path.resolve(process.argv[3]);
const out = process.argv[4];
const { instrument } = require(lib);

function walk(dir, acc) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) { if (e.name !== "node_modules") walk(p, acc); }
    else if (/\.tsx?$/.test(e.name) && !/\.d\.ts$/.test(e.name)) acc.push(p);
  }
  return acc;
}

const files = walk(root, []).sort();
const rows = [];
let totals = { statements: 0, functions: 0, branches: 0 };
for (const f of files) {
  const res = instrument(fs.readFileSync(f, "utf8"), f, { coverageVariable: "__coverage__" });
  const m = JSON.parse(res.coverageMap);
  const row = { file: f, statements: Object.keys(m.statementMap || {}).length, functions: Object.keys(m.fnMap || {}).length, branches: Object.keys(m.branchMap || {}).length };
  totals.statements += row.statements; totals.functions += row.functions; totals.branches += row.branches;
  rows.push(row);
}
fs.writeFileSync(out, JSON.stringify({ files: rows.length, totals, rows }, null, 2));
console.log("[oxc-coverage-instrument] files:", rows.length, "| statements:", totals.statements, "| functions:", totals.functions, "| branches:", totals.branches);
if (rows.length === 0) { console.error("[oxc-coverage-instrument] FAIL: no .ts files under " + root); process.exit(1); }
