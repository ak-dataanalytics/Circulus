# CIRCULUS REST API Documentation

Base URL: `/api/v1`

## 1. Authentication & Invitations
- `POST /auth/verify-invitation`: Check code validity and retrieve metadata.
- `POST /auth/register`: Register new officer using valid invitation code.
- `POST /auth/login`: Exchange credentials for JWT bearer token.

## 2. User & Directory
- `GET /users/me`: Authenticated profile details.
- `PATCH /users/me`: Update bio, phone, avatar, designation.
- `GET /users/directory`: Search verified members by name, batch, or department.
- `GET /users/{user_id}`: Member profile detail.

## 3. Social Feed & Posts
- `GET /posts/feed`: Paginated feed of posts.
- `POST /posts/`: Publish new text or image post.
- `POST /posts/{post_id}/like`: Toggle like.
- `POST /posts/{post_id}/comments`: Threaded comment submission.

## 4. Communities & Events
- `GET /communities/`: List available circles.
- `POST /communities/`: Create new professional circle.
- `POST /communities/{id}/join`: Join open community.
- `GET /events/`: List scheduled workshops and webinars.
- `POST /events/`: Organize an event.
- `POST /events/{id}/register`: Register for attendance.

## 5. Direct & Group Messaging
- `GET /chat/conversations`: Active conversations.
- `POST /chat/conversations`: Initiate personal chat or group thread.
- `GET /chat/conversations/{id}/messages`: Paginated message history.
- `POST /chat/conversations/{id}/messages`: Transmit message.

## 6. Brain Arena Games & Scoring
- `GET /games/`: List active games.
- `GET /games/{id}/questions`: Question bank (answers omitted for integrity).
- `POST /games/sessions/start`: Start authenticated game session.
- `POST /games/sessions/answer`: Submit timed answer with latency check.
- `POST /games/sessions/finish`: Validate solution (Sudoku/Memory) and award verified points.

## 7. Leaderboards & Podium
- `GET /leaderboard/daily`: Daily rankings.
- `GET /leaderboard/weekly`: Current week competition standings.
- `GET /leaderboard/lifetime`: Cumulative lifetime hall of fame.
- `GET /leaderboard/podium/history`: Permanent Gold, Silver, Bronze records.
- `GET /leaderboard/summary`: Authenticated member points and ranks.

## 8. Administrative Operations
- `GET /admin/stats`: KPI dashboard summary metrics.
- `POST /admin/members/{id}/verify`: Approve pending officer credentials.
- `POST /admin/members/{id}/suspend`: Suspend or reactivate user account.
- `GET /admin/reports`: Content moderation reports.
- `GET /admin/audit-logs`: System audit trail.
