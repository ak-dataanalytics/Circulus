"""
CIRCULUS Schemas - Points, Leaderboard & Achievements
"""
import uuid
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict
from app.schemas.user import ProfileRead


class LeaderboardEntry(BaseModel):
    user_id: uuid.UUID
    rank: int
    points: int
    user: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class PodiumHistoryRead(BaseModel):
    id: uuid.UUID
    week_start: date
    week_end: date
    gold_user_id: uuid.UUID
    silver_user_id: uuid.UUID
    bronze_user_id: uuid.UUID
    gold_points: int
    silver_points: int
    bronze_points: int
    gold_user: Optional[ProfileRead] = None
    silver_user: Optional[ProfileRead] = None
    bronze_user: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class AchievementRead(BaseModel):
    id: uuid.UUID
    code: str
    title: str
    description: str
    icon_name: str
    points: int
    unlocked_at: Optional[datetime] = None
    model_config = ConfigDict(from_attributes=True)


class PointsSummary(BaseModel):
    daily_points: int = 0
    weekly_points: int = 0
    lifetime_points: int = 0
    daily_rank: Optional[int] = None
    weekly_rank: Optional[int] = None
    lifetime_rank: Optional[int] = None
    recent_transactions: list[dict] = []
