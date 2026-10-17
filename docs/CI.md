# CI, CD, and APK builds

Two workflows:

- **`ci.yml`** — quality gates on every push to `main`, every pull request, and `v*` tags: `make check`/`make test` for the game, ruff + pyright + pytest for the backend. No artifacts.
- **`cd.yml`** — triggered after CI **succeeds**. Runs only for `main` and `v*` tags:

| Job | Runs for | What it does |
|---|---|---|
| `deploy-render` | `main` | POSTs the Render deploy hook, then polls the Render API until the deploy is live (or fails the run) |
| `apk` | `main`, tags | Version + server-URL injection, `make apk`, uploads `dropgrid-apk` artifact (30 days) |
| `release` | `main`, tags | `main`: refreshes one rolling **latest** pre-release with the new APK. Tag: creates the official GitHub Release with generated notes |

So a normal push to `main` does: tests → backend deploy → APK → new `latest` pre-release. A tagged push (`v0.2.0`) does: tests → APK → official release.

## Downloading the APK

1. **Rolling build** (main): GitHub > **Releases** > *Latest build…* — always the newest APK.
2. **Run artifact**: GitHub > **Actions** > the CD run > **Artifacts** > `dropgrid-apk` (a zip with the APK in it).
3. **Versioned release**: tag and push, and the APK lands on a stable release page:

```sh
git tag v0.2.0 && git push origin v0.2.0
```

To install: copy it to the phone and open it (allow "install unknown apps" once), or `adb install -r dropgrid-*.apk`.

The file name carries the version: `dropgrid-0.1.0-<commit>.apk` for main builds, `dropgrid-0.2.0.apk` for tags. The version code is the CD run number, so a newer build installs over an older one (with the fixed key below).

## One-time setup (secrets and variables)

### 1. A fixed signing key (needed to update an installed app)

Without it, every build signs with a new throwaway key. Android then refuses to install a build over the previous one ("package conflicts"), and you would have to uninstall first, losing local scores.

```sh
make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64
```

`make android-key` creates a key inside Docker (no Java needed on your Mac) and prints it as base64. `gh secret set` reads the value from the pipe, so it never appears on screen. Do this once; keep using that same secret — changing it changes the key.

This is a **debug** key: fine for testing and sideloading, not for Google Play. Play needs a release upload keystore and an `.aab` (Phase F).

### 2. The server address (needed for accounts and the leaderboard)

Without it the APK points at `localhost` (offline-only game). After deploying the backend ([DEPLOY.md](DEPLOY.md)):

```sh
gh variable set API_BASE_URL --body "https://dropgrid-api.onrender.com/v1"
```

It must start with `https://` and end with `/v1`, or the build fails saying so. It is injected into the project settings for that build only; your checked-in `project.godot` is untouched. Missing values print warnings in the run log.

### 3. Render deploy (optional; `main` CD only)

```sh
gh secret set RENDER_DEPLOY_HOOK_URL --body "https://api.render.com/deploy/srv-XXXX?key=YYYY"
gh secret set RENDER_API_KEY --body "rnd_..."
```

- `RENDER_DEPLOY_HOOK_URL`: Render > your web service > **Settings** > **Deploy Hook**. Triggers the backend deploy. Without it, CD logs a warning and skips deployment.
- `RENDER_API_KEY`: Render > **Account Settings** > **API Keys**. Without it, CD triggers the deploy but cannot wait for it, so the APK may build against a backend that is still deploying. With it, the `deploy-render` job polls until the deploy is live and fails the run if the deploy fails or times out (~10 minutes).

## Run the same build locally

```sh
make check test apk      # writes game/build/dropgrid-debug.apk
```

To sign locally with the same key CI uses, export `ANDROID_DEBUG_KEYSTORE_BASE64` first (the value from `make android-key`). Locally the key lives in a Docker volume, so the first build creates it and later builds reuse it.

## Known limits

- Debug APK, not a Play Store release.
- Each run rebuilds the Godot Docker image from scratch (a few minutes).
- The Render deploy hook always deploys the service's latest auto-build; it does not deploy a specific commit. Pin the service to "deploy on hook only" (autoDeploy off) if you want hook = truth.
