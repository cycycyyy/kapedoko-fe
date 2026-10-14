-- =========================================================
-- KapéDoko — Add hidden to shop_status
-- =========================================================
-- Run this as its own query BEFORE 20261013_shop_status_hidden.sql.
-- Postgres cannot use a newly added enum value in the same
-- transaction that adds it.
-- =========================================================

alter type public.shop_status add value if not exists 'hidden';
