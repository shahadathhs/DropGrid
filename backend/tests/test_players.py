from fastapi.testclient import TestClient

from tests.conftest import PASSWORD, auth_headers, register


def test_me_returns_profile(client: TestClient) -> None:
    tokens = register(client, "me@example.com", "me_user")
    response = client.get("/v1/players/me", headers=auth_headers(tokens))
    assert response.status_code == 200
    body = response.json()
    assert set(body) == {"id", "email", "username", "best_score", "total_lines", "games_played"}
    assert body["email"] == "me@example.com"
    assert body["username"] == "me_user"
    assert body["best_score"] == body["total_lines"] == body["games_played"] == 0


def test_me_without_or_with_bad_token_is_401(client: TestClient) -> None:
    assert client.get("/v1/players/me").status_code == 401
    bad = {"Authorization": "Bearer not-a-jwt"}
    assert client.get("/v1/players/me", headers=bad).status_code == 401
    wrong_scheme = {"Authorization": "Basic abc"}
    assert client.get("/v1/players/me", headers=wrong_scheme).status_code == 401


def test_patch_renames_and_returns_profile(client: TestClient) -> None:
    tokens = register(client, "rename@example.com", "old_name")
    response = client.patch(
        "/v1/players/me", json={"username": "New_Name"}, headers=auth_headers(tokens)
    )
    assert response.status_code == 200
    assert response.json()["username"] == "new_name"
    assert client.get("/v1/players/me", headers=auth_headers(tokens)).json()["username"] == (
        "new_name"
    )


def test_patch_to_own_username_is_allowed(client: TestClient) -> None:
    tokens = register(client, "same@example.com", "same_name")
    response = client.patch(
        "/v1/players/me", json={"username": "SAME_NAME"}, headers=auth_headers(tokens)
    )
    assert response.status_code == 200


def test_patch_to_taken_username_is_409(client: TestClient) -> None:
    register(client, "owner@example.com", "taken_one")
    tokens = register(client, "other@example.com", "other_one")
    response = client.patch(
        "/v1/players/me", json={"username": "TAKEN_ONE"}, headers=auth_headers(tokens)
    )
    assert response.status_code == 409


def test_patch_validates_username_and_requires_auth(client: TestClient) -> None:
    tokens = register(client, "val@example.com", "val_user")
    bad = client.patch("/v1/players/me", json={"username": "x"}, headers=auth_headers(tokens))
    assert bad.status_code == 422
    unauth = client.patch("/v1/players/me", json={"username": "fine_name"})
    assert unauth.status_code == 401


def test_delete_hard_deletes_account(client: TestClient) -> None:
    tokens = register(client, "bye@example.com", "bye_user")
    response = client.delete("/v1/players/me", headers=auth_headers(tokens))
    assert response.status_code == 204
    assert response.content == b""

    login = client.post("/v1/auth/login", json={"email": "bye@example.com", "password": PASSWORD})
    assert login.status_code == 401
    assert client.get("/v1/players/me", headers=auth_headers(tokens)).status_code == 401
    # The username is free again after a hard delete.
    again = register(client, "new@example.com", "bye_user")
    assert again["access_token"]


def test_delete_requires_auth(client: TestClient) -> None:
    assert client.delete("/v1/players/me").status_code == 401
