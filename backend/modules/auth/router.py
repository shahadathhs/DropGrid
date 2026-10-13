"""Placeholder auth routes. Handlers land in Phase 9 of the implementation plan."""

from fastapi import APIRouter

from core.exceptions import NotImplementedException
from modules.auth.schemas import LoginIn, RegisterIn, TokensOut

router = APIRouter(prefix="/auth", tags=["auth"])

_NOT_IMPLEMENTED = "auth is scaffolded but not implemented yet (Phase 9)"


@router.post("/register", response_model=TokensOut)
async def register(data: RegisterIn) -> TokensOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)


@router.post("/login", response_model=TokensOut)
async def login(data: LoginIn) -> TokensOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)


@router.post("/refresh", response_model=TokensOut)
async def refresh() -> TokensOut:
    raise NotImplementedException(_NOT_IMPLEMENTED)
