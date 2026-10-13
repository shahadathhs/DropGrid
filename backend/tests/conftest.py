"""Test harness: a throwaway SQLite file, migrated once per session.

Environment must be set before the app is imported. core/config.py is
lru_cache'd and core/database.py creates the engine at import time.
"""

import atexit
import os
import shutil
import tempfile
import uuid
from collections.abc import Callable, Iterator
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

_DB_DIR = tempfile.mkdtemp(prefix="dropgrid-test-")
atexit.register(shutil.rmtree, _DB_DIR, ignore_errors=True)

os.environ["DATABASE_URL"] = f"sqlite+aiosqlite:///{_DB_DIR}/test.db"
os.environ["JWT_SECRET"] = "test-secret-" + "x" * 32  # HMAC key >= 32 bytes
os.environ["RATE_LIMIT_ENABLED"] = "false"  # rate-limit tests opt in explicitly

import pytest  # noqa: E402
from alembic import command  # noqa: E402
from alembic.config import Config  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import delete  # noqa: E402

from core.database import async_session_factory, engine  # noqa: E402
from core.ratelimit import limiter  # noqa: E402
from core.security.password import hash_password  # noqa: E402
from main import app  # noqa: E402
from models.player import Player  # noqa: E402

BACKEND_DIR = Path(__file__).resolve().parent.parent
PASSWORD = "password123"
# One shared hash keeps seeding fast (bcrypt is deliberately slow).
_SEED_HASH = hash_password(PASSWORD)


@pytest.fixture(scope="session", autouse=True)
def _migrated_database() -> None:
    config = Config(str(BACKEND_DIR / "alembic.ini"))
    command.upgrade(config, "head")


async def _truncate_players() -> None:
    async with async_session_factory() as session:
        await session.execute(delete(Player))
        await session.commit()


async def _insert_players(rows: list[dict[str, Any]]) -> None:
    async with async_session_factory() as session:
        for row in rows:
            session.add(
                Player(
                    id=uuid.uuid4(),
                    email=row["email"],
                    username=row["username"],
                    password_hash=_SEED_HASH,
                    password_version=row.get("password_version", 0),
                    best_score=row.get("best_score", 0),
                    total_lines=row.get("total_lines", 0),
                    games_played=row.get("games_played", 0),
                    created_at=datetime.now(UTC),
                    updated_at=datetime.now(UTC),
                )
            )
            # Commit per row so created_at values are strictly ordered by insertion.
            await session.commit()


@pytest.fixture
def client() -> Iterator[TestClient]:
    """A TestClient whose requests and DB calls share one event loop, with empty tables."""
    limiter.reset()
    with TestClient(app) as test_client:
        assert test_client.portal is not None
        test_client.portal.call(_truncate_players)
        yield test_client
        # Close pooled connections while this loop is still alive.
        test_client.portal.call(engine.dispose)
    limiter.reset()


@pytest.fixture
def seed(client: TestClient) -> Callable[[list[dict[str, Any]]], None]:
    def _seed(rows: list[dict[str, Any]]) -> None:
        client.portal.call(_insert_players, rows)

    return _seed


@pytest.fixture
def run_db(client: TestClient) -> Callable[..., Any]:
    """Run an async helper against the test DB on the client's event loop."""

    def _run(fn: Callable[..., Any], *args: Any) -> Any:
        return client.portal.call(fn, *args)

    return _run


def register(client: TestClient, email: str, username: str, password: str = PASSWORD) -> dict:
    response = client.post(
        "/v1/auth/register",
        json={"email": email, "password": password, "username": username},
    )
    assert response.status_code == 201, response.text
    return response.json()


def auth_headers(tokens: dict) -> dict[str, str]:
    return {"Authorization": f"Bearer {tokens['access_token']}"}
