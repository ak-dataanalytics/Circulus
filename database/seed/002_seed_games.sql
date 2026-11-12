-- ============================================================================
-- CIRCULUS Seed Data: Brain Arena Games & Question Bank
-- ============================================================================

-- 1. Games
INSERT INTO games (id, name, game_type, description, base_points, is_active, daily_challenge) VALUES
('g1111111-1111-1111-1111-111111111111', 'Daily Sudoku', 'sudoku', '9x9 logical grid puzzle. Tests analytical reasoning and working memory.', 150, TRUE, TRUE),
('g2222222-2222-2222-2222-222222222222', 'Logical Sequences', 'logic', 'Pattern recognition, deductive series, and analytical problem-solving.', 100, TRUE, FALSE),
('g3333333-3333-3333-3333-333333333333', 'Governance & General Knowledge', 'gk', 'Timed questions covering constitutional history, public economics, and world affairs.', 100, TRUE, TRUE),
('g4444444-4444-4444-4444-444444444444', 'Executive Memory Recall', 'memory', 'Grid pattern recognition and rapid sequence recall challenge.', 120, TRUE, FALSE),
('g5555555-5555-5555-5555-555555555555', 'Lexicon Word Challenge', 'word', 'Vocabulary precision, administrative phrasing, and verbal fluency.', 100, TRUE, FALSE)
ON CONFLICT (id) DO NOTHING;

-- 2. Questions for General Knowledge & Governance
INSERT INTO questions (id, game_id, category, difficulty, prompt, options, correct_answer, explanation, time_limit_seconds) VALUES
(
  uuid_generate_v4(),
  'g3333333-3333-3333-3333-333333333333',
  'Constitutional Law',
  'medium',
  'Which Article of the Constitution of India provides for the establishment of the Finance Commission?',
  '["Article 280", "Article 324", "Article 312", "Article 368"]'::jsonb,
  'Article 280',
  'Article 280 requires the President to constitute a Finance Commission at the expiration of every fifth year or earlier to make recommendations on tax devolution.',
  30
),
(
  uuid_generate_v4(),
  'g3333333-3333-3333-3333-333333333333',
  'Public Administration',
  'medium',
  'Which Committee recommended the introduction of the Citizens Charter in public administration in India?',
  '["Chief Ministers Conference 1997", "Sarkaria Commission", "Punchhi Commission", "First ARC"]'::jsonb,
  'Chief Ministers Conference 1997',
  'The conference of Chief Ministers held in May 1997 decided to formulate Citizens Charters for public offices with large citizen interfaces.',
  30
),
(
  uuid_generate_v4(),
  'g2222222-2222-2222-2222-222222222222',
  'Number Series',
  'medium',
  'What is the next number in the sequence: 2, 6, 12, 20, 30, ?',
  '["40", "42", "44", "46"]'::jsonb,
  '42',
  'The differences between consecutive terms are +4, +6, +8, +10. Thus the next difference is +12: 30 + 12 = 42 (also n*(n+1): 1*2, 2*3, 3*4, 4*5, 5*6, 6*7).',
  30
),
(
  uuid_generate_v4(),
  'g2222222-2222-2222-2222-222222222222',
  'Analytical Reasoning',
  'hard',
  'If all Ministers are Officers, and some Officers are Economists, which of the following is necessarily true?',
  '["All Economists are Ministers", "Some Officers may be Economists", "No Minister can be an Economist", "All Officers are Ministers"]'::jsonb,
  'Some Officers may be Economists',
  'Given directly in premise: since some Officers are Economists, it is necessarily true that some Officers may be/are Economists.',
  40
)
ON CONFLICT DO NOTHING;
