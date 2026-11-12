"""
CIRCULUS Schemas - Communities
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.schemas.user import ProfileRead


class CommunityBase(BaseModel):
    name: str = Field(..., max_length=150)
    description: Optional[str] = None
    avatar_url: Optional[str] = None
    cover_url: Optional[str] = None
    is_private: bool = False
    rules: Optional[str] = None


class CommunityCreate(CommunityBase):
    pass


class CommunityUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=150)
    description: Optional[str] = None
    avatar_url: Optional[str] = None
    cover_url: Optional[str] = None
    is_private: Optional[bool] = None
    rules: Optional[str] = None


class CommunityMemberRead(BaseModel):
    id: uuid.UUID
    community_id: uuid.UUID
    user_id: uuid.UUID
    role: str = "member"  # admin, moderator, member
    joined_at: datetime
    user: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class CommunityRead(CommunityBase):
    id: uuid.UUID
    created_by: uuid.UUID
    member_count: int = 0
    is_member: bool = False
    my_role: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)
