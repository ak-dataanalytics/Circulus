"""
CIRCULUS API - User & Directory Endpoints
"""
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

from app.core.dependencies import get_db, get_current_user, CurrentUser
from app.models.user import Profile, Department, Batch
from app.schemas.user import ProfileRead, ProfileUpdate
from app.services.common_services import UserService

router = APIRouter(prefix="/users", tags=["Users & Directory"])


@router.get("/me", response_model=ProfileRead)
async def get_my_profile(current_user: CurrentUser):
    """Retrieve the profile of the authenticated user."""
    return current_user


@router.patch("/me", response_model=ProfileRead)
async def update_my_profile(
    payload: ProfileUpdate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Update editable fields on the authenticated user's profile."""
    update_data = payload.model_dump(exclude_unset=True)
    if update_data:
        for key, val in update_data.items():
            setattr(current_user, key, val)
        await db.commit()
        await db.refresh(current_user)
    return current_user


@router.get("/directory", response_model=List[ProfileRead])
async def search_directory(
    query: Optional[str] = Query(None, description="Search by name or bio"),
    department_id: Optional[uuid.UUID] = Query(None),
    batch_id: Optional[uuid.UUID] = Query(None),
    limit: int = Query(20, le=100),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Search verified government officers & faculty members in the persistent directory."""
    profiles = await UserService.search_directory(
        db, query=query, department_id=department_id, batch_id=batch_id, limit=limit, offset=offset
    )
    return profiles


@router.get("/{user_id}", response_model=ProfileRead)
async def get_user_by_id(
    user_id: uuid.UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Get full profile details for a specific verified member."""
    profile = await UserService.get_profile(db, user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Member profile not found.")
    return profile
