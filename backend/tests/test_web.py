import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select

from core.config import settings
from models.player import Player
from tests.conftest import PASSWORD, register


def _exists(run_db, email: str) -> bool:
    from core.database import async_session_factory

    async def _q() -> bool:
        async with async_session_factory() as s:
            return (
                await s.execute(select(Player.id).where(Player.email == email))
            ).first() is not None

    return run_db(_q)


def test_privacy_page(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "contact_email", "")
    page = client.get("/privacy")
    assert page.status_code == 200
    assert "text/html" in page.headers["content-type"]
    assert "leaderboard" in page.text and "Contact" not in page.text
    monkeypatch.setattr(settings, "contact_email", "hi@<example>.com")
    assert "hi@&lt;example&gt;.com" in client.get("/privacy").text


def test_delete_form_renders(client: TestClient) -> None:
    page = client.get("/account/delete")
    assert page.status_code == 200
    assert 'name="password"' in page.text


def test_delete_success(client: TestClient, run_db) -> None:
    register(client, "gone@example.com", "gone_user")
    response = client.post(
        "/account/delete", data={"email": "Gone@Example.com", "password": PASSWORD}
    )
    assert response.status_code == 200
    assert "deleted" in response.text
    assert not _exists(run_db, "gone@example.com")


def test_delete_wrong_credentials_generic(client: TestClient, run_db) -> None:
    register(client, "stay@example.com", "stay_user")
    wrong = client.post(
        "/account/delete", data={"email": "stay@example.com", "password": "nope-nope"}
    )
    unknown = client.post(
        "/account/delete", data={"email": "who@example.com", "password": "nope-nope"}
    )
    assert wrong.status_code == unknown.status_code == 401
    assert "Invalid email or password" in wrong.text
    assert _exists(run_db, "stay@example.com")


def test_delete_escapes_input(client: TestClient) -> None:
    response = client.post(
        "/account/delete", data={"email": '"><script>x</script>', "password": "p"}
    )
    assert "<script>x" not in response.text


def test_delete_is_rate_limited(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "rate_limit_enabled", True)
    monkeypatch.setattr(settings, "rate_limit_per_minute", 2)
    for _ in range(2):
        assert (
            client.post("/account/delete", data={"email": "a@b.co", "password": "x"}).status_code
            == 401
        )
    assert (
        client.post("/account/delete", data={"email": "a@b.co", "password": "x"}).status_code == 429
    )


def test_production_rejects_default_secret() -> None:
    from core.config import Settings

    with pytest.raises(ValueError):
        Settings(environment="production", jwt_secret="change-me")
    Settings(environment="production", jwt_secret="x" * 40)
