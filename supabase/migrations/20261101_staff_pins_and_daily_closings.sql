-- ====================================================================
-- BISHE Car Wash Service - Dynamic Staff PINs & Daily Closings Sync
-- Migration: 20261101_staff_pins_and_daily_closings.sql
-- 1. Create update_staff_pin RPC for instant SQL-backed PIN modification
-- 2. Retire hardcoded default PIN fallbacks in verify_staff_pin
-- 3. Create daily_closings table with real-time audit capability
-- ====================================================================

-- 1. Create or replace update_staff_pin RPC function
DROP FUNCTION IF EXISTS public.update_staff_pin(TEXT, TEXT);
DROP FUNCTION IF EXISTS public.update_staff_pin(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.update_staff_pin(
    p_role TEXT,
    p_new_pin TEXT,
    p_full_name TEXT DEFAULT NULL
)
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

    -- Update existing staff credential for this role
    UPDATE public.staff_credentials
    SET pin_hash = clean_pin,
        full_name = COALESCE(p_full_name, full_name),
        is_active = TRUE
    WHERE lower(trim(role)) = role_norm;

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

-- 2. Update verify_staff_pin: database is authoritative source of truth
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

    -- 1. Verify against active credentials stored directly in database
    SELECT COUNT(*) INTO matched_count
    FROM public.staff_credentials
    WHERE lower(trim(role)) = role_norm
      AND is_active = TRUE
      AND pin_hash = clean_pin;

    IF matched_count > 0 THEN
        RETURN TRUE;
    END IF;

    -- 2. Bootstrap check: ONLY if zero rows exist in staff_credentials for this role
    -- Once a row exists in the table, hardcoded pins are permanently rejected.
    SELECT COUNT(*) INTO matched_count
    FROM public.staff_credentials
    WHERE lower(trim(role)) = role_norm;

    IF matched_count = 0 THEN
        IF role_norm = 'admin' AND clean_pin = '1234' THEN RETURN TRUE; END IF;
        IF role_norm = 'cashier' AND clean_pin = '0000' THEN RETURN TRUE; END IF;
        IF role_norm = 'storekeeper' AND clean_pin = '3344' THEN RETURN TRUE; END IF;
        IF role_norm = 'accountant' AND clean_pin = '5566' THEN RETURN TRUE; END IF;
    END IF;

    RETURN FALSE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.verify_staff_pin(TEXT, TEXT) TO anon, authenticated, service_role;

-- 3. Create daily_closings table for cashier -> accountant/admin real-time audit
CREATE TABLE IF NOT EXISTS public.daily_closings (
    id TEXT PRIMARY KEY,
    closing_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cashier_name TEXT NOT NULL,
    gross_revenue NUMERIC NOT NULL DEFAULT 0,
    cash_revenue NUMERIC NOT NULL DEFAULT 0,
    digital_revenue NUMERIC NOT NULL DEFAULT 0,
    cars_washed_count INTEGER NOT NULL DEFAULT 0,
    commission_pool NUMERIC NOT NULL DEFAULT 0,
    net_station_profit NUMERIC NOT NULL DEFAULT 0,
    cash_deposited NUMERIC NOT NULL DEFAULT 0,
    petty_cash_expenses NUMERIC NOT NULL DEFAULT 0,
    cash_remaining NUMERIC NOT NULL DEFAULT 0,
    provider_breakdown JSONB DEFAULT '{}',
    washer_dividends JSONB DEFAULT '{}',
    notes TEXT,
    is_confirmed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS and setup policies
ALTER TABLE public.daily_closings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public select daily closings" ON public.daily_closings;
CREATE POLICY "Allow public select daily closings"
ON public.daily_closings
FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public insert daily closings" ON public.daily_closings;
CREATE POLICY "Allow public insert daily closings"
ON public.daily_closings
FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update daily closings" ON public.daily_closings;
CREATE POLICY "Allow public update daily closings"
ON public.daily_closings
FOR UPDATE
USING (true);
