-- Verify that all tables exist and have correct structure
-- Run this to check your Supabase setup

-- Check all tables exist
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_name IN ('households', 'household_members', 'shopping', 'tasks', 'clifford', 'quick_add')
ORDER BY table_name;

-- Check RLS is enabled
SELECT
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('households', 'household_members', 'shopping', 'tasks', 'clifford', 'quick_add');

-- Check if the RPC function exists
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'get_household_by_invite_code';
