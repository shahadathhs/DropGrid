import pytest
from fastapi.testclient import TestClient

from core.blocklist import is_blocked_username
from tests.conftest import PASSWORD, auth_headers, register


def _register(client: TestClient, username: str):
    return client.post(
        "/v1/auth/register",
        json={"email": f"{username}@example.com", "password": PASSWORD, "username": username},
    )


@pytest.mark.parametrize(
    "name", ["admin", "Admin", "4dm1n", "dropgrid", "support", "null", "fuck", "f_u_c_k", "sh1t"]
)
def test_blocked(name: str) -> None:
    assert is_blocked_username(name)


@pytest.mark.parametrize(
    "name",
    ["classic", "cockpit_pilot", "scunthorpe", "assassin", "player_1", "tetris_fan", "modern"],
)
def test_not_blocked(name: str) -> None:
    assert not is_blocked_username(name)


def test_register_rejects_blocked_name(client: TestClient) -> None:
    assert _register(client, "admin").status_code == 422
    assert _register(client, "n1gger_x").status_code == 422
    assert _register(client, "4dm1n").status_code == 422


def test_register_allows_clean_name_with_short_substring(client: TestClient) -> None:
    assert _register(client, "classic").status_code == 201


def test_rename_rejects_blocked_name(client: TestClient) -> None:
    tokens = register(client, "rn@example.com", "rename_me")
    headers = auth_headers(tokens)
    assert (
        client.patch("/v1/players/me", json={"username": "M0derator"}, headers=headers).status_code
        == 422
    )
    assert (
        client.patch("/v1/players/me", json={"username": "cockpit"}, headers=headers).status_code
        == 200
    )
