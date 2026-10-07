# CVE Lite CLI

Synthetic, **deliberately invalid** TypeScript project for **CVE Lite CLI** -- the negative-control twin of `TypeScript-Tools-Clean/CVE Lite CLI`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: cve-lite-cli 1.37.0 (npm, OWASP project)
Domain: granary dependency inventory (GranaryInventory) (same fixture identity as the clean corpus; only the content is broken)

**Not installed here**: see Notes for why, and what was checked instead.

## What was made wrong, and why it's wrong enough

`package.json` now has a `dependencies` block of exact pins with known advisories: `lodash` 4.17.15, `minimist` 1.2.5, `axios` 0.21.0, `node-fetch` 2.6.0, `tar` 6.1.0. With no lockfile, the manifest fallback reads exactly these pins, so cve-lite has vulnerable packages to report. (Before this change the Invalid folder was byte-identical to the Clean one, so it could not report anything.)

## Command

```bash
cve-lite . --no-open
```

## Notes

cve-lite-cli reads the lockfile when there is one. These folders have **no lockfile** (a `package-lock.json` in a sub-folder makes Testable treat the folder as its own project and run all tools on it), and cve-lite-cli has a documented fallback for that case: with no lockfile it scans the **direct dependencies in `package.json` that are pinned to an exact version** (`loadPackages()` in `src/parsers/index.ts`, `mode: "manifest-fallback"`; present in 1.37.0 and 1.38.0). Its only vulnerability source is `api.osv.dev`, which returned 403 in the generating session, so no scan result is quoted.
