# CIRCULUS Automated Testing Guide

## 1. Backend Testing (Pytest)

The backend features automated unit and security tests covering:
- Mathematical Sudoku solution validation
- Sub-grid duplicate rejection
- Anti-cheat completion latency thresholds
- Invitation code generation entropy
- RBAC permissions

### Execution
Run tests from the backend directory:
```bash
cd backend
python -m pytest tests/
```

Run specific test modules:
```bash
python -m pytest tests/services/test_game_engine.py
python -m pytest tests/security/test_security.py
```

## 2. Flutter Mobile Testing
Run widget and logic tests from the mobile directory:
```bash
cd mobile
flutter test
```

## 3. End-to-End User Journey Verification
1. **Invite Creation**: Admin creates invitation `CIR-TEST01` on Admin Dashboard.
2. **Registration**: New user validates code and submits registration form on Android App.
3. **Admin Approval**: Admin visits `/members`, reviews Level 7+ credential test document, and clicks **Approve**.
4. **Login**: User logs in with registered email address and receives JWT bearer token.
5. **Feed & Social**: User views daily knowledge drop and creates a post.
6. **Brain Arena**: User completes Sudoku or GK Quiz; points engine updates score.
7. **Podium**: User checks Weekly Podium; rankings reflect updated score.
