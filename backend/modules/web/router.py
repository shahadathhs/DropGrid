"""Plain HTML pages: privacy policy and account deletion (store requirements).

Self-contained (inline CSS, no external assets). Everything rendered from user
input or settings goes through html.escape.
"""

from html import escape
from typing import Annotated

from fastapi import APIRouter, Depends, Form
from fastapi.responses import HTMLResponse

from core.config import settings
from core.ratelimit import rate_limit
from core.security.deps import DbSession
from modules.auth.router import authenticate
from modules.players.router import delete_player

router = APIRouter(include_in_schema=False)

_CSS = (
    "body{font:16px/1.5 system-ui,sans-serif;max-width:40rem;margin:2rem auto;padding:0 1rem;"
    "color:#1a1a1a;background:#fff}h1{font-size:1.6rem}label{display:block;margin:1rem 0 .25rem}"
    "input{width:100%;padding:.5rem;font-size:1rem;box-sizing:border-box}"
    "button{margin-top:1.25rem;padding:.6rem 1.2rem;font-size:1rem}"
    ".error{color:#b00020}@media(prefers-color-scheme:dark){body{color:#eee;background:#161616}"
    ".error{color:#ff6b81}input{background:#222;color:#eee;border:1px solid #555}}"
)


def _page(title: str, body: str, status_code: int = 200) -> HTMLResponse:
    html = (
        '<!doctype html><html lang="en"><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        f"<title>{escape(title)}</title><style>{_CSS}</style></head><body>{body}</body></html>"
    )
    return HTMLResponse(
        html,
        status_code=status_code,
        headers={"Cache-Control": "no-store", "X-Frame-Options": "DENY"},
    )


@router.get("/privacy")
async def privacy() -> HTMLResponse:
    contact = ""
    if settings.contact_email.strip():
        contact = f"<h2>Contact</h2><p>{escape(settings.contact_email.strip())}</p>"
    body = f"""
<h1>{escape(settings.app_name)} privacy policy</h1>
<h2>Playing without an account</h2>
<p>If you play as a guest, the game sends nothing to our servers. Your progress stays on
your device.</p>
<h2>What we collect</h2>
<p>Only if you create an account: your email address, a username, and three game
statistics: your best score, total lines cleared and games played.</p>
<h2>Why</h2>
<p>To run your account (sign in, carry your progress to a new phone) and to show the
leaderboard.</p>
<h2>What is public</h2>
<p>Your username and best score appear on the public leaderboard. Your email is never
shown to other players.</p>
<h2>What we do not do</h2>
<p>No ads, no analytics, no third-party SDKs, and we do not sell or share your data. Our
hosting and database providers store the data on our behalf.</p>
<h2>Retention and deletion</h2>
<p>We keep your data until you delete your account. You can delete it inside the app, or
on the <a href="/account/delete">web deletion page</a>. Deletion removes your account and
all its data immediately.</p>
<h2>Known limitation</h2>
<p>There is no password reset yet. If you lose your password, your synced copy cannot be
recovered (the stats on your device stay).</p>
{contact}
"""
    return _page("Privacy policy", body)


def _delete_form(error: str = "", email: str = "") -> str:
    err = f'<p class="error" role="alert">{escape(error)}</p>' if error else ""
    return f"""
<h1>Delete your {escape(settings.app_name)} account</h1>
<p>Enter your account email and password. This permanently deletes your account, username
and synced stats, and removes you from the leaderboard. It cannot be undone.</p>
{err}
<form method="post" action="/account/delete">
<label for="email">Email</label>
<input id="email" name="email" type="email" autocomplete="username" required
value="{escape(email, quote=True)}">
<label for="password">Password</label>
<input id="password" name="password" type="password" autocomplete="current-password" required>
<button type="submit">Delete my account</button>
</form>
<p><a href="/privacy">Privacy policy</a></p>
"""


@router.get("/account/delete")
async def delete_form() -> HTMLResponse:
    return _page("Delete account", _delete_form())


@router.post("/account/delete", dependencies=[Depends(rate_limit("login"))])
async def delete_submit(
    db: DbSession,
    email: Annotated[str, Form(max_length=320)] = "",
    password: Annotated[str, Form(max_length=128)] = "",
) -> HTMLResponse:
    player = await authenticate(db, email.strip().lower(), password)
    if player is None:
        return _page(
            "Delete account",
            _delete_form("Invalid email or password.", email),
            status_code=401,
        )
    await delete_player(db, player)
    return _page(
        "Account deleted",
        f"<h1>Account deleted</h1><p>Your {escape(settings.app_name)} account and its data "
        "have been permanently deleted.</p>",
    )
