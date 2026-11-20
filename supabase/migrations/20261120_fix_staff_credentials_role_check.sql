-- ====================================================================
-- BISHE Car Wash Service - Fix staff_credentials Role Check Constraint
-- Migration: 20261120_fix_staff_credentials_role_check.sql
-- 
-- Resolves error 23514 ("new row for relation staff_credentials violates check constraint staff_credentials_role_check")
-- Allows roles: admin, cashier, manager, accountant, storekeeper.
-- ====================================================================

-- 1. Drop existing restrictive role check constraint if present
ALTER TABLE IF EXISTS public.staff_credentials
    DROP CONSTRAINT IF EXISTS staff_credentials_role_check;

-- 2. Add updated role check constraint allowing all official station roles
ALTER TABLE IF EXISTS public.staff_credentials
    ADD CONSTRAINT staff_credentials_role_check
    CHECK (lower(trim(role)) IN ('admin', 'cashier', 'manager', 'accountant', 'storekeeper'));

-- 3. Clean up legacy duplicate test credentials
DELETE FROM public.staff_credentials
WHERE role = 'admin' AND username IN ('tare', 'dawit');

-- 4. Authoritative update_staff_pin function
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

-- 5. Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
