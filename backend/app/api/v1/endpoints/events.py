"""
CIRCULUS API - Events & Webinars Endpoints
"""
import uuid
from typing import List
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.dependencies import get_db, CurrentUser
from app.models.event import Event, EventRegistration
from app.schemas.event import EventCreate, EventRead, EventRegistrationRead

router = APIRouter(prefix="/events", tags=["Events & Webinars"])


@router.get("/", response_model=List[EventRead])
async def list_events(current_user: CurrentUser, db: AsyncSession = Depends(get_db)):
    """Fetch upcoming professional events and seminars."""
    stmt = select(Event).where(Event.is_cancelled == False).order_by(Event.start_time)
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("/", response_model=EventRead, status_code=status.HTTP_201_CREATED)
async def create_event(
    payload: EventCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Publish a new workshop, webinar, or alumni meetup."""
    event = Event(
        id=uuid.uuid4(),
        organizer_id=current_user.id,
        title=payload.title,
        description=payload.description,
        event_type=payload.event_type,
        start_time=payload.start_time,
        end_time=payload.end_time,
        venue=payload.venue,
        meeting_url=payload.meeting_url,
        community_id=payload.community_id,
        max_participants=payload.max_participants,
    )
    db.add(event)
    await db.commit()
    await db.refresh(event)
    return event


@router.post("/{event_id}/register", response_model=EventRegistrationRead)
async def register_for_event(
    event_id: uuid.UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Register for an event."""
    reg = EventRegistration(
        id=uuid.uuid4(),
        event_id=event_id,
        user_id=current_user.id,
        status="registered",
        registered_at=datetime.now(timezone.utc)
    )
    db.add(reg)
    await db.commit()
    await db.refresh(reg)
    return reg
