"""
CIRCULUS Service - Authentication & Invitation Validation
"""
import secrets
import string
import uuid
from datetime import datetime, timedelta, timezone
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.core.config import Settings
from app.core.security import get_password_hash, create_access_token, verify_password
from app.models.user import Profile, UserRole
from app.models.invitation import Invitation
from app.schemas.invitation import InvitationRegister

settings = Settings()


class AuthService:
    @staticmethod
    def generate_invitation_code(length: int = 12) -> str:
        chars = string.ascii_uppercase + string.digits
        return "".join(secrets.choice(chars) for _ in range(length))

    @staticmethod
    async def verify_invitation(db: AsyncSession, code: str) -> Invitation:
        stmt = select(Invitation).where(
            Invitation.invitation_code == code,
            Invitation.status == "pending"
        )
        result = await db.execute(stmt)
        invitation = result.scalar_one_or_none()
        if not invitation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Invalid or expired invitation code."
            )
        if invitation.expires_at and invitation.expires_at < datetime.now(timezone.utc):
            invitation.status = "expired"
            await db.commit()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This invitation has expired."
            )
        if invitation.use_count >= invitation.max_uses:
            invitation.status = "accepted"
            await db.commit()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This invitation has already reached its maximum uses."
            )
        return invitation

    @staticmethod
    async def register_with_invitation(
        db: AsyncSession, register_data: InvitationRegister
    ) -> Profile:
        invitation = await AuthService.verify_invitation(db, register_data.invitation_code)

        # Check existing user
        existing_stmt = select(Profile).where(
            (Profile.email == register_data.email) | (Profile.username == register_data.username)
        )
        res = await db.execute(existing_stmt)
        if res.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email or username already in use."
            )

        new_profile = Profile(
            id=uuid.uuid4(),
            email=register_data.email,
            username=register_data.username,
            full_name=register_data.full_name,
            phone=register_data.phone,
            department_id=register_data.department_id or invitation.department_id,
            batch_id=register_data.batch_id or invitation.batch_id,
            bio=register_data.bio,
            is_active=True,
            is_verified=False,  # Requires Admin Approval per Master Prompt
            is_onboarded=True,
        )
        db.add(new_profile)

        # Assign Role
        role = UserRole(
            id=uuid.uuid4(),
            user_id=new_profile.id,
            role=invitation.role or "officer",
            assigned_by=invitation.invited_by
        )
        db.add(role)

        # Update invitation
        invitation.use_count += 1
        invitation.accepted_at = datetime.now(timezone.utc)
        if invitation.use_count >= invitation.max_uses:
            invitation.status = "accepted"

        await db.commit()
        await db.refresh(new_profile)
        return new_profile
