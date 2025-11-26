-- ========================================
-- FIX RLS POLICIES - NO CIRCULAR DEPENDENCIES
-- This uses a helper function to avoid recursion
-- ========================================

-- First, create a helper function that bypasses RLS
CREATE OR REPLACE FUNCTION user_households()
RETURNS TABLE (household_id UUID) AS $$
BEGIN
    RETURN QUERY
    SELECT hm.household_id
    FROM household_members hm
    WHERE hm.user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop all existing policies
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

-- ========================================
-- HOUSEHOLD MEMBERS - NO RECURSION
-- ========================================

-- Simple policy: users can see members of their households
-- Using the security definer function to avoid recursion
CREATE POLICY "Users can view household members" ON household_members
    FOR SELECT USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can join households" ON household_members
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own membership" ON household_members
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can leave households" ON household_members
    FOR DELETE USING (user_id = auth.uid());

-- ========================================
-- HOUSEHOLDS POLICIES
-- ========================================

CREATE POLICY "Users can view their households" ON households
    FOR SELECT USING (
        id IN (SELECT user_households())
    );

CREATE POLICY "Users can create households" ON households
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can update their households" ON households
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM household_members
            WHERE household_members.household_id = households.id
            AND household_members.user_id = auth.uid()
            AND household_members.is_admin = TRUE
        )
    );

-- ========================================
-- SHOPPING POLICIES
-- ========================================

CREATE POLICY "Users can view shopping items" ON shopping
    FOR SELECT USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can add shopping items" ON shopping
    FOR INSERT WITH CHECK (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can update shopping items" ON shopping
    FOR UPDATE USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can delete shopping items" ON shopping
    FOR DELETE USING (
        household_id IN (SELECT user_households())
    );

-- ========================================
-- TASKS POLICIES
-- ========================================

CREATE POLICY "Users can view tasks" ON tasks
    FOR SELECT USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can add tasks" ON tasks
    FOR INSERT WITH CHECK (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can update tasks" ON tasks
    FOR UPDATE USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can delete tasks" ON tasks
    FOR DELETE USING (
        household_id IN (SELECT user_households())
    );

-- ========================================
-- CLIFFORD POLICIES
-- ========================================

CREATE POLICY "Users can view clifford" ON clifford
    FOR SELECT USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can add clifford" ON clifford
    FOR INSERT WITH CHECK (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can update clifford" ON clifford
    FOR UPDATE USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can delete clifford" ON clifford
    FOR DELETE USING (
        household_id IN (SELECT user_households())
    );

-- ========================================
-- QUICK ADD POLICIES
-- ========================================

CREATE POLICY "Users can view quick_add" ON quick_add
    FOR SELECT USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can add quick_add" ON quick_add
    FOR INSERT WITH CHECK (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can update quick_add" ON quick_add
    FOR UPDATE USING (
        household_id IN (SELECT user_households())
    );

CREATE POLICY "Users can delete quick_add" ON quick_add
    FOR DELETE USING (
        household_id IN (SELECT user_households())
    );

-- ========================================
-- DONE! No more infinite recursion!
-- ========================================
