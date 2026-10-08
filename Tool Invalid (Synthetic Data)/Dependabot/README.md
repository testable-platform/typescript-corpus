# Dependabot

Synthetic, **deliberately invalid** TypeScript project for **Dependabot** -- the negative-control twin of `TypeScript-Tools-Clean/Dependabot`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: Dependabot -- github.com/dependabot/dependabot-core (Ruby) and its CLI github.com/dependabot/cli
Domain: dock-lock scheduling (LockSchedule) (same fixture identity as the clean corpus; only the content is broken)

**Not installed here**: see Notes for why, and what was checked instead.

## What was made wrong, and why it's wrong enough

`package.json` pins `lodash` 4.17.15, `minimist` 1.2.5, `axios` 0.21.0, `node-fetch` 2.6.0 and `tar` 6.1.0 -- releases from 2020-2021 that have newer versions (all five exist on the registry; checked with `npm view <package>@<version> version`). Dependabot proposes a version update, and a security update where an advisory exists, for each of them.

## Command

```bash
dependabot update npm_and_yarn <owner>/<repo> --local .      # Dependabot CLI (github.com/dependabot/cli)
```

## Notes

Dependabot's npm updater reads `package.json` and, when present, a lockfile. The folder deliberately has **no lockfile** (a `package-lock.json` in a sub-folder makes Testable treat the folder as its own project), so only the manifest and `.github/dependabot.yml` are inputs. Not executed in the generating session: Dependabot needs a repository on GitHub (or the Dependabot CLI and a container runtime) and neither was available; the versions below were checked against the npm registry on 2026-10-07.
