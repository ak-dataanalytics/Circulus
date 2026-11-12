"""
CIRCULUS API - Admin Management & System Operations
"""
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, update, desc

from app.core.dependencies import get_db, require_admin, CurrentUser
from app.models.user import Profile, UserRole
from app.models.community import Community
from app.models.post import Post
from app.models.event import Event
from app.models.admin import Report, AuditLog, PlatformSetting
from app.schemas.admin import AdminDashboardStats, ReportRead, ReportAction, AuditLogRead

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])


@router.get("/stats", response_model=AdminDashboardStats)
async def get_dashboard_stats(
    admin: CurrentUser = require_admin(),
    db: AsyncSession = Depends(get_db)
):
    """Provides key metrics for the Admin Dashboard."""
    total_m = (await db.execute(select(func.count(Profile.id)))).scalar_one() or 0
    active_m = (await db.execute(select(func.count(Profile.id)).where(Profile.is_active == True))).scalar_one() or 0
    pending_v = (await db.execute(select(func.count(Profile.id)).where(Profile.is_verified == False))).scalar_one() or 0
    
    faculty_cnt = (
        await db.execute(
            select(func.count(UserRole.id)).where(UserRole.role == "faculty")
        )
    ).scalar_one() or 0

    officer_cnt = (
        await db.execute(
            select(func.count(UserRole.id)).where(UserRole.role.in_(["officer", "student"]))
        )
    ).scalar_one() or 0

    total_c = (await db.execute(select(func.count(Community.id)))).scalar_one() or 0
    total_p = (await db.execute(select(func.count(Post.id)))).scalar_one() or 0
    total_e = (await db.execute(select(func.count(Event.id)))).scalar_one() or 0

    return AdminDashboardStats(
        total_members=total_m,
        active_members=active_m,
        pending_approvals=pending_v,
        faculty_count=faculty_cnt,
        officer_count=officer_cnt,
        total_communities=total_c,
        total_posts=total_p,
        total_events=total_e,
        daily_active_users=active_m // 2 if active_m > 0 else 0
    )


@router.post("/members/{user_id}/verify", status_code=status.HTTP_200_OK)
async def verify_member(
    user_id: uuid.UUID,
    admin: CurrentUser = require_admin(),
    db: AsyncSession = Depends(get_db)
):
    """Admin approves officer verification."""
    res = await db.execute(select(Profile).where(Profile.id == user_id))
    profile = res.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Member not found.")
    profile.is_verified = True
    await db.commit()
    return {"message": "Member verified successfully."}


@router.post("/members/{user_id}/suspend", status_code=status.HTTP_200_OK)
async def suspend_member(
    user_id: uuid.UUID,
    admin: CurrentUser = require_admin(),
    db: AsyncSession = Depends(get_db)
):
    """Suspend or reactivate an account."""
    res = await db.execute(select(Profile).where(Profile.id == user_id))
    profile = res.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Member not found.")
    profile.is_active = not profile.is_active
    await db.commit()
    return {"message": f"Account active status changed to {profile.is_active}"}


@router.get("/reports", response_model=List[ReportRead])
async def list_reports(
    status: Optional[str] = None,
    admin: CurrentUser = require_admin(),
    db: AsyncSession = Depends(get_db)
):
    """List moderation reports."""
    stmt = select(Report).order_by(desc(Report.created_at))
    if status:
        stmt = stmt.where(Report.status == status)
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.get("/audit-logs", response_model=List[AuditLogRead])
async def list_audit_logs(
    limit: int = Query(50, le=200),
    admin: CurrentUser = require_admin(),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve security and administrative audit trail."""
    stmt = select(AuditLog).order_by(desc(AuditLog.created_at)).limit(limit)
    res = await db.execute(stmt)
    return list(res.scalars().all())
