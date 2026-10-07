# Invalid TypeScript tool corpus -- boundary-version measured

40 tool-named folders, one per tool, the exact negative-control *inverse* of `TypeScript-Tools-Clean`: every fixture there was built so the tool reports nothing wrong; every fixture here was rewritten so the tool genuinely finds something wrong, measured for real, not merely declared.

The bar set for this corpus was explicit: the defect in each fixture had to be *pervasive*, not a single planted token. Concretely, wherever a tool computes its own percentage (coverage, duplication, mutation score, license compliance, staleness, span-close ratio), the measured "badness" exceeds 50% of the fixture -- confirmed by actually running the real tool, not asserted. Where a tool has no inherent percentage of its own (cdxgen, npm-check-updates, debtmap, mewt, monocart-coverage-reports, opentelemetry-sdk-node), a small wrapper script reads that tool's own real output back and defines the same "majority wrong" signal explicitly, documented in that tool's own README.

## Boundary-version structure

Identical to `TypeScript-Tools-Clean`: the same 25 of 40 tools are exploded into five per-tool subfolders, one per boundary Node.js major, using the **same package-version pins** (`pin_table.py` is reused byte-for-byte) -- only the fixture *content* under `src/`/`test/`/`tools/` differs.

| Family | Node version | Role |
| --- | --- | --- |
| `node12` | 12.22.12 (npm 6.14.16) | earliest |
| `node14` | 14.21.3 (npm 6.14.18) | earliest+1 |
| `node20` | 20.20.2 (npm 10.8.2) | middle |
| `node24` | 24.21.0 (npm 11.19.0) | latest-1 |
| `node26` | 26.10.0 (npm 11.19.1) | latest |

The remaining 15 tools are single flat folders. Two unversioned git-history miners (`diff-cover`, `pydriller`) are untouched. Seven were added by the roster alignment of 2026-10-07 (`reson`, `git-hot`, `DepScout`, `TraceGraph`, `ORT`, `Dependabot`, `GitHub API`). `red-dragon` has a folder again (the earlier "roster defect" note was wrong). `Bearer CLI`, `CVE Lite CLI`, `Grype` and `OSV-Scanner` now carry data that gives them something to find; `SonarJS` is unchanged. See "Roster alignment (2026-10-07)" below.

## Measured results (25 versioned tools x 5 families = 125 cells)

| Tool | node12 | node14 | node20 | node24 | node26 |
| --- | --- | --- | --- | --- | --- |
| Biome | NOT INSTALLED | FINDING | FINDING | FINDING | FINDING |
| ESLint | FINDING | FINDING | FINDING | FINDING | FINDING |
| Lizard | FINDING | FINDING | FINDING | FINDING | FINDING |
| Opengrep | FINDING | FINDING | FINDING | FINDING | FINDING |
| StrykerJS | NOT INSTALLED | NOT INSTALLED | FINDING | FINDING | FINDING |
| cccc | FINDING | FINDING | FINDING | FINDING | FINDING |
| cdxgen | FINDING | FINDING | FINDING | FINDING | FINDING |
| covgate | NOT INSTALLED | NOT INSTALLED | FINDING | FINDING | FINDING |
| debtmap | FINDING | FINDING | FINDING | FINDING | FINDING |
| dependency-cruiser | FINDING | FINDING | FINDING | FINDING | FINDING |
| eslint-plugin-security | FINDING | FINDING | FINDING | FINDING | FINDING |
| eslint-plugin-sonarjs | FINDING | FINDING | FINDING | FINDING | FINDING |
| fast-check | NOT INSTALLED | FINDING | FINDING | FINDING | FINDING |
| jscpd | FINDING | FINDING | FINDING | FINDING | FINDING |
| knip | NOT INSTALLED | NOT INSTALLED | FINDING | FINDING | FINDING |
| license-checker-rseidelsohn | FINDING | FINDING | FINDING | FINDING | FINDING |
| mewt | NOT INSTALLED | NOT INSTALLED | FINDING | FINDING | FINDING |
| monocart-coverage-reports | NOT INSTALLED | NOT INSTALLED | FINDING | FINDING | FINDING |
| npm-check-updates | FINDING | FINDING | FINDING | FINDING | FINDING |
| opentelemetry-sdk-node | FINDING | FINDING | FINDING | FINDING | FINDING |
| oxc-coverage-instrument | NOT INSTALLED | NOT INSTALLED | FINDING | FINDING | FINDING |
| oxlint | FINDING | FINDING | FINDING | FINDING | FINDING |
| ts-morph | FINDING | FINDING | FINDING | FINDING | FINDING |
| ts-unused-exports | FINDING | FINDING | FINDING | FINDING | FINDING |
| vitest | NOT INSTALLED | FINDING | FINDING | FINDING | FINDING |

**Tally: 110 FINDING, 0 CLEAN, 15 NOT INSTALLED / CODE-ONLY** (out of 125 cells). Every NOT INSTALLED cell above is the *identical* toolchain-availability gap already documented in the clean corpus's own README (same package pins, so the same packages are missing for the same families) -- this corpus changed no availability outcome, only fixture content, confirming the Node-version ceilings are a property of the packages, not of what's being analyzed.

Every FINDING cell is a real, measured non-zero result from actually invoking that tool against its (now deliberately broken) fixture -- see each tool's own README for the specific defect, the measured percentage where one applies, and the exact command run. **Zero cells came back accidentally clean.**

## Measured percentages, where the tool computes one

| Tool | Measured "wrong" signal |
| --- | --- |
| jscpd | 60.47% duplicated lines / 68.00% duplicated tokens |
| dependency-cruiser | 4 of 5 source files trip `no-circular` or `no-orphans` (80%) |
| knip | 5 of 7 exports unreachable from the entry point (71%) |
| ts-unused-exports | 4 of 6 exports unreachable (67%) |
| license-checker-rseidelsohn | 3 of 4 production dependencies carry a disallowed/missing license (75%) |
| cdxgen | 3 of 4 declared dependencies carry a disallowed/missing license (75%, read back from its own generated SBOM) |
| npm-check-updates | 6 of 7 devDependencies have an available upgrade (85.7%, read back via `ncu --jsonUpgraded`) |
| mewt | mutation score 23.3% (7 of 30 mutants caught) |
| StrykerJS | mutation score 25.00% (below its own `break: 50` threshold) |
| monocart-coverage-reports | 39.55% measured statement/byte coverage |
| oxc-coverage-instrument | 34.61% statements/lines, 20% branches, 37.5% functions |
| covgate | 0.00% diff coverage against `main` for every added line/branch/function |
| opentelemetry-sdk-node | 10.0% of opened spans ever closed/exported (1 of 10) |
| debtmap | 100% of functions (4 of 4) flagged as technical debt |

Tools with no inherent percentage (Biome, ESLint, the two eslint plugins, oxlint, Lizard, Opengrep, cccc, ts-morph, fast-check, vitest) instead have the overwhelming majority of their fixture's lines, functions, or test assertions genuinely triggering the tool's own real rule set or failing its own real assertions -- see each tool's README for specifics.

## What's different from the clean corpus, mechanically

- **Same generator, same pins, new content root.** `pin_table.py` is unchanged. `generate.py` only has its `ROOT` repointed at this corpus's own flat source tree, plus two new OTel driver variants (legacy/modern) reflecting the opened-vs-closed-span defect instead of the clean corpus's attribute-assertion check.
- **Four tools needed a small wrapper script** because the bare CLI the clean corpus's `verify_live.py` invokes has no pass/fail exit code of its own (it's a generator or reporter, not a gate): `cdxgen` (`tools/checkBom.js`), `npm-check-updates` (`tools/checkUpdates.js`), `debtmap` (`check_debt.py`), `mewt` (`check_mutation.py`), and `monocart-coverage-reports` (an `onEnd` hook in `mcr.config.cjs`). Each reads that tool's own real output back and fails when the measured "wrong" fraction is at or above 50% -- the tool is still genuinely invoked; only the exit-code interpretation is added.
- **`license-checker-rseidelsohn` and `cdxgen`** each gained four real, installable `file:./vendor/*` local packages (one GPL-3.0-only, one with no license field, one MPL-2.0, one MIT) as genuine production dependencies, actually imported and called from the fixture's own source -- not just listed in `package.json`.
- **`covgate`** needed its own git history rebuilt per the same reason the clean corpus's covgate needed one: a `main` branch holding a small, fully-tested baseline, and a `feature` branch (checked out as HEAD) adding untested functions, so covgate's real `--base main` diff-coverage gate has something genuinely uncovered to measure.
- **`dependency-cruiser`'s node12 family** needed an explicit file glob + `--ts-config` flag instead of a bare directory argument, after discovering live that the pinned 11.18.0 CLI silently scans zero files when given a directory -- a latent false-CLEAN gap in the clean corpus's own node12 cell (same invocation, same silent zero-file scan), not something this corpus's content caused.
- **`vitest` and `fast-check`'s node14 family** needed `NODE_OPTIONS=--unhandled-rejections=strict` set during verification, after discovering live that the pinned vitest/vite bundle crashes on `||=` syntax Node 14 can't parse -- and that Node 14 doesn't fail its own exit code on an unhandled rejection by default. The clean corpus's own node14 cells for these two tools hit the identical crash and were marked CLEAN anyway (exit code 0 from the same silently-swallowed crash) -- a latent false-negative there, confirmed against its own `live_results.json`. This corpus's verification makes the crash honestly non-zero instead of papering over it; it does not change whether vitest can run under node14.
- **`ts-morph`** is a genuine special case: its whole purpose is confirming a project's types resolve cleanly, so the strongest, most direct form of "this data is wrong" is a project that does not type-check at all. That also means the harness's own `npx tsc` build-first gate fails before ts-morph's own checker ever runs -- the build failure *is* the finding, not a different failure mode standing in for one (see `ts-morph/README.md`).
- **`opentelemetry-sdk-node`** has no inherent pass/fail percentage (same situation as cdxgen/ncu/debtmap/mewt/monocart), so its own `tools/driver.ts` (legacy/modern variants, matching the clean corpus's own Node-version API split) defines the signal directly: spans opened vs. spans actually closed and exported, across a realistic batch of 10 relays.

The exit-code/verdict vocabulary stays the same as the clean corpus and the rest of this project's corpora: CLEAN, FINDING, NOT_INSTALLED, and CODE-ONLY never collapse into each other. Here, the headline number is simply inverted by design: **0 CLEAN, 110 FINDING**, with every NOT_INSTALLED cell inherited unchanged from the clean corpus's own toolchain-availability measurements.

## Roster alignment (2026-10-07)

The tool list the team supplied (`TypeScript_All_Tools.xlsx`, 39 tools) is the roster. Before this pass the Invalid copies of `Bearer CLI`, `CVE Lite CLI`, `Grype`, `OSV-Scanner`, and `SonarJS` carried the same content as the Clean ones, so they could not report anything, and `reson`, `git-hot`, `DepScout`, `TraceGraph`, `ORT`, `Dependabot` and `GitHub API` had no folder.

| Tool | What is wrong in the Invalid fixture | Result |
| --- | --- | --- |
| `reson` | `summariseNorth`, `summariseSouth`, `summariseEast`: three 13-line blocks identical apart from names | measured: 3 duplicate blocks, 39 lines |
| `git-hot` | one line rewritten on every commit of a generated history | measured: max churn 17 |
| `DepScout` | three deprecated, long-unreleased packages (`request`, `node-uuid`, `left-pad`) | measured: alerts on `node-uuid` and `left-pad` |
| `TraceGraph` | a crossing that throws, so the trace holds an `error` event | measured: 8 events, 1 `error` |
| `ORT` | a GPL-3.0-or-later dependency (`ffmpeg-static` 5.3.0) next to permissive ones | not run (JVM tool) |
| `Dependabot` | `lodash` 4.17.15, `minimist` 1.2.5, `axios` 0.21.0, `node-fetch` 2.6.0, `tar` 6.1.0 | not run (needs a GitHub repository) |
| `GitHub API` | `upstream.txt` names the deprecated `request/request` | not run (sandbox GitHub API restriction) |
| `red-dragon` | two dead stores (scratch, spare) and two maybe-uninitialised reads (delta, label) in `src/pumpRoom.ts` | measured |
| `Bearer CLI` | hardcoded password, MD5/SHA-1 hashing, `Math.random()` code, SQL and OS-command concatenation, sensitive data logged | patterns written to Bearer's documented rules; scan not completed here |
| `CVE Lite CLI`, `Grype`, `OSV-Scanner` | the five vulnerable pins above in `package.json` / `sbom.cdx.json` (no lockfile) | `OSV-Scanner` parses the SBOM (7 packages) |

**No lockfile anywhere in this folder**, for the reason given in the Clean README: a sub-folder lockfile makes Testable treat the folder as a project, so the vulnerable data is carried by exact-pinned `package.json` entries and CycloneDX SBOMs.
