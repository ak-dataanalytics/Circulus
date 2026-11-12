"""
CIRCULUS Service - Brain Arena Game Engine & Scoring Validation
"""
import uuid
import random
from datetime import datetime, timezone
from typing import Any, Optional
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.models.game import Game, Question, GameSession, GameAnswer
from app.models.points import PointsTransaction
from app.services.points_service import PointsService


class GameService:
    @staticmethod
    def is_valid_sudoku_solution(board: list[list[int]]) -> bool:
        """Validates a 9x9 Sudoku complete solution."""
        if len(board) != 9 or any(len(row) != 9 for row in board):
            return False
        
        # Check rows & columns
        for i in range(9):
            row_digits = [n for n in board[i] if 1 <= n <= 9]
            if len(row_digits) != 9 or len(set(row_digits)) != 9:
                return False
            col_digits = [board[r][i] for r in range(9) if 1 <= board[r][i] <= 9]
            if len(col_digits) != 9 or len(set(col_digits)) != 9:
                return False

        # Check 3x3 blocks
        for block_row in range(0, 9, 3):
            for block_col in range(0, 9, 3):
                block_digits = []
                for r in range(3):
                    for c in range(3):
                        n = board[block_row + r][block_col + c]
                        if 1 <= n <= 9:
                            block_digits.append(n)
                if len(block_digits) != 9 or len(set(block_digits)) != 9:
                    return False
        return True

    @staticmethod
    async def start_session(
        db: AsyncSession, user_id: uuid.UUID, game_id: uuid.UUID, difficulty: str = "medium"
    ) -> GameSession:
        game_res = await db.execute(select(Game).where(Game.id == game_id))
        game = game_res.scalar_one_or_none()
        if not game:
            raise HTTPException(status_code=404, detail="Game not found")

        puzzle_data = {}
        if game.game_type == "sudoku":
            # Generate valid starting grid and solution
            puzzle_data = GameService.generate_sudoku_puzzle(difficulty)

        session = GameSession(
            id=uuid.uuid4(),
            user_id=user_id,
            game_id=game_id,
            status="in_progress",
            score=0,
            points_awarded=0,
            duration_seconds=0,
            puzzle_data=puzzle_data,
            started_at=datetime.now(timezone.utc),
        )
        db.add(session)
        await db.commit()
        await db.refresh(session)
        return session

    @staticmethod
    def generate_sudoku_puzzle(difficulty: str) -> dict[str, Any]:
        """Provides a precomputed mathematically validated puzzle based on difficulty."""
        # Clean sample base puzzle
        base_puzzle = [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ]
        solution = [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
        return {
            "initial_grid": base_puzzle,
            "solution": solution,
            "difficulty": difficulty
        }

    @staticmethod
    async def submit_answer(
        db: AsyncSession,
        user_id: uuid.UUID,
        session_id: uuid.UUID,
        question_id: uuid.UUID,
        submitted_answer: str,
        time_taken_seconds: int,
    ) -> dict[str, Any]:
        session_res = await db.execute(
            select(GameSession).where(
                GameSession.id == session_id,
                GameSession.user_id == user_id,
                GameSession.status == "in_progress"
            )
        )
        session = session_res.scalar_one_or_none()
        if not session:
            raise HTTPException(status_code=400, detail="Active game session not found.")

        q_res = await db.execute(select(Question).where(Question.id == question_id))
        question = q_res.scalar_one_or_none()
        if not question:
            raise HTTPException(status_code=404, detail="Question not found.")

        is_correct = (submitted_answer.strip().lower() == question.correct_answer.strip().lower())
        points = 0
        if is_correct:
            # Score scaling: faster answers get higher score
            speed_bonus = max(0, question.time_limit_seconds - time_taken_seconds)
            points = 20 + speed_bonus

        answer = GameAnswer(
            id=uuid.uuid4(),
            session_id=session.id,
            question_id=question.id,
            submitted_answer=submitted_answer,
            is_correct=is_correct,
            time_taken_seconds=time_taken_seconds,
            points_awarded=points,
        )
        db.add(answer)
        session.score += points
        await db.commit()

        return {
            "is_correct": is_correct,
            "points_earned": points,
            "explanation": question.explanation,
            "correct_answer": question.correct_answer if not is_correct else None,
        }

    @staticmethod
    async def finish_session(
        db: AsyncSession,
        user_id: uuid.UUID,
        session_id: uuid.UUID,
        solution_data: Optional[dict[str, Any]],
        duration_seconds: int,
    ) -> dict[str, Any]:
        session_res = await db.execute(
            select(GameSession).where(
                GameSession.id == session_id,
                GameSession.user_id == user_id,
                GameSession.status == "in_progress"
            )
        )
        session = session_res.scalar_one_or_none()
        if not session:
            raise HTTPException(status_code=400, detail="Active game session not found.")

        game_res = await db.execute(select(Game).where(Game.id == session.game_id))
        game = game_res.scalar_one()

        points_awarded = 0
        if game.game_type == "sudoku":
            if solution_data and "board" in solution_data:
                board = solution_data["board"]
                if GameService.is_valid_sudoku_solution(board):
                    # Anti-cheat check: min realistic completion time
                    if duration_seconds >= 60:
                        base = 150
                        time_penalty = min(50, duration_seconds // 30)
                        points_awarded = max(50, base - time_penalty)
                        session.score = points_awarded
                    else:
                        raise HTTPException(status_code=400, detail="Submission rejected: unrealistic completion speed.")
                else:
                    raise HTTPException(status_code=400, detail="Invalid Sudoku solution.")
        elif game.game_type in ["gk", "logic", "daily"]:
            points_awarded = session.score
        elif game.game_type == "memory":
            if solution_data and solution_data.get("matches", 0) >= 8:
                points_awarded = max(30, 100 - (duration_seconds // 2))
                session.score = points_awarded

        session.status = "completed"
        session.points_awarded = points_awarded
        session.duration_seconds = duration_seconds
        session.completed_at = datetime.now(timezone.utc)

        # Award points through PointsService
        daily_pts, weekly_pts = await PointsService.award_points(
            db=db,
            user_id=user_id,
            points=points_awarded,
            source=f"game_{game.game_type}",
            reference_id=session.id
        )

        await db.commit()

        return {
            "session_id": session.id,
            "status": session.status,
            "score": session.score,
            "points_awarded": points_awarded,
            "new_daily_points": daily_pts,
            "new_weekly_points": weekly_pts,
            "achievements_unlocked": []
        }
