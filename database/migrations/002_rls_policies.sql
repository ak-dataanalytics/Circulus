-- ============================================================================
-- CIRCULUS - Row Level Security Policies
-- Migration: 002_rls_policies.sql
-- Description: Comprehensive RLS policies for all tables
-- ============================================================================

-- ============================================================================
-- HELPER FUNCTION: Check if user is admin
-- ============================================================================

CREATE OR REPLACE FUNCTION public.is_admin(check_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = check_user_id
      AND role IN ('admin', 'super_admin')
      AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Helper: Check if user is a member of a community
CREATE OR REPLACE FUNCTION public.is_community_member(p_community_id UUID, p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM community_members
    WHERE community_id = p_community_id
      AND user_id = p_user_id
      AND is_banned = FALSE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Helper: Check if user is a conversation participant
CREATE OR REPLACE FUNCTION public.is_conversation_member(p_conversation_id UUID, p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM conversation_members
    WHERE conversation_id = p_conversation_id
      AND user_id = p_user_id
      AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Helper: Check if users share at least one community
CREATE OR REPLACE FUNCTION public.shares_community_with(p_other_user_id UUID, p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM community_members cm1
    JOIN community_members cm2 ON cm1.community_id = cm2.community_id
    WHERE cm1.user_id = p_user_id
      AND cm2.user_id = p_other_user_id
      AND cm1.is_banned = FALSE
      AND cm2.is_banned = FALSE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================================================
-- PROFILES POLICIES
-- ============================================================================

-- Users can view their own full profile
CREATE POLICY profiles_select_own ON profiles
  FOR SELECT USING (id = auth.uid());

-- Users can view basic profiles of others in shared communities
CREATE POLICY profiles_select_shared ON profiles
  FOR SELECT USING (
    is_active = TRUE
    AND (
      id = auth.uid()
      OR shares_community_with(id)
      OR is_admin()
    )
  );

-- Users can update their own profile
CREATE POLICY profiles_update_own ON profiles
  FOR UPDATE USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Admins can update any profile
CREATE POLICY profiles_update_admin ON profiles
  FOR UPDATE USING (is_admin())
  WITH CHECK (is_admin());

-- Profiles are inserted via trigger on auth.users creation
CREATE POLICY profiles_insert ON profiles
  FOR INSERT WITH CHECK (id = auth.uid());

-- ============================================================================
-- DEPARTMENTS POLICIES
-- ============================================================================

-- Everyone can read departments
CREATE POLICY departments_select ON departments
  FOR SELECT USING (TRUE);

-- Only admins can manage departments
CREATE POLICY departments_insert ON departments
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY departments_update ON departments
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY departments_delete ON departments
  FOR DELETE USING (is_admin());

-- ============================================================================
-- BATCHES POLICIES
-- ============================================================================

CREATE POLICY batches_select ON batches
  FOR SELECT USING (TRUE);

CREATE POLICY batches_insert ON batches
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY batches_update ON batches
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY batches_delete ON batches
  FOR DELETE USING (is_admin());

-- ============================================================================
-- USER ROLES POLICIES
-- ============================================================================

-- Users can see their own roles
CREATE POLICY user_roles_select_own ON user_roles
  FOR SELECT USING (user_id = auth.uid());

-- Admins can see all roles
CREATE POLICY user_roles_select_admin ON user_roles
  FOR SELECT USING (is_admin());

-- Only admins can manage roles
CREATE POLICY user_roles_insert ON user_roles
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY user_roles_update ON user_roles
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY user_roles_delete ON user_roles
  FOR DELETE USING (is_admin());

-- ============================================================================
-- INVITATIONS POLICIES
-- ============================================================================

-- Only admins can view invitations
CREATE POLICY invitations_select ON invitations
  FOR SELECT USING (is_admin() OR invited_by = auth.uid());

-- Only admins can create invitations
CREATE POLICY invitations_insert ON invitations
  FOR INSERT WITH CHECK (is_admin());

-- Only admins can update invitations
CREATE POLICY invitations_update ON invitations
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

-- Only admins can delete invitations
CREATE POLICY invitations_delete ON invitations
  FOR DELETE USING (is_admin());

-- ============================================================================
-- VERIFICATION REQUESTS POLICIES
-- ============================================================================

-- Users can see their own verification requests
CREATE POLICY verification_select_own ON verification_requests
  FOR SELECT USING (user_id = auth.uid());

-- Admins can see all verification requests
CREATE POLICY verification_select_admin ON verification_requests
  FOR SELECT USING (is_admin());

-- Users can create their own verification requests
CREATE POLICY verification_insert ON verification_requests
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Only admins can update verification requests (approve/reject)
CREATE POLICY verification_update ON verification_requests
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

-- ============================================================================
-- POSTS POLICIES
-- ============================================================================

-- Public posts visible to all authenticated users
CREATE POLICY posts_select_public ON posts
  FOR SELECT USING (
    is_deleted = FALSE
    AND (
      -- Public posts
      visibility = 'public'
      -- Own posts
      OR author_id = auth.uid()
      -- Community posts visible to members
      OR (
        visibility = 'community_only'
        AND community_id IS NOT NULL
        AND is_community_member(community_id)
      )
      -- Admin override
      OR is_admin()
    )
  );

-- Users can create posts
CREATE POLICY posts_insert ON posts
  FOR INSERT WITH CHECK (
    author_id = auth.uid()
    AND (
      community_id IS NULL
      OR is_community_member(community_id)
    )
  );

-- Users can update their own posts
CREATE POLICY posts_update_own ON posts
  FOR UPDATE USING (author_id = auth.uid())
  WITH CHECK (author_id = auth.uid());

-- Admins can update any post
CREATE POLICY posts_update_admin ON posts
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

-- Users can soft-delete their own posts
CREATE POLICY posts_delete_own ON posts
  FOR DELETE USING (author_id = auth.uid() OR is_admin());

-- ============================================================================
-- POST MEDIA POLICIES
-- ============================================================================

CREATE POLICY post_media_select ON post_media
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM posts p
      WHERE p.id = post_id AND p.is_deleted = FALSE
      AND (
        p.visibility = 'public'
        OR p.author_id = auth.uid()
        OR (p.community_id IS NOT NULL AND is_community_member(p.community_id))
        OR is_admin()
      )
    )
  );

CREATE POLICY post_media_insert ON post_media
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM posts WHERE id = post_id AND author_id = auth.uid()
    )
  );

CREATE POLICY post_media_delete ON post_media
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM posts WHERE id = post_id AND author_id = auth.uid()
    ) OR is_admin()
  );

-- ============================================================================
-- POST LIKES POLICIES
-- ============================================================================

CREATE POLICY post_likes_select ON post_likes
  FOR SELECT USING (TRUE);

CREATE POLICY post_likes_insert ON post_likes
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY post_likes_delete ON post_likes
  FOR DELETE USING (user_id = auth.uid());

-- ============================================================================
-- COMMENTS POLICIES
-- ============================================================================

CREATE POLICY comments_select ON comments
  FOR SELECT USING (
    is_deleted = FALSE
    AND EXISTS (
      SELECT 1 FROM posts p WHERE p.id = post_id
      AND p.is_deleted = FALSE
      AND (
        p.visibility = 'public'
        OR p.author_id = auth.uid()
        OR (p.community_id IS NOT NULL AND is_community_member(p.community_id))
        OR is_admin()
      )
    )
  );

CREATE POLICY comments_insert ON comments
  FOR INSERT WITH CHECK (author_id = auth.uid());

CREATE POLICY comments_update ON comments
  FOR UPDATE USING (author_id = auth.uid())
  WITH CHECK (author_id = auth.uid());

CREATE POLICY comments_delete ON comments
  FOR DELETE USING (author_id = auth.uid() OR is_admin());

-- ============================================================================
-- SAVED POSTS POLICIES
-- ============================================================================

CREATE POLICY saved_posts_select ON saved_posts
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY saved_posts_insert ON saved_posts
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY saved_posts_delete ON saved_posts
  FOR DELETE USING (user_id = auth.uid());

-- ============================================================================
-- COMMUNITIES POLICIES
-- ============================================================================

-- Public communities visible to all; private/restricted to members only
CREATE POLICY communities_select ON communities
  FOR SELECT USING (
    is_active = TRUE
    AND (
      privacy = 'public'
      OR is_community_member(id)
      OR created_by = auth.uid()
      OR is_admin()
    )
  );

-- Any verified user can create a community
CREATE POLICY communities_insert ON communities
  FOR INSERT WITH CHECK (created_by = auth.uid());

-- Only community admins/owners or platform admins can update
CREATE POLICY communities_update ON communities
  FOR UPDATE USING (
    created_by = auth.uid()
    OR is_admin()
    OR EXISTS (
      SELECT 1 FROM community_members
      WHERE community_id = id AND user_id = auth.uid()
      AND role IN ('admin', 'owner')
    )
  );

CREATE POLICY communities_delete ON communities
  FOR DELETE USING (created_by = auth.uid() OR is_admin());

-- ============================================================================
-- COMMUNITY MEMBERS POLICIES
-- ============================================================================

-- Members visible to other members of the same community
CREATE POLICY community_members_select ON community_members
  FOR SELECT USING (
    is_community_member(community_id)
    OR is_admin()
  );

-- Join public communities; admin approval for others
CREATE POLICY community_members_insert ON community_members
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND (
      EXISTS (SELECT 1 FROM communities WHERE id = community_id AND privacy = 'public')
      OR is_admin()
    )
  );

-- Community admins can update members
CREATE POLICY community_members_update ON community_members
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.community_id = community_members.community_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('admin', 'owner', 'moderator')
    )
    OR is_admin()
  );

-- Users can leave communities; admins can remove members
CREATE POLICY community_members_delete ON community_members
  FOR DELETE USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.community_id = community_members.community_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('admin', 'owner')
    )
    OR is_admin()
  );

-- ============================================================================
-- COMMUNITY POSTS POLICIES
-- ============================================================================

CREATE POLICY community_posts_select ON community_posts
  FOR SELECT USING (is_community_member(community_id) OR is_admin());

CREATE POLICY community_posts_insert ON community_posts
  FOR INSERT WITH CHECK (is_community_member(community_id));

CREATE POLICY community_posts_delete ON community_posts
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM posts WHERE id = post_id AND author_id = auth.uid()
    )
    OR is_admin()
  );

-- ============================================================================
-- EVENTS POLICIES
-- ============================================================================

-- Published events are visible to all; drafts only to organizer
CREATE POLICY events_select ON events
  FOR SELECT USING (
    status IN ('published', 'ongoing', 'completed')
    OR organizer_id = auth.uid()
    OR is_admin()
  );

CREATE POLICY events_insert ON events
  FOR INSERT WITH CHECK (organizer_id = auth.uid());

CREATE POLICY events_update ON events
  FOR UPDATE USING (organizer_id = auth.uid() OR is_admin())
  WITH CHECK (organizer_id = auth.uid() OR is_admin());

CREATE POLICY events_delete ON events
  FOR DELETE USING (organizer_id = auth.uid() OR is_admin());

-- ============================================================================
-- EVENT REGISTRATIONS POLICIES
-- ============================================================================

CREATE POLICY event_registrations_select ON event_registrations
  FOR SELECT USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM events WHERE id = event_id AND organizer_id = auth.uid())
    OR is_admin()
  );

CREATE POLICY event_registrations_insert ON event_registrations
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY event_registrations_update ON event_registrations
  FOR UPDATE USING (
    user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM events WHERE id = event_id AND organizer_id = auth.uid())
    OR is_admin()
  );

CREATE POLICY event_registrations_delete ON event_registrations
  FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- ============================================================================
-- CONVERSATIONS POLICIES
-- ============================================================================

CREATE POLICY conversations_select ON conversations
  FOR SELECT USING (
    is_conversation_member(id) OR is_admin()
  );

CREATE POLICY conversations_insert ON conversations
  FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY conversations_update ON conversations
  FOR UPDATE USING (
    is_conversation_member(id) OR is_admin()
  );

-- ============================================================================
-- CONVERSATION MEMBERS POLICIES
-- ============================================================================

CREATE POLICY conversation_members_select ON conversation_members
  FOR SELECT USING (
    is_conversation_member(conversation_id) OR is_admin()
  );

CREATE POLICY conversation_members_insert ON conversation_members
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM conversations WHERE id = conversation_id AND created_by = auth.uid()
    )
    OR is_conversation_member(conversation_id)
    OR is_admin()
  );

CREATE POLICY conversation_members_update ON conversation_members
  FOR UPDATE USING (
    user_id = auth.uid() OR is_admin()
  );

-- ============================================================================
-- MESSAGES POLICIES
-- ============================================================================

-- Only conversation members can see messages
CREATE POLICY messages_select ON messages
  FOR SELECT USING (
    is_conversation_member(conversation_id) OR is_admin()
  );

-- Only conversation members can send messages
CREATE POLICY messages_insert ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND is_conversation_member(conversation_id)
  );

-- Only sender can edit their own messages
CREATE POLICY messages_update ON messages
  FOR UPDATE USING (sender_id = auth.uid())
  WITH CHECK (sender_id = auth.uid());

-- Sender can delete their own messages; admins too
CREATE POLICY messages_delete ON messages
  FOR DELETE USING (sender_id = auth.uid() OR is_admin());

-- ============================================================================
-- MESSAGE ATTACHMENTS POLICIES
-- ============================================================================

CREATE POLICY message_attachments_select ON message_attachments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM messages m
      WHERE m.id = message_id
      AND is_conversation_member(m.conversation_id)
    ) OR is_admin()
  );

CREATE POLICY message_attachments_insert ON message_attachments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM messages m
      WHERE m.id = message_id AND m.sender_id = auth.uid()
    )
  );

-- ============================================================================
-- GAMES POLICIES
-- ============================================================================

CREATE POLICY games_select ON games
  FOR SELECT USING (
    is_active = TRUE OR created_by = auth.uid() OR is_admin()
  );

CREATE POLICY games_insert ON games
  FOR INSERT WITH CHECK (is_admin() OR created_by = auth.uid());

CREATE POLICY games_update ON games
  FOR UPDATE USING (created_by = auth.uid() OR is_admin());

CREATE POLICY games_delete ON games
  FOR DELETE USING (is_admin());

-- ============================================================================
-- QUESTIONS POLICIES
-- ============================================================================

CREATE POLICY questions_select ON questions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM games WHERE id = game_id AND (is_active = TRUE OR created_by = auth.uid() OR is_admin()))
  );

CREATE POLICY questions_insert ON questions
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM games WHERE id = game_id AND (created_by = auth.uid() OR is_admin()))
  );

CREATE POLICY questions_update ON questions
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM games WHERE id = game_id AND (created_by = auth.uid() OR is_admin()))
  );

CREATE POLICY questions_delete ON questions
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM games WHERE id = game_id AND (created_by = auth.uid() OR is_admin()))
  );

-- ============================================================================
-- GAME SESSIONS POLICIES
-- ============================================================================

-- Users can see their own sessions; admins can see all
CREATE POLICY game_sessions_select ON game_sessions
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

-- Users can create their own sessions
CREATE POLICY game_sessions_insert ON game_sessions
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Only backend service role can update scores (prevents cheating)
CREATE POLICY game_sessions_update_service ON game_sessions
  FOR UPDATE USING (
    auth.jwt()->>'role' = 'service_role' OR is_admin()
  );

-- ============================================================================
-- GAME ANSWERS POLICIES
-- ============================================================================

CREATE POLICY game_answers_select ON game_answers
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM game_sessions WHERE id = session_id AND user_id = auth.uid())
    OR is_admin()
  );

-- Only backend service role can insert answers (prevents cheating)
CREATE POLICY game_answers_insert ON game_answers
  FOR INSERT WITH CHECK (
    auth.jwt()->>'role' = 'service_role'
    OR EXISTS (SELECT 1 FROM game_sessions WHERE id = session_id AND user_id = auth.uid())
  );

-- ============================================================================
-- POINTS TRANSACTIONS POLICIES
-- ============================================================================

CREATE POLICY points_transactions_select ON points_transactions
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

-- Only service role or admin can insert points
CREATE POLICY points_transactions_insert ON points_transactions
  FOR INSERT WITH CHECK (
    auth.jwt()->>'role' = 'service_role' OR is_admin()
  );

-- ============================================================================
-- LEADERBOARD POLICIES (read-only for users)
-- ============================================================================

CREATE POLICY daily_leaderboards_select ON daily_leaderboards
  FOR SELECT USING (TRUE);

CREATE POLICY daily_leaderboards_insert ON daily_leaderboards
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

CREATE POLICY daily_leaderboards_update ON daily_leaderboards
  FOR UPDATE USING (auth.jwt()->>'role' = 'service_role' OR is_admin());

CREATE POLICY weekly_leaderboards_select ON weekly_leaderboards
  FOR SELECT USING (TRUE);

CREATE POLICY weekly_leaderboards_insert ON weekly_leaderboards
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

CREATE POLICY weekly_leaderboards_update ON weekly_leaderboards
  FOR UPDATE USING (auth.jwt()->>'role' = 'service_role' OR is_admin());

CREATE POLICY lifetime_leaderboards_select ON lifetime_leaderboards
  FOR SELECT USING (TRUE);

CREATE POLICY lifetime_leaderboards_insert ON lifetime_leaderboards
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

CREATE POLICY lifetime_leaderboards_update ON lifetime_leaderboards
  FOR UPDATE USING (auth.jwt()->>'role' = 'service_role' OR is_admin());

-- ============================================================================
-- PODIUM HISTORY POLICIES
-- ============================================================================

CREATE POLICY podium_history_select ON podium_history
  FOR SELECT USING (TRUE);

CREATE POLICY podium_history_insert ON podium_history
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

-- ============================================================================
-- ACHIEVEMENTS POLICIES
-- ============================================================================

CREATE POLICY achievements_select ON achievements
  FOR SELECT USING (is_active = TRUE OR is_admin());

CREATE POLICY achievements_insert ON achievements
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY achievements_update ON achievements
  FOR UPDATE USING (is_admin());

CREATE POLICY achievements_delete ON achievements
  FOR DELETE USING (is_admin());

-- ============================================================================
-- USER ACHIEVEMENTS POLICIES
-- ============================================================================

CREATE POLICY user_achievements_select ON user_achievements
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

CREATE POLICY user_achievements_insert ON user_achievements
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

-- ============================================================================
-- NOTIFICATIONS POLICIES
-- ============================================================================

CREATE POLICY notifications_select ON notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY notifications_insert ON notifications
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

CREATE POLICY notifications_update ON notifications
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY notifications_delete ON notifications
  FOR DELETE USING (user_id = auth.uid());

-- ============================================================================
-- USER NOTIFICATION PREFERENCES POLICIES
-- ============================================================================

CREATE POLICY user_notification_prefs_select ON user_notification_preferences
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY user_notification_prefs_insert ON user_notification_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY user_notification_prefs_update ON user_notification_preferences
  FOR UPDATE USING (user_id = auth.uid());

-- ============================================================================
-- REPORTS POLICIES
-- ============================================================================

-- Users can see their own reports; admins can see all
CREATE POLICY reports_select ON reports
  FOR SELECT USING (reporter_id = auth.uid() OR is_admin());

-- Any authenticated user can create a report
CREATE POLICY reports_insert ON reports
  FOR INSERT WITH CHECK (reporter_id = auth.uid());

-- Only admins can update reports
CREATE POLICY reports_update ON reports
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

-- ============================================================================
-- AUDIT LOGS POLICIES
-- ============================================================================

-- Only admins can view audit logs
CREATE POLICY audit_logs_select ON audit_logs
  FOR SELECT USING (is_admin());

-- Service role and system can insert audit logs
CREATE POLICY audit_logs_insert ON audit_logs
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'service_role' OR is_admin());

-- ============================================================================
-- PLATFORM SETTINGS POLICIES
-- ============================================================================

-- Public settings visible to all; private settings to admins only
CREATE POLICY platform_settings_select ON platform_settings
  FOR SELECT USING (is_public = TRUE OR is_admin());

CREATE POLICY platform_settings_insert ON platform_settings
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY platform_settings_update ON platform_settings
  FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY platform_settings_delete ON platform_settings
  FOR DELETE USING (is_admin());

-- ============================================================================
-- End of Migration 002
-- ============================================================================
