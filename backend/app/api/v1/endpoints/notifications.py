"""
CIRCULUS API - Notifications & User Preferences
"""
import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, desc

from app.core.dependencies import get_db, CurrentUser
from app.models.notification import Notification, UserNotificationPreference
from app.schemas.notification import NotificationRead, NotificationPreferenceRead, NotificationPreferenceUpdate

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("/", response_model=List[NotificationRead])
async def list_notifications(
    current_user: CurrentUser,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    """Retrieve personal notifications for the authenticated user."""
    stmt = (
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .order_by(desc(Notification.created_at))
        .limit(limit)
    )
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.patch("/{notification_id}/read", status_code=status.HTTP_204_NO_CONTENT)
async def mark_as_read(
    notification_id: uuid.UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Mark a specific notification as read."""
    await db.execute(
        update(Notification)
        .where(Notification.id == notification_id, Notification.user_id == current_user.id)
        .values(is_read=True)
    )
    await db.commit()
