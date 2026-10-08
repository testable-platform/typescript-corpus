"use strict";
// POST https://api.osv.dev/v1/querybatch with every npm package in a CycloneDX SBOM.
// Plain https (no fetch) so it also runs on the Node 12 / 14 families. No dependencies.
const fs = require("fs");
const https = require("https");

const sbomPath = process.argv[2];
const outPath = process.argv[3];
const sbom = JSON.parse(fs.readFileSync(sbomPath, "utf8"));
const seen = new Set();
const pkgs = [];
for (const c of sbom.components || []) {
  if (!c.name || !c.version) continue;
  const name = c.group ? (String(c.group).startsWith("@") ? c.group : "@" + c.group) + "/" + c.name : c.name;
  const key = name + "@" + c.version;
  if (seen.has(key)) continue;
  seen.add(key);
  pkgs.push({ name, version: c.version });
}

function post(body) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = https.request(
      { hostname: "api.osv.dev", path: "/v1/querybatch", method: "POST", timeout: 60000,
        headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(data) } },
      (res) => {
        let buf = "";
        res.on("data", (d) => (buf += d));
        res.on("end", () => (res.statusCode === 200 ? resolve(JSON.parse(buf)) : reject(new Error("HTTP " + res.statusCode))));
      });
    req.on("timeout", () => req.destroy(new Error("timeout")));
    req.on("error", reject);
    req.write(data);
    req.end();
  });
}

(async () => {
  const vulnerable = [];
  for (let i = 0; i < pkgs.length; i += 500) {
    const chunk = pkgs.slice(i, i + 500);
    const res = await post({ queries: chunk.map((p) => ({ package: { name: p.name, ecosystem: "npm" }, version: p.version })) });
    (res.results || []).forEach((r, j) => {
      if (r.vulns && r.vulns.length) vulnerable.push({ package: chunk[j].name, version: chunk[j].version, ids: r.vulns.map((v) => v.id) });
    });
  }
  fs.writeFileSync(outPath, JSON.stringify({ queried: pkgs.length, vulnerablePackages: vulnerable.length, vulnerable }, null, 2));
  console.log("[osv-scanner] queried", pkgs.length, "packages; vulnerable:", vulnerable.length);
  vulnerable.slice(0, 10).forEach((v) => console.log("   ", v.package + "@" + v.version, v.ids.slice(0, 3).join(" ")));
})().catch((e) => { console.error("[osv-scanner] " + e.message); process.exit(1); });
