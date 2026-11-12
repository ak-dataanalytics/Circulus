"""
CIRCULUS API - Invitation Management Endpoints
"""
import uuid
from datetime import datetime, timedelta, timezone
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.dependencies import get_db, get_current_user, require_admin, CurrentUser
from app.models.invitation import Invitation
from app.schemas.invitation import InvitationCreate, InvitationRead
from app.services.auth_service import AuthService

router = APIRouter(prefix="/invitations", tags=["Invitations"])


@router.post("/", response_model=InvitationRead, status_code=status.HTTP_201_CREATED)
async def create_invitation(
    payload: InvitationCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Generate a single-use or multi-use invitation code (Admin/Authorized Faculty)."""
    code = AuthService.generate_invitation_code()
    expires_at = datetime.now(timezone.utc) + timedelta(hours=payload.expires_in_hours)

    invitation = Invitation(
        id=uuid.uuid4(),
        email=payload.email,
        role=payload.role,
        invited_by=current_user.id,
        invitation_code=code,
        status="pending",
        department_id=payload.department_id,
        batch_id=payload.batch_id,
        message=payload.message,
        expires_at=expires_at,
        max_uses=payload.max_uses,
        use_count=0,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )
    db.add(invitation)
    await db.commit()
    await db.refresh(invitation)
    return invitation


@router.get("/", response_model=List[InvitationRead])
async def list_invitations(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """List invitations sent by current user or all if admin."""
    stmt = select(Invitation).order_by(desc(Invitation.created_at)).limit(100)
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.delete("/{invitation_id}", status_code=status.HTTP_204_NO_CONTENT)
async def revoke_invitation(
    invitation_id: uuid.UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Revoke an active invitation."""
    res = await db.execute(select(Invitation).where(Invitation.id == invitation_id))
    inv = res.scalar_one_or_none()
    if not inv:
        raise HTTPException(status_code=404, detail="Invitation not found.")
    inv.status = "revoked"
    await db.commit()
