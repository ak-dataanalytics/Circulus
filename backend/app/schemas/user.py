"""
CIRCULUS Schemas - User / Profile
"""
import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class DepartmentBase(BaseModel):
    name: str = Field(..., max_length=150)
    code: str = Field(..., max_length=20)
    description: Optional[str] = None


class DepartmentCreate(DepartmentBase):
    pass


class DepartmentRead(DepartmentBase):
    id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class BatchBase(BaseModel):
    name: str = Field(..., max_length=100)
    year: int
    training_institution: Optional[str] = None


class BatchCreate(BatchBase):
    pass


class BatchRead(BatchBase):
    id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class UserRoleRead(BaseModel):
    id: uuid.UUID
    role: str
    assigned_by: Optional[uuid.UUID] = None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class ProfileBase(BaseModel):
    full_name: str = Field(..., max_length=120)
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None
    department_id: Optional[uuid.UUID] = None
    batch_id: Optional[uuid.UUID] = None
    designation: Optional[str] = None
    current_posting: Optional[str] = None


class ProfileCreate(ProfileBase):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50)


class ProfileUpdate(BaseModel):
    full_name: Optional[str] = Field(None, max_length=120)
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None
    designation: Optional[str] = None
    current_posting: Optional[str] = None
    department_id: Optional[uuid.UUID] = None
    batch_id: Optional[uuid.UUID] = None


class ProfileRead(ProfileBase):
    id: uuid.UUID
    email: str
    username: str
    is_active: bool
    is_verified: bool
    is_onboarded: bool
    last_seen: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    roles: list[UserRoleRead] = []
    department: Optional[DepartmentRead] = None
    batch: Optional[BatchRead] = None
    model_config = ConfigDict(from_attributes=True)


class DirectoryFilter(BaseModel):
    query: Optional[str] = None
    department_id: Optional[uuid.UUID] = None
    batch_id: Optional[uuid.UUID] = None
    designation: Optional[str] = None
    current_posting: Optional[str] = None
    page: int = 1
    page_size: int = 20
