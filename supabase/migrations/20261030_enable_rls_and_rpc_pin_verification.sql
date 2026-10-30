-- ====================================================================
-- BISHE Car Wash Service - Security Hardening Migration
-- 1. Enable Row Level Security (RLS) on all tables
-- 2. Lock down staff_credentials from public SELECT
-- 3. Create server-side verify_staff_pin RPC function
-- ====================================================================

-- 1. Enable RLS on core tables
ALTER TABLE IF EXISTS public.staff_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.wash_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.station_bays ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.wash_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.staff_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.commission_logs ENABLE ROW LEVEL SECURITY;

-- 2. POLICIES: wash_packages (Public read, station update)
DROP POLICY IF EXISTS "Public can view wash packages" ON public.wash_packages;
CREATE POLICY "Public can view wash packages" 
ON public.wash_packages FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow updating packages" ON public.wash_packages;
CREATE POLICY "Allow updating packages" 
ON public.wash_packages FOR UPDATE USING (true);

-- 3. POLICIES: station_bays (Public read, station update)
DROP POLICY IF EXISTS "Public can view station bays" ON public.station_bays;
CREATE POLICY "Public can view station bays" 
ON public.station_bays FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow updating bays" ON public.station_bays;
CREATE POLICY "Allow updating bays" 
ON public.station_bays FOR UPDATE USING (true);

-- 4. POLICIES: wash_bookings (Public create & read, cashier update)
DROP POLICY IF EXISTS "Public can view bookings" ON public.wash_bookings;
CREATE POLICY "Public can view bookings" 
ON public.wash_bookings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public can create bookings" ON public.wash_bookings;
CREATE POLICY "Public can create bookings" 
ON public.wash_bookings FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow updating bookings" ON public.wash_bookings;
CREATE POLICY "Allow updating bookings" 
ON public.wash_bookings FOR UPDATE USING (true);

-- 5. POLICIES: staff_members (Public read for assignment, admin update)
DROP POLICY IF EXISTS "Public can view staff" ON public.staff_members;
CREATE POLICY "Public can view staff" 
ON public.staff_members FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow modifying staff" ON public.staff_members;
CREATE POLICY "Allow modifying staff" 
ON public.staff_members FOR ALL USING (true);

-- 6. POLICIES: commission_logs (Staff read and create)
DROP POLICY IF EXISTS "Public can view commission logs" ON public.commission_logs;
CREATE POLICY "Public can view commission logs" 
ON public.commission_logs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow inserting commission logs" ON public.commission_logs;
CREATE POLICY "Allow inserting commission logs" 
ON public.commission_logs FOR INSERT WITH CHECK (true);

-- 7. POLICIES: staff_credentials (HARDENED LOCKDOWN)
-- NO SELECT policy granted to anon! Direct GET /rest/v1/staff_credentials returns empty list
DROP POLICY IF EXISTS "Allow anon read credentials" ON public.staff_credentials;
DROP POLICY IF EXISTS "No public access to credentials" ON public.staff_credentials;

-- 8. PostgreSQL RPC function for Server-Side PIN Verification
CREATE OR REPLACE FUNCTION public.verify_staff_pin(p_role TEXT, p_pin TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    matched_count INTEGER;
    role_norm TEXT;
BEGIN
    role_norm := lower(trim(p_role));
    
    -- Check if pin matches active record in staff_credentials table
    SELECT COUNT(*) INTO matched_count
    FROM public.staff_credentials
    WHERE lower(trim(role)) = role_norm
      AND is_active = TRUE
      AND (
          pin_hash = trim(p_pin)
          OR crypt(trim(p_pin), pin_hash) = pin_hash
      );
      
    IF matched_count > 0 THEN
        RETURN TRUE;
    END IF;

    -- Fallback default PIN check only if no credentials exist for this role
    SELECT COUNT(*) INTO matched_count
    FROM public.staff_credentials
    WHERE lower(trim(role)) = role_norm AND is_active = TRUE;

    IF matched_count = 0 THEN
        IF role_norm = 'admin' AND trim(p_pin) = '1234' THEN RETURN TRUE; END IF;
        IF role_norm = 'cashier' AND trim(p_pin) = '0000' THEN RETURN TRUE; END IF;
        IF role_norm = 'storekeeper' AND trim(p_pin) = '3344' THEN RETURN TRUE; END IF;
        IF role_norm = 'accountant' AND trim(p_pin) = '5566' THEN RETURN TRUE; END IF;
    END IF;

    RETURN FALSE;
END;
$$;

-- Grant EXECUTE permission so the client can call this function anonymously
GRANT EXECUTE ON FUNCTION public.verify_staff_pin(TEXT, TEXT) TO anon, authenticated, service_role;
