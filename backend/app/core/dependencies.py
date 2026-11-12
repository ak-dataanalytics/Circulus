"""
CIRCULUS Application - Dependency Injection
"""
import uuid
from typing import Annotated, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_async_session
from app.core.security import decode_supabase_jwt
from app.models.user import Profile, UserRole

security_scheme = HTTPBearer(auto_error=False)


async def get_db() -> AsyncSession:
    """Database session dependency."""
    async for session in get_async_session():
        yield session


async def get_current_user(
    credentials: Annotated[Optional[HTTPAuthorizationCredentials], Depends(security_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Profile:
    """
    Extract & verify the Supabase JWT, then return the corresponding Profile row.
    Raises 401 if token is missing/invalid or no profile exists.
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication credentials missing",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        payload = decode_supabase_jwt(credentials.credentials)
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_id_str = payload.get("sub")
    if user_id_str is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")

    user_id = uuid.UUID(user_id_str)
    result = await db.execute(select(Profile).where(Profile.id == user_id))
    profile = result.scalar_one_or_none()

    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User profile not found")

    if not profile.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is deactivated")

    return profile


async def get_current_active_user(
    current_user: Annotated[Profile, Depends(get_current_user)],
) -> Profile:
    """Alias ensuring user is active (already checked in get_current_user)."""
    return current_user


async def require_role(
    role_name: str,
    current_user: Profile,
    db: AsyncSession,
) -> bool:
    """Check whether the user holds a given role. Raises 403 if not."""
    result = await db.execute(
        select(UserRole).where(
            UserRole.user_id == current_user.id,
            UserRole.role == role_name,
        )
    )
    role = result.scalar_one_or_none()
    if role is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Role '{role_name}' required",
        )
    return True


def require_admin():
    """Dependency that ensures the current user is an admin."""
    async def _inner(
        current_user: Annotated[Profile, Depends(get_current_user)],
        db: Annotated[AsyncSession, Depends(get_db)],
    ) -> Profile:
        await require_role("admin", current_user, db)
        return current_user
    return Depends(_inner)


def require_moderator():
    """Dependency that ensures the current user is a moderator or admin."""
    async def _inner(
        current_user: Annotated[Profile, Depends(get_current_user)],
        db: Annotated[AsyncSession, Depends(get_db)],
    ) -> Profile:
        result = await db.execute(
            select(UserRole).where(
                UserRole.user_id == current_user.id,
                UserRole.role.in_(["admin", "moderator"]),
            )
        )
        role = result.scalar_one_or_none()
        if role is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Moderator or Admin role required",
            )
        return current_user
    return Depends(_inner)


# Type aliases for convenience
DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUser = Annotated[Profile, Depends(get_current_user)]
