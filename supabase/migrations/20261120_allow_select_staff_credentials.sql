-- ====================================================================
-- BISHE Car Wash Service - Dynamic Staff PINs Sync & RLS Read Enablement
-- Migration: 20261120_allow_select_staff_credentials.sql
-- 1. Enable SELECT & direct access for staff_credentials (anon & authenticated)
-- 2. Provide get_staff_credentials() RPC function
-- 3. Align verify_staff_pin bootstrap defaults with official app PINs
--    (admin: 4450, cashier: 2233, manager: 7788, accountant: 3344, storekeeper: 3344)
-- Safe & idempotent: can be executed repeatedly in Supabase SQL Editor.
-- ====================================================================

-- 1. Table Permissions & RLS Configuration
ALTER TABLE IF EXISTS public.staff_credentials ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.staff_credentials TO anon, authenticated, service_role;

-- Ensure role check constraint permits all station staff roles
ALTER TABLE IF EXISTS public.staff_credentials
    DROP CONSTRAINT IF EXISTS staff_credentials_role_check;

ALTER TABLE IF EXISTS public.staff_credentials
    ADD CONSTRAINT staff_credentials_role_check
    CHECK (lower(trim(role)) IN ('admin', 'cashier', 'manager', 'accountant', 'storekeeper'));

-- 2. Clean up legacy or restrictive policies on staff_credentials
DROP POLICY IF EXISTS "Allow anon manage tiktok reels config" ON public.staff_credentials;
DROP POLICY IF EXISTS "Allow updating staff credentials" ON public.staff_credentials;
DROP POLICY IF EXISTS "Allow inserting staff credentials" ON public.staff_credentials;
DROP POLICY IF EXISTS "staff_credentials_public_select" ON public.staff_credentials;
DROP POLICY IF EXISTS "staff_credentials_public_insert" ON public.staff_credentials;
DROP POLICY IF EXISTS "staff_credentials_public_update" ON public.staff_credentials;
DROP POLICY IF EXISTS "staff_credentials_public_delete" ON public.staff_credentials;

-- 3. Create permissive RLS policies for client sync
CREATE POLICY "staff_credentials_public_select"
ON public.staff_credentials
FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "staff_credentials_public_insert"
ON public.staff_credentials
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

CREATE POLICY "staff_credentials_public_update"
ON public.staff_credentials
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "staff_credentials_public_delete"
ON public.staff_credentials
FOR DELETE
TO anon, authenticated
USING (true);

-- 4. Create authoritative get_staff_credentials RPC function
DROP FUNCTION IF EXISTS public.get_staff_credentials();

CREATE OR REPLACE FUNCTION public.get_staff_credentials()
RETURNS TABLE (
    id TEXT,
    username TEXT,
    pin_hash TEXT,
    role TEXT,
    full_name TEXT,
    is_active BOOLEAN
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT DISTINCT ON (role)
        id::text,
        username::text,
        pin_hash::text,
        role::text,
        full_name::text,
        is_active::boolean
    FROM public.staff_credentials
    WHERE username NOT LIKE 'app_config_%'
      AND username NOT IN ('tare', 'dawit')
    ORDER BY role, (CASE WHEN username = 'admin' THEN 0 ELSE 1 END), updated_at DESC;
$$;

GRANT EXECUTE ON FUNCTION public.get_staff_credentials() TO anon, authenticated, service_role;

-- 5. Align verify_staff_pin with official system defaults and strict database priority
CREATE OR REPLACE FUNCTION public.verify_staff_pin(p_role TEXT, p_pin TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    matched_count INTEGER;
    role_norm TEXT;
    clean_pin TEXT;
BEGIN
    role_norm := lower(trim(p_role));
    clean_pin := trim(p_pin);

    IF clean_pin IS NULL OR clean_pin = '' THEN
        RETURN FALSE;
    END IF;

    -- 1. Primary check: Exact match against active stored credentials in database
    SELECT COUNT(*) INTO matched_count
    FROM public.staff_credentials
    WHERE lower(trim(role)) = role_norm
      AND is_active = TRUE
      AND pin_hash = clean_pin;

    IF matched_count > 0 THEN
        RETURN TRUE;
    END IF;

    -- 2. Bootstrap check: ONLY if NO row exists in staff_credentials for this role.
    -- Once a row exists in the database for this role, default PINs are strictly rejected!
    SELECT COUNT(*) INTO matched_count
    FROM public.staff_credentials
    WHERE lower(trim(role)) = role_norm;

    IF matched_count = 0 THEN
        IF role_norm = 'admin' AND clean_pin = '4450' THEN RETURN TRUE; END IF;
        IF role_norm = 'cashier' AND clean_pin = '2233' THEN RETURN TRUE; END IF;
        IF role_norm = 'manager' AND clean_pin = '7788' THEN RETURN TRUE; END IF;
        IF role_norm = 'accountant' AND clean_pin = '3344' THEN RETURN TRUE; END IF;
        IF role_norm = 'storekeeper' AND clean_pin = '3344' THEN RETURN TRUE; END IF;
    END IF;

    RETURN FALSE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.verify_staff_pin(TEXT, TEXT) TO anon, authenticated, service_role;

-- 6. Clean up legacy duplicate test credentials (e.g. tare, dawit test accounts)
DELETE FROM public.staff_credentials
WHERE role = 'admin' AND username IN ('tare', 'dawit');

-- 7. Update update_staff_pin function to prevent updating multiple accounts when role is admin
CREATE OR REPLACE FUNCTION public.update_staff_pin(p_role TEXT, p_new_pin TEXT, p_full_name TEXT DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    role_norm TEXT;
    clean_pin TEXT;
BEGIN
    role_norm := lower(trim(p_role));
    clean_pin := trim(p_new_pin);

    IF clean_pin IS NULL OR clean_pin = '' THEN
        RETURN FALSE;
    END IF;

    -- Update existing staff credential for this role (primary account)
    UPDATE public.staff_credentials
    SET pin_hash = clean_pin,
        full_name = COALESCE(p_full_name, full_name),
        is_active = TRUE
    WHERE lower(trim(role)) = role_norm
      AND (lower(trim(username)) = role_norm OR lower(trim(username)) = 'admin');

    -- If no row exists yet for this role, insert fresh active record
    IF NOT FOUND THEN
        INSERT INTO public.staff_credentials (role, username, pin_hash, full_name, is_active)
        VALUES (
            role_norm,
            role_norm,
            clean_pin,
            COALESCE(p_full_name, initcap(role_norm) || ' Staff'),
            TRUE
        );
    END IF;

    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_staff_pin(TEXT, TEXT, TEXT) TO anon, authenticated, service_role;

-- 8. Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
