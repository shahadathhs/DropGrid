# Security Policy

## Supported versions

Only the latest code on `main` is supported. Releases are cut from `main`; older releases do not receive security patches.

## Reporting a vulnerability

Do **not** open a public issue. Email <shahadathhossensajib732@gmail.com> with:

- what the vulnerability is and where,
- how to reproduce it,
- what an attacker could do with it.

You will get a reply within a week. Once a fix is released, your report will be credited in the release notes if you want.

## Scope

- The backend API (`backend/`): auth, accounts, sync, leaderboard. Note that the production deployment is a single Render instance by design (in-process rate limiter); reports about scaling behavior are out of scope.
- The game client (`game/`): it talks only to the configured API URL and stores tokens in app-local storage (`user://session.json`).

## Known non-issues

- The game is offline-first: guest play makes no network requests by design.
- Server-side plausibility caps (`backend/core/game_limits.py`) intentionally tolerate small inconsistencies to keep sync merge simple; exact anti-cheat hardening is not a goal of v1.
