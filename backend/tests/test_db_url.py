from core.db_url import resolve_database_url


def test_sqlite_url_is_untouched() -> None:
    url, kwargs = resolve_database_url("sqlite+aiosqlite:///./dropgrid.db")
    assert url == "sqlite+aiosqlite:///./dropgrid.db"
    assert kwargs == {}


def test_neon_url_becomes_asyncpg_and_drops_libpq_params() -> None:
    url, kwargs = resolve_database_url(
        "postgresql://user:pw@ep-x.neon.tech/db?sslmode=require&channel_binding=require"
    )
    assert url == "postgresql+asyncpg://user:pw@ep-x.neon.tech/db"
    assert kwargs["connect_args"]["ssl"] is True
    assert kwargs["connect_args"]["statement_cache_size"] == 0
    assert kwargs["connect_args"]["prepared_statement_cache_size"] == 0


def test_postgres_scheme_alias_is_accepted() -> None:
    url, _ = resolve_database_url("postgres://user:pw@localhost:5432/dropgrid")
    assert url == "postgresql+asyncpg://user:pw@localhost:5432/dropgrid"


def test_local_docker_url_has_no_ssl() -> None:
    url, kwargs = resolve_database_url("postgresql://dropgrid:dropgrid@localhost:5432/dropgrid")
    assert url == "postgresql+asyncpg://dropgrid:dropgrid@localhost:5432/dropgrid"
    assert "ssl" not in kwargs["connect_args"]
    assert kwargs["connect_args"]["statement_cache_size"] == 0


def test_sslmode_disable_means_no_ssl() -> None:
    _, kwargs = resolve_database_url("postgresql://u:p@h/db?sslmode=disable")
    assert "ssl" not in kwargs["connect_args"]
