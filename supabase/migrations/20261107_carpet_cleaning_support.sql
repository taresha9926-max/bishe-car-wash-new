-- ====================================================================
-- Migration: 20261107_carpet_cleaning_support.sql
-- Dedicated database support for Carpet Cleaning Service Operations
-- ====================================================================

ALTER TABLE public.wash_bookings
ADD COLUMN IF NOT EXISTS is_carpet BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS carpet_type TEXT,
ADD COLUMN IF NOT EXISTS carpet_area_sq_meters NUMERIC(10, 2),
ADD COLUMN IF NOT EXISTS carpet_dimensions TEXT,
ADD COLUMN IF NOT EXISTS custom_total_price NUMERIC(10, 2);

-- Performance index for real-time division separation
CREATE INDEX IF NOT EXISTS idx_wash_bookings_is_carpet ON public.wash_bookings(is_carpet);
