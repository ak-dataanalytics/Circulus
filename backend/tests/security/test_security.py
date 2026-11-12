"""
CIRCULUS Security Tests - Invitation Validation, Anti-Cheat, and RBAC
"""
import unittest
import uuid
from app.services.auth_service import AuthService
from app.services.game_service import GameService


class TestSecurityAndAntiCheat(unittest.TestCase):
    def test_invitation_code_generation_entropy(self):
        """Verify generated invitation codes have high entropy and correct format."""
        code1 = AuthService.generate_invitation_code(12)
        code2 = AuthService.generate_invitation_code(12)
        self.assertEqual(len(code1), 12)
        self.assertEqual(len(code2), 12)
        self.assertNotEqual(code1, code2)
        self.assertTrue(code1.isalnum())
        self.assertTrue(code1.isupper())

    def test_sudoku_anti_cheat_rejection_on_invalid_board(self):
        """Ensure manipulated client-submitted Sudoku solutions are firmly rejected."""
        # Row with zeros is incomplete
        incomplete_board = [
            [0, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
        self.assertFalse(GameService.is_valid_sudoku_solution(incomplete_board))

    def test_sudoku_anti_cheat_sub_grid_conflict(self):
        """Ensure 3x3 block sub-grid duplicate violations are rejected."""
        grid_conflict = [
            [1, 2, 3, 4, 5, 6, 7, 8, 9],
            [4, 5, 6, 7, 8, 9, 1, 2, 3],
            [7, 8, 1, 2, 3, 4, 5, 6, 0], # invalid
            [2, 3, 4, 5, 6, 7, 8, 9, 1],
            [5, 6, 7, 8, 9, 1, 2, 3, 4],
            [8, 9, 2, 3, 4, 5, 6, 7, 5],
            [3, 4, 5, 6, 7, 8, 9, 1, 2],
            [6, 7, 8, 9, 1, 2, 3, 4, 5],
            [9, 1, 3, 4, 5, 6, 7, 8, 6]
        ]
        self.assertFalse(GameService.is_valid_sudoku_solution(grid_conflict))


if __name__ == "__main__":
    unittest.main()
