from functools import lru_cache

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # App. ENVIRONMENT=production turns on startup safety checks (see below).
    environment: str = "development"
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

    # Shown on the privacy page. Unset = no contact line (set it on the host's environment).
    contact_email: str = ""

    # Browser origins allowed by CORS (comma-separated). The Godot client does not
    # need CORS, so none are allowed by default.
    cors_origins: str = ""

    @model_validator(mode="after")
    def _require_real_secret_in_production(self) -> "Settings":
        if self.environment.lower() == "production" and (
            self.jwt_secret == "change-me" or len(self.jwt_secret) < 32
        ):
            raise ValueError("JWT_SECRET must be a random string of 32+ chars in production")
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
