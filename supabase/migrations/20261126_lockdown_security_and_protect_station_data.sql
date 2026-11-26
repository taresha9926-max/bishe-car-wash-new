-- ====================================================================
-- BISHE Car Wash & Auto Care Service — Production Security Hardening
-- Migration: 20261126_lockdown_security_and_protect_station_data.sql
-- 
-- Objectives:
-- 1. Permanently DROP dangerous clear_all_bookings() wipe RPC function.
-- 2. DROP permissive DELETE policies on live transaction tables:
--    (wash_bookings, daily_closings, commission_logs, staff_credentials).
-- 3. Explicitly DENY DELETE queries from public anon key.
-- 4. Preserve full operational capabilities for live station:
--    - SELECT, INSERT, UPDATE on wash_bookings (intake, wash, complete, pay)
--    - SELECT, INSERT, UPDATE on daily_closings (closings & handovers)
--    - SELECT, INSERT, UPDATE on commission_logs (washer earnings & settlements)
--    - SELECT, UPDATE on station_bays (bay occupancy)
--    - SELECT, INSERT, UPDATE on wash_packages & staff_credentials
--    - RPC execute on verify_staff_pin & update_staff_pin
-- ====================================================================

-- 1. Permanently remove the dangerous reset/wipe function
REVOKE ALL ON FUNCTION public.clear_all_bookings() FROM PUBLIC, anon, authenticated;
DROP FUNCTION IF EXISTS public.clear_all_bookings();

-- 2. Remove all permissive DELETE policies on critical tables
DROP POLICY IF EXISTS "Allow deleting bookings" ON public.wash_bookings;
DROP POLICY IF EXISTS "Allow deleting commission logs" ON public.commission_logs;
DROP POLICY IF EXISTS "Allow public delete daily closings" ON public.daily_closings;
DROP POLICY IF EXISTS "staff_credentials_public_delete" ON public.staff_credentials;
DROP POLICY IF EXISTS "Allow deleting sms_outbox" ON public.sms_outbox;

-- 3. Explicitly block DELETE operations for anonymous / public access
CREATE POLICY "wash_bookings_prevent_anon_delete"
ON public.wash_bookings FOR DELETE TO anon USING (false);

CREATE POLICY "daily_closings_prevent_anon_delete"
ON public.daily_closings FOR DELETE TO anon USING (false);

CREATE POLICY "commission_logs_prevent_anon_delete"
ON public.commission_logs FOR DELETE TO anon USING (false);

CREATE POLICY "staff_credentials_prevent_anon_delete"
ON public.staff_credentials FOR DELETE TO anon USING (false);

-- 4. Ensure Row Level Security (RLS) is enabled and normal operations continue smoothly
ALTER TABLE public.wash_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_closings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.station_bays ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wash_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff_credentials ENABLE ROW LEVEL SECURITY;

-- 5. Guarantee clean operational policies (SELECT, INSERT, UPDATE) for station staff
-- wash_bookings
DROP POLICY IF EXISTS "wash_bookings_operational_select" ON public.wash_bookings;
CREATE POLICY "wash_bookings_operational_select" ON public.wash_bookings FOR SELECT USING (true);

DROP POLICY IF EXISTS "wash_bookings_operational_insert" ON public.wash_bookings;
CREATE POLICY "wash_bookings_operational_insert" ON public.wash_bookings FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "wash_bookings_operational_update" ON public.wash_bookings;
CREATE POLICY "wash_bookings_operational_update" ON public.wash_bookings FOR UPDATE USING (true) WITH CHECK (true);

-- daily_closings
DROP POLICY IF EXISTS "daily_closings_operational_select" ON public.daily_closings;
CREATE POLICY "daily_closings_operational_select" ON public.daily_closings FOR SELECT USING (true);

DROP POLICY IF EXISTS "daily_closings_operational_insert" ON public.daily_closings;
CREATE POLICY "daily_closings_operational_insert" ON public.daily_closings FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "daily_closings_operational_update" ON public.daily_closings;
CREATE POLICY "daily_closings_operational_update" ON public.daily_closings FOR UPDATE USING (true) WITH CHECK (true);

-- commission_logs
DROP POLICY IF EXISTS "commission_logs_operational_select" ON public.commission_logs;
CREATE POLICY "commission_logs_operational_select" ON public.commission_logs FOR SELECT USING (true);

DROP POLICY IF EXISTS "commission_logs_operational_insert" ON public.commission_logs;
CREATE POLICY "commission_logs_operational_insert" ON public.commission_logs FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "commission_logs_operational_update" ON public.commission_logs;
CREATE POLICY "commission_logs_operational_update" ON public.commission_logs FOR UPDATE USING (true) WITH CHECK (true);

-- station_bays
DROP POLICY IF EXISTS "station_bays_operational_select" ON public.station_bays;
CREATE POLICY "station_bays_operational_select" ON public.station_bays FOR SELECT USING (true);

DROP POLICY IF EXISTS "station_bays_operational_update" ON public.station_bays;
CREATE POLICY "station_bays_operational_update" ON public.station_bays FOR UPDATE USING (true) WITH CHECK (true);

-- 6. Grant RPC verification permissions
GRANT EXECUTE ON FUNCTION public.verify_staff_pin(TEXT, TEXT) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.update_staff_pin(TEXT, TEXT, TEXT) TO anon, authenticated, service_role;

-- 7. Notify PostgREST to reload schema cache immediately
NOTIFY pgrst, 'reload schema';
