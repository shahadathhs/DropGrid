# Deploying the backend (Fly.io + Neon)

Nothing here has been run for you. The API runs as **one** Fly.io machine and stores data in a Neon Postgres database. Both have free or cheap tiers.

> **Single instance only.** Rate limits live in the app's memory. A second machine would double the limits and split their counters. `fly.toml` pins one machine; do not run `fly scale count 2` without first moving the limiter to a shared store.

## 1. Create the database (Neon)

1. Sign up at neon.tech and create a project (pick a region near your Fly region).
2. On the project dashboard, copy the **connection string** (it starts with `postgresql://` and ends with `?sslmode=require`). Paste it as-is later; the backend converts it for its async driver.

## 2. Install Fly and sign in

```sh
brew install flyctl      # or see fly.io/docs/flyctl/install
fly auth signup          # or: fly auth login
```

## 3. Create the app (no deploy yet)

```sh
cd backend
fly launch --no-deploy --copy-config
```

Use the existing `fly.toml` when asked. Pick an app name (it becomes `https://<name>.fly.dev`) and a region, and say **no** to a Postgres or Redis database. If it edits `fly.toml`, keep `release_command`, `force_https` and `min_machines_running = 1`.

## 4. Set secrets

Secrets never go into files or git.

```sh
fly secrets set \
  DATABASE_URL='postgresql://USER:PASSWORD@ep-xxxx.region.aws.neon.tech/dbname?sslmode=require' \
  JWT_SECRET="$(openssl rand -hex 32)" \
  CONTACT_EMAIL='you@example.com'
```

`CONTACT_EMAIL` is shown on the privacy page (`/privacy`); leave it out to show no contact line. In production (`ENVIRONMENT=production`, set by `fly.toml`) the app refuses to start with the default or a short `JWT_SECRET`.

## 5. Deploy

```sh
fly deploy
```

Fly builds the image, runs `alembic upgrade head` as the release command, then starts the machine. Check `fly status` and `fly logs`.

## 6. Smoke test

```sh
BASE=https://<name>.fly.dev
curl $BASE/health

# register (note the access_token in the response)
curl -s -X POST $BASE/v1/auth/register -H 'content-type: application/json' \
  -d '{"email":"smoke@example.com","password":"smoke-test-pw","username":"smoke_test"}'
TOKEN=<paste access_token>

# sync (200 = ok; best_score must be plausible for total_lines)
curl -s -X POST $BASE/v1/sync -H "authorization: Bearer $TOKEN" -H 'content-type: application/json' \
  -d '{"best_score":1200,"total_lines":10,"games_played":1}'

curl -s $BASE/v1/leaderboard          # smoke_test should be listed

curl -i -X DELETE $BASE/v1/players/me -H "authorization: Bearer $TOKEN"   # 204
curl -s $BASE/v1/leaderboard          # gone again
```

Also open `$BASE/privacy` and `$BASE/account/delete` in a browser. These two URLs are the ones to enter in the Google Play Console (privacy policy and account deletion links).

## 7. Point the game at it

In `game/project.godot`, set the release URL (HTTPS only, no trailing slash):

```ini
dropgrid/network/api_base_url.release="https://<name>.fly.dev"
```

Debug builds keep using the LAN/emulator URL.

## Later

- New migration: just `fly deploy`; the release command applies it before the new version goes live.
- Rotate the JWT secret with `fly secrets set JWT_SECRET=...` (this signs everyone out).
- Logs: `fly logs`. Rollback: `fly releases` then `fly deploy --image <previous image>`.
