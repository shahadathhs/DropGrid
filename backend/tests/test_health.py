from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "app": "dropgrid"}


def test_planned_routes_answer_501_until_phase_9() -> None:
    login = client.post("/v1/auth/login", json={"email": "a@b.co", "password": "x"})
    assert login.status_code == 501
    assert client.get("/v1/leaderboard").status_code == 501
