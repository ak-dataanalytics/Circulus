"""
CIRCULUS Services - User, Post, Community, Event, Chat & Notifications
"""
import uuid
from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy import select, update, delete, or_, and_, desc
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.user import Profile, Department, Batch
from app.models.post import Post, PostLike, Comment, SavedPost
from app.models.community import Community, CommunityMember
from app.models.event import Event, EventRegistration
from app.models.chat import Conversation, ConversationMember, Message
from app.models.notification import Notification


class UserService:
    @staticmethod
    async def get_profile(db: AsyncSession, user_id: uuid.UUID) -> Optional[Profile]:
        res = await db.execute(select(Profile).where(Profile.id == user_id))
        return res.scalar_one_or_none()

    @staticmethod
    async def search_directory(
        db: AsyncSession,
        query: Optional[str] = None,
        department_id: Optional[uuid.UUID] = None,
        batch_id: Optional[uuid.UUID] = None,
        limit: int = 50,
        offset: int = 0
    ) -> List[Profile]:
        stmt = select(Profile).where(Profile.is_active == True, Profile.is_verified == True)
        if query:
            stmt = stmt.where(
                or_(
                    Profile.full_name.ilike(f"%{query}%"),
                    Profile.username.ilike(f"%{query}%"),
                    Profile.bio.ilike(f"%{query}%")
                )
            )
        if department_id:
            stmt = stmt.where(Profile.department_id == department_id)
        if batch_id:
            stmt = stmt.where(Profile.batch_id == batch_id)

        stmt = stmt.order_by(Profile.full_name).limit(limit).offset(offset)
        result = await db.execute(stmt)
        return list(result.scalars().all())


class PostService:
    @staticmethod
    async def create_post(db: AsyncSession, user_id: uuid.UUID, content: str, community_id: Optional[uuid.UUID] = None) -> Post:
        post = Post(
            id=uuid.uuid4(),
            user_id=user_id,
            community_id=community_id,
            content=content,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
        )
        db.add(post)
        await db.commit()
        await db.refresh(post)
        return post

    @staticmethod
    async def get_feed(db: AsyncSession, limit: int = 20, offset: int = 0) -> List[Post]:
        stmt = select(Post).order_by(desc(Post.created_at)).limit(limit).offset(offset)
        res = await db.execute(stmt)
        return list(res.scalars().all())

    @staticmethod
    async def toggle_like(db: AsyncSession, user_id: uuid.UUID, post_id: uuid.UUID) -> bool:
        stmt = select(PostLike).where(PostLike.post_id == post_id, PostLike.user_id == user_id)
        res = await db.execute(stmt)
        existing = res.scalar_one_or_none()
        if existing:
            await db.delete(existing)
            await db.execute(update(Post).where(Post.id == post_id).values(like_count=Post.like_count - 1))
            await db.commit()
            return False
        else:
            new_like = PostLike(id=uuid.uuid4(), post_id=post_id, user_id=user_id)
            db.add(new_like)
            await db.execute(update(Post).where(Post.id == post_id).values(like_count=Post.like_count + 1))
            await db.commit()
            return True


class CommunityService:
    @staticmethod
    async def create_community(db: AsyncSession, user_id: uuid.UUID, name: str, description: Optional[str], is_private: bool = False) -> Community:
        community = Community(
            id=uuid.uuid4(),
            name=name,
            description=description,
            is_private=is_private,
            created_by=user_id,
            member_count=1,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
        )
        db.add(community)
        # Add creator as admin member
        member = CommunityMember(
            id=uuid.uuid4(),
            community_id=community.id,
            user_id=user_id,
            role="admin",
            joined_at=datetime.now(timezone.utc)
        )
        db.add(member)
        await db.commit()
        await db.refresh(community)
        return community

    @staticmethod
    async def join_community(db: AsyncSession, user_id: uuid.UUID, community_id: uuid.UUID) -> CommunityMember:
        member = CommunityMember(
            id=uuid.uuid4(),
            community_id=community_id,
            user_id=user_id,
            role="member",
            joined_at=datetime.now(timezone.utc)
        )
        db.add(member)
        await db.execute(update(Community).where(Community.id == community_id).values(member_count=Community.member_count + 1))
        await db.commit()
        await db.refresh(member)
        return member


class ChatService:
    @staticmethod
    async def send_message(db: AsyncSession, conversation_id: uuid.UUID, sender_id: uuid.UUID, content: str) -> Message:
        # Check membership
        mem = await db.execute(
            select(ConversationMember).where(
                ConversationMember.conversation_id == conversation_id,
                ConversationMember.user_id == sender_id
            )
        )
        if not mem.scalar_one_or_none():
            raise HTTPException(status_code=403, detail="User is not a member of this conversation")

        msg = Message(
            id=uuid.uuid4(),
            conversation_id=conversation_id,
            sender_id=sender_id,
            content=content,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc)
        )
        db.add(msg)
        await db.commit()
        await db.refresh(msg)
        return msg
