-- ====================================================================
-- BISHE Car Wash Service - Enable Delete Policy & Fix clear_all_bookings
-- Migration: 20261106_allow_delete_daily_closings.sql
-- 1. Allow public DELETE and UPDATE on daily_closings
-- 2. Fix clear_all_bookings RPC with explicit WHERE clauses
-- ====================================================================

-- 1. Setup DELETE policy for daily_closings table
DROP POLICY IF EXISTS "Allow public delete daily closings" ON public.daily_closings;
CREATE POLICY "Allow public delete daily closings"
ON public.daily_closings
FOR DELETE
USING (true);

-- 2. Setup UPDATE policy for daily_closings table
DROP POLICY IF EXISTS "Allow public update daily closings" ON public.daily_closings;
CREATE POLICY "Allow public update daily closings"
ON public.daily_closings
FOR UPDATE
USING (true)
WITH CHECK (true);

-- 3. Fix clear_all_bookings RPC to comply with Postgres sql_safe_updates (requires WHERE clause)
CREATE OR REPLACE FUNCTION public.clear_all_bookings()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM public.wash_bookings WHERE id IS NOT NULL;
    DELETE FROM public.commission_logs WHERE id IS NOT NULL;
    DELETE FROM public.daily_closings WHERE id IS NOT NULL;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sms_outbox') THEN
        DELETE FROM public.sms_outbox WHERE id IS NOT NULL;
    END IF;
    UPDATE public.station_bays 
    SET is_occupied = FALSE, 
        current_booking_id = NULL, 
        active_license_plate = NULL, 
        assigned_washer_name = NULL, 
        started_at = NULL
    WHERE id IS NOT NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_all_bookings() TO anon, authenticated, service_role;
