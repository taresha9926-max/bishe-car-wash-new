-- ====================================================================
-- BISHE Car Wash Service - Reset Bookings & Enable App Clearing
-- 1. Wipe all test bookings and test commission logs immediately
-- 2. Reset bays to completely vacant status
-- 3. Grant DELETE policies so station staff / admin can clear records
-- 4. Create clear_all_bookings() RPC function for one-click app resets
-- ====================================================================

-- 1. Truncate test transaction records immediately
TRUNCATE TABLE public.wash_bookings CASCADE;
TRUNCATE TABLE public.commission_logs CASCADE;
DO $$ 
BEGIN 
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sms_outbox') THEN
        TRUNCATE TABLE public.sms_outbox CASCADE;
    END IF;
END $$;

-- 2. Reset station bays to vacant
UPDATE public.station_bays 
SET is_occupied = FALSE, 
    current_booking_id = NULL, 
    active_license_plate = NULL, 
    assigned_washer_name = NULL, 
    started_at = NULL;

-- 3. Allow DELETE policy on wash_bookings and commission_logs for anon & authenticated
DROP POLICY IF EXISTS "Allow deleting bookings" ON public.wash_bookings;
CREATE POLICY "Allow deleting bookings" 
ON public.wash_bookings FOR DELETE USING (true);

DROP POLICY IF EXISTS "Allow deleting commission logs" ON public.commission_logs;
CREATE POLICY "Allow deleting commission logs" 
ON public.commission_logs FOR DELETE USING (true);

DO $$ 
BEGIN 
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sms_outbox') THEN
        DROP POLICY IF EXISTS "Allow deleting sms_outbox" ON public.sms_outbox;
        CREATE POLICY "Allow deleting sms_outbox" ON public.sms_outbox FOR DELETE USING (true);
    END IF;
END $$;

-- 4. Server-Side RPC Function to safely clear all bookings and history from the app
CREATE OR REPLACE FUNCTION public.clear_all_bookings()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM public.wash_bookings;
    DELETE FROM public.commission_logs;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sms_outbox') THEN
        DELETE FROM public.sms_outbox;
    END IF;
    UPDATE public.station_bays 
    SET is_occupied = FALSE, 
        current_booking_id = NULL, 
        active_license_plate = NULL, 
        assigned_washer_name = NULL, 
        started_at = NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_all_bookings() TO anon, authenticated, service_role;
