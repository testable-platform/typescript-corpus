# Bearer CLI

Synthetic, **deliberately invalid** TypeScript project for **Bearer CLI** -- the negative-control twin of `TypeScript-Tools-Clean/Bearer CLI`, built so the tool genuinely finds something wrong rather than reporting clean.

Package: bearer/bearer 2.1.1 (Go binary / GitHub release)
Domain: patient intake form handling (IntakeForm) (same fixture identity as the clean corpus; only the content is broken)

**Not installed here**: see Notes for why, and what was checked instead.

## What was made wrong, and why it's wrong enough

`src/intakeForm.ts` now hardcodes a database password, hashes a social-security number with MD5 and SHA-1, builds a confirmation code from `Math.random()`, assembles SQL and an OS command by string concatenation, and writes an e-mail address, the social-security number and the password to `console.log`. The patterns were written to match Bearer's documented JavaScript rules (javascript_lang_hardcoded_secret, javascript_lang_weak_hash_md5, javascript_lang_weak_hash_sha1, javascript_lang_insufficiently_random_values, javascript_lang_sql_injection, javascript_lang_dynamic_os_command, javascript_lang_logger); the scan itself could not complete in the generating session, so no finding count is quoted.

## Command

```bash
bearer scan .
```

## Notes

Bearer's SAST / data-flow scanner ships as a GitHub release binary (v2.1.1: `bearer_2.1.1_linux_amd64.tar.gz`); the npm package literally named `bearer` is an unrelated HTTP auth-header micro-library. Correction to the earlier note: the release download itself works (HTTP 200 on 2026-10-07); what failed in the generating session is Bearer's first-run download of its default rules (`0 rules found for supported language, default rules could not be downloaded` -- bearer-rules returned 403), so the scan could not complete there. The Clean folder is therefore **expected** clean and not measured.
