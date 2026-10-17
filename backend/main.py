import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import settings
from modules.auth.router import router as auth_router
from modules.players.router import router as players_router
from modules.scores.router import router as scores_router
from modules.web.router import router as web_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")

# Keep in sync with backend/pyproject.toml.
APP_VERSION = "0.1.0"

DESCRIPTION = """\
Backend for **DropGrid**, a portrait falling-block puzzle game for Android.

Guest play is fully offline: the game works with no network at all. These
endpoints power the optional account features — sign-in, profile, stats
sync, and a global leaderboard.

- **Base path:** `/v1`
- **Auth:** JWT bearer tokens. Access tokens last 30 minutes; refresh
  tokens last 30 days and survive password changes only until the next
  refresh (`pv` claim).
- **Sync merge rule:** `max(server, client)` per stat, guarded by
  server-side plausibility checks (score vs. lines).
- **Rate limits:** per-IP sliding 60 s window on auth endpoints. The
  limiter lives in process memory, so the service runs as one instance.

Accounts can be deleted in the game or on the
[account deletion page](/account/delete); the
[privacy policy](/privacy) describes what is stored. The full client
contract lives in the repository: `docs/README_ARCHITECTURE.md`, section 9.
"""

TAGS_METADATA = [
    {"name": "auth", "description": "Create an account, sign in, and refresh tokens."},
    {"name": "players", "description": "The signed-in player's profile and account deletion."},
    {"name": "scores", "description": "Stats sync and the global leaderboard."},
    {"name": "health", "description": "Liveness probe for deploys and uptime checks."},
]

_contact: dict[str, str] = {"name": "DropGrid"}
if settings.contact_email:
    _contact["email"] = settings.contact_email

app = FastAPI(
    title="DropGrid API",
    summary="Accounts, stats sync, and leaderboard for the DropGrid game.",
    description=DESCRIPTION,
    version=APP_VERSION,
    contact=_contact,
    license_info={"name": "MIT", "identifier": "MIT"},
    openapi_tags=TAGS_METADATA,
    docs_url="/docs" if settings.debug else None,
    redoc_url=None,
    openapi_url="/openapi.json" if settings.debug else None,
)

origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["health"], summary="Liveness probe")
async def health() -> dict[str, str]:
    """Return 200 while the service is up; used as the Render health check."""
    return {"status": "ok", "app": settings.app_name}


# ── Routers ───────────────────────────────────────────────────────────
# All game-facing routes mount under /v1 (see docs/README_ARCHITECTURE.md
# section 9 for the full API contract).
app.include_router(auth_router, prefix=settings.api_prefix)
app.include_router(players_router, prefix=settings.api_prefix)
app.include_router(scores_router, prefix=settings.api_prefix)

# Plain HTML pages (privacy policy, account deletion) live outside /v1.
app.include_router(web_router)
