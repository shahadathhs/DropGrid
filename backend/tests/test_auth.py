import uuid
from collections.abc import Callable
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
from fastapi.testclient import TestClient
from sqlalchemy import select

from core.config import settings
from core.database import async_session_factory
from models.player import Player
from tests.conftest import PASSWORD, auth_headers, register


async def _bump_password_version(email: str) -> None:
    async with async_session_factory() as session:
        player = (await session.execute(select(Player).where(Player.email == email))).scalar_one()
        player.password_version += 1
        await session.commit()


def _claims(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])


def test_register_returns_201_and_token_pair(client: TestClient) -> None:
    body = register(client, "Ann@Example.com", "ann_1")
    assert set(body) == {"access_token", "refresh_token", "token_type"}
    assert body["token_type"] == "bearer"
    access = _claims(body["access_token"])
    refresh = _claims(body["refresh_token"])
    assert access["type"] == "access"
    assert refresh["type"] == "refresh"
    assert access["pv"] == 0 and refresh["pv"] == 0
    assert access["sub"] == refresh["sub"]
    assert {"exp", "iat"} <= set(access)


def test_register_stores_lowercase_and_profile_is_normalized(client: TestClient) -> None:
    tokens = register(client, "Ann@Example.COM", "Ann_One")
    profile = client.get("/v1/players/me", headers=auth_headers(tokens)).json()
    assert profile["email"] == "ann@example.com"
    assert profile["username"] == "ann_one"


def test_register_duplicate_email_is_409_case_insensitive(client: TestClient) -> None:
    register(client, "dup@example.com", "first_user")
    response = client.post(
        "/v1/auth/register",
        json={"email": "DUP@example.com", "password": PASSWORD, "username": "second_user"},
    )
    assert response.status_code == 409
    assert "detail" in response.json()


def test_register_duplicate_username_is_409_case_insensitive(client: TestClient) -> None:
    register(client, "one@example.com", "Taken_Name")
    response = client.post(
        "/v1/auth/register",
        json={"email": "two@example.com", "password": PASSWORD, "username": "taken_name"},
    )
    assert response.status_code == 409


def test_register_validation_rules_return_422(client: TestClient) -> None:
    def attempt(**overrides: str) -> int:
        body = {"email": "v@example.com", "password": PASSWORD, "username": "valid_name"}
        body.update(overrides)
        return client.post("/v1/auth/register", json=body).status_code

    assert attempt(username="ab") == 422  # under 3 chars
    assert attempt(username="a" * 21) == 422  # over 20 chars
    assert attempt(username="bad-name") == 422  # hyphen not allowed
    assert attempt(username="has space") == 422
    assert attempt(password="short7!") == 422  # under 8 chars
    assert attempt(password="a" * 129) == 422  # over 128 chars
    assert attempt(password="é" * 40) == 422  # 40 chars but 80 UTF-8 bytes
    assert attempt(email="not-an-email") == 422


def test_register_accepts_password_of_exactly_72_bytes(client: TestClient) -> None:
    register(client, "edge@example.com", "edge_user", password="a" * 72)
    response = client.post(
        "/v1/auth/login", json={"email": "edge@example.com", "password": "a" * 72}
    )
    assert response.status_code == 200


def test_login_success_is_case_insensitive_on_email(client: TestClient) -> None:
    register(client, "login@example.com", "login_user")
    response = client.post(
        "/v1/auth/login", json={"email": "LOGIN@Example.com", "password": PASSWORD}
    )
    assert response.status_code == 200
    body = response.json()
    assert body["token_type"] == "bearer"
    assert _claims(body["access_token"])["type"] == "access"


def test_login_wrong_password_and_unknown_email_share_one_message(client: TestClient) -> None:
    register(client, "known@example.com", "known_user")
    wrong = client.post(
        "/v1/auth/login", json={"email": "known@example.com", "password": "wrong-password"}
    )
    unknown = client.post(
        "/v1/auth/login", json={"email": "ghost@example.com", "password": PASSWORD}
    )
    assert wrong.status_code == unknown.status_code == 401
    assert wrong.json() == unknown.json()


def test_login_with_over_72_byte_password_is_401_not_500(client: TestClient) -> None:
    register(client, "long@example.com", "long_user")
    response = client.post(
        "/v1/auth/login", json={"email": "long@example.com", "password": "x" * 100}
    )
    assert response.status_code == 401


def test_refresh_returns_new_pair(client: TestClient) -> None:
    tokens = register(client, "refresh@example.com", "refresh_user")
    response = client.post("/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert response.status_code == 200
    body = response.json()
    assert _claims(body["access_token"])["type"] == "access"
    assert _claims(body["refresh_token"])["type"] == "refresh"
    # The new access token works for an authenticated call.
    assert client.get("/v1/players/me", headers=auth_headers(body)).status_code == 200


def test_refresh_rejects_access_token(client: TestClient) -> None:
    tokens = register(client, "type1@example.com", "type_user1")
    response = client.post("/v1/auth/refresh", json={"refresh_token": tokens["access_token"]})
    assert response.status_code == 401


def test_access_endpoint_rejects_refresh_token(client: TestClient) -> None:
    tokens = register(client, "type2@example.com", "type_user2")
    response = client.get(
        "/v1/players/me", headers={"Authorization": f"Bearer {tokens['refresh_token']}"}
    )
    assert response.status_code == 401


def test_refresh_rejects_garbage_and_expired_tokens(client: TestClient) -> None:
    assert client.post("/v1/auth/refresh", json={"refresh_token": "nope"}).status_code == 401

    tokens = register(client, "expired@example.com", "expired_user")
    claims = _claims(tokens["refresh_token"])
    past = datetime.now(UTC) - timedelta(days=1)
    expired = jwt.encode(
        {
            **claims,
            "iat": int((past - timedelta(days=30)).timestamp()),
            "exp": int(past.timestamp()),
        },
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )
    response = client.post("/v1/auth/refresh", json={"refresh_token": expired})
    assert response.status_code == 401


def test_refresh_rejects_token_signed_with_other_secret(client: TestClient) -> None:
    tokens = register(client, "forge@example.com", "forge_user")
    claims = _claims(tokens["refresh_token"])
    forged = jwt.encode(claims, "wrong-secret", algorithm=settings.jwt_algorithm)
    response = client.post("/v1/auth/refresh", json={"refresh_token": forged})
    assert response.status_code == 401


def test_stale_password_version_rejects_refresh_and_access(
    client: TestClient, run_db: Callable[..., Any]
) -> None:
    tokens = register(client, "stale@example.com", "stale_user")
    run_db(_bump_password_version, "stale@example.com")

    refresh = client.post("/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert refresh.status_code == 401
    access = client.get("/v1/players/me", headers=auth_headers(tokens))
    assert access.status_code == 401


def test_token_for_deleted_player_is_rejected(client: TestClient) -> None:
    tokens = register(client, "gone@example.com", "gone_user")
    assert client.delete("/v1/players/me", headers=auth_headers(tokens)).status_code == 204
    refresh = client.post("/v1/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert refresh.status_code == 401
    assert client.get("/v1/players/me", headers=auth_headers(tokens)).status_code == 401


def test_token_subject_is_a_uuid(client: TestClient) -> None:
    tokens = register(client, "uuid@example.com", "uuid_user")
    profile = client.get("/v1/players/me", headers=auth_headers(tokens)).json()
    assert uuid.UUID(profile["id"]) == uuid.UUID(_claims(tokens["access_token"])["sub"])
