"""
CIRCULUS Schemas - Brain Arena Games
"""
import uuid
from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel, ConfigDict, Field


class GameBase(BaseModel):
    name: str = Field(..., max_length=100)
    game_type: str = Field(..., max_length=50)  # sudoku, logic, gk, memory, word, daily
    description: Optional[str] = None
    icon_name: Optional[str] = None
    is_active: bool = True
    base_points: int = 100
    daily_challenge: bool = False


class GameCreate(GameBase):
    pass


class GameRead(GameBase):
    id: uuid.UUID
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class QuestionBase(BaseModel):
    game_id: uuid.UUID
    category: str
    difficulty: str = "medium"  # easy, medium, hard
    prompt: str
    options: Optional[list[str]] = None
    time_limit_seconds: int = 30
    explanation: Optional[str] = None


class QuestionCreate(QuestionBase):
    correct_answer: str


class QuestionClientRead(QuestionBase):
    """Sent to client without the correct answer!"""
    id: uuid.UUID
    model_config = ConfigDict(from_attributes=True)


class QuestionAdminRead(QuestionBase):
    id: uuid.UUID
    correct_answer: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class GameSessionStart(BaseModel):
    game_id: uuid.UUID
    difficulty: str = "medium"


class GameSessionRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    game_id: uuid.UUID
    status: str  # in_progress, completed, abandoned
    score: int = 0
    points_awarded: int = 0
    duration_seconds: int = 0
    started_at: datetime
    completed_at: Optional[datetime] = None
    puzzle_data: Optional[dict[str, Any]] = None
    model_config = ConfigDict(from_attributes=True)


class GameAnswerSubmit(BaseModel):
    session_id: uuid.UUID
    question_id: Optional[uuid.UUID] = None
    submitted_answer: str
    time_taken_seconds: int


class GameAnswerResult(BaseModel):
    is_correct: bool
    explanation: Optional[str] = None
    correct_answer: Optional[str] = None
    points_earned: int = 0


class GameSessionFinish(BaseModel):
    session_id: uuid.UUID
    solution_data: Optional[dict[str, Any]] = None
    duration_seconds: int


class GameSessionFinishResult(BaseModel):
    session_id: uuid.UUID
    status: str
    score: int
    points_awarded: int
    new_daily_points: int
    new_weekly_points: int
    achievements_unlocked: list[str] = []
