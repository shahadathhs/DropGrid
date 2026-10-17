#!/usr/bin/env bash
# Bump the release version: make release v=0.2.0
# Writes VERSION (source of truth for release builds), updates the export
# preset defaults, commits, and pushes. On the next merge to main the
# pipeline cuts the v0.2.0 release; the rolling "latest" build is unaffected.
set -euo pipefail

v="${v:-}"
[[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo 'Usage: make release v=0.2.0' >&2
  exit 1
}

printf '%s\n' "$v" > VERSION
sed -i.bak "s|^version/name=.*|version/name=\"${v}\"|" game/export_presets.cfg && rm -f game/export_presets.cfg.bak

git add VERSION game/export_presets.cfg
git commit -m "chore(release): v${v}"
git push origin "$(git rev-parse --abbrev-ref HEAD)"
echo "v${v} staged for release: merge/push to main and the pipeline cuts it."
