# git-hot

Synthetic, **deliberately invalid** TypeScript project for **git-hot** -- the negative-control twin of `TypeScript-Tools-Clean/git-hot`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: git-hot 0.11.1 (PyPI, github.com/dspinellis/git-hot)
Domain: lighthouse lamp maintenance log (LampLog) (same fixture identity as the clean corpus; only the content is broken)

**Measured**: installed (or built from real source) and actually invoked in the build environment; the result below is real, not asserted.

## What was made wrong, and why it's wrong enough

`bash make-history.sh hot` builds 18 commits that rewrite the one line `SERVICE_INTERVAL_DAYS = N` in `src/lampLog.ts` on every commit. Measured: git-hot reports `max(churn) = 17` for `src/lampLog.ts` (the Clean twin reports 0 for every file).

## Command

```bash
bash make-history.sh hot
cd history-repo && git-hot --format '{max(churn):5d} {days(median(line_age)):5d} {path}' HEAD
```

## Notes

git-hot reports, per file, how often its live lines were rewritten (`churn`) and how old they are (`line_age`). It needs real history, so the folder carries `make-history.sh`, which builds a deterministic repository in `history-repo/` (fixed author, fixed dates; it is git-ignored) instead of a binary git bundle. git-hot is a Python tool: Node-version-independent, one folder. Measured 2026-10-07 with git-hot 0.11.1.
