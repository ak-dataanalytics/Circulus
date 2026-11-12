"""
CIRCULUS Schemas - Posts, Likes, Comments
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.schemas.user import ProfileRead


class PostMediaBase(BaseModel):
    media_url: str
    media_type: str = "image"
    file_size_bytes: Optional[int] = None


class PostMediaRead(PostMediaBase):
    id: uuid.UUID
    post_id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class PostCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=5000)
    community_id: Optional[uuid.UUID] = None
    media_urls: Optional[list[str]] = None


class PostUpdate(BaseModel):
    content: Optional[str] = Field(None, min_length=1, max_length=5000)


class CommentCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=1000)
    parent_comment_id: Optional[uuid.UUID] = None


class CommentRead(BaseModel):
    id: uuid.UUID
    post_id: uuid.UUID
    user_id: uuid.UUID
    parent_comment_id: Optional[uuid.UUID] = None
    content: str
    created_at: datetime
    author: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class PostRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    community_id: Optional[uuid.UUID] = None
    content: str
    like_count: int = 0
    comment_count: int = 0
    share_count: int = 0
    is_liked_by_me: bool = False
    is_saved_by_me: bool = False
    created_at: datetime
    updated_at: datetime
    author: Optional[ProfileRead] = None
    media: list[PostMediaRead] = []
    model_config = ConfigDict(from_attributes=True)
