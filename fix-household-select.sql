-- ========================================
-- FIX HOUSEHOLD SELECT POLICY
-- Allow users to see households they created
-- ========================================

-- Drop and recreate the household SELECT policy
DROP POLICY IF EXISTS "Users can view their households" ON households;

-- Allow users to see households they're members of OR households they created
CREATE POLICY "Users can view their households" ON households
    FOR SELECT USING (
        id IN (SELECT user_households()) OR
        created_by = auth.uid()
    );

-- ========================================
-- DONE! You should now be able to create and view households
-- ========================================
