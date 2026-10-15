"""Username blocklist: the leaderboard shows usernames publicly.

Usernames are [a-z0-9_] only (core/validation.py). To catch simple evasions the
name is normalised (leetspeak digits mapped to letters, remaining digits and
underscores dropped) and then compared against a short list of terms.

Matching avoids the Scunthorpe problem (innocent names that merely contain a
bad substring, such as "classic" or "cockpit_pilot"):
  - terms shorter than SUBSTRING_MIN_LEN match only a whole token (a part of the
    name split on "_") or the entire normalised name;
  - longer terms are distinctive enough to match anywhere in the normalised name.
The cost is that glued-together short words ("xshitx") are not caught. This is a
cheap first line of defence, not moderation; extend the lists as needed.
"""

import re
from typing import Final

SUBSTRING_MIN_LEN: Final = 5

_LEET: Final = str.maketrans({"0": "o", "1": "i", "3": "e", "4": "a", "5": "s", "7": "t"})

# Reserved and impersonating names.
RESERVED: Final = frozenset(
    {
        "admin",
        "administrator",
        "moderator",
        "mod",
        "dropgrid",
        "support",
        "system",
        "staff",
        "official",
        "root",
        "null",
        "undefined",
        "anonymous",
        "guest",
    }
)

# Common slurs and profanity (kept deliberately modest).
OFFENSIVE: Final = frozenset(
    {
        "fuck",
        "shit",
        "cunt",
        "bitch",
        "asshole",
        "dick",
        "cock",
        "pussy",
        "whore",
        "slut",
        "rape",
        "rapist",
        "nigger",
        "nigga",
        "faggot",
        "fag",
        "retard",
        "kike",
        "spic",
        "chink",
        "tranny",
        "nazi",
        "hitler",
    }
)

_TERMS: Final = RESERVED | OFFENSIVE
_LONG_TERMS: Final = tuple(t for t in _TERMS if len(t) >= SUBSTRING_MIN_LEN)
_NON_LETTERS: Final = re.compile(r"[^a-z]")


def _normalise(token: str) -> str:
    return _NON_LETTERS.sub("", token.lower().translate(_LEET))


def is_blocked_username(username: str) -> bool:
    tokens = {_normalise(part) for part in re.split(r"[_.]", username.lower())}
    tokens.discard("")
    whole = _normalise(username)
    candidates = tokens | {whole}
    if candidates & _TERMS:
        return True
    return any(term in whole for term in _LONG_TERMS)
