# TraceGraph

Synthetic, **deliberately invalid** TypeScript project for **TraceGraph** -- the negative-control twin of `TypeScript-Tools-Clean/TraceGraph`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: @tracegraph/trace-js 0.3.1 (npm)
Domain: ferry crossing logbook (CrossingLog) (same fixture identity as the clean corpus; only the content is broken)

**Measured**: installed (or built from real source) and actually invoked in the build environment; the result below is real, not asserted.

## What was made wrong, and why it's wrong enough

`crossings.json` now holds a crossing with `passengers: -3`. Measured: the trace holds 8 events (4 `function_call`, 3 `return`, 1 `error`) -- the rejected call is recorded as an `error` event; the Clean twin has none.

## Command

```bash
npm install --prefix .tracegraph --no-save --no-package-lock @tracegraph/trace-js@0.3.1
node trace_crossings.cjs .tracegraph .tracegraph-run     # run from the repository root, where typescript is installed
```

## Notes

@tracegraph/trace-js is an instrumentation **library** (no CLI): it records a call as a `function_call` event and its outcome as a `return` or `error` event. `trace_crossings.cjs` compiles `src/crossingLog.ts` in memory (with the repository's own TypeScript), wraps `CrossingLog.record` and `total`, and logs `crossings.json`. The package needs Node >= 14 (it uses the `??` operator), so there is no Node 12 run. The upstream project publishes no public repository, so the `Tool Triggering (Tool Github Test data)` folder has no TraceGraph test suite to mirror. Measured 2026-10-07 with @tracegraph/trace-js 0.3.1.
