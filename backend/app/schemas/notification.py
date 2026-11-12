"""
CIRCULUS Schemas - Notifications
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class NotificationRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    body: str
    notification_type: str  # message, event, community, achievement, podium, invitation
    is_read: bool = False
    action_url: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class NotificationPreferenceRead(BaseModel):
    user_id: uuid.UUID
    email_notifications: bool = True
    push_notifications: bool = True
    message_notifications: bool = True
    event_reminders: bool = True
    daily_challenge_reminders: bool = True
    model_config = ConfigDict(from_attributes=True)


class NotificationPreferenceUpdate(BaseModel):
    email_notifications: Optional[bool] = None
    push_notifications: Optional[bool] = None
    message_notifications: Optional[bool] = None
    event_reminders: Optional[bool] = None
    daily_challenge_reminders: Optional[bool] = None
