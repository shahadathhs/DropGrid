"""Shared Pydantic field types so auth and players agree on normalization."""

from typing import Annotated

from pydantic import AfterValidator, EmailStr, Field

from core.blocklist import is_blocked_username

BCRYPT_MAX_BYTES = 72


def _lower(value: str) -> str:
    return value.lower()


def _check_username_allowed(value: str) -> str:
    if is_blocked_username(value):
        raise ValueError("username is not allowed")
    return value


def _check_bcrypt_length(value: str) -> str:
    if len(value.encode("utf-8")) > BCRYPT_MAX_BYTES:
        raise ValueError(f"password must be at most {BCRYPT_MAX_BYTES} bytes in UTF-8")
    return value


# Stored and compared lowercase; the unique index is therefore case-insensitive.
NormalizedEmail = Annotated[EmailStr, AfterValidator(_lower)]
Username = Annotated[
    str,
    Field(min_length=3, max_length=20, pattern=r"^[A-Za-z0-9_]+$"),
    AfterValidator(_lower),
    AfterValidator(_check_username_allowed),
]
NewPassword = Annotated[
    str,
    Field(min_length=8, max_length=128),
    AfterValidator(_check_bcrypt_length),
]
