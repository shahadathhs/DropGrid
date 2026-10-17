# CI/CD and APK builds

One workflow: `.github/workflows/ci.yml`. Pull requests and pushes run the quality gates; pushes to `main` and `v*` tags continue through deploy, packaging, and release — all visible as check status on the commit.

| Job             | Runs for          | What it does                                                                                                                                                                                                    |
| --------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `game-tests`    | every push and PR | `make lint`, `make check`, `make test` (headless Godot in Docker)                                                                                                                                               |
| `backend-tests` | every push and PR | ruff, pyright, pytest in `backend/`                                                                                                                                                                             |
| `site`          | every push and PR | site lint (oxlint + prettier), tsc, `next build`                                                                                                                                                                |
| `deploy-render` | `main`            | POSTs the Render deploy hook, then polls the Render API until the deploy is live (fails the run otherwise)                                                                                                      |
| `apk`           | `main`            | Version + server-URL injection, `make apk`, uploads the `dropgrid-apk` artifact (30 days)                                                                                                                       |
| `web`           | every push and PR | `make web`, packs `game/build/web` into `dropgrid-web.tar.gz`, uploads the `dropgrid-web` artifact (7 days); pull requests prove the web export works                                                           |
| `release`       | `main`            | Refreshes the rolling **Latest build** (the APK and `dropgrid-web.tar.gz`), then POSTs `VERCEL_DEPLOY_HOOK` if set; if the `VERSION` file names a version without a release, also publishes **DropGrid vX.Y.Z** |

So a normal push to `main` does: gates → backend deploy → APK and web export → new rolling _Latest build_ → site rebuild (when the hook is set). A version bump does all of that plus the versioned release.

## Cutting a versioned release

```sh
make release v=0.2.0   # writes VERSION, updates export_presets, commits, pushes
```

Merge to `main` (or push the commit there) and the pipeline publishes
**DropGrid v0.2.0** with `dropgrid-0.2.0.apk`, marked as the latest release.
Rolling dev builds keep flowing and never take the latest flag. Releases are
idempotent: a version is published once, when `VERSION` names a version that has
no release yet.

## Downloading the APK

1. **Versioned release**: [releases/latest](https://github.com/shahadathhs/DropGrid/releases/latest) — the newest `vX.Y.Z`.
2. **Rolling dev build**: [releases/tag/latest](https://github.com/shahadathhs/DropGrid/releases/tag/latest) — automatic build of `main`.
3. **Run artifact**: GitHub > **Actions** > the run > **Artifacts** > `dropgrid-apk` (a zip with the APK in it).

To install: copy it to the phone and open it (allow "install unknown apps" once), or `adb install -r dropgrid-*.apk`.

The file name carries the version: `dropgrid-<version>-<commit>.apk` for main builds (the version comes from the `VERSION` file), `dropgrid-0.2.0.apk` for tags. The version code is the run number, so a newer build installs over an older one (with the fixed key below).

## One-time setup (secrets and variables)

### 1. A fixed signing key (needed to update an installed app)

Without it, every build signs with a new throwaway key. Android then refuses to install a build over the previous one ("package conflicts"), and you would have to uninstall first, losing local scores.

```sh
make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64
```

`make android-key` creates a key inside Docker (no Java needed on your Mac) and prints it as base64. `gh secret set` reads the value from the pipe, so it never appears on screen. Do this once; keep using that same secret — changing it changes the key. **Already configured for this repo.**

This is a **debug** key: fine for testing and sideloading, not for Google Play. Play needs a release upload keystore and an `.aab` (Phase F).

### 2. The server address (needed for accounts and the leaderboard)

Without it the APK points at `localhost` (offline-only game). After deploying the backend ([DEPLOY.md](DEPLOY.md)):

```sh
gh variable set API_BASE_URL --body "https://dropgrid-api.onrender.com/v1"
```

It must start with `https://` and end with `/v1`, or the build fails saying so. It is injected into the project settings for that build only; your checked-in `project.godot` is untouched. Missing values print warnings in the run log. **Already configured for this repo.**

### 3. Render deploy (`main` and tag pushes)

```sh
gh secret set RENDER_DEPLOY_HOOK_URL   # Render > dropgrid-api > Settings > Deploy Hook
gh secret set RENDER_API_KEY           # Render > Account Settings > API Keys
```

- `RENDER_DEPLOY_HOOK_URL` triggers the backend deploy. Without it, the job warns and skips deployment.
- `RENDER_API_KEY` lets the job wait until the deploy is live and fail the run if the deploy fails or times out (~10 minutes). Without it, the APK may build against a backend that is still deploying.

**Already configured for this repo.** Optional: turn **autoDeploy off** in Render's service settings so the hook is the only deploy path and the deploy CD verifies is the deploy that runs.

### 4. Site rebuild (optional, `VERCEL_DEPLOY_HOOK`)

The site's `/play` page hosts the game's web export. The site fetches `dropgrid-web.tar.gz` from the rolling `latest` release when it builds (`site/scripts/fetch-playground.mjs`), but Vercel starts its build as soon as the push lands, before CI has attached the new asset. Without a rebuild, the playground lags one site deploy behind the game.

```sh
gh secret set VERCEL_DEPLOY_HOOK   # Vercel > project > Settings > Git > Deploy Hooks (branch: main)
```

The `release` job POSTs the hook after refreshing `latest`. Without the secret the step prints a notice and skips; nothing fails.

## Run the same build locally

```sh
make lint check test apk    # writes game/build/dropgrid-debug.apk
make web                    # writes game/build/web/ (the browser build)
```

To sign locally with the same key CI uses, export `ANDROID_DEBUG_KEYSTORE_BASE64` first (the value from `make android-key`). Locally the key lives in a Docker volume, so the first build creates it and later builds reuse it.

## Known limits

- Debug APK, not a Play Store release.
- Each run rebuilds the Godot Docker image from scratch (a few minutes).
- The Render deploy hook deploys the service's latest branch state; it does not pin a commit.
- Dependabot reads `backend/pyproject.toml` but not `uv.lock`: after merging a backend bump, run `make backend-install` (or `uv lock`) and commit the lockfile.
