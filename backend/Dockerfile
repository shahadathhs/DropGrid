FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    PATH=/app/.venv/bin:$PATH

# uv as a single binary, copied from the official image.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Install dependencies first for better layer caching (no dev group).
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

COPY . .

# start.sh must be executable regardless of local file modes.
RUN chmod +x start.sh

# Run as an unprivileged user.
RUN useradd --system --no-create-home --uid 10001 app
USER app

ENV PORT=8000
EXPOSE 8000
# start.sh applies migrations before serving (safe with one instance: alembic
# upgrade head is a no-op when the database is current). It is exec'd so uvicorn
# is PID 1 and gets clean signals. --proxy-headers: behind the host's proxy the
# real client IP (used by the rate limiter) arrives in X-Forwarded-For, and
# trusting "*" is safe only because the app is reachable solely through that proxy.
CMD ["./start.sh"]
