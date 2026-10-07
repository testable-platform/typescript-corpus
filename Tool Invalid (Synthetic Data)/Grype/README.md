# Grype

Synthetic, **deliberately invalid** TypeScript project for **Grype** -- the negative-control twin of `TypeScript-Tools-Clean/Grype`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: Grype -- github.com/anchore/grype (Go binary / GitHub release)
Domain: ship chandlery stock pins (ChandleryStock) (same fixture identity as the clean corpus; only the content is broken)

**Not installed here**: see Notes for why, and what was checked instead.

## What was made wrong, and why it's wrong enough

`sbom.cdx.json` and `package.json` now also list `lodash` 4.17.15, `minimist` 1.2.5, `axios` 0.21.0, `node-fetch` 2.6.0, `tar` 6.1.0 -- exact pins that have known advisories. (Before this change the Invalid folder was byte-identical to the Clean one, so it could not report anything.)

## Command

```bash
grype sbom:./sbom.cdx.json
```

## Notes

Grype scans an SBOM document with `grype sbom:<file>` (its README: "Scan an SBOM for even faster vulnerability detection: grype sbom:./sbom.json"; the provider decodes through Syft's multi-format `syft/format` package, which includes CycloneDX). The Grype release was not obtainable in the generating session (`github.com/anchore/grype/releases/latest` returned 403), so Grype itself was not run. The folder has **no lockfile** on purpose: a `package-lock.json` in a sub-folder makes Testable treat the folder as its own project (one extra task per tool), so the dependency inventory is supplied as a CycloneDX 1.5 SBOM instead.
