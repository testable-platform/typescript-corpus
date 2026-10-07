# DepScout

Synthetic, **deliberately invalid** TypeScript project for **DepScout** -- the negative-control twin of `TypeScript-Tools-Clean/DepScout`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: deps-scout 1.0.0 (npm, github.com/FreddyMartinez/deps-scout)
Domain: door-lock service tracking (LockKeeper) (same fixture identity as the clean corpus; only the content is broken)

**Measured**: installed (or built from real source) and actually invoked in the build environment; the result below is real, not asserted.

## What was made wrong, and why it's wrong enough

`package.json` now depends on three npm packages that are deprecated on the registry: `request` 2.88.2 ("request has been deprecated"), `node-uuid` 1.4.8 ("Use uuid module instead") and `left-pad` 1.3.0 ("use String.prototype.padStart()"). Measured: deps-scout flags `node-uuid` (not updated in the last 1245 days, average 383 days between releases) and `left-pad` (905 days, 306 days between releases) as Alerts and stops the evaluation at `maxAlerts`.

## Command

```bash
# scout reads package.json and scout.config.json from the current directory; Enter accepts "javascript" and "console"
printf '\n'; sleep 1; printf '\n'  |  scout
```

## Notes

deps-scout is a pure-JavaScript CLI, so it is installed on demand and is **not** a `package.json` dependency here (a new dependency would change the lockfile of every branch). It prompts twice (language, output); the command above answers both with Enter. It queries the npm registry (release dates, downloads) and the GitHub API (stars, issues, forks, health); without a token the GitHub API rate limit (60 requests per hour per address) is reached quickly, which leaves the GitHub-derived indicators empty -- the release-age indicators come from the npm registry and are unaffected. Requires Node >= 14 (it uses optional-call syntax), so there is no Node 12 run. The folder has no lockfile on purpose. Measured 2026-10-07 with deps-scout 1.0.0.
