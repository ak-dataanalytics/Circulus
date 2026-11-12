"""
CIRCULUS Schemas - Admin & Platform Operations
"""
import uuid
from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel, ConfigDict
from app.schemas.user import ProfileRead


class AdminDashboardStats(BaseModel):
    total_members: int = 0
    active_members: int = 0
    pending_approvals: int = 0
    faculty_count: int = 0
    officer_count: int = 0
    total_communities: int = 0
    total_posts: int = 0
    total_events: int = 0
    daily_active_users: int = 0


class ReportCreate(BaseModel):
    target_type: str  # post, comment, user, message, community
    target_id: uuid.UUID
    reason: str
    details: Optional[str] = None


class ReportRead(BaseModel):
    id: uuid.UUID
    reporter_id: uuid.UUID
    target_type: str
    target_id: uuid.UUID
    reason: str
    details: Optional[str] = None
    status: str = "pending"  # pending, reviewed, dismissed, resolved
    reviewed_by: Optional[uuid.UUID] = None
    created_at: datetime
    reporter: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class ReportAction(BaseModel):
    status: str  # reviewed, dismissed, resolved
    resolution_notes: Optional[str] = None
    action_taken: Optional[str] = None  # delete_content, suspend_user, warn_user, none


class AuditLogRead(BaseModel):
    id: uuid.UUID
    user_id: Optional[uuid.UUID] = None
    action: str
    entity_type: Optional[str] = None
    entity_id: Optional[uuid.UUID] = None
    details: Optional[dict[str, Any]] = None
    ip_address: Optional[str] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class PlatformSettingRead(BaseModel):
    key: str
    value: Any
    description: Optional[str] = None
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)


class PlatformSettingUpdate(BaseModel):
    value: Any
