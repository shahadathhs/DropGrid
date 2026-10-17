from datetime import UTC, datetime, timedelta

from fastapi.testclient import TestClient

from tests.conftest import auth_headers, register

TODAY = datetime.now(UTC).strftime("%Y-%m-%d")
YESTERDAY = (datetime.now(UTC) - timedelta(days=1)).strftime("%Y-%m-%d")


def _category(client: TestClient, category: str, period: str = "all") -> dict:
    response = client.get(f"/v1/leaderboard?category={category}&period={period}")
    assert response.status_code == 200
    return response.json()


def _push_category(client: TestClient, tokens: dict, entry: dict):
    return client.post(
        "/v1/sync",
        json={"best_score": 0, "total_lines": 0, "games_played": 1, "categories": [entry]},
        headers=auth_headers(tokens),
    )


def test_categories_end_to_end(client: TestClient) -> None:
    tokens = register(client, "cat@example.com", "cat_user")
    entries = [
        {"category": "sprint", "score": 40, "lines": 40, "duration_ms": 63_000},
        {"category": "ultra", "score": 1_800, "lines": 12},
        {"category": "daily", "score": 2_400, "lines": 14, "date": TODAY},
    ]
    for entry in entries:
        response = _push_category(client, tokens, entry)
        assert response.status_code == 200
    # The marathon best travels as best_score on the player row (legacy column).
    client.post(
        "/v1/sync",
        json={"best_score": 5_000, "total_lines": 30, "games_played": 3},
        headers=auth_headers(tokens),
    )

    marathon = _category(client, "marathon")
    assert marathon["entries"] == [
        {"rank": 1, "username": "cat_user", "score": 5_000, "lines": 30, "duration_ms": None}
    ]
    sprint = _category(client, "sprint")
    assert sprint["entries"][0]["duration_ms"] == 63_000
    ultra = _category(client, "ultra")
    assert ultra["entries"][0]["score"] == 1_800
    daily = _category(client, "daily", "today")
    assert daily["entries"][0]["score"] == 2_400
    assert daily["period"] == "today"


def test_sprint_ranks_lowest_duration_first(client: TestClient) -> None:
    tokens = register(client, "fast@example.com", "fast_user")
    slow = register(client, "slow@example.com", "slow_user")
    _push_category(
        client,
        tokens,
        {"category": "sprint", "score": 40, "lines": 40, "duration_ms": 61_000},
    )
    _push_category(
        client, slow, {"category": "sprint", "score": 40, "lines": 40, "duration_ms": 44_000}
    )
    entries = _category(client, "sprint")["entries"]
    assert [entry["username"] for entry in entries] == ["slow_user", "fast_user"]


def test_daily_only_accepts_today_and_isolates_days(client: TestClient) -> None:
    tokens = register(client, "daily@example.com", "daily_user")
    stale = _push_category(
        client, tokens, {"category": "daily", "score": 500, "lines": 4, "date": YESTERDAY}
    )
    assert stale.status_code == 422
    assert _push_category(
        client, tokens, {"category": "daily", "score": 500, "lines": 4, "date": TODAY}
    ).status_code == 200
    today = _category(client, "daily", "today")
    assert today["entries"][0]["score"] == 500


def test_daily_bests_merge_within_the_day(client: TestClient) -> None:
    tokens = register(client, "merge@example.com", "merge_user")
    _push_category(client, tokens, {"category": "daily", "score": 300, "lines": 2, "date": TODAY})
    _push_category(client, tokens, {"category": "daily", "score": 900, "lines": 6, "date": TODAY})
    assert _category(client, "daily", "today")["entries"][0]["score"] == 900


def test_implausible_categories_are_rejected(client: TestClient) -> None:
    tokens = register(client, "cheat@example.com", "cheat_user")
    too_many_lines = _push_category(
        client,
        tokens,
        {"category": "sprint", "score": 55, "lines": 55, "duration_ms": 60_000},
    )
    assert too_many_lines.status_code == 422
    too_fast = _push_category(
        client,
        tokens,
        {"category": "sprint", "score": 40, "lines": 40, "duration_ms": 900},
    )
    assert too_fast.status_code == 422
    absurd = _push_category(
        client, tokens, {"category": "ultra", "score": 99_999_999, "lines": 10}
    )
    assert absurd.status_code == 422


def test_unknown_category_is_rejected(client: TestClient) -> None:
    tokens = register(client, "zen@example.com", "zen_user")
    zen = _push_category(client, tokens, {"category": "zen", "score": 1, "lines": 1})
    assert zen.status_code == 422  # zen earns no leaderboard


def test_rank_endpoint_reports_the_players_own_row(client: TestClient) -> None:
    fast = register(client, "r1@example.com", "rank_one")
    me = register(client, "r2@example.com", "rank_two")
    _push_category(
        client, fast, {"category": "sprint", "score": 40, "lines": 40, "duration_ms": 30_000}
    )
    _push_category(
        client, me, {"category": "sprint", "score": 40, "lines": 40, "duration_ms": 50_000}
    )
    theirs = client.get(
        "/v1/leaderboard/rank?category=sprint&period=all", headers=auth_headers(fast)
    ).json()
    assert theirs["rank"] is not None
    mine = client.get(
        "/v1/leaderboard/rank?category=sprint&period=all", headers=auth_headers(me)
    ).json()
    # The board may hold rows from earlier tests; ours must simply rank behind
    # the faster one.
    assert mine["duration_ms"] == 50_000
    assert mine["rank"] > theirs["rank"]


def test_rank_is_none_without_a_score(client: TestClient) -> None:
    tokens = register(client, "r3@example.com", "rank_none")
    body = client.get(
        "/v1/leaderboard/rank?category=marathon&period=all", headers=auth_headers(tokens)
    ).json()
    assert body["rank"] is None
