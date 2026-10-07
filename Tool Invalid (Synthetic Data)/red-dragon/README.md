# red-dragon

Synthetic, **deliberately invalid** TypeScript project for **red-dragon** -- the negative-control twin of `TypeScript-Tools-Clean/red-dragon`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: red-dragon (Python, github.com/avishek-sen-gupta/red-dragon, commit c287bb2)
Domain: pump-room pressure trends (PumpRoom) (same fixture identity as the clean corpus; only the content is broken)

**Measured**: installed (or built from real source) and actually invoked in the build environment; the result below is real, not asserted.

## What was made wrong, and why it's wrong enough

`src/pumpRoom.ts` plants two kinds of data-flow defect. Dead stores: `spare` (assigned, never read) and `scratch` (assigned twice, never read). Maybe-uninitialised reads: `delta` and `label` are declared without a value and read on a path that never assigned them. Measured: the driver reports `deadStores = [scratch, spare]` and `maybeUninitialisedReads = [delta, label]`; the Clean twin reports both lists empty.

## Command

```bash
# red-dragon is not on PyPI: clone it, check out the pinned commit, `uv sync` (Python >= 3.13)
uv run --project <red-dragon checkout> python "../../Tool Triggering (Synthetic Data)/red-dragon/dataflow.py" <red-dragon checkout> reports/red-dragon.json src/pumpRoom.ts
```

## Notes

The earlier version of this folder called `red-dragon` a roster defect (a COBOL-only tool with no TypeScript support). That was wrong: upstream's README describes a multi-language pipeline (tree-sitter frontends, an intermediate representation, a CFG, reaching-definitions and def-use analysis), and it has a TypeScript frontend (`interpreter/frontends/typescript`). Checked by running commit c287bb2 on TypeScript source on 2026-10-07: it lowers `src/pumpRoom.ts` to IR, builds the CFG and reports definitions and def-use chains. One limit was found on the way: this commit cannot lower a compound assignment such as `i += 1` (`ValueError: Unknown binary operator: '+='`), so the fixtures here use `i = i + 1`. Needs Python >= 3.13 and `uv`; Node-version-independent, one folder. The driver is `Tool Triggering (Synthetic Data)/red-dragon/dataflow.py`; it counts a named variable that is assigned but never read as a dead store, and a read that an initialiser-less `let x;` can reach as a maybe-uninitialised read.
