from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # App
    app_name: str = "afterdrop"
    debug: bool = True
    api_prefix: str = "/v1"

    # Database — SQLite in development, PostgreSQL in production
    # (postgresql+asyncpg://...).
    database_url: str = "sqlite+aiosqlite:///./afterdrop.db"

    # Auth
    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30

    # CORS origins (comma-separated). The Next.js prototype dev server.
    cors_origins: str = "http://localhost:3000"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
