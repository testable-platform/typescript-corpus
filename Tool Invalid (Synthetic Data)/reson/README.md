# reson

Synthetic, **deliberately invalid** TypeScript project for **reson** -- the negative-control twin of `TypeScript-Tools-Clean/reson`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: reson (Rust, github.com/nexepic/reson, built from the v1.4.1 tag with `cargo install --git ... --tag v1.4.1 --locked`)
Domain: harbour tide-gauge readings (TideGauge) (same fixture identity as the clean corpus; only the content is broken)

**Measured**: installed (or built from real source) and actually invoked in the build environment; the result below is real, not asserted.

## What was made wrong, and why it's wrong enough

`src/tideGauge.ts` gained `summariseNorth`, `summariseSouth` and `summariseEast`: three 13-line blocks that are identical apart from the variable name and one letter. Measured: reson reports `duplicateBlocks: 3` (one group of three), `duplicateFiles: 1`, `duplicateLines: 39` at `--threshold 10 --min-ast-nodes 12`; the Clean twin reports 0 on all three.

## Command

```bash
reson --source-path src --output-format json --output-file reports/reson.json --threshold 10 --min-ast-nodes 12
```

## Notes

reson is an AST-level duplicate-code detector written in Rust; it has no npm package, so the folder is Node-version-independent. Built from the `v1.4.1` tag; the binary reports itself as `reson v1.3.3` because upstream did not bump the version in `Cargo.toml` for that tag (`cargo install` printed `reson v1.3.3 (https://github.com/nexepic/reson?tag=v1.4.1#83aad4e4)`). The thresholds are the ones the `Tool Triggering (Synthetic Data)/reson` runner uses. Measured 2026-10-07.
