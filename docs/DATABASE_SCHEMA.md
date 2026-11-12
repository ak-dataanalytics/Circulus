# CIRCULUS Database Schema Documentation

PostgreSQL database hosted on Supabase (ap-south-1 Mumbai region recommended).

## Tables Overview (36 Tables)

| Table | Description | Primary Key | Foreign Keys / Constraints |
|---|---|---|---|
| `profiles` | Extended profile for verified officers & faculty | `id` (UUID) | Matches `auth.users(id)` |
| `user_roles` | RBAC roles (superadmin, admin, faculty, officer) | `id` (UUID) | `user_id` -> `profiles(id)` |
| `departments` | Administrative departments | `id` (UUID) | Unique code |
| `batches` | Training batches | `id` (UUID) | Year, institution |
| `invitations` | Controlled invitation codes | `id` (UUID) | `invited_by` -> `profiles(id)` |
| `verification_requests` | Officer credential verification queue | `id` (UUID) | `user_id` -> `profiles(id)` |
| `posts` | Network social feed posts | `id` (UUID) | `user_id` -> `profiles(id)` |
| `post_media` | Image and document attachments for posts | `id` (UUID) | `post_id` -> `posts(id)` |
| `post_likes` | Likes on posts | `id` (UUID) | Unique (`post_id`, `user_id`) |
| `comments` | Threaded comments on posts | `id` (UUID) | `post_id`, `parent_comment_id` |
| `saved_posts` | Bookmarked posts | `id` (UUID) | Unique (`post_id`, `user_id`) |
| `communities` | Professional communities & circles | `id` (UUID) | `created_by` -> `profiles(id)` |
| `community_members` | Community membership and roles | `id` (UUID) | Unique (`community_id`, `user_id`) |
| `community_posts` | Mapping posts to communities | `id` (UUID) | `community_id`, `post_id` |
| `events` | Workshops, seminars, webinars | `id` (UUID) | `organizer_id` -> `profiles(id)` |
| `event_registrations` | Officer event registrations | `id` (UUID) | Unique (`event_id`, `user_id`) |
| `conversations` | 1-to-1 and group chat threads | `id` (UUID) | `created_by` |
| `conversation_members` | Participants in chat threads | `id` (UUID) | Unique (`conversation_id`, `user_id`) |
| `messages` | Direct and group messages | `id` (UUID) | `conversation_id`, `sender_id` |
| `message_attachments` | Encrypted media and document payloads | `id` (UUID) | `message_id` -> `messages(id)` |
| `games` | Brain Arena games (Sudoku, GK, Memory) | `id` (UUID) | Unique game_type |
| `questions` | Question bank for quizzes & reasoning | `id` (UUID) | `game_id` -> `games(id)` |
| `game_sessions` | Authenticated play sessions | `id` (UUID) | `user_id`, `game_id` |
| `game_answers` | Answer logs with timestamps | `id` (UUID) | `session_id`, `question_id` |
| `points_transactions` | Immutable ledger of point awards | `id` (UUID) | `user_id` -> `profiles(id)` |
| `daily_leaderboards` | Daily scores & rankings | `id` (UUID) | Unique (`user_id`, `date`) |
| `weekly_leaderboards` | Current competition week standings | `id` (UUID) | Unique (`user_id`, `week_start`) |
| `lifetime_leaderboards` | Cumulative lifetime points | `id` (UUID) | Unique (`user_id`) |
| `podium_history` | Permanent archive of Gold/Silver/Bronze winners | `id` (UUID) | Unique `week_start` |
| `achievements` | Badges and milestones | `id` (UUID) | Unique code |
| `user_achievements` | Unlocked member achievements | `id` (UUID) | Unique (`user_id`, `achievement_id`) |
| `notifications` | In-app alerts and updates | `id` (UUID) | `user_id` -> `profiles(id)` |
| `user_notification_preferences`| User delivery settings | `user_id` (UUID) | `user_id` -> `profiles(id)` |
| `reports` | Moderation queue for flagged content | `id` (UUID) | `reporter_id` -> `profiles(id)` |
| `audit_logs` | System governance audit trail | `id` (UUID) | User, action, entity |
| `platform_settings` | Dynamic platform parameters | `key` (Text) | JSONB values |
