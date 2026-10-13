from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # App
    app_name: str = "dropgrid"
    debug: bool = True
    api_prefix: str = "/v1"

    # Database. Default is local SQLite. For Postgres (local Docker Compose or Neon),
    # set DATABASE_URL to the provider's URL as-is, e.g.
    # postgresql://user:pass@host/db?sslmode=require. core/db_url.py converts it.
    database_url: str = "sqlite+aiosqlite:///./dropgrid.db"

    # Auth
    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30

    # Rate limiting: per client IP, per auth endpoint, sliding 60 s window.
    # Set RATE_LIMIT_ENABLED=false in tests (or any local harness) to bypass.
    rate_limit_enabled: bool = True
    rate_limit_per_minute: int = 10

    # CORS origins (comma-separated). The Next.js prototype dev server.
    cors_origins: str = "http://localhost:3000"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
