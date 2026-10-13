from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient

from core import ratelimit
from core.config import settings
from tests.conftest import PASSWORD, register


@pytest.fixture
def limited(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    monkeypatch.setattr(settings, "rate_limit_enabled", True)
    monkeypatch.setattr(settings, "rate_limit_per_minute", 3)
    yield


def _login(client: TestClient):
    return client.post("/v1/auth/login", json={"email": "rl@example.com", "password": "nope-nope"})


def test_login_returns_429_after_limit(client: TestClient, limited) -> None:
    register(client, "rl@example.com", "rl_user")
    for _ in range(3):
        assert _login(client).status_code == 401
    blocked = _login(client)
    assert blocked.status_code == 429
    assert "detail" in blocked.json()
    assert int(blocked.headers["Retry-After"]) >= 1


def test_each_auth_endpoint_has_its_own_bucket(client: TestClient, limited) -> None:
    tokens = register(client, "rl2@example.com", "rl_user2")  # register: 1 of 3 used
    for _ in range(2):
        _login(client)  # login: 2 of 3 used
    assert _login(client).status_code == 401  # login: 3 of 3 used
    assert _login(client).status_code == 429

    # Refresh has its own bucket and is unaffected by the exhausted login bucket.
    refresh = client.post("/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert refresh.status_code == 200


def test_register_is_limited(client: TestClient, limited) -> None:
    statuses = [
        client.post(
            "/v1/auth/register",
            json={
                "email": f"many{i}@example.com",
                "password": PASSWORD,
                "username": f"many_{i}",
            },
        ).status_code
        for i in range(4)
    ]
    assert statuses == [201, 201, 201, 429]


def test_window_slides_and_allows_again(
    client: TestClient, limited, monkeypatch: pytest.MonkeyPatch
) -> None:
    clock = {"now": 1000.0}
    monkeypatch.setattr(ratelimit, "_now", lambda: clock["now"])

    for _ in range(3):
        _login(client)
    assert _login(client).status_code == 429

    clock["now"] += 30.0  # still inside the 60 s window
    assert _login(client).status_code == 429

    clock["now"] += 31.0  # the first hits have aged out
    assert _login(client).status_code == 401


def test_disabled_limit_never_blocks(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "rate_limit_enabled", False)
    monkeypatch.setattr(settings, "rate_limit_per_minute", 1)
    for _ in range(5):
        assert _login(client).status_code == 401
