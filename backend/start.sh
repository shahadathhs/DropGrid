#!/bin/sh
# Container entrypoint: apply migrations, then serve. Render injects $PORT.
set -e
alembic upgrade head
exec uvicorn main:app --host 0.0.0.0 --port "${PORT:-8000}" --proxy-headers --forwarded-allow-ips='*'
