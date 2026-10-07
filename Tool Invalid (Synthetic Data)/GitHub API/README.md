# GitHub API

Synthetic, **deliberately invalid** TypeScript project for **GitHub API** -- the negative-control twin of `TypeScript-Tools-Clean/GitHub API`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: GitHub REST API (api.github.com) -- the same endpoints the Octokit client (github.com/octokit/rest.js) wraps
Domain: release watching (ReleaseWatch) (same fixture identity as the clean corpus; only the content is broken)

**Not installed here**: see Notes for why, and what was checked instead.

## What was made wrong, and why it's wrong enough

`upstream.txt` names `request/request`, whose README states "As of Feb 11th 2020, request is fully deprecated. No new changes are expected to land." (read from github.com/request/request on 2026-10-07). A watcher fed this repository reports a last release years old.

## Command

```bash
UPSTREAM_REPO=$(cat upstream.txt) bash "../../Tool Triggering (Synthetic Data)/github-api/run_github_api.sh"   # from this folder inside a corpus branch
```

## Notes

The `Tool Triggering (Synthetic Data)/github-api` runner reads `UPSTREAM_REPO` (an `owner/name`), calls `GET /repos/{repo}` and `GET /repos/{repo}/releases/latest`, and writes stars, forks, open issues and the latest tag. `upstream.txt` is the repository this folder points it at. Not executed in the generating session (the sandbox's GitHub API access is restricted to the session's own repositories), so no response is quoted here.
