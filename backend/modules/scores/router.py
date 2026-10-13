"""Placeholder score routes. Handlers land in Phase 9 of the implementation plan."""

from fastapi import APIRouter

from core.exceptions import NotImplementedException
from modules.scores.schemas import LeaderboardOut, SyncIn, SyncOut

router = APIRouter(tags=["scores"])

_NOT_IMPLEMENTED = "scores is scaffolded but not implemented yet (Phase 9)"


@router.post("/sync", response_model=SyncOut)
async def sync(data: SyncIn) -> SyncOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)


@router.get("/leaderboard", response_model=LeaderboardOut)
async def leaderboard() -> LeaderboardOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)
