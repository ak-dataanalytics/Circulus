"""
CIRCULUS API - Real-time Chat & Messaging Endpoints
"""
import uuid
from typing import List
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.dependencies import get_db, CurrentUser
from app.models.chat import Conversation, ConversationMember, Message
from app.schemas.chat import ConversationCreate, ConversationRead, MessageCreate, MessageRead
from app.services.common_services import ChatService

router = APIRouter(prefix="/chat", tags=["Direct & Group Messaging"])


@router.get("/conversations", response_model=List[ConversationRead])
async def list_conversations(current_user: CurrentUser, db: AsyncSession = Depends(get_db)):
    """Fetch active 1-to-1 and group conversations for the authenticated user."""
    stmt = (
        select(Conversation)
        .join(ConversationMember)
        .where(ConversationMember.user_id == current_user.id)
        .order_by(desc(Conversation.updated_at))
    )
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("/conversations", response_model=ConversationRead, status_code=status.HTTP_201_CREATED)
async def create_conversation(
    payload: ConversationCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Initiate a personal chat or create a group conversation."""
    conv = Conversation(
        id=uuid.uuid4(),
        is_group=payload.is_group,
        title=payload.title,
        created_by=current_user.id,
    )
    db.add(conv)

    # Add creator
    db.add(ConversationMember(
        id=uuid.uuid4(),
        conversation_id=conv.id,
        user_id=current_user.id,
        role="admin" if payload.is_group else "member"
    ))

    # Add other participants
    for p_id in payload.participant_ids:
        if p_id != current_user.id:
            db.add(ConversationMember(
                id=uuid.uuid4(),
                conversation_id=conv.id,
                user_id=p_id,
                role="member"
            ))

    await db.commit()
    await db.refresh(conv)
    return conv


@router.get("/conversations/{conversation_id}/messages", response_model=List[MessageRead])
async def get_messages(
    conversation_id: uuid.UUID,
    current_user: CurrentUser,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    """Retrieve message history for an authorized conversation."""
    # Check membership
    mem_res = await db.execute(
        select(ConversationMember).where(
            ConversationMember.conversation_id == conversation_id,
            ConversationMember.user_id == current_user.id
        )
    )
    if not mem_res.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Not authorized to access this conversation.")

    stmt = (
        select(Message)
        .where(Message.conversation_id == conversation_id, Message.is_deleted == False)
        .order_by(desc(Message.created_at))
        .limit(limit)
    )
    res = await db.execute(stmt)
    messages = list(res.scalars().all())
    messages.reverse()
    return messages


@router.post("/conversations/{conversation_id}/messages", response_model=MessageRead, status_code=status.HTTP_201_CREATED)
async def send_message(
    conversation_id: uuid.UUID,
    payload: MessageCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Send a text or attachment message."""
    msg = await ChatService.send_message(
        db, conversation_id=conversation_id, sender_id=current_user.id, content=payload.content or ""
    )
    return msg
