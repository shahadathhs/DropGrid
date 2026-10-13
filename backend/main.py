import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import settings
from modules.auth.router import router as auth_router
from modules.players.router import router as players_router
from modules.scores.router import router as scores_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")

app = FastAPI(
    title=settings.app_name,
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


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok", "app": settings.app_name}


# ── Routers ───────────────────────────────────────────────────────────
# All game-facing routes mount under /v1 (see docs/README_ARCHITECTURE.md
# section 9 for the full API contract). Phase 9 fills in the handlers.
app.include_router(auth_router, prefix=settings.api_prefix)
app.include_router(players_router, prefix=settings.api_prefix)
app.include_router(scores_router, prefix=settings.api_prefix)
