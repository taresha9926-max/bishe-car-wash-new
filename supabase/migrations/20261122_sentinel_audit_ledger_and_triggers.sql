-- ====================================================================
-- BISHE Car Wash Service - Bishoftu, Oromia, Ethiopia
-- Migration: 20261122_sentinel_audit_ledger_and_triggers.sql
-- Super AI Sentinel: Tamper-Proof Audit Event Sourcing & Station Integrity
-- ====================================================================

-- 1. TABLE: sentinel_audit_ledger
-- Monotonically ordered, tamper-proof audit event stream
CREATE TABLE IF NOT EXISTS public.sentinel_audit_ledger (
    id BIGSERIAL PRIMARY KEY,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    table_name TEXT NOT NULL,
    action TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    record_id TEXT,
    actor_id TEXT,
    actor_role TEXT,
    actor_name TEXT,
    old_record JSONB,
    new_record JSONB,
    risk_score INTEGER NOT NULL DEFAULT 0, -- 0=normal, 1=warning, 2=critical/theft
    anomaly_flags TEXT[] DEFAULT '{}'::text[],
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_sentinel_audit_id ON public.sentinel_audit_ledger(id);
CREATE INDEX IF NOT EXISTS idx_sentinel_audit_recorded_at ON public.sentinel_audit_ledger(recorded_at);
CREATE INDEX IF NOT EXISTS idx_sentinel_audit_risk_score ON public.sentinel_audit_ledger(risk_score);
CREATE INDEX IF NOT EXISTS idx_sentinel_audit_table ON public.sentinel_audit_ledger(table_name);

-- 2. ROW LEVEL SECURITY (RLS) FOR TAMPER-PROOF INTEGRITY
ALTER TABLE public.sentinel_audit_ledger ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow select on sentinel_audit_ledger" ON public.sentinel_audit_ledger;
DROP POLICY IF EXISTS "Deny client writes on sentinel_audit_ledger" ON public.sentinel_audit_ledger;

-- Allow read access so the developer's laptop Sentinel can stream incremental changes
CREATE POLICY "Allow select on sentinel_audit_ledger" 
ON public.sentinel_audit_ledger 
FOR SELECT 
TO public, anon, authenticated 
USING (true);

-- Deny all client-side inserts, updates, deletes (Triggers write via SECURITY DEFINER)
CREATE POLICY "Deny client writes on sentinel_audit_ledger" 
ON public.sentinel_audit_ledger 
FOR ALL 
TO public, anon, authenticated 
USING (false) 
WITH CHECK (false);

-- 3. AUDIT TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION public.fn_sentinel_audit_logger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_record_id TEXT;
    v_actor_id TEXT := 'system';
    v_actor_role TEXT := 'station_device';
    v_actor_name TEXT := 'Unknown';
    v_old_json JSONB := NULL;
    v_new_json JSONB := NULL;
    v_risk_score INTEGER := 0;
    v_anomaly_flags TEXT[] := '{}'::text[];
    v_notes TEXT := '';
    v_dup_count INTEGER := 0;
BEGIN
    -- Extract Record ID and JSON snapshots
    IF TG_OP = 'DELETE' THEN
        v_record_id := OLD.id::TEXT;
        v_old_json := to_jsonb(OLD);
    ELSIF TG_OP = 'UPDATE' THEN
        v_record_id := NEW.id::TEXT;
        v_old_json := to_jsonb(OLD);
        v_new_json := to_jsonb(NEW);
    ELSIF TG_OP = 'INSERT' THEN
        v_record_id := NEW.id::TEXT;
        v_new_json := to_jsonb(NEW);
    END IF;

    -- ====================================================================
    -- FORENSIC ANOMALY RULES (Ground Truth: BISHE_OPERATIONS_MANUAL.md)
    -- ====================================================================

    -- RULE 1: WASH BOOKINGS AUDIT
    IF TG_TABLE_NAME = 'wash_bookings' THEN
        -- Identify Actor
        IF TG_OP != 'DELETE' THEN
            v_actor_name := COALESCE(NEW.owner_name, 'Cashier Desk');
        END IF;

        IF TG_OP = 'UPDATE' THEN
            -- Check 1A: Vehicle Downgrade after wash started or paid (THEFT PATTERN)
            IF (LOWER(OLD.car_type) IN ('minibus', 'truck', 'medium', 'heavy')) 
               AND (LOWER(NEW.car_type) IN ('automobile', 'small', 'sedan')) THEN
                IF OLD.is_paid = TRUE OR OLD.status IN ('washing', 'drying', 'readyForPickup', 'completed') THEN
                    v_risk_score := 2;
                    v_anomaly_flags := array_append(v_anomaly_flags, 'VEHICLE_DOWNGRADE_AFTER_WASH');
                    v_notes := 'CRITICAL: Vehicle category downgraded from ' || OLD.car_type || ' to ' || NEW.car_type || ' after wash started or payment completed.';
                END IF;
            END IF;

            -- Check 1B: Manual Price Reduction on Paid Booking (CASH SKIMMING PATTERN)
            IF OLD.total_amount > NEW.total_amount AND (OLD.is_paid = TRUE OR OLD.status = 'completed') THEN
                v_risk_score := 2;
                v_anomaly_flags := array_append(v_anomaly_flags, 'POST_PAYMENT_PRICE_REDUCTION');
                v_notes := 'CRITICAL: Total amount reduced from ' || OLD.total_amount || ' ETB to ' || NEW.total_amount || ' ETB on settled ticket.';
            END IF;

            -- Check 1C: Voiding or Resetting a Completed Wash
            IF OLD.status = 'completed' AND NEW.status IN ('pending', 'queued', 'cancelled') THEN
                v_risk_score := 2;
                v_anomaly_flags := array_append(v_anomaly_flags, 'COMPLETED_WASH_VOIDED');
                v_notes := 'CRITICAL: Completed wash ticket was retroactively moved back to ' || NEW.status;
            END IF;
        END IF;

        -- Check 1D: Digital Double-Spend Reference (Telebirr / CBE reference reused)
        IF TG_OP IN ('INSERT', 'UPDATE') THEN
            IF NEW.transaction_ref IS NOT NULL AND TRIM(NEW.transaction_ref) <> '' THEN
                SELECT COUNT(*) INTO v_dup_count 
                FROM public.wash_bookings 
                WHERE transaction_ref = NEW.transaction_ref AND id::TEXT <> NEW.id::TEXT;

                IF v_dup_count > 0 THEN
                    v_risk_score := 2;
                    v_anomaly_flags := array_append(v_anomaly_flags, 'DUPLICATE_TRANSACTION_REF');
                    v_notes := 'CRITICAL: Bank reference number ' || NEW.transaction_ref || ' is attached to multiple bookings.';
                END IF;
            END IF;
        END IF;

        -- Check 1E: Statutory 15% VAT Tampering
        IF TG_OP IN ('INSERT', 'UPDATE') THEN
            IF (NEW.is_carpet IS NOT TRUE) AND (LOWER(COALESCE(NEW.service_type, '')) NOT LIKE '%shower%') THEN
                IF NEW.is_vat_applicable IS FALSE OR (NEW.vat_rate IS NOT NULL AND NEW.vat_rate < 0.15) THEN
                    v_risk_score := 1;
                    v_anomaly_flags := array_append(v_anomaly_flags, 'ILLEGAL_VAT_MODIFICATION');
                    v_notes := 'WARNING: Car wash service billed without required 15% statutory VAT.';
                END IF;
            END IF;
        END IF;

    -- RULE 2: SHIFT CASH HANDOVERS (OTP DUAL CUSTODY)
    ELSIF TG_TABLE_NAME = 'cash_handovers' THEN
        v_actor_name := COALESCE(NEW.from_staff_name, 'Cashier');
        v_actor_role := COALESCE(NEW.from_role, 'cashier');

        IF TG_OP IN ('INSERT', 'UPDATE') THEN
            -- Check large urgent expenses claimed during handover
            IF NEW.urgent_expenses_deducted > 2000.00 THEN
                v_risk_score := 1;
                v_anomaly_flags := array_append(v_anomaly_flags, 'HIGH_HANDOVER_EXPENSES');
                v_notes := 'WARNING: High petty cash expense claimed during shift handover (' || NEW.urgent_expenses_deducted || ' ETB).';
            END IF;
        END IF;

    -- RULE 3: INCOMING BANK SMS (TELEBIRR / CBE)
    ELSIF TG_TABLE_NAME = 'bank_incoming_transactions' THEN
        v_actor_name := 'Sentinel Phone Listener';
        v_actor_role := 'sentinel_gateway';

        -- Flag any transaction without amount or reference
        IF TG_OP = 'INSERT' THEN
            IF NEW.amount IS NULL OR NEW.amount <= 0 THEN
                v_risk_score := 1;
                v_anomaly_flags := array_append(v_anomaly_flags, 'ZERO_AMOUNT_BANK_SMS');
            END IF;
        END IF;

    -- RULE 4: STAFF CREDENTIALS & COMMISSIONS
    ELSIF TG_TABLE_NAME = 'staff_members' THEN
        IF TG_OP IN ('INSERT', 'UPDATE') THEN
            IF NEW.commission_rate < 0.02 OR NEW.commission_rate > 0.25 THEN
                v_risk_score := 1;
                v_anomaly_flags := array_append(v_anomaly_flags, 'OUT_OF_BOUNDS_COMMISSION_RATE');
                v_notes := 'WARNING: Staff commission rate set to ' || (NEW.commission_rate * 100) || '% (Allowed: 2% - 25%).';
            END IF;
        END IF;
    END IF;

    -- Insert into tamper-proof audit ledger
    INSERT INTO public.sentinel_audit_ledger (
        table_name,
        action,
        record_id,
        actor_id,
        actor_role,
        actor_name,
        old_record,
        new_record,
        risk_score,
        anomaly_flags,
        notes
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        v_record_id,
        v_actor_id,
        v_actor_role,
        v_actor_name,
        v_old_json,
        v_new_json,
        v_risk_score,
        v_anomaly_flags,
        v_notes
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

-- 4. ATTACH TRIGGERS TO PRODUCTION TABLES
DROP TRIGGER IF EXISTS trg_sentinel_audit_wash_bookings ON public.wash_bookings;
CREATE TRIGGER trg_sentinel_audit_wash_bookings
AFTER INSERT OR UPDATE OR DELETE ON public.wash_bookings
FOR EACH ROW EXECUTE FUNCTION public.fn_sentinel_audit_logger();

DROP TRIGGER IF EXISTS trg_sentinel_audit_cash_handovers ON public.cash_handovers;
CREATE TRIGGER trg_sentinel_audit_cash_handovers
AFTER INSERT OR UPDATE OR DELETE ON public.cash_handovers
FOR EACH ROW EXECUTE FUNCTION public.fn_sentinel_audit_logger();

DROP TRIGGER IF EXISTS trg_sentinel_audit_daily_closings ON public.daily_closings;
CREATE TRIGGER trg_sentinel_audit_daily_closings
AFTER INSERT OR UPDATE OR DELETE ON public.daily_closings
FOR EACH ROW EXECUTE FUNCTION public.fn_sentinel_audit_logger();

DROP TRIGGER IF EXISTS trg_sentinel_audit_bank_sms ON public.bank_incoming_transactions;
CREATE TRIGGER trg_sentinel_audit_bank_sms
AFTER INSERT OR UPDATE OR DELETE ON public.bank_incoming_transactions
FOR EACH ROW EXECUTE FUNCTION public.fn_sentinel_audit_logger();

DROP TRIGGER IF EXISTS trg_sentinel_audit_staff_members ON public.staff_members;
CREATE TRIGGER trg_sentinel_audit_staff_members
AFTER INSERT OR UPDATE OR DELETE ON public.staff_members
FOR EACH ROW EXECUTE FUNCTION public.fn_sentinel_audit_logger();

-- 5. STORAGE RETENTION MANAGEMENT (Rule 9: Supabase Free Tier Storage Conservation)
CREATE OR REPLACE FUNCTION public.prune_old_sentinel_audit_ledger(p_days_to_keep INT DEFAULT 14)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.sentinel_audit_ledger
    WHERE recorded_at < NOW() - (p_days_to_keep || ' days')::INTERVAL;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;
