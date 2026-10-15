from fastapi.testclient import TestClient

from tests.conftest import auth_headers, register


def _sync(client: TestClient, tokens: dict, best: int, lines: int, games: int):
    return client.post(
        "/v1/sync",
        json={"best_score": best, "total_lines": lines, "games_played": games},
        headers=auth_headers(tokens),
    )


def test_sync_returns_merged_profile(client: TestClient) -> None:
    tokens = register(client, "sync@example.com", "sync_user")
    response = client.post(
        "/v1/sync",
        json={"best_score": 120, "total_lines": 15, "games_played": 3},
        headers=auth_headers(tokens),
    )
    assert response.status_code == 200
    body = response.json()
    assert body["username"] == "sync_user"
    assert body["email"] == "sync@example.com"
    assert (body["best_score"], body["total_lines"], body["games_played"]) == (120, 15, 3)


def test_sync_takes_max_per_stat(client: TestClient) -> None:
    tokens = register(client, "max@example.com", "max_user")
    _sync(client, tokens, 500, 40, 10)
    # Client sends higher best and games, lower lines.
    body = _sync(client, tokens, 700, 25, 12).json()
    assert (body["best_score"], body["total_lines"], body["games_played"]) == (700, 40, 12)


def test_lower_client_value_never_lowers_server(client: TestClient) -> None:
    tokens = register(client, "lower@example.com", "lower_user")
    _sync(client, tokens, 900, 90, 9)
    body = _sync(client, tokens, 10, 1, 1).json()
    assert (body["best_score"], body["total_lines"], body["games_played"]) == (900, 90, 9)
    # Profile reflects the stored merge, not just the response.
    profile = client.get("/v1/players/me", headers=auth_headers(tokens)).json()
    assert (profile["best_score"], profile["total_lines"], profile["games_played"]) == (900, 90, 9)


def test_sync_accepts_bounds_and_rejects_out_of_range(client: TestClient) -> None:
    tokens = register(client, "bounds@example.com", "bounds_user")
    assert _sync(client, tokens, 2_000_000_000, 2_000_000_000, 1).status_code == 200
    assert _sync(client, tokens, -1, 0, 1).status_code == 422
    assert _sync(client, tokens, 2_000_000_001, 0, 1).status_code == 422
    assert _sync(client, tokens, 0, 0, -5).status_code == 422


def test_sync_requires_auth(client: TestClient) -> None:
    response = client.post("/v1/sync", json={"best_score": 1, "total_lines": 1, "games_played": 1})
    assert response.status_code == 401


def test_sync_plausibility_boundary(client: TestClient) -> None:
    tokens = register(client, "plaus@example.com", "plaus_user")
    # 25 lines: 200 * 25 * (10 + 2) = 60000
    assert _sync(client, tokens, 60_000, 25, 5).status_code == 200
    over = _sync(client, tokens, 60_001, 25, 5)
    assert over.status_code == 422
    assert "detail" in over.json()


def test_sync_rejects_score_with_no_lines(client: TestClient) -> None:
    tokens = register(client, "zero@example.com", "zero_user")
    assert _sync(client, tokens, 1, 0, 1).status_code == 422
    assert _sync(client, tokens, 0, 0, 1).status_code == 200


def test_sync_rejects_progress_without_games(client: TestClient) -> None:
    tokens = register(client, "nog@example.com", "nog_user")
    assert _sync(client, tokens, 0, 5, 0).status_code == 422
    assert _sync(client, tokens, 100, 0, 0).status_code == 422
    assert _sync(client, tokens, 0, 0, 0).status_code == 200
