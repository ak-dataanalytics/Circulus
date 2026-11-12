-- ============================================================================
-- CIRCULUS Database Functions & Triggers
-- Automated Weekly Leaderboard Reset & Podium Calculation, Timestamps, Stats
-- ============================================================================

-- Function: update_timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: profiles updated_at
DROP TRIGGER IF EXISTS trigger_update_profiles_timestamp ON profiles;
CREATE TRIGGER trigger_update_profiles_timestamp
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger: posts updated_at
DROP TRIGGER IF EXISTS trigger_update_posts_timestamp ON posts;
CREATE TRIGGER trigger_update_posts_timestamp
BEFORE UPDATE ON posts
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger: communities updated_at
DROP TRIGGER IF EXISTS trigger_update_communities_timestamp ON communities;
CREATE TRIGGER trigger_update_communities_timestamp
BEFORE UPDATE ON communities
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger: conversations updated_at
DROP TRIGGER IF EXISTS trigger_update_conversations_timestamp ON conversations;
CREATE TRIGGER trigger_update_conversations_timestamp
BEFORE UPDATE ON conversations
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Function: auto_finalize_weekly_podium
-- Scheduled every Sunday at 23:59:59 (Asia/Kolkata) to seal top 3 performers
CREATE OR REPLACE FUNCTION finalize_weekly_podium(target_week_start DATE)
RETURNS UUID AS $$
DECLARE
  top_gold RECORD;
  top_silver RECORD;
  top_bronze RECORD;
  podium_id UUID;
  week_ending DATE;
BEGIN
  week_ending := target_week_start + INTERVAL '6 days';

  -- Select Top 3
  SELECT user_id, points INTO top_gold FROM weekly_leaderboards 
  WHERE week_start = target_week_start ORDER BY points DESC LIMIT 1 OFFSET 0;

  SELECT user_id, points INTO top_silver FROM weekly_leaderboards 
  WHERE week_start = target_week_start ORDER BY points DESC LIMIT 1 OFFSET 1;

  SELECT user_id, points INTO top_bronze FROM weekly_leaderboards 
  WHERE week_start = target_week_start ORDER BY points DESC LIMIT 1 OFFSET 2;

  IF top_gold.user_id IS NOT NULL THEN
    INSERT INTO podium_history (
      id, week_start, week_end, 
      gold_user_id, silver_user_id, bronze_user_id,
      gold_points, silver_points, bronze_points,
      created_at
    ) VALUES (
      uuid_generate_v4(), target_week_start, week_ending,
      top_gold.user_id, COALESCE(top_silver.user_id, top_gold.user_id), COALESCE(top_bronze.user_id, top_gold.user_id),
      top_gold.points, COALESCE(top_silver.points, 0), COALESCE(top_bronze.points, 0),
      NOW()
    ) RETURNING id INTO podium_id;

    RETURN podium_id;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
