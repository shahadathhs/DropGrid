"""Turn a DATABASE_URL into what SQLAlchemy's async engine needs.

Accepts the URLs people copy from their providers:
- sqlite+aiosqlite:///./dropgrid.db (local default, no changes)
- postgresql://... or postgres://... (what Neon and Docker Compose show)
- postgresql+asyncpg://... (already async)

asyncpg rejects libpq-only query parameters such as sslmode and channel_binding,
so they are removed here and turned into connect arguments instead.
"""

from typing import Any

from sqlalchemy.engine import make_url


def resolve_database_url(url: str) -> tuple[str, dict[str, Any]]:
    """Return (async_url, engine_kwargs) for the given DATABASE_URL."""
    # Some providers still print the old alias, which SQLAlchemy no longer accepts.
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://") :]
    parsed = make_url(url)
    if parsed.get_backend_name() != "postgresql":
        return url, {}

    query = dict(parsed.query)
    sslmode = query.pop("sslmode", None)
    query.pop("channel_binding", None)
    async_url = parsed.set(drivername="postgresql+asyncpg", query=query).render_as_string(
        hide_password=False
    )

    connect_args: dict[str, Any] = {
        # Neon's pooler (PgBouncer in transaction mode) cannot reuse prepared
        # statements, so both caches must be off.
        "statement_cache_size": 0,
        "prepared_statement_cache_size": 0,
    }
    if sslmode not in (None, "disable"):
        connect_args["ssl"] = True

    return async_url, {"connect_args": connect_args}
