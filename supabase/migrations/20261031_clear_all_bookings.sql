-- ====================================================================
-- BISHE Car Wash Service - Reset Bookings & Enable App Clearing
-- 1. Wipe all test bookings and test commission logs
-- 2. Reset bays to completely vacant status
-- 3. Grant DELETE policy so station staff / admin can clear records
-- 4. Create clear_all_bookings() RPC function for one-click app resets
-- ====================================================================

-- 1. Truncate test transaction records
TRUNCATE TABLE public.wash_bookings CASCADE;
TRUNCATE TABLE public.commission_logs CASCADE;

-- 2. Reset station bays to vacant
UPDATE public.station_bays 
SET is_occupied = FALSE, 
    current_booking_id = NULL, 
    active_license_plate = NULL, 
    assigned_washer_name = NULL, 
    started_at = NULL;

-- 3. Allow DELETE policy on wash_bookings and commission_logs
DROP POLICY IF EXISTS "Allow deleting bookings" ON public.wash_bookings;
CREATE POLICY "Allow deleting bookings" 
ON public.wash_bookings FOR DELETE USING (true);

DROP POLICY IF EXISTS "Allow deleting commission logs" ON public.commission_logs;
CREATE POLICY "Allow deleting commission logs" 
ON public.commission_logs FOR DELETE USING (true);

-- 4. Server-Side RPC Function to safely clear all bookings from the app
CREATE OR REPLACE FUNCTION public.clear_all_bookings()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM public.wash_bookings;
    DELETE FROM public.commission_logs;
    UPDATE public.station_bays 
    SET is_occupied = FALSE, 
        current_booking_id = NULL, 
        active_license_plate = NULL, 
        assigned_washer_name = NULL, 
        started_at = NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_all_bookings() TO anon, authenticated, service_role;
