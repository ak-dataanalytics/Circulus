-- ============================================================================
-- CIRCULUS Performance Indexes
-- Optimizes feeds, search directory, message retrieval, and leaderboards
-- ============================================================================

-- Profiles directory indexing
CREATE INDEX IF NOT EXISTS idx_profiles_name_trgm ON profiles USING gin (full_name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_profiles_department ON profiles (department_id);
CREATE INDEX IF NOT EXISTS idx_profiles_batch ON profiles (batch_id);
CREATE INDEX IF NOT EXISTS idx_profiles_is_verified_active ON profiles (is_verified, is_active);

-- Posts feed indexing
CREATE INDEX IF NOT EXISTS idx_posts_created_at_desc ON posts (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts (user_id);
CREATE INDEX IF NOT EXISTS idx_posts_community_id ON posts (community_id);

-- Chat messaging indexing
CREATE INDEX IF NOT EXISTS idx_messages_conv_created ON messages (conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conv_members_user_conv ON conversation_members (user_id, conversation_id);

-- Leaderboards indexing
CREATE INDEX IF NOT EXISTS idx_daily_leaderboard_date_points ON daily_leaderboards (date, points DESC);
CREATE INDEX IF NOT EXISTS idx_weekly_leaderboard_week_points ON weekly_leaderboards (week_start, points DESC);
CREATE INDEX IF NOT EXISTS idx_lifetime_leaderboard_points ON lifetime_leaderboards (points DESC);

-- Game session indexing
CREATE INDEX IF NOT EXISTS idx_game_sessions_user_status ON game_sessions (user_id, status);
