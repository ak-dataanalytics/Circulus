"""
CIRCULUS Schemas - Chat & Messaging
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.schemas.user import ProfileRead


class MessageAttachmentBase(BaseModel):
    file_url: str
    file_type: str
    file_name: Optional[str] = None
    file_size_bytes: Optional[int] = None


class MessageAttachmentRead(MessageAttachmentBase):
    id: uuid.UUID
    message_id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class MessageCreate(BaseModel):
    content: Optional[str] = Field(None, max_length=5000)
    reply_to_message_id: Optional[uuid.UUID] = None
    attachments: Optional[list[MessageAttachmentBase]] = None


class MessageRead(BaseModel):
    id: uuid.UUID
    conversation_id: uuid.UUID
    sender_id: uuid.UUID
    reply_to_message_id: Optional[uuid.UUID] = None
    content: Optional[str] = None
    is_deleted: bool = False
    created_at: datetime
    updated_at: datetime
    sender: Optional[ProfileRead] = None
    attachments: list[MessageAttachmentRead] = []
    model_config = ConfigDict(from_attributes=True)


class ConversationCreate(BaseModel):
    is_group: bool = False
    title: Optional[str] = None
    participant_ids: list[uuid.UUID]


class ConversationMemberRead(BaseModel):
    id: uuid.UUID
    conversation_id: uuid.UUID
    user_id: uuid.UUID
    role: str = "member"
    last_read_at: Optional[datetime] = None
    joined_at: datetime
    user: Optional[ProfileRead] = None
    model_config = ConfigDict(from_attributes=True)


class ConversationRead(BaseModel):
    id: uuid.UUID
    is_group: bool
    title: Optional[str] = None
    avatar_url: Optional[str] = None
    created_by: Optional[uuid.UUID] = None
    last_message: Optional[MessageRead] = None
    unread_count: int = 0
    members: list[ConversationMemberRead] = []
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)
