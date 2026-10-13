from pydantic import BaseModel, Field

from core.validation import NewPassword, NormalizedEmail, Username


class RegisterIn(BaseModel):
    email: NormalizedEmail
    password: NewPassword
    username: Username


class LoginIn(BaseModel):
    email: NormalizedEmail
    password: str = Field(min_length=1, max_length=128)


class RefreshIn(BaseModel):
    refresh_token: str = Field(min_length=1)


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
