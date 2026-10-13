import bcrypt

from core.validation import BCRYPT_MAX_BYTES


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, password_hash: str) -> bool:
    # bcrypt 5 raises on inputs over 72 bytes. No such password can have been
    # registered (the schema rejects it), so treat it as a plain mismatch.
    if len(password.encode()) > BCRYPT_MAX_BYTES:
        return False
    return bcrypt.checkpw(password.encode(), password_hash.encode())
