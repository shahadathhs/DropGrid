"""In-memory sliding-window rate limiter for the auth endpoints.

State lives in one process. Behind a reverse proxy, the client address is the
proxy's unless uvicorn is configured to trust forwarded headers.
"""

import math
import time
from collections import deque
from collections.abc import Awaitable, Callable
from typing import Final

from fastapi import Request

from core.config import settings
from core.exceptions import RateLimitedException

WINDOW_SECONDS: Final = 60.0
_SWEEP_EVERY: Final = 1024


def _now() -> float:
    return time.monotonic()


class SlidingWindowLimiter:
    def __init__(self) -> None:
        self._hits: dict[str, deque[float]] = {}
        self._calls = 0

    def hit(self, key: str, limit: int, window: float, now: float) -> float | None:
        """Record a hit. Return None if allowed, else seconds until the next slot frees up."""
        self._calls += 1
        if self._calls % _SWEEP_EVERY == 0:
            self._sweep(now, window)
        stamps = self._hits.setdefault(key, deque())
        cutoff = now - window
        while stamps and stamps[0] <= cutoff:
            stamps.popleft()
        if len(stamps) >= limit:
            # Rejected hits are not recorded, so they do not extend the window.
            return (stamps[0] if stamps else now) + window - now
        stamps.append(now)
        return None

    def _sweep(self, now: float, window: float) -> None:
        cutoff = now - window
        stale = [key for key, stamps in self._hits.items() if not stamps or stamps[-1] <= cutoff]
        for key in stale:
            del self._hits[key]

    def reset(self) -> None:
        self._hits.clear()
        self._calls = 0


limiter = SlidingWindowLimiter()


def rate_limit(scope: str) -> Callable[[Request], Awaitable[None]]:
    """FastAPI dependency: each endpoint (scope) gets its own bucket per client IP."""

    async def _check(request: Request) -> None:
        if not settings.rate_limit_enabled:
            return
        ip = request.client.host if request.client else "unknown"
        retry_after = limiter.hit(
            f"{scope}:{ip}",
            settings.rate_limit_per_minute,
            WINDOW_SECONDS,
            _now(),
        )
        if retry_after is not None:
            raise RateLimitedException(retry_after=max(1, math.ceil(retry_after)))

    return _check
