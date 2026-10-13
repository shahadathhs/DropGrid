from fastapi.testclient import TestClient


def _entries(client: TestClient) -> list[dict]:
    response = client.get("/v1/leaderboard")
    assert response.status_code == 200
    return response.json()["entries"]


def test_leaderboard_is_public_and_empty_by_default(client: TestClient) -> None:
    assert _entries(client) == []


def test_leaderboard_orders_by_score_desc(client: TestClient, seed) -> None:
    seed(
        [
            {"email": "a@example.com", "username": "alpha", "best_score": 300},
            {"email": "b@example.com", "username": "bravo", "best_score": 900},
            {"email": "c@example.com", "username": "charlie", "best_score": 600},
        ]
    )
    assert _entries(client) == [
        {"rank": 1, "username": "bravo", "best_score": 900},
        {"rank": 2, "username": "charlie", "best_score": 600},
        {"rank": 3, "username": "alpha", "best_score": 300},
    ]


def test_ties_break_by_created_at_ascending(client: TestClient, seed) -> None:
    # Seeded in insertion order, so created_at ascends in this order.
    seed(
        [
            {"email": "first@example.com", "username": "first_in", "best_score": 500},
            {"email": "second@example.com", "username": "second_in", "best_score": 500},
            {"email": "third@example.com", "username": "third_in", "best_score": 500},
        ]
    )
    names = [entry["username"] for entry in _entries(client)]
    assert names == ["first_in", "second_in", "third_in"]


def test_zero_scores_are_excluded(client: TestClient, seed) -> None:
    seed(
        [
            {"email": "zero@example.com", "username": "zero_one", "best_score": 0},
            {"email": "pos@example.com", "username": "pos_one", "best_score": 1},
            {"email": "none@example.com", "username": "none_one", "total_lines": 50},
        ]
    )
    entries = _entries(client)
    assert [entry["username"] for entry in entries] == ["pos_one"]
    assert entries[0]["rank"] == 1


def test_leaderboard_is_capped_at_top_50(client: TestClient, seed) -> None:
    seed(
        [
            {"email": f"p{i}@example.com", "username": f"player_{i:02d}", "best_score": i * 10}
            for i in range(1, 61)  # 60 players, scores 10..600
        ]
    )
    entries = _entries(client)
    assert len(entries) == 50
    assert [entry["rank"] for entry in entries] == list(range(1, 51))
    assert entries[0] == {"rank": 1, "username": "player_60", "best_score": 600}
    assert entries[-1] == {"rank": 50, "username": "player_11", "best_score": 110}
    assert "player_10" not in {entry["username"] for entry in entries}


def test_leaderboard_reflects_sync(client: TestClient) -> None:
    from tests.conftest import auth_headers, register

    tokens = register(client, "sync_lb@example.com", "sync_lb")
    client.post(
        "/v1/sync",
        json={"best_score": 42, "total_lines": 4, "games_played": 1},
        headers=auth_headers(tokens),
    )
    assert _entries(client) == [{"rank": 1, "username": "sync_lb", "best_score": 42}]
