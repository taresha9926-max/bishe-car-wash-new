-- ====================================================================
-- BISHE Car Wash Service - Fix payment_meta and refresh ingest_bank_sms
-- Migration: 20261121_fix_payment_meta_and_ingest_bank_sms.sql
-- ====================================================================

-- 1. Ensure wash_bookings has payment_meta column so queries or triggers never fail
ALTER TABLE IF EXISTS public.wash_bookings 
ADD COLUMN IF NOT EXISTS payment_meta JSONB DEFAULT '{}'::jsonb;

-- 2. Drop existing function overloads to prevent signature conflicts
DROP FUNCTION IF EXISTS public.ingest_bank_sms(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.ingest_bank_sms(TEXT, TEXT);

-- 3. Create authoritative ingest_bank_sms RPC function
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
NOTIFY pgrst, 'reload schema';
