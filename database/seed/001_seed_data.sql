-- ============================================================================
-- CIRCULUS Seed Data: Synthetic Fictional Identities & Standard Records
-- (Strictly fictional demo identities complying with security requirements)
-- ============================================================================

-- 1. Departments
INSERT INTO departments (id, name, code, description) VALUES
('d1111111-1111-1111-1111-111111111111', 'Administrative Services & Governance', 'ASG', 'Department of Administrative Services and Public Governance'),
('d2222222-2222-2222-2222-222222222222', 'Revenue, Finance & Accounts', 'RFA', 'Department of Revenue Administration and Public Finance'),
('d3333333-3333-3333-3333-333333333333', 'Digital Infrastructure & Technology', 'DIT', 'Department of Digital Governance and e-Services'),
('d4444444-4444-4444-4444-444444444444', 'Faculty of Public Policy', 'FPP', 'Academic and Training Faculty in Governance and Public Law')
ON CONFLICT (id) DO NOTHING;

-- 2. Batches
INSERT INTO batches (id, name, year, training_institution) VALUES
('b1111111-1111-1111-1111-111111111111', 'Batch of 2021 (Foundational)', 2021, 'National Academy of Administration'),
('b2222222-2222-2222-2222-222222222222', 'Batch of 2022 (Specialized)', 2022, 'National Institute of Public Governance'),
('b3333333-3333-3333-3333-333333333333', 'Batch of 2023 (Executive)', 2023, 'Academy of Strategic Management')
ON CONFLICT (id) DO NOTHING;

-- 3. Synthetic Seed Profiles
-- Super Administrator
INSERT INTO profiles (id, email, username, full_name, designation, current_posting, is_active, is_verified, is_onboarded)
VALUES (
  'a0000000-0000-0000-0000-000000000001',
  'admin@circulus.app',
  'superadmin',
  'System Administrator',
  'Director of Information Systems',
  'Headquarters, New Delhi',
  TRUE, TRUE, TRUE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_roles (id, user_id, role)
VALUES ('r0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'superadmin')
ON CONFLICT (id) DO NOTHING;

-- Faculty Member
INSERT INTO profiles (id, email, username, full_name, designation, department_id, current_posting, bio, is_active, is_verified, is_onboarded)
VALUES (
  'a0000000-0000-0000-0000-000000000002',
  'dr.sharma@circulus.app',
  'dr_sharma',
  'Prof. Rajesh Sharma',
  'Professor of Public Policy',
  'd4444444-4444-4444-4444-444444444444',
  'National Academy Campus',
  'Faculty in Public Governance & Regulatory Economics with 20+ years training civil servants.',
  TRUE, TRUE, TRUE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_roles (id, user_id, role)
VALUES ('r0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'faculty')
ON CONFLICT (id) DO NOTHING;

-- Verified Officer 1
INSERT INTO profiles (id, email, username, full_name, designation, department_id, batch_id, current_posting, bio, is_active, is_verified, is_onboarded)
VALUES (
  'a0000000-0000-0000-0000-000000000003',
  'ananya.verma@circulus.app',
  'ananya_v',
  'Ananya Verma',
  'Deputy Secretary',
  'd1111111-1111-1111-1111-111111111111',
  'b1111111-1111-1111-1111-111111111111',
  'Ministry of Finance, New Delhi',
  'Officer Batch 2021. Alumna of Prof. Sharma. Passionate about sustainable public investments.',
  TRUE, TRUE, TRUE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_roles (id, user_id, role)
VALUES ('r0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000003', 'officer')
ON CONFLICT (id) DO NOTHING;

-- Verified Officer 2
INSERT INTO profiles (id, email, username, full_name, designation, department_id, batch_id, current_posting, bio, is_active, is_verified, is_onboarded)
VALUES (
  'a0000000-0000-0000-0000-000000000004',
  'vikram.singh@circulus.app',
  'vikram_s',
  'Vikram Singh',
  'Joint Director',
  'd3333333-3333-3333-3333-333333333333',
  'b2222222-2222-2222-2222-222222222222',
  'State Secretariat, Mumbai',
  'Batch 2022. Working on digital infrastructure and open public data platforms.',
  TRUE, TRUE, TRUE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_roles (id, user_id, role)
VALUES ('r0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000004', 'officer')
ON CONFLICT (id) DO NOTHING;

-- 4. Initial Communities
INSERT INTO communities (id, name, description, is_private, created_by, member_count) VALUES
('c1111111-1111-1111-1111-111111111111', 'Policy & Economic Reforms', 'Discussions on macroeconomic policy, fiscal federalism, and regulatory frameworks.', FALSE, 'a0000000-0000-0000-0000-000000000002', 3),
('c2222222-2222-2222-2222-222222222222', 'Digital Governance Circle', 'Exchange of technical innovations, cybersecurity, and e-governance case studies.', FALSE, 'a0000000-0000-0000-0000-000000000004', 2),
('c3333333-3333-3333-3333-333333333333', 'Faculty & Alumni Network', 'Persistent forum connecting alumni with faculty mentors across batches.', FALSE, 'a0000000-0000-0000-0000-000000000002', 4)
ON CONFLICT (id) DO NOTHING;

-- Community Memberships
INSERT INTO community_members (id, community_id, user_id, role) VALUES
(uuid_generate_v4(), 'c1111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-000000000002', 'admin'),
(uuid_generate_v4(), 'c1111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-000000000003', 'member'),
(uuid_generate_v4(), 'c3333333-3333-3333-3333-333333333333', 'a0000000-0000-0000-0000-000000000002', 'admin'),
(uuid_generate_v4(), 'c3333333-3333-3333-3333-333333333333', 'a0000000-0000-0000-0000-000000000003', 'member'),
(uuid_generate_v4(), 'c3333333-3333-3333-3333-333333333333', 'a0000000-0000-0000-0000-000000000004', 'member')
ON CONFLICT DO NOTHING;

-- 5. Sample Invitation Code for testing
INSERT INTO invitations (id, email, role, invited_by, invitation_code, status, max_uses, use_count, expires_at)
VALUES (
  'i1111111-1111-1111-1111-111111111111',
  'officer.test@circulus.app',
  'officer',
  'a0000000-0000-0000-0000-000000000001',
  'CIRCULUS2026',
  'pending',
  5,
  0,
  NOW() + INTERVAL '30 days'
) ON CONFLICT (id) DO NOTHING;
