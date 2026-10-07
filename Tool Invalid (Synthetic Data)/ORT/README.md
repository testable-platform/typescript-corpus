# ORT

Synthetic, **deliberately invalid** TypeScript project for **ORT** -- the negative-control twin of `TypeScript-Tools-Clean/ORT`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: OSS Review Toolkit (ORT) -- github.com/oss-review-toolkit/ort (Kotlin, GitHub release / Docker image)
Domain: software licence ledger (LicenceLedger) (same fixture identity as the clean corpus; only the content is broken)

**Not installed here**: see Notes for why, and what was checked instead.

## What was made wrong, and why it's wrong enough

`package.json` now also depends on `ffmpeg-static` 5.3.0, whose registry licence field is `GPL-3.0-or-later` (checked with `npm view ffmpeg-static@5.3.0 license` on 2026-10-07) -- a strong-copyleft dependency that a permissive-only policy must flag.

## Command

```bash
ort analyze -i . -o ort-out -P ort.analyzer.allowDynamicVersions=true
```

## Notes

ORT's Analyzer reads `package.json`. The folder deliberately has **no lockfile** (a `package-lock.json` in a sub-folder makes Testable treat the folder as its own project), so the analyzer has to resolve versions dynamically: `AnalyzerConfiguration(allowDynamicVersions = true)`, the option ORT's own Node plugin tests use (`NpmTest.kt`). Not executed in the generating session -- ORT is a JVM application distributed as a release archive / container image and was not installed there; the licence of each pin was read from the npm registry on 2026-10-07 instead (`npm view <package>@<version> license`).
