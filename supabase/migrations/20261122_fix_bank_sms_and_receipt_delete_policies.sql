-- ====================================================================
-- BISHE Car Wash Service - Fix Bank SMS & Station Receipt Delete Capabilities
-- Bishoftu (Debre Zeyit), Oromia
-- 1. Explicitly grant DELETE policies on bank_incoming_transactions
-- 2. Create RPC functions with SECURITY DEFINER to guarantee deletions
-- ====================================================================

-- 1. Enable RLS and Grant DELETE policy for bank_incoming_transactions
ALTER TABLE IF EXISTS public.bank_incoming_transactions ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.bank_incoming_transactions TO anon, authenticated, service_role;

DROP POLICY IF EXISTS "bank_incoming_public_delete" ON public.bank_incoming_transactions;
CREATE POLICY "bank_incoming_public_delete" 
ON public.bank_incoming_transactions FOR DELETE TO anon, authenticated USING (true);

-- 2. RPC to delete a single bank incoming transaction by ID or Ref No
CREATE OR REPLACE FUNCTION public.delete_bank_incoming_transaction(p_id TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM public.bank_incoming_transactions 
    WHERE id::TEXT = p_id OR lower(trim(ref_no)) = lower(trim(p_id));
    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_bank_incoming_transaction(TEXT) TO anon, authenticated, service_role;

-- 3. RPC to clear all bank incoming transactions
CREATE OR REPLACE FUNCTION public.clear_all_bank_incoming_transactions()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    DELETE FROM public.bank_incoming_transactions;
    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_all_bank_incoming_transactions() TO anon, authenticated, service_role;

-- 4. RPC to delete a station receipt for a single booking
CREATE OR REPLACE FUNCTION public.delete_station_receipt(p_booking_id TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.wash_bookings 
    SET receipt_url = NULL 
    WHERE id::TEXT = p_booking_id;
    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_station_receipt(TEXT) TO anon, authenticated, service_role;

-- 5. RPC to clear all station receipts
CREATE OR REPLACE FUNCTION public.clear_all_station_receipts()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    UPDATE public.wash_bookings 
    SET receipt_url = NULL 
    WHERE receipt_url IS NOT NULL;
    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clear_all_station_receipts() TO anon, authenticated, service_role;
