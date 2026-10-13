from fastapi import HTTPException, status


class UnauthorizedException(HTTPException):
    def __init__(self, detail: str = "Not authenticated", headers: dict[str, str] | None = None):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
            headers=headers or {"WWW-Authenticate": "Bearer"},
        )


class NotImplementedException(HTTPException):
    """Marks scaffolding for a planned endpoint as not implemented yet."""

    def __init__(self, detail: str):
        super().__init__(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=detail)
