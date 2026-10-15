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

# Run as an unprivileged user.
RUN useradd --system --no-create-home --uid 10001 app
USER app

ENV PORT=8000
EXPOSE 8000
# Shell form so ${PORT} is expanded; exec keeps uvicorn as PID 1 for clean signals.
# --proxy-headers: behind Fly's proxy the real client IP (used by the rate limiter)
# arrives in X-Forwarded-For. Trusting "*" is safe only because the app is reachable
# solely through that proxy.
CMD exec uvicorn main:app --host 0.0.0.0 --port "${PORT}" --proxy-headers --forwarded-allow-ips='*'
