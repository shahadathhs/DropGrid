"""Placeholder player routes. Handlers land in Phase 9 of the implementation plan."""

from fastapi import APIRouter

from core.exceptions import NotImplementedException
from modules.players.schemas import PlayerOut

router = APIRouter(prefix="/players", tags=["players"])

_NOT_IMPLEMENTED = "players is scaffolded but not implemented yet (Phase 9)"


@router.get("/me", response_model=PlayerOut)
async def me() -> PlayerOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)


@router.patch("/me", response_model=PlayerOut)
async def rename() -> PlayerOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)


@router.delete("/me")
async def delete_account() -> None:
    raise NotImplementedException(_NOT_IMPLEMENTED)
