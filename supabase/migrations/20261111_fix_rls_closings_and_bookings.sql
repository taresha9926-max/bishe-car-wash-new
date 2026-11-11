-- ====================================================================
-- BISHE Car Wash Service - Fix RLS Policies for daily_closings, wash_bookings & commission_logs
-- Migration: 20261111_fix_rls_closings_and_bookings.sql
-- Fixes PostgREST 401 (SQLSTATE 42501):
--   "new row violates row-level security policy (USING expression) for table daily_closings"
-- caused when UPDATE/DELETE policies are missing or restricted to authenticated-only.
-- Safe & idempotent: can be run repeatedly in Supabase SQL Editor.
-- ====================================================================

ALTER TABLE IF EXISTS public.daily_closings ENABLE ROW LEVEL SECURITY;

-- Drop any legacy or Studio-created policies on daily_closings so no stale USING expression blocks anon writes
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'daily_closings'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.daily_closings', pol.policyname);
    END LOOP;
END $$;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.daily_closings TO anon, authenticated, service_role;

CREATE POLICY "daily_closings_public_select"
ON public.daily_closings
FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "daily_closings_public_insert"
ON public.daily_closings
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

CREATE POLICY "daily_closings_public_update"
ON public.daily_closings
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "daily_closings_public_delete"
ON public.daily_closings
FOR DELETE
TO anon, authenticated
USING (true);

-- Ensure wash_bookings allows UPDATE WITH CHECK and DELETE (needed for Night Shift unarrived online no-show cleanup)
ALTER TABLE IF EXISTS public.wash_bookings ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.wash_bookings TO anon, authenticated, service_role;

DROP POLICY IF EXISTS "Allow updating bookings" ON public.wash_bookings;
CREATE POLICY "Allow updating bookings"
ON public.wash_bookings
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public delete bookings" ON public.wash_bookings;
CREATE POLICY "Allow public delete bookings"
ON public.wash_bookings
FOR DELETE
TO anon, authenticated
USING (true);

-- Ensure commission_logs allows UPDATE & DELETE (for settlement & admin cleanup)
ALTER TABLE IF EXISTS public.commission_logs ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.commission_logs TO anon, authenticated, service_role;

DROP POLICY IF EXISTS "Allow updating commission logs" ON public.commission_logs;
CREATE POLICY "Allow updating commission logs"
ON public.commission_logs
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow deleting commission logs" ON public.commission_logs;
CREATE POLICY "Allow deleting commission logs"
ON public.commission_logs
FOR DELETE
TO anon, authenticated
USING (true);

-- Reload PostgREST schema & policy cache immediately
NOTIFY pgrst, 'reload schema';
