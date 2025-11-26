-- ========================================
-- FIX HOUSEHOLD MEMBERS INSERT POLICY
-- Allow users to add themselves to households they created
-- ========================================

-- Drop and recreate the household_members policies
DROP POLICY IF EXISTS "Users can join households" ON household_members;
DROP POLICY IF EXISTS "Users can view household members" ON household_members;

-- Allow users to add themselves as members to any household
CREATE POLICY "Users can join households" ON household_members
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Allow users to view members in households they belong to
CREATE POLICY "Users can view household members" ON household_members
    FOR SELECT USING (
        user_id = auth.uid() OR
        household_id IN (SELECT user_households())
    );

-- ========================================
-- DONE! You should now be able to create households and be added as a member
-- ========================================
