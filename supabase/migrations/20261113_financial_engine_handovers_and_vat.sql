-- ====================================================================
-- BISHE Car Wash Service - Zero-Leakage Financial Architecture
-- Migration: 20261113_financial_engine_handovers_and_vat.sql
-- ====================================================================

-- 1. UPGRADE wash_bookings WITH TAX & NET REVENUE COLUMNS
ALTER TABLE IF EXISTS public.wash_bookings
ADD COLUMN IF NOT EXISTS is_vat_applicable BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS vat_rate NUMERIC(4, 2) DEFAULT 0.15,
ADD COLUMN IF NOT EXISTS vat_amount NUMERIC(10, 2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS net_base_revenue NUMERIC(10, 2) DEFAULT 0.00;

-- Backfill existing bookings (Shower is exempt 0.00, car wash & carpet is 15%)
UPDATE public.wash_bookings
SET 
  is_vat_applicable = CASE 
    WHEN lower(trim(coalesce(service_type, ''))) LIKE '%shower%' THEN FALSE 
    ELSE TRUE 
  END,
  vat_rate = CASE 
    WHEN lower(trim(coalesce(service_type, ''))) LIKE '%shower%' THEN 0.00 
    ELSE 0.15 
  END,
  net_base_revenue = CASE 
    WHEN lower(trim(coalesce(service_type, ''))) LIKE '%shower%' THEN COALESCE(total_amount, 0)
    ELSE ROUND(COALESCE(total_amount, 0) / 1.15, 2)
  END,
  vat_amount = CASE 
    WHEN lower(trim(coalesce(service_type, ''))) LIKE '%shower%' THEN 0.00
    ELSE ROUND(COALESCE(total_amount, 0) - (COALESCE(total_amount, 0) / 1.15), 2)
  END
WHERE net_base_revenue = 0.00 OR net_base_revenue IS NULL;

-- 2. CREATE cash_handovers TABLE (FREEZES THE EXACT BIRR ON OTP)
CREATE TABLE IF NOT EXISTS public.cash_handovers (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    from_role TEXT NOT NULL DEFAULT 'cashier',
    from_staff_name TEXT NOT NULL,
    to_role TEXT NOT NULL DEFAULT 'operations_manager',
    to_staff_name TEXT,
    shift_type TEXT NOT NULL DEFAULT 'day_shift',
    gross_cash_collected NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    urgent_expenses_deducted NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    net_cash_handed_over NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    otp_code VARCHAR(6) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 minutes')
);

CREATE INDEX IF NOT EXISTS idx_cash_handovers_otp_status 
ON public.cash_handovers(otp_code, status);

-- 3. CREATE urgent_cash_expenses TABLE (DRAWER CASH DEDUCTIONS)
CREATE TABLE IF NOT EXISTS public.urgent_cash_expenses (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    handover_id TEXT REFERENCES public.cash_handovers(id) ON DELETE SET NULL,
    spent_by_staff_name TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    category TEXT NOT NULL DEFAULT 'equipment_repair',
    description TEXT NOT NULL,
    receipt_photo_url TEXT,
    approved_by_role TEXT DEFAULT 'operations_manager',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. CREATE bank_deposits TABLE (PHYSICAL CASH -> ADMIN BANK PROOF)
CREATE TABLE IF NOT EXISTS public.bank_deposits (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    deposited_by_name TEXT NOT NULL,
    deposited_by_role TEXT NOT NULL,
    amount_deposited NUMERIC(10, 2) NOT NULL,
    bank_name TEXT NOT NULL DEFAULT 'Commercial Bank of Ethiopia (CBE)',
    account_number TEXT,
    bank_slip_photo_url TEXT NOT NULL,
    bank_reference_number TEXT,
    is_verified_by_admin BOOLEAN DEFAULT FALSE,
    verified_by_admin_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. UPGRADE daily_closings TABLE FOR SHIFT-AWARE STATUS
ALTER TABLE IF EXISTS public.daily_closings
ADD COLUMN IF NOT EXISTS shift_type TEXT DEFAULT 'day_shift',
ADD COLUMN IF NOT EXISTS vat_collected NUMERIC(10, 2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS net_base_revenue NUMERIC(10, 2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS handover_id TEXT REFERENCES public.cash_handovers(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS is_cash_handed_over BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS cash_in_drawer_current NUMERIC(10, 2) DEFAULT 0.00;

-- 6. RPC: ATOMIC OTP VERIFICATION & HANDOVER ACCEPTANCE
CREATE OR REPLACE FUNCTION public.accept_cash_handover(
    p_otp_code TEXT,
    p_receiver_name TEXT,
    p_receiver_role TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_handover RECORD;
BEGIN
    SELECT * INTO v_handover
    FROM public.cash_handovers
    WHERE otp_code = trim(p_otp_code)
      AND status = 'pending'
      AND expires_at > NOW()
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Invalid, expired, or already accepted Handover OTP code.'
        );
    END IF;

    UPDATE public.cash_handovers
    SET 
        status = 'accepted',
        to_staff_name = p_receiver_name,
        to_role = p_receiver_role,
        accepted_at = NOW()
    WHERE id = v_handover.id;

    UPDATE public.daily_closings
    SET 
        is_cash_handed_over = TRUE,
        cash_in_drawer_current = 0.00,
        handover_id = v_handover.id
    WHERE is_confirmed = FALSE OR closing_date >= (NOW() - INTERVAL '24 hours');

    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Handover accepted successfully.',
        'cash_amount', v_handover.net_cash_handed_over,
        'from_staff', v_handover.from_staff_name
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_cash_handover(TEXT, TEXT, TEXT) TO anon, authenticated, service_role;

-- 7. ENABLE ROW LEVEL SECURITY (RLS) & POLICIES
ALTER TABLE public.cash_handovers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.urgent_cash_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_deposits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public select cash_handovers" ON public.cash_handovers;
CREATE POLICY "Public select cash_handovers" ON public.cash_handovers FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert cash_handovers" ON public.cash_handovers;
CREATE POLICY "Public insert cash_handovers" ON public.cash_handovers FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update cash_handovers" ON public.cash_handovers;
CREATE POLICY "Public update cash_handovers" ON public.cash_handovers FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public select urgent_cash_expenses" ON public.urgent_cash_expenses;
CREATE POLICY "Public select urgent_cash_expenses" ON public.urgent_cash_expenses FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert urgent_cash_expenses" ON public.urgent_cash_expenses;
CREATE POLICY "Public insert urgent_cash_expenses" ON public.urgent_cash_expenses FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public select bank_deposits" ON public.bank_deposits;
CREATE POLICY "Public select bank_deposits" ON public.bank_deposits FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert bank_deposits" ON public.bank_deposits;
CREATE POLICY "Public insert bank_deposits" ON public.bank_deposits FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update bank_deposits" ON public.bank_deposits;
CREATE POLICY "Public update bank_deposits" ON public.bank_deposits FOR UPDATE USING (true);

-- Enable Supabase Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.cash_handovers;
ALTER PUBLICATION supabase_realtime ADD TABLE public.bank_deposits;
