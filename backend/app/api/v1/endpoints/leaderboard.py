"""
CIRCULUS API - Leaderboard & Weekly Podium Endpoints
"""
import uuid
from datetime import date, timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.dependencies import get_db, CurrentUser
from app.models.points import (
    DailyLeaderboard,
    WeeklyLeaderboard,
    LifetimeLeaderboard,
    PodiumHistory,
)
from app.schemas.points import LeaderboardEntry, PodiumHistoryRead, PointsSummary
from app.services.points_service import PointsService

router = APIRouter(prefix="/leaderboard", tags=["Leaderboard & Competitions"])


@router.get("/daily", response_model=List[LeaderboardEntry])
async def get_daily_leaderboard(
    limit: int = Query(25, le=100),
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Retrieve top members in the daily leaderboard."""
    today = date.today()
    stmt = (
        select(DailyLeaderboard)
        .where(DailyLeaderboard.date == today)
        .order_by(desc(DailyLeaderboard.points))
        .limit(limit)
    )
    res = await db.execute(stmt)
    entries = res.scalars().all()
    return [
        LeaderboardEntry(user_id=e.user_id, rank=idx + 1, points=e.points)
        for idx, e in enumerate(entries)
    ]


@router.get("/weekly", response_model=List[LeaderboardEntry])
async def get_weekly_leaderboard(
    limit: int = Query(25, le=100),
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Retrieve top members for the current competition week."""
    today = date.today()
    week_start = today - timedelta(days=today.weekday())
    stmt = (
        select(WeeklyLeaderboard)
        .where(WeeklyLeaderboard.week_start == week_start)
        .order_by(desc(WeeklyLeaderboard.points))
        .limit(limit)
    )
    res = await db.execute(stmt)
    entries = res.scalars().all()
    return [
        LeaderboardEntry(user_id=e.user_id, rank=idx + 1, points=e.points)
        for idx, e in enumerate(entries)
    ]


@router.get("/lifetime", response_model=List[LeaderboardEntry])
async def get_lifetime_leaderboard(
    limit: int = Query(25, le=100),
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Retrieve cumulative all-time points leaderboard."""
    stmt = (
        select(LifetimeLeaderboard)
        .order_by(desc(LifetimeLeaderboard.points))
        .limit(limit)
    )
    res = await db.execute(stmt)
    entries = res.scalars().all()
    return [
        LeaderboardEntry(user_id=e.user_id, rank=idx + 1, points=e.points)
        for idx, e in enumerate(entries)
    ]


@router.get("/podium/history", response_model=List[PodiumHistoryRead])
async def get_podium_history(
    limit: int = Query(10, le=52),
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Retrieve past weekly podium winners (Gold, Silver, Bronze permanent records)."""
    stmt = (
        select(PodiumHistory)
        .order_by(desc(PodiumHistory.week_start))
        .limit(limit)
    )
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.get("/summary", response_model=PointsSummary)
async def get_user_points_summary(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Fetch current authenticated user's points across daily, weekly, and lifetime."""
    today = date.today()
    week_start = today - timedelta(days=today.weekday())

    d_res = await db.execute(
        select(DailyLeaderboard).where(
            DailyLeaderboard.user_id == current_user.id,
            DailyLeaderboard.date == today
        )
    )
    daily = d_res.scalar_one_or_none()

    w_res = await db.execute(
        select(WeeklyLeaderboard).where(
            WeeklyLeaderboard.user_id == current_user.id,
            WeeklyLeaderboard.week_start == week_start
        )
    )
    weekly = w_res.scalar_one_or_none()

    l_res = await db.execute(
        select(LifetimeLeaderboard).where(LifetimeLeaderboard.user_id == current_user.id)
    )
    lifetime = l_res.scalar_one_or_none()

    return PointsSummary(
        daily_points=daily.points if daily else 0,
        weekly_points=weekly.points if weekly else 0,
        lifetime_points=lifetime.points if lifetime else 0,
        daily_rank=daily.rank if daily else None,
        weekly_rank=weekly.rank if weekly else None,
        lifetime_rank=lifetime.rank if lifetime else None,
    )
