"""
CIRCULUS Service - Points & Leaderboard Calculation Engine
"""
import uuid
from datetime import date, datetime, timedelta, timezone
from sqlalchemy import select, update, desc, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.points import (
    PointsTransaction,
    DailyLeaderboard,
    WeeklyLeaderboard,
    LifetimeLeaderboard,
    PodiumHistory,
    Achievement,
    UserAchievement,
)


class PointsService:
    @staticmethod
    async def award_points(
        db: AsyncSession,
        user_id: uuid.UUID,
        points: int,
        source: str,
        reference_id: uuid.UUID | None = None,
    ) -> tuple[int, int]:
        if points <= 0:
            return (0, 0)

        # 1. Record Transaction
        tx = PointsTransaction(
            id=uuid.uuid4(),
            user_id=user_id,
            points=points,
            source=source,
            reference_id=reference_id,
            created_at=datetime.now(timezone.utc),
        )
        db.add(tx)

        today = date.today()
        # Week start (Monday)
        week_start = today - timedelta(days=today.weekday())

        # 2. Update Daily Leaderboard
        daily_res = await db.execute(
            select(DailyLeaderboard).where(
                DailyLeaderboard.user_id == user_id,
                DailyLeaderboard.date == today
            )
        )
        daily = daily_res.scalar_one_or_none()
        if daily:
            daily.points += points
        else:
            daily = DailyLeaderboard(
                id=uuid.uuid4(),
                user_id=user_id,
                date=today,
                points=points,
                rank=0
            )
            db.add(daily)

        # 3. Update Weekly Leaderboard
        weekly_res = await db.execute(
            select(WeeklyLeaderboard).where(
                WeeklyLeaderboard.user_id == user_id,
                WeeklyLeaderboard.week_start == week_start
            )
        )
        weekly = weekly_res.scalar_one_or_none()
        if weekly:
            weekly.points += points
        else:
            weekly = WeeklyLeaderboard(
                id=uuid.uuid4(),
                user_id=user_id,
                week_start=week_start,
                points=points,
                rank=0
            )
            db.add(weekly)

        # 4. Update Lifetime Leaderboard
        life_res = await db.execute(
            select(LifetimeLeaderboard).where(LifetimeLeaderboard.user_id == user_id)
        )
        lifetime = life_res.scalar_one_or_none()
        if lifetime:
            lifetime.points += points
        else:
            lifetime = LifetimeLeaderboard(
                id=uuid.uuid4(),
                user_id=user_id,
                points=points,
                rank=0
            )
            db.add(lifetime)

        await db.flush()
        return (daily.points, weekly.points)

    @staticmethod
    async def recalculate_ranks(db: AsyncSession):
        """Calculates rankings for today, this week, and lifetime."""
        today = date.today()
        week_start = today - timedelta(days=today.weekday())

        # Daily Ranks
        daily_entries = (
            await db.execute(
                select(DailyLeaderboard)
                .where(DailyLeaderboard.date == today)
                .order_by(desc(DailyLeaderboard.points))
            )
        ).scalars().all()
        for idx, entry in enumerate(daily_entries, start=1):
            entry.rank = idx

        # Weekly Ranks
        weekly_entries = (
            await db.execute(
                select(WeeklyLeaderboard)
                .where(WeeklyLeaderboard.week_start == week_start)
                .order_by(desc(WeeklyLeaderboard.points))
            )
        ).scalars().all()
        for idx, entry in enumerate(weekly_entries, start=1):
            entry.rank = idx

        # Lifetime Ranks
        life_entries = (
            await db.execute(
                select(LifetimeLeaderboard).order_by(desc(LifetimeLeaderboard.points))
            )
        ).scalars().all()
        for idx, entry in enumerate(life_entries, start=1):
            entry.rank = idx

        await db.commit()

    @staticmethod
    async def finalize_weekly_podium(db: AsyncSession, last_week_start: date) -> PodiumHistory | None:
        """Called automatically at the end of every competition week to assign Gold/Silver/Bronze."""
        last_week_end = last_week_start + timedelta(days=6)
        
        top_three = (
            await db.execute(
                select(WeeklyLeaderboard)
                .where(WeeklyLeaderboard.week_start == last_week_start)
                .order_by(desc(WeeklyLeaderboard.points))
                .limit(3)
            )
        ).scalars().all()

        if len(top_three) < 3:
            return None

        podium = PodiumHistory(
            id=uuid.uuid4(),
            week_start=last_week_start,
            week_end=last_week_end,
            gold_user_id=top_three[0].user_id,
            silver_user_id=top_three[1].user_id,
            bronze_user_id=top_three[2].user_id,
            gold_points=top_three[0].points,
            silver_points=top_three[1].points,
            bronze_points=top_three[2].points,
        )
        db.add(podium)
        await db.commit()
        await db.refresh(podium)
        return podium
