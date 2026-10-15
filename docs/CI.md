# Continuous integration and APK builds

`.github/workflows/ci.yml` runs on every push. It tests the game and the backend, builds an Android APK, and keeps the APK for 30 days.

| Job | What it does |
|---|---|
| `game-tests` | `make check` and `make test` (headless Godot in Docker, the same as local) |
| `backend-tests` | `ruff check` and `pytest` in `backend/` |
| `apk` | After the game tests pass: `make apk`, then uploads the APK as an artifact |
| `release` | Only for tags like `v0.2.0`: attaches the APK to a GitHub Release |

## Downloading the APK

1. GitHub > **Actions** > pick a run > **Artifacts** > `dropgrid-apk` (a zip with the APK in it).
2. Or tag a release, and the APK is attached to the release page, which is a stable link you can open on your phone:

```sh
git tag v0.2.0 && git push origin v0.2.0
```

To install: copy it to the phone and open it (allow "install unknown apps" once), or `adb install -r dropgrid-*.apk`.

The file name carries the version: `dropgrid-0.1.0-<commit>.apk` for branch builds, `dropgrid-0.2.0.apk` for tags. The version code is the run number, so a newer build installs over an older one.

## One-time setup (two things)

### 1. A fixed signing key (needed to update an installed app)

Without it, every CI run signs with a new throwaway key. Android then refuses to install a build over the previous one ("package conflicts"), and you would have to uninstall first, losing local scores.

```sh
make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64
```

`make android-key` creates a key inside Docker (this does not need Java on your Mac) and prints it as base64. `gh secret set` stores it as a repository secret and reads the value from the pipe, so it never appears on screen. Do this once. Keep using that same secret: changing it changes the key.

This is a **debug** key. Debug-signed APKs are fine for testing and sideloading but cannot go to Google Play. Play needs a release key (an upload keystore) and an `.aab`; that is a separate step in Phase F.

### 2. The server address (needed for accounts and the leaderboard)

Without it the APK points at `localhost`, so it works as an offline game only. After you have deployed the backend ([DEPLOY.md](DEPLOY.md)), set the URL as a repository **variable** (not a secret; it is public anyway):

```sh
gh variable set API_BASE_URL --body "https://dropgrid-api.onrender.com/v1"
```

It must start with `https://` and end with `/v1`, or the build fails with a message saying so. CI writes it into the project settings for that build only; your checked-in `project.godot` is not changed.

The build prints a warning in the run log if either value is missing.

## Run the same build locally

```sh
make check test apk      # writes game/build/dropgrid-debug.apk
```

To sign locally with the same key CI uses, export `ANDROID_DEBUG_KEYSTORE_BASE64` first (the value from `make android-key`). Locally the key lives in a Docker volume, so the first build creates it and later builds reuse it.

## Known limits

- It builds a debug APK, not a Play Store release.
- Each run builds the Godot Docker image from scratch (a few minutes). Add image caching if run time becomes a problem.
- The workflow was linted with `actionlint` and its build steps were run locally, but it has not run on GitHub yet.
