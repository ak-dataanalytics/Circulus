"""
CIRCULUS API - Authentication & Registration Endpoints
"""
import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import create_access_token, verify_password
from app.models.user import Profile, UserRole
from app.schemas.invitation import InvitationVerify, InvitationRegister, InvitationRead
from app.schemas.user import ProfileRead
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/verify-invitation")
async def verify_invitation(payload: InvitationVerify, db: AsyncSession = Depends(get_db)):
    """Verifies that an invitation code is valid, non-expired, and has remaining uses."""
    inv = await AuthService.verify_invitation(db, payload.invitation_code)
    return {
        "valid": True,
        "email": inv.email,
        "role": inv.role,
        "department_id": inv.department_id,
        "batch_id": inv.batch_id,
        "message": inv.message
    }


@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register(payload: InvitationRegister, db: AsyncSession = Depends(get_db)):
    """Registers a new officer or faculty member using an invitation code."""
    profile = await AuthService.register_with_invitation(db, payload)
    token = create_access_token({"sub": str(profile.id), "email": profile.email})
    return {
        "access_token": token,
        "token_type": "bearer",
        "user_id": profile.id,
        "is_verified": profile.is_verified,
        "message": "Registration successful. Awaiting administrator verification."
    }


@router.post("/login", response_model=dict)
async def login(email: str, db: AsyncSession = Depends(get_db)):
    """Passwordless or Supabase Auth token exchange entrypoint."""
    res = await db.execute(select(Profile).where(Profile.email == email))
    profile = res.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Account not found.")
    if not profile.is_active:
        raise HTTPException(status_code=403, detail="Account is suspended.")

    token = create_access_token({"sub": str(profile.id), "email": profile.email})
    return {
        "access_token": token,
        "token_type": "bearer",
        "user_id": profile.id,
        "is_verified": profile.is_verified
    }
