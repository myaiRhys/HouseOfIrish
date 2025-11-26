-- ========================================
-- FIX HOUSEHOLD CREATION POLICY
-- ========================================

-- Drop and recreate the household INSERT policy
DROP POLICY IF EXISTS "Users can create households" ON households;

-- Allow users to create households where they are the creator
CREATE POLICY "Users can create households" ON households
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL AND
        (created_by = auth.uid() OR created_by IS NULL)
    );

-- ========================================
-- DONE! You should now be able to create households
-- ========================================
