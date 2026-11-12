"""
CIRCULUS Models Package
Exports all SQLAlchemy ORM models.
"""
from app.models.user import Profile, UserRole, Department, Batch, VerificationRequest
from app.models.invitation import Invitation
from app.models.post import Post, PostMedia, PostLike, Comment, SavedPost
from app.models.community import Community, CommunityMember, CommunityPost
from app.models.event import Event, EventRegistration
from app.models.chat import Conversation, ConversationMember, Message, MessageAttachment
from app.models.game import Game, Question, GameSession, GameAnswer
from app.models.points import (
    PointsTransaction,
    DailyLeaderboard,
    WeeklyLeaderboard,
    LifetimeLeaderboard,
    PodiumHistory,
    Achievement,
    UserAchievement,
)
from app.models.notification import Notification, UserNotificationPreference
from app.models.admin import Report, AuditLog, PlatformSetting

__all__ = [
    "Profile",
    "UserRole",
    "Department",
    "Batch",
    "VerificationRequest",
    "Invitation",
    "Post",
    "PostMedia",
    "PostLike",
    "Comment",
    "SavedPost",
    "Community",
    "CommunityMember",
    "CommunityPost",
    "Event",
    "EventRegistration",
    "Conversation",
    "ConversationMember",
    "Message",
    "MessageAttachment",
    "Game",
    "Question",
    "GameSession",
    "GameAnswer",
    "PointsTransaction",
    "DailyLeaderboard",
    "WeeklyLeaderboard",
    "LifetimeLeaderboard",
    "PodiumHistory",
    "Achievement",
    "UserAchievement",
    "Notification",
    "UserNotificationPreference",
    "Report",
    "AuditLog",
    "PlatformSetting",
]
