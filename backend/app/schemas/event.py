"""
CIRCULUS Schemas - Events
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.schemas.user import ProfileRead


class EventBase(BaseModel):
    title: str = Field(..., max_length=200)
    description: Optional[str] = None
    banner_url: Optional[str] = None
    event_type: str = "webinar"  # workshop, seminar, webinar, meetup, reunion
    start_time: datetime
    end_time: Optional[datetime] = None
    venue: Optional[str] = None
    meeting_url: Optional[str] = None
    community_id: Optional[uuid.UUID] = None
    max_participants: Optional[int] = None


class EventCreate(EventBase):
    pass


class EventUpdate(BaseModel):
    title: Optional[str] = Field(None, max_length=200)
    description: Optional[str] = None
    banner_url: Optional[str] = None
    event_type: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    venue: Optional[str] = None
    meeting_url: Optional[str] = None
    max_participants: Optional[int] = None
    is_cancelled: Optional[bool] = None


class EventRegistrationRead(BaseModel):
    id: uuid.UUID
    event_id: uuid.UUID
    user_id: uuid.UUID
    status: str = "registered"
    registered_at: datetime
    user: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class EventRead(EventBase):
    id: uuid.UUID
    organizer_id: uuid.UUID
    is_cancelled: bool = False
    registered_count: int = 0
    is_registered_by_me: bool = False
    created_at: datetime
    updated_at: datetime
    organizer: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)
