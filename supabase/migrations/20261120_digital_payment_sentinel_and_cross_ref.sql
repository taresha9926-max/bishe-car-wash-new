-- ====================================================================
-- BISHE Car Wash Service - Bank SMS Sentinel & Automated Cross-Reference Engine
-- Migration: 20261120_digital_payment_sentinel_and_cross_ref.sql
--
-- 1. Table for incoming bank transactions (CBE & Telebirr)
-- 2. Sentinel phone configuration & health monitor
-- 3. Ingest Bank SMS RPC function with automated regex parsing & booking match
-- 4. RLS & Permissions
-- ====================================================================

-- 1. Table: bank_incoming_transactions
CREATE TABLE IF NOT EXISTS public.bank_incoming_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider TEXT NOT NULL CHECK (lower(trim(provider)) IN ('cbe', 'telebirr')),
    ref_no TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payer_name TEXT,
    payer_phone TEXT,
    target_account TEXT,
    raw_sms TEXT,
    matched_booking_id TEXT,
    match_status TEXT NOT NULL DEFAULT 'unmatched' CHECK (match_status IN ('unmatched', 'matched', 'discrepancy')),
    receipt_url TEXT,
    received_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT bank_incoming_unique_provider_ref UNIQUE(provider, ref_no)
);

CREATE INDEX IF NOT EXISTS idx_bank_incoming_ref ON public.bank_incoming_transactions(ref_no);
CREATE INDEX IF NOT EXISTS idx_bank_incoming_matched ON public.bank_incoming_transactions(matched_booking_id);
CREATE INDEX IF NOT EXISTS idx_bank_incoming_received_at ON public.bank_incoming_transactions(received_at DESC);

-- 2. Table: app_config_sentinel (Station payment hardware settings)
CREATE TABLE IF NOT EXISTS public.app_config_sentinel (
    id TEXT PRIMARY KEY DEFAULT 'primary',
    sentinel_status TEXT NOT NULL DEFAULT 'online',
    battery_level INT DEFAULT 100,
    target_cbe_account TEXT DEFAULT '10004388',
    target_cbe_name TEXT DEFAULT 'Tariku G/tsadik G/silase',
    target_telebirr_phone TEXT DEFAULT '0910046553',
    target_telebirr_name TEXT DEFAULT 'Tariku Gebretsadike',
    security_mode TEXT NOT NULL DEFAULT 'flexible' CHECK (security_mode IN ('flexible', 'strict')),
    secret_token TEXT DEFAULT 'bishe_sentinel_token_2026',
    last_heartbeat TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- Seed initial default configuration
INSERT INTO public.app_config_sentinel (id, target_cbe_account, target_telebirr_phone, security_mode)
VALUES ('primary', '10004388', '0910046553', 'flexible')
ON CONFLICT (id) DO NOTHING;

-- 3. RLS and Grants
ALTER TABLE IF EXISTS public.bank_incoming_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.app_config_sentinel ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.bank_incoming_transactions TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.app_config_sentinel TO anon, authenticated, service_role;

DROP POLICY IF EXISTS "bank_incoming_public_read" ON public.bank_incoming_transactions;
CREATE POLICY "bank_incoming_public_read" ON public.bank_incoming_transactions FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "bank_incoming_public_insert" ON public.bank_incoming_transactions;
CREATE POLICY "bank_incoming_public_insert" ON public.bank_incoming_transactions FOR INSERT TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "bank_incoming_public_update" ON public.bank_incoming_transactions;
CREATE POLICY "bank_incoming_public_update" ON public.bank_incoming_transactions FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "app_config_sentinel_public_all" ON public.app_config_sentinel;
CREATE POLICY "app_config_sentinel_public_all" ON public.app_config_sentinel FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- 4. Authoritative RPC: ingest_bank_sms
CREATE OR REPLACE FUNCTION public.ingest_bank_sms(
    p_provider TEXT,
    p_raw_sms TEXT,
    p_secret_token TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    clean_provider TEXT;
    clean_sms TEXT;
    extracted_ref TEXT;
    extracted_amount NUMERIC(12, 2);
    extracted_payer TEXT;
    extracted_phone TEXT;
    extracted_target TEXT;
    extracted_receipt_url TEXT;
    match_row_id TEXT;
    amount_str TEXT;
    expected_token TEXT;
    booking_id_match TEXT;
BEGIN
    clean_provider := lower(trim(p_provider));
    clean_sms := trim(p_raw_sms);

    IF clean_sms IS NULL OR clean_sms = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Empty SMS content');
    END IF;

    -- Verify secret token if sentinel configuration requires it
    SELECT secret_token INTO expected_token FROM public.app_config_sentinel WHERE id = 'primary';
    IF expected_token IS NOT NULL AND expected_token <> '' AND p_secret_token IS NOT NULL THEN
        IF p_secret_token <> expected_token THEN
            RETURN jsonb_build_object('success', false, 'error', 'Invalid secret token');
        END IF;
    END IF;

    -- PARSE TELEBIRR
    IF clean_provider = 'telebirr' THEN
        -- Amount: "You have received ETB 50.00" or "ETB 4,000.00"
        amount_str := substring(clean_sms from '(?i)received ETB\s*([0-9,]+\.?[0-9]*)');
        IF amount_str IS NOT NULL THEN
            extracted_amount := replace(amount_str, ',', '')::NUMERIC;
        END IF;

        -- Transaction Ref: "Your transaction number is DKK0G3C37O"
        extracted_ref := substring(clean_sms from '(?i)transaction number is\s+([A-Za-z0-9]+)');

        -- Payer Name: "from Rakeb Kassahun(2519****1239)"
        extracted_payer := trim(substring(clean_sms from '(?i)from\s+([^(]+)\('));
        extracted_phone := substring(clean_sms from '\((2519[0-9*]+)\)');

        extracted_target := 'telebirr';
        extracted_receipt_url := 'https://transactioninfo.ethiotelecom.et/receipt/' || COALESCE(extracted_ref, '');

    -- PARSE CBE
    ELSIF clean_provider = 'cbe' THEN
        -- Amount: "You have received ETB 2,000.00"
        amount_str := substring(clean_sms from '(?i)received ETB\s*([0-9,]+\.?[0-9]*)');
        IF amount_str IS NOT NULL THEN
            extracted_amount := replace(amount_str, ',', '')::NUMERIC;
        END IF;

        -- Check if direct FT... is inside SMS (e.g. "Ref: FT263237JRB8")
        extracted_ref := substring(clean_sms from '(?i)\b(FT[0-9A-Za-z]{8,14})\b');

        -- If not, check CBE receipt link (e.g. "https://mbreciept.cbe.com.et/v2-hfHCxO9eFffMNPj5SyIp")
        IF extracted_ref IS NULL THEN
            extracted_ref := substring(clean_sms from '(?i)mbreciept\.cbe\.com\.et/([A-Za-z0-9_-]+)');
            IF extracted_ref IS NOT NULL THEN
                extracted_receipt_url := 'https://mbreciept.cbe.com.et/' || extracted_ref;
            END IF;
        ELSE
            extracted_receipt_url := 'https://mbreciept.cbe.com.et/' || extracted_ref;
        END IF;

        -- Payer: "from account 1*********8773 (Mizan Seifu Dube)"
        extracted_phone := substring(clean_sms from '(?i)from account\s+([0-9*]+)');
        extracted_payer := substring(clean_sms from '(?i)\(([A-Za-z\s]+)\)\s+to your account');

        -- Target: "to your account 1*********4388"
        extracted_target := substring(clean_sms from '(?i)to your account\s+([0-9*]+)');
    ELSE
        RETURN jsonb_build_object('success', false, 'error', 'Unsupported provider: ' || p_provider);
    END IF;

    IF extracted_ref IS NULL OR extracted_ref = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Could not parse reference number from SMS');
    END IF;

    IF extracted_amount IS NULL OR extracted_amount <= 0 THEN
        RETURN jsonb_build_object('success', false, 'error', 'Could not parse amount from SMS');
    END IF;

    -- Check for duplicate transaction
    IF EXISTS (
        SELECT 1 FROM public.bank_incoming_transactions
        WHERE lower(provider) = clean_provider AND lower(ref_no) = lower(extracted_ref)
    ) THEN
        RETURN jsonb_build_object(
            'success', true,
            'is_duplicate', true,
            'provider', clean_provider,
            'ref_no', extracted_ref,
            'amount', extracted_amount
        );
    END IF;

    -- Look for pending wash booking that has this transaction_ref
    SELECT id::text INTO booking_id_match
    FROM public.wash_bookings
    WHERE lower(trim(COALESCE(transaction_ref, ''))) = lower(trim(extracted_ref))
    ORDER BY created_at DESC
    LIMIT 1;

    -- Insert into bank_incoming_transactions
    INSERT INTO public.bank_incoming_transactions (
        provider,
        ref_no,
        amount,
        payer_name,
        payer_phone,
        target_account,
        raw_sms,
        matched_booking_id,
        match_status,
        receipt_url
    ) VALUES (
        clean_provider,
        extracted_ref,
        extracted_amount,
        extracted_payer,
        extracted_phone,
        extracted_target,
        clean_sms,
        booking_id_match,
        CASE WHEN booking_id_match IS NOT NULL THEN 'matched' ELSE 'unmatched' END,
        extracted_receipt_url
    )
    RETURNING id::text INTO match_row_id;

    -- Update sentinel heartbeat
    UPDATE public.app_config_sentinel
    SET sentinel_status = 'online',
        last_heartbeat = timezone('utc'::text, now()),
        updated_at = timezone('utc'::text, now())
    WHERE id = 'primary';

    RETURN jsonb_build_object(
        'success', true,
        'id', match_row_id,
        'provider', clean_provider,
        'ref_no', extracted_ref,
        'amount', extracted_amount,
        'payer_name', extracted_payer,
        'matched_booking_id', booking_id_match,
        'is_matched', (booking_id_match IS NOT NULL)
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.ingest_bank_sms(TEXT, TEXT, TEXT) TO anon, authenticated, service_role;

-- 5. Helper RPC to update Sentinel phone heartbeat & battery level
CREATE OR REPLACE FUNCTION public.update_sentinel_heartbeat(p_battery INT DEFAULT 100)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    UPDATE public.app_config_sentinel
    SET sentinel_status = 'online',
        battery_level = COALESCE(p_battery, battery_level),
        last_heartbeat = timezone('utc'::text, now()),
        updated_at = timezone('utc'::text, now())
    WHERE id = 'primary';
    SELECT true;
$$;

GRANT EXECUTE ON FUNCTION public.update_sentinel_heartbeat(INT) TO anon, authenticated, service_role;

-- 6. Reload schema cache
NOTIFY pgrst, 'reload schema';
