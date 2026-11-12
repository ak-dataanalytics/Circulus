"""
CIRCULUS API - Social Feed & Posts Endpoints
"""
import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.dependencies import get_db, CurrentUser
from app.models.post import Post, Comment, PostMedia
from app.schemas.post import PostCreate, PostRead, CommentCreate, CommentRead
from app.services.common_services import PostService

router = APIRouter(prefix="/posts", tags=["Social Feed"])


@router.post("/", response_model=PostRead, status_code=status.HTTP_201_CREATED)
async def create_post(
    payload: PostCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Create a new text or multimedia post on the network feed."""
    post = await PostService.create_post(
        db, user_id=current_user.id, content=payload.content, community_id=payload.community_id
    )
    if payload.media_urls:
        for url in payload.media_urls:
            pm = PostMedia(id=uuid.uuid4(), post_id=post.id, media_url=url, media_type="image")
            db.add(pm)
        await db.commit()
        await db.refresh(post)
    return post


@router.get("/feed", response_model=List[PostRead])
async def get_feed(
    limit: int = Query(20, le=50),
    offset: int = Query(0, ge=0),
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Fetch paginated network feed items."""
    posts = await PostService.get_feed(db, limit=limit, offset=offset)
    return posts


@router.post("/{post_id}/like")
async def toggle_like(
    post_id: uuid.UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Like or unlike a post."""
    liked = await PostService.toggle_like(db, user_id=current_user.id, post_id=post_id)
    return {"post_id": post_id, "liked": liked}


@router.post("/{post_id}/comments", response_model=CommentRead, status_code=status.HTTP_201_CREATED)
async def add_comment(
    post_id: uuid.UUID,
    payload: CommentCreate,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Add a comment or reply to an existing post."""
    comment = Comment(
        id=uuid.uuid4(),
        post_id=post_id,
        user_id=current_user.id,
        parent_comment_id=payload.parent_comment_id,
        content=payload.content,
    )
    db.add(comment)
    await db.commit()
    await db.refresh(comment)
    return comment
