"""
CIRCULUS API - Brain Arena Game Endpoints
"""
import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.dependencies import get_db, CurrentUser
from app.models.game import Game, Question, GameSession
from app.schemas.game import (
    GameRead,
    QuestionClientRead,
    GameSessionStart,
    GameSessionRead,
    GameAnswerSubmit,
    GameAnswerResult,
    GameSessionFinish,
    GameSessionFinishResult,
)
from app.services.game_service import GameService

router = APIRouter(prefix="/games", tags=["Brain Arena"])


@router.get("/", response_model=List[GameRead])
async def list_games(current_user: CurrentUser, db: AsyncSession = Depends(get_db)):
    """List available games in the Brain Arena."""
    res = await db.execute(select(Game).where(Game.is_active == True))
    return list(res.scalars().all())


@router.get("/{game_id}/questions", response_model=List[QuestionClientRead])
async def get_game_questions(
    game_id: uuid.UUID,
    difficulty: str = "medium",
    limit: int = 10,
    current_user: CurrentUser = None,
    db: AsyncSession = Depends(get_db)
):
    """Fetch question bank for quiz or logical reasoning (without answers!)."""
    stmt = (
        select(Question)
        .where(Question.game_id == game_id, Question.difficulty == difficulty)
        .limit(limit)
    )
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("/sessions/start", response_model=GameSessionRead)
async def start_session(
    payload: GameSessionStart,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Start an authenticated game session (Sudoku, GK, Memory, etc.)."""
    session = await GameService.start_session(
        db, user_id=current_user.id, game_id=payload.game_id, difficulty=payload.difficulty
    )
    return session


@router.post("/sessions/answer", response_model=GameAnswerResult)
async def submit_answer(
    payload: GameAnswerSubmit,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Submit an answer to a question during a timed quiz/puzzle."""
    result = await GameService.submit_answer(
        db,
        user_id=current_user.id,
        session_id=payload.session_id,
        question_id=payload.question_id,
        submitted_answer=payload.submitted_answer,
        time_taken_seconds=payload.time_taken_seconds,
    )
    return result


@router.post("/sessions/finish", response_model=GameSessionFinishResult)
async def finish_session(
    payload: GameSessionFinish,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db)
):
    """Submit completed game for server-side verification and point allocation."""
    result = await GameService.finish_session(
        db,
        user_id=current_user.id,
        session_id=payload.session_id,
        solution_data=payload.solution_data,
        duration_seconds=payload.duration_seconds,
    )
    return result
