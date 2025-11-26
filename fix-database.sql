-- ========================================
-- FIX DATABASE ISSUES
-- Run this in your Supabase SQL Editor
-- ========================================

-- First, let's drop any existing problematic policies and tables
-- This will clean up any conflicts

-- Drop the user_profiles table if it exists (this is causing the recursion issue)
DROP TABLE IF EXISTS user_profiles CASCADE;

-- Drop all existing tables to start fresh (optional, only if you want a clean slate)
-- Uncomment these lines if you want to completely reset:
-- DROP TABLE IF EXISTS quick_add CASCADE;
-- DROP TABLE IF EXISTS clifford CASCADE;
-- DROP TABLE IF EXISTS tasks CASCADE;
-- DROP TABLE IF EXISTS shopping CASCADE;
-- DROP TABLE IF EXISTS household_members CASCADE;
-- DROP TABLE IF EXISTS households CASCADE;

-- Now run the main schema below
-- (Copy the contents of supabase-schema.sql here)
