-- ========================================
-- HOUSE OF IRISH - FIX EXISTING SCHEMA
-- This script handles existing objects properly
-- ========================================

-- Step 1: Drop the problematic user_profiles table that's causing infinite recursion
DROP TABLE IF EXISTS user_profiles CASCADE;

-- Step 2: Drop existing indexes (they'll be recreated)
DROP INDEX IF EXISTS idx_shopping_household;
DROP INDEX IF EXISTS idx_tasks_household;
DROP INDEX IF EXISTS idx_clifford_household;
DROP INDEX IF EXISTS idx_quick_add_household;
DROP INDEX IF EXISTS idx_household_members_user;
DROP INDEX IF EXISTS idx_household_members_household;
DROP INDEX IF EXISTS idx_households_invite_code;

-- Step 3: Ensure UUID extension exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Step 4: Create tables if they don't exist
-- (We'll use CREATE TABLE IF NOT EXISTS for safety)

-- HOUSEHOLDS TABLE
CREATE TABLE IF NOT EXISTS households (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    invite_code TEXT UNIQUE NOT NULL DEFAULT UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6)),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- HOUSEHOLD MEMBERS TABLE
CREATE TABLE IF NOT EXISTS household_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    initials TEXT NOT NULL,
    role TEXT DEFAULT 'member',
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(household_id, user_id)
);

-- SHOPPING ITEMS TABLE
CREATE TABLE IF NOT EXISTS shopping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    notes TEXT DEFAULT '',
    completed BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TASKS TABLE
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    notes TEXT DEFAULT '',
    assignee UUID REFERENCES household_members(id),
    due_date DATE,
    completed BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CLIFFORD TASKS TABLE
CREATE TABLE IF NOT EXISTS clifford (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    notes TEXT DEFAULT '',
    assignee UUID REFERENCES household_members(id),
    due_date DATE,
    completed BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- QUICK ADD ITEMS TABLE
CREATE TABLE IF NOT EXISTS quick_add (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID REFERENCES households(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('shopping', 'tasks', 'clifford')),
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- DROP AND RECREATE RLS POLICIES
-- (This ensures clean slate for policies)
-- ========================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their households" ON households;
DROP POLICY IF EXISTS "Users can create households" ON households;
DROP POLICY IF EXISTS "Admins can update their households" ON households;
DROP POLICY IF EXISTS "Users can view household members" ON household_members;
DROP POLICY IF EXISTS "Users can join households" ON household_members;
DROP POLICY IF EXISTS "Users can update their own membership" ON household_members;
DROP POLICY IF EXISTS "Users can leave households" ON household_members;
DROP POLICY IF EXISTS "Users can view shopping items" ON shopping;
DROP POLICY IF EXISTS "Users can add shopping items" ON shopping;
DROP POLICY IF EXISTS "Users can update shopping items" ON shopping;
DROP POLICY IF EXISTS "Users can delete shopping items" ON shopping;
DROP POLICY IF EXISTS "Users can view tasks" ON tasks;
DROP POLICY IF EXISTS "Users can add tasks" ON tasks;
DROP POLICY IF EXISTS "Users can update tasks" ON tasks;
DROP POLICY IF EXISTS "Users can delete tasks" ON tasks;
DROP POLICY IF EXISTS "Users can view clifford" ON clifford;
DROP POLICY IF EXISTS "Users can add clifford" ON clifford;
DROP POLICY IF EXISTS "Users can update clifford" ON clifford;
DROP POLICY IF EXISTS "Users can delete clifford" ON clifford;
DROP POLICY IF EXISTS "Users can view quick_add" ON quick_add;
DROP POLICY IF EXISTS "Users can add quick_add" ON quick_add;
DROP POLICY IF EXISTS "Users can update quick_add" ON quick_add;
DROP POLICY IF EXISTS "Users can delete quick_add" ON quick_add;

-- Enable RLS on all tables
ALTER TABLE households ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE clifford ENABLE ROW LEVEL SECURITY;
ALTER TABLE quick_add ENABLE ROW LEVEL SECURITY;

-- Households policies
CREATE POLICY "Users can view their households" ON households
    FOR SELECT USING (
        id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can create households" ON households
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can update their households" ON households
    FOR UPDATE USING (
        id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid() AND is_admin = TRUE)
    );

-- Household Members policies
CREATE POLICY "Users can view household members" ON household_members
    FOR SELECT USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can join households" ON household_members
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own membership" ON household_members
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can leave households" ON household_members
    FOR DELETE USING (user_id = auth.uid());

-- Shopping policies
CREATE POLICY "Users can view shopping items" ON shopping
    FOR SELECT USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can add shopping items" ON shopping
    FOR INSERT WITH CHECK (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can update shopping items" ON shopping
    FOR UPDATE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can delete shopping items" ON shopping
    FOR DELETE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

-- Tasks policies
CREATE POLICY "Users can view tasks" ON tasks
    FOR SELECT USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can add tasks" ON tasks
    FOR INSERT WITH CHECK (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can update tasks" ON tasks
    FOR UPDATE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can delete tasks" ON tasks
    FOR DELETE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

-- Clifford policies
CREATE POLICY "Users can view clifford" ON clifford
    FOR SELECT USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can add clifford" ON clifford
    FOR INSERT WITH CHECK (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can update clifford" ON clifford
    FOR UPDATE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can delete clifford" ON clifford
    FOR DELETE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

-- Quick Add policies
CREATE POLICY "Users can view quick_add" ON quick_add
    FOR SELECT USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can add quick_add" ON quick_add
    FOR INSERT WITH CHECK (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can update quick_add" ON quick_add
    FOR UPDATE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can delete quick_add" ON quick_add
    FOR DELETE USING (
        household_id IN (SELECT household_id FROM household_members WHERE user_id = auth.uid())
    );

-- ========================================
-- FUNCTIONS
-- ========================================

-- Function to get household by invite code (for joining)
CREATE OR REPLACE FUNCTION get_household_by_invite_code(code TEXT)
RETURNS TABLE (id UUID, name TEXT) AS $$
BEGIN
    RETURN QUERY SELECT h.id, h.name FROM households h WHERE h.invite_code = UPPER(code);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- REALTIME SUBSCRIPTIONS
-- ========================================

-- Remove tables from publication first (if they exist)
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS shopping;
    ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS tasks;
    ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS clifford;
    ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS household_members;
    ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS quick_add;
EXCEPTION WHEN OTHERS THEN
    NULL; -- Ignore errors if tables weren't in publication
END $$;

-- Add tables to publication
ALTER PUBLICATION supabase_realtime ADD TABLE shopping;
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE clifford;
ALTER PUBLICATION supabase_realtime ADD TABLE household_members;
ALTER PUBLICATION supabase_realtime ADD TABLE quick_add;

-- ========================================
-- INDEXES FOR PERFORMANCE
-- ========================================
CREATE INDEX idx_shopping_household ON shopping(household_id);
CREATE INDEX idx_tasks_household ON tasks(household_id);
CREATE INDEX idx_clifford_household ON clifford(household_id);
CREATE INDEX idx_quick_add_household ON quick_add(household_id, type);
CREATE INDEX idx_household_members_user ON household_members(user_id);
CREATE INDEX idx_household_members_household ON household_members(household_id);
CREATE INDEX idx_households_invite_code ON households(invite_code);

-- ========================================
-- DONE! Your database is now ready to use.
-- ========================================
