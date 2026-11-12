"""
CIRCULUS API - Communities Endpoints
"""
import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.dependencies import get_db, CurrentUser
from app.models.community import Community, CommunityMember
from app.schemas.community import CommunityCreate, CommunityRead, CommunityMemberRead
from app.services.common_services import CommunityService

router = APIRouter(prefix="/communities", tags=["Communities"])


@router.get("/", response_model=List[CommunityRead])
async def list_communities(current_user: CurrentUser, db: AsyncSession = Depends(get_db)):
    """List available communities."""
    res = await db.execute(select(Community).order_by(Community.name))
    return list(res.scalars().all())


@router.post("/", response_model=CommunityRead, status_code=status.HTTP_201_CREATED)
async def create_community(
    payload: CommunityCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Create a new community."""
    community = await CommunityService.create_community(
        db,
        user_id=current_user.id,
        name=payload.name,
        description=payload.description,
        is_private=payload.is_private
    )
    return community


@router.post("/{community_id}/join", response_model=CommunityMemberRead)
async def join_community(
    community_id: uuid.UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Join an open community."""
    member = await CommunityService.join_community(db, user_id=current_user.id, community_id=community_id)
    return member
