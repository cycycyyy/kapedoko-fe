-- =========================================================
-- KapéDoko — Add auditor to user_role
-- =========================================================
-- Run this as its own query in the SQL editor BEFORE
-- 20261003_amenity_source_of_truth.sql when profiles.role is
-- the live user_role enum. PostgreSQL cannot use a new enum
-- label in the same transaction that adds it.
-- Safe to re-run.
-- =========================================================

alter type public.user_role add value if not exists 'auditor';
