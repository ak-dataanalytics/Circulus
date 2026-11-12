-- ============================================================================
-- CIRCULUS - Initial Database Schema
-- Migration: 001_initial_schema.sql
-- Description: Creates all core tables for the CIRCULUS college community app
-- Database: PostgreSQL 15+ (Supabase)
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================================
-- ENUMS
-- ============================================================================

CREATE TYPE user_role_enum AS ENUM ('student', 'faculty', 'officer', 'admin', 'super_admin');
CREATE TYPE verification_status_enum AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE invitation_status_enum AS ENUM ('pending', 'accepted', 'expired', 'revoked');
CREATE TYPE post_visibility_enum AS ENUM ('public', 'community_only', 'private');
CREATE TYPE community_privacy_enum AS ENUM ('public', 'private', 'restricted');
CREATE TYPE community_member_role_enum AS ENUM ('member', 'moderator', 'admin', 'owner');
CREATE TYPE event_status_enum AS ENUM ('draft', 'published', 'ongoing', 'completed', 'cancelled');
CREATE TYPE message_type_enum AS ENUM ('text', 'image', 'file', 'system');
CREATE TYPE conversation_type_enum AS ENUM ('direct', 'group');
CREATE TYPE game_type_enum AS ENUM ('quiz', 'trivia', 'puzzle', 'word_game', 'challenge');
CREATE TYPE game_difficulty_enum AS ENUM ('easy', 'medium', 'hard', 'expert');
CREATE TYPE question_type_enum AS ENUM ('multiple_choice', 'true_false', 'fill_blank', 'matching');
CREATE TYPE notification_type_enum AS ENUM (
  'like', 'comment', 'follow', 'mention', 'event_reminder',
  'community_invite', 'message', 'achievement', 'game_challenge',
  'verification_update', 'system'
);
CREATE TYPE report_status_enum AS ENUM ('pending', 'investigating', 'resolved', 'dismissed');
CREATE TYPE report_category_enum AS ENUM ('spam', 'harassment', 'inappropriate', 'misinformation', 'other');
CREATE TYPE points_action_enum AS ENUM (
  'post_created', 'post_liked', 'comment_created', 'event_attended',
  'game_won', 'game_participated', 'achievement_unlocked', 'daily_login',
  'community_joined', 'profile_completed', 'streak_bonus', 'referral', 'admin_adjustment'
);
CREATE TYPE media_type_enum AS ENUM ('image', 'video', 'document', 'audio');

-- ============================================================================
-- 1. PROFILES
-- ============================================================================

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  cover_image_url TEXT,
  bio TEXT CHECK (char_length(bio) <= 500),
  phone TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'non_binary', 'prefer_not_to_say')),
  department_id UUID,
  batch_id UUID,
  enrollment_number TEXT UNIQUE,
  designation TEXT, -- for faculty/officers
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_onboarded BOOLEAN DEFAULT FALSE,
  total_points INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_active_at TIMESTAMPTZ,
  last_login_at TIMESTAMPTZ,
  profile_completed_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_department ON profiles(department_id);
CREATE INDEX idx_profiles_batch ON profiles(batch_id);
CREATE INDEX idx_profiles_enrollment ON profiles(enrollment_number);
CREATE INDEX idx_profiles_active ON profiles(is_active) WHERE is_active = TRUE;

-- ============================================================================
-- 2. DEPARTMENTS
-- ============================================================================

CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  code TEXT NOT NULL UNIQUE,
  description TEXT,
  head_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  icon_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK from profiles to departments
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_department
  FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL;

-- ============================================================================
-- 3. BATCHES
-- ============================================================================

CREATE TABLE batches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL, -- e.g., "2024-2028"
  start_year INTEGER NOT NULL,
  end_year INTEGER NOT NULL,
  department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(name, department_id)
);

ALTER TABLE profiles ADD CONSTRAINT fk_profiles_batch
  FOREIGN KEY (batch_id) REFERENCES batches(id) ON DELETE SET NULL;

-- ============================================================================
-- 4. USER ROLES
-- ============================================================================

CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role user_role_enum NOT NULL DEFAULT 'student',
  granted_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  revoked_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);

-- ============================================================================
-- 5. INVITATIONS
-- ============================================================================

CREATE TABLE invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL,
  role user_role_enum NOT NULL DEFAULT 'student',
  invited_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  invitation_code TEXT NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(16), 'hex'),
  status invitation_status_enum DEFAULT 'pending',
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  batch_id UUID REFERENCES batches(id) ON DELETE SET NULL,
  message TEXT,
  accepted_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
  max_uses INTEGER DEFAULT 1,
  use_count INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_invitations_email ON invitations(email);
CREATE INDEX idx_invitations_code ON invitations(invitation_code);
CREATE INDEX idx_invitations_status ON invitations(status);

-- ============================================================================
-- 6. VERIFICATION REQUESTS
-- ============================================================================

CREATE TABLE verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL, -- 'id_card', 'enrollment_proof', 'faculty_id'
  document_url TEXT NOT NULL,
  additional_info TEXT,
  status verification_status_enum DEFAULT 'pending',
  reviewed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_verification_user ON verification_requests(user_id);
CREATE INDEX idx_verification_status ON verification_requests(status);

-- ============================================================================
-- 7. POSTS
-- ============================================================================

CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) <= 5000),
  visibility post_visibility_enum DEFAULT 'public',
  community_id UUID, -- NULL means general feed
  is_pinned BOOLEAN DEFAULT FALSE,
  is_announcement BOOLEAN DEFAULT FALSE,
  like_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  view_count INTEGER DEFAULT 0,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_community ON posts(community_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
CREATE INDEX idx_posts_visibility ON posts(visibility);
CREATE INDEX idx_posts_not_deleted ON posts(is_deleted) WHERE is_deleted = FALSE;

-- ============================================================================
-- 8. POST MEDIA
-- ============================================================================

CREATE TABLE post_media (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  media_url TEXT NOT NULL,
  media_type media_type_enum NOT NULL DEFAULT 'image',
  thumbnail_url TEXT,
  file_name TEXT,
  file_size BIGINT,
  mime_type TEXT,
  width INTEGER,
  height INTEGER,
  duration_seconds INTEGER, -- for video/audio
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_post_media_post ON post_media(post_id);

-- ============================================================================
-- 9. POST LIKES
-- ============================================================================

CREATE TABLE post_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_likes_post ON post_likes(post_id);
CREATE INDEX idx_post_likes_user ON post_likes(user_id);

-- ============================================================================
-- 10. COMMENTS
-- ============================================================================

CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE, -- for replies
  content TEXT NOT NULL CHECK (char_length(content) <= 2000),
  like_count INTEGER DEFAULT 0,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_comments_post ON comments(post_id);
CREATE INDEX idx_comments_author ON comments(author_id);
CREATE INDEX idx_comments_parent ON comments(parent_id);

-- ============================================================================
-- 11. SAVED POSTS
-- ============================================================================

CREATE TABLE saved_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

CREATE INDEX idx_saved_posts_user ON saved_posts(user_id);

-- ============================================================================
-- 12. COMMUNITIES
-- ============================================================================

CREATE TABLE communities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT CHECK (char_length(description) <= 1000),
  avatar_url TEXT,
  cover_image_url TEXT,
  privacy community_privacy_enum DEFAULT 'public',
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  member_count INTEGER DEFAULT 0,
  post_count INTEGER DEFAULT 0,
  is_official BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rules JSONB DEFAULT '[]', -- array of rule objects
  tags TEXT[] DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_communities_slug ON communities(slug);
CREATE INDEX idx_communities_privacy ON communities(privacy);
CREATE INDEX idx_communities_created_by ON communities(created_by);
CREATE INDEX idx_communities_department ON communities(department_id);

-- ============================================================================
-- 13. COMMUNITY MEMBERS
-- ============================================================================

CREATE TABLE community_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role community_member_role_enum DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  invited_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  is_muted BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE,
  banned_at TIMESTAMPTZ,
  banned_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  ban_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(community_id, user_id)
);

CREATE INDEX idx_community_members_community ON community_members(community_id);
CREATE INDEX idx_community_members_user ON community_members(user_id);

-- ============================================================================
-- 14. COMMUNITY POSTS (junction table)
-- ============================================================================

CREATE TABLE community_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  is_pinned BOOLEAN DEFAULT FALSE,
  pinned_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  pinned_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(community_id, post_id)
);

-- Add FK from posts to communities
ALTER TABLE posts ADD CONSTRAINT fk_posts_community
  FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE SET NULL;

CREATE INDEX idx_community_posts_community ON community_posts(community_id);
CREATE INDEX idx_community_posts_post ON community_posts(post_id);

-- ============================================================================
-- 15. EVENTS
-- ============================================================================

CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT CHECK (char_length(description) <= 5000),
  short_description TEXT CHECK (char_length(short_description) <= 200),
  cover_image_url TEXT,
  organizer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  community_id UUID REFERENCES communities(id) ON DELETE SET NULL,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  venue TEXT,
  venue_url TEXT, -- maps link
  is_online BOOLEAN DEFAULT FALSE,
  meeting_link TEXT,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  registration_deadline TIMESTAMPTZ,
  max_participants INTEGER,
  registration_count INTEGER DEFAULT 0,
  status event_status_enum DEFAULT 'draft',
  is_featured BOOLEAN DEFAULT FALSE,
  entry_fee DECIMAL(10, 2) DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  contact_email TEXT,
  contact_phone TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT check_event_times CHECK (end_time > start_time)
);

CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_community ON events(community_id);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_start_time ON events(start_time);
CREATE INDEX idx_events_featured ON events(is_featured) WHERE is_featured = TRUE;

-- ============================================================================
-- 16. EVENT REGISTRATIONS
-- ============================================================================

CREATE TABLE event_registrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'registered' CHECK (status IN ('registered', 'waitlisted', 'cancelled', 'attended')),
  checked_in_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_registrations_event ON event_registrations(event_id);
CREATE INDEX idx_event_registrations_user ON event_registrations(user_id);

-- ============================================================================
-- 17. CONVERSATIONS
-- ============================================================================

CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type conversation_type_enum NOT NULL DEFAULT 'direct',
  name TEXT, -- for group conversations
  avatar_url TEXT, -- for group conversations
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  last_message_id UUID,
  last_message_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_created_by ON conversations(created_by);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- ============================================================================
-- 18. CONVERSATION MEMBERS
-- ============================================================================

CREATE TABLE conversation_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_admin BOOLEAN DEFAULT FALSE,
  last_read_at TIMESTAMPTZ,
  is_muted BOOLEAN DEFAULT FALSE,
  muted_until TIMESTAMPTZ,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_conversation_members_conversation ON conversation_members(conversation_id);
CREATE INDEX idx_conversation_members_user ON conversation_members(user_id);

-- ============================================================================
-- 19. MESSAGES
-- ============================================================================

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT,
  type message_type_enum DEFAULT 'text',
  reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  read_by UUID[] DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK for last_message
ALTER TABLE conversations ADD CONSTRAINT fk_conversations_last_message
  FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL;

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- ============================================================================
-- 20. MESSAGE ATTACHMENTS
-- ============================================================================

CREATE TABLE message_attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size BIGINT,
  mime_type TEXT,
  media_type media_type_enum DEFAULT 'document',
  thumbnail_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_message_attachments_message ON message_attachments(message_id);

-- ============================================================================
-- 21. GAMES
-- ============================================================================

CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  type game_type_enum NOT NULL,
  difficulty game_difficulty_enum DEFAULT 'medium',
  cover_image_url TEXT,
  time_limit_seconds INTEGER DEFAULT 300,
  max_questions INTEGER DEFAULT 10,
  points_per_correct INTEGER DEFAULT 10,
  points_per_wrong INTEGER DEFAULT 0,
  bonus_time_points BOOLEAN DEFAULT TRUE, -- bonus for faster answers
  is_daily BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  community_id UUID REFERENCES communities(id) ON DELETE SET NULL,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  play_count INTEGER DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_games_type ON games(type);
CREATE INDEX idx_games_active ON games(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_games_daily ON games(is_daily) WHERE is_daily = TRUE;

-- ============================================================================
-- 22. QUESTIONS
-- ============================================================================

CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type question_type_enum NOT NULL DEFAULT 'multiple_choice',
  options JSONB NOT NULL DEFAULT '[]', -- array of {id, text, is_correct}
  correct_answer TEXT, -- for fill_blank
  explanation TEXT,
  image_url TEXT,
  points INTEGER DEFAULT 10,
  time_limit_seconds INTEGER DEFAULT 30,
  sort_order INTEGER DEFAULT 0,
  difficulty game_difficulty_enum DEFAULT 'medium',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_questions_game ON questions(game_id);

-- ============================================================================
-- 23. GAME SESSIONS
-- ============================================================================

CREATE TABLE game_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  score INTEGER DEFAULT 0,
  correct_count INTEGER DEFAULT 0,
  wrong_count INTEGER DEFAULT 0,
  skipped_count INTEGER DEFAULT 0,
  time_taken_seconds INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_game_sessions_game ON game_sessions(game_id);
CREATE INDEX idx_game_sessions_user ON game_sessions(user_id);
CREATE INDEX idx_game_sessions_score ON game_sessions(score DESC);

-- ============================================================================
-- 24. GAME ANSWERS
-- ============================================================================

CREATE TABLE game_answers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  selected_option TEXT,
  is_correct BOOLEAN DEFAULT FALSE,
  time_taken_seconds INTEGER DEFAULT 0,
  points_earned INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_game_answers_session ON game_answers(session_id);

-- ============================================================================
-- 25. POINTS TRANSACTIONS
-- ============================================================================

CREATE TABLE points_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  action points_action_enum NOT NULL,
  points INTEGER NOT NULL,
  description TEXT,
  reference_id UUID, -- generic reference to the source entity
  reference_type TEXT, -- 'post', 'comment', 'game_session', etc.
  balance_after INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_points_transactions_user ON points_transactions(user_id);
CREATE INDEX idx_points_transactions_action ON points_transactions(action);
CREATE INDEX idx_points_transactions_created ON points_transactions(created_at DESC);

-- ============================================================================
-- 26. DAILY LEADERBOARDS
-- ============================================================================

CREATE TABLE daily_leaderboards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  points INTEGER DEFAULT 0,
  rank INTEGER,
  games_played INTEGER DEFAULT 0,
  posts_created INTEGER DEFAULT 0,
  comments_created INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

CREATE INDEX idx_daily_leaderboards_date ON daily_leaderboards(date);
CREATE INDEX idx_daily_leaderboards_rank ON daily_leaderboards(date, rank);

-- ============================================================================
-- 27. WEEKLY LEADERBOARDS
-- ============================================================================

CREATE TABLE weekly_leaderboards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  week_end DATE NOT NULL,
  points INTEGER DEFAULT 0,
  rank INTEGER,
  games_played INTEGER DEFAULT 0,
  posts_created INTEGER DEFAULT 0,
  comments_created INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, week_start)
);

CREATE INDEX idx_weekly_leaderboards_week ON weekly_leaderboards(week_start);

-- ============================================================================
-- 28. LIFETIME LEADERBOARDS
-- ============================================================================

CREATE TABLE lifetime_leaderboards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  total_points INTEGER DEFAULT 0,
  rank INTEGER,
  total_games_played INTEGER DEFAULT 0,
  total_posts INTEGER DEFAULT 0,
  total_comments INTEGER DEFAULT 0,
  total_events_attended INTEGER DEFAULT 0,
  total_achievements INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lifetime_leaderboards_rank ON lifetime_leaderboards(rank);
CREATE INDEX idx_lifetime_leaderboards_points ON lifetime_leaderboards(total_points DESC);

-- ============================================================================
-- 29. PODIUM HISTORY
-- ============================================================================

CREATE TABLE podium_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  period_type TEXT NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly')),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  rank INTEGER NOT NULL CHECK (rank BETWEEN 1 AND 3),
  points INTEGER DEFAULT 0,
  badge_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_podium_history_user ON podium_history(user_id);
CREATE INDEX idx_podium_history_period ON podium_history(period_type, period_start);

-- ============================================================================
-- 30. ACHIEVEMENTS
-- ============================================================================

CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  icon_url TEXT,
  badge_url TEXT,
  category TEXT NOT NULL, -- 'social', 'academic', 'gaming', 'community', 'milestone'
  points_reward INTEGER DEFAULT 0,
  criteria JSONB NOT NULL DEFAULT '{}', -- {type: 'post_count', threshold: 10}
  is_hidden BOOLEAN DEFAULT FALSE, -- secret achievements
  rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 31. USER ACHIEVEMENTS
-- ============================================================================

CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  progress DECIMAL(5, 2) DEFAULT 100.0, -- percentage
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);

-- ============================================================================
-- 32. NOTIFICATIONS
-- ============================================================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type notification_type_enum NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  data JSONB DEFAULT '{}', -- {post_id, comment_id, etc.}
  actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL, -- who triggered
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  action_url TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- ============================================================================
-- 33. USER NOTIFICATION PREFERENCES
-- ============================================================================

CREATE TABLE user_notification_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  push_enabled BOOLEAN DEFAULT TRUE,
  email_enabled BOOLEAN DEFAULT FALSE,
  likes_enabled BOOLEAN DEFAULT TRUE,
  comments_enabled BOOLEAN DEFAULT TRUE,
  follows_enabled BOOLEAN DEFAULT TRUE,
  mentions_enabled BOOLEAN DEFAULT TRUE,
  event_reminders_enabled BOOLEAN DEFAULT TRUE,
  community_updates_enabled BOOLEAN DEFAULT TRUE,
  messages_enabled BOOLEAN DEFAULT TRUE,
  game_challenges_enabled BOOLEAN DEFAULT TRUE,
  achievements_enabled BOOLEAN DEFAULT TRUE,
  system_enabled BOOLEAN DEFAULT TRUE,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 34. REPORTS
-- ============================================================================

CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reported_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content_type TEXT NOT NULL, -- 'post', 'comment', 'message', 'user', 'community'
  content_id UUID NOT NULL,
  category report_category_enum NOT NULL,
  description TEXT,
  evidence_urls TEXT[] DEFAULT '{}',
  status report_status_enum DEFAULT 'pending',
  assigned_to UUID REFERENCES profiles(id) ON DELETE SET NULL,
  resolution_notes TEXT,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_content ON reports(content_type, content_id);

-- ============================================================================
-- 35. AUDIT LOGS
-- ============================================================================

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- ============================================================================
-- 36. PLATFORM SETTINGS
-- ============================================================================

CREATE TABLE platform_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT NOT NULL UNIQUE,
  value JSONB NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'general',
  is_public BOOLEAN DEFAULT FALSE, -- if true, visible to non-admins
  updated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_platform_settings_key ON platform_settings(key);
CREATE INDEX idx_platform_settings_category ON platform_settings(category);

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE lifetime_leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE podium_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_settings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- End of Migration 001
-- ============================================================================
