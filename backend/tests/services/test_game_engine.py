"""
CIRCULUS Unit & Integration Tests - Game Engine & Scoring Security
Supports both pytest and standard library unittest
"""
import unittest
from app.services.game_service import GameService


class TestGameEngine(unittest.TestCase):
    def test_sudoku_validator_valid(self):
        valid_board = [
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
        self.assertTrue(GameService.is_valid_sudoku_solution(valid_board))

    def test_sudoku_validator_invalid_duplicate(self):
        # Duplicate '5' in first row
        invalid_board = [
            [5, 5, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
        self.assertFalse(GameService.is_valid_sudoku_solution(invalid_board))

    def test_sudoku_puzzle_generator(self):
        puzzle = GameService.generate_sudoku_puzzle("medium")
        self.assertIn("initial_grid", puzzle)
        self.assertIn("solution", puzzle)
        self.assertEqual(len(puzzle["initial_grid"]), 9)
        self.assertEqual(len(puzzle["solution"]), 9)
        self.assertTrue(GameService.is_valid_sudoku_solution(puzzle["solution"]))


if __name__ == "__main__":
    unittest.main()
