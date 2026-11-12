"""
CIRCULUS Schemas - Invitation
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class InvitationCreate(BaseModel):
    email: EmailStr
    role: str = Field(default="officer", description="officer, faculty, administrator")
    department_id: Optional[uuid.UUID] = None
    batch_id: Optional[uuid.UUID] = None
    message: Optional[str] = None
    expires_in_hours: int = 72
    max_uses: int = 1


class InvitationVerify(BaseModel):
    invitation_code: str


class InvitationRegister(BaseModel):
    invitation_code: str
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str = Field(..., max_length=120)
    username: str = Field(..., min_length=3, max_length=50)
    phone: Optional[str] = None
    designation: Optional[str] = None
    department_id: Optional[uuid.UUID] = None
    batch_id: Optional[uuid.UUID] = None
    current_posting: Optional[str] = None
    bio: Optional[str] = None


class InvitationRead(BaseModel):
    id: uuid.UUID
    email: str
    role: str
    invited_by: uuid.UUID
    invitation_code: str
    status: str
    department_id: Optional[uuid.UUID] = None
    batch_id: Optional[uuid.UUID] = None
    message: Optional[str] = None
    accepted_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    max_uses: int
    use_count: int
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)
