"""
CIRCULUS API v1 Router Aggregator
"""
from fastapi import APIRouter

from app.api.v1.endpoints import (
    auth,
    users,
    invitations,
    posts,
    communities,
    events,
    chat,
    games,
    leaderboard,
    notifications,
    admin,
)

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(invitations.router)
api_router.include_router(posts.router)
api_router.include_router(communities.router)
api_router.include_router(events.router)
api_router.include_router(chat.router)
api_router.include_router(games.router)
api_router.include_router(leaderboard.router)
api_router.include_router(notifications.router)
api_router.include_router(admin.router)
