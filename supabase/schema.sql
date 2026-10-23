-- ====================================================================
-- BISHE Car Wash Service - Bishoftu, Oromia, Ethiopia
-- PostgreSQL Schema Definition for Supabase (Project: siioobajphmwzwwarlrr)
-- File: supabase/schema.sql
-- ====================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ====================================================================
-- 2. TABLE: wash_packages
-- Stores wash service tiers and car-type pricing matrices (ETB)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.wash_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price_automobile NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    price_minibus NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    price_truck NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    estimated_minutes INTEGER DEFAULT 30,
    features JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial packages
INSERT INTO public.wash_packages (id, name, description, price_automobile, price_minibus, price_truck, estimated_minutes, features)
VALUES 
    ('a0000000-0000-0000-0000-000000000101', 'Express Foam Wash', 'High-pressure water rinse, active snow foam soak, tire shine & hand dry.', 300.00, 450.00, 600.00, 25, '["High Pressure Pre-wash", "Touchless Snow Foam", "Rims & Tire Gloss", "Microfiber Hand Dry"]'::jsonb),
    ('a0000000-0000-0000-0000-000000000102', 'Standard Clean & Vacuum', 'Complete exterior body wash plus deep interior vacuum, dashboard wipe & glass cleaning.', 500.00, 750.00, 950.00, 45, '["Full Exterior Foam Wash", "Interior Floor & Seat Vacuum", "Dashboard & Console Dressing", "Door Jambs & Windows Clean"]'::jsonb),
    ('a0000000-0000-0000-0000-000000000103', 'Deluxe Spa & Engine Detail', 'Comprehensive exterior hand polish, high-temperature interior steam sanitize, engine bay shampoo & synthetic spray wax.', 850.00, 1200.00, 1500.00, 75, '["Engine Bay Degreasing", "Interior High-Heat Steam Clean", "Hand Applied Hydrophobic Wax", "Upholstery Deep Extraction"]'::jsonb),
    ('a0000000-0000-0000-0000-000000000104', 'Mobile At-Home Express Van', 'Doorstep wash anywhere in Bishoftu. Onboard high-pressure system, spotless deionized water & silent generator.', 450.00, 650.00, 850.00, 40, '["At-Your-Door Bishoftu Service", "Self-Contained Water & Power", "Exterior High Gloss Snow Foam", "Tire & Wheel Arch Deep Rinse"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ====================================================================
-- 3. TABLE: station_bays
-- Manages physical bays (Bay 1, Bay 2) and Mobile Van 1
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.station_bays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bay_number INTEGER NOT NULL UNIQUE,
    bay_type TEXT NOT NULL, -- 'bay1', 'bay2', 'mobileVan'
    is_occupied BOOLEAN DEFAULT FALSE,
    current_booking_id UUID,
    active_license_plate TEXT,
    assigned_washer_name TEXT,
    started_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial 3 bays
INSERT INTO public.station_bays (id, bay_number, bay_type, is_occupied)
VALUES 
    ('b0000000-0000-0000-0000-000000000001', 1, 'bay1', FALSE),
    ('b0000000-0000-0000-0000-000000000002', 2, 'bay2', FALSE),
    ('b0000000-0000-0000-0000-000000000003', 3, 'mobileVan', FALSE)
ON CONFLICT (id) DO NOTHING;

-- ====================================================================
-- 4. TABLE: staff_members
-- Roster of washers, detailers, and cashiers with salary & commission
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.staff_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    role TEXT NOT NULL, -- 'washer', 'leadDetailer', 'cashier', 'admin'
    phone TEXT,
    base_salary NUMERIC(10, 2) DEFAULT 0.00,
    commission_rate NUMERIC(5, 2) DEFAULT 0.15,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial 4 washers
INSERT INTO public.staff_members (id, name, role, phone, base_salary, commission_rate)
VALUES 
    ('c0000000-0000-0000-0000-000000000001', 'Abebe Kebede', 'washer', '+251 91 123 4567', 4500.00, 0.15),
    ('c0000000-0000-0000-0000-000000000002', 'Chala Gemechu', 'washer', '+251 92 234 5678', 4200.00, 0.15),
    ('c0000000-0000-0000-0000-000000000003', 'Tolosa Desta', 'washer', '+251 93 345 6789', 4200.00, 0.15),
    ('c0000000-0000-0000-0000-000000000004', 'Desta Alemu', 'washer', '+251 94 456 7890', 4000.00, 0.15)
ON CONFLICT (id) DO NOTHING;

-- ====================================================================
-- 5. TABLE: wash_bookings
-- Wash queue, active bays, payments and customer orders
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.wash_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_name TEXT NOT NULL,
    customer_phone TEXT,
    car_type TEXT NOT NULL, -- 'automobile', 'minibus', 'truck'
    service_type TEXT NOT NULL, -- 'walkInStation', 'atHomeMobile'
    package_id UUID REFERENCES public.wash_packages(id),
    assigned_bay_id UUID REFERENCES public.station_bays(id),
    assigned_washer_id UUID REFERENCES public.staff_members(id),
    status TEXT NOT NULL DEFAULT 'queued', -- 'pending', 'confirmed', 'washing', 'drying', 'readyForPickup', 'completed'
    payment_method TEXT NOT NULL DEFAULT 'cash', -- 'cash', 'telebirr', 'cbeBirr'
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    commission_amount NUMERIC(10, 2) DEFAULT 0.00,
    license_plate TEXT,
    delivery_location TEXT,
    booking_origin TEXT DEFAULT 'gate_walk_in',
    preferred_language TEXT DEFAULT 'om',
    washer_1_id UUID,
    washer_1_name TEXT,
    washer_2_id UUID,
    washer_2_name TEXT,
    is_paid BOOLEAN DEFAULT FALSE,
    payment_category TEXT DEFAULT 'cash',
    digital_provider TEXT,
    transaction_ref TEXT,
    receipt_url TEXT,
    scheduled_time TIMESTAMPTZ,
    commission_logged BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- ====================================================================
-- 6. TABLE: commission_logs
-- Auto-logged washer commissions generated upon wash completion
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.commission_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES public.wash_bookings(id),
    staff_id UUID REFERENCES public.staff_members(id),
    staff_name TEXT NOT NULL,
    car_type TEXT NOT NULL,
    service_name TEXT NOT NULL,
    license_plate TEXT,
    earned_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    is_settled BOOLEAN DEFAULT FALSE,
    settled_at TIMESTAMPTZ,
    logged_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 7. TABLE: staff_credentials
-- PIN / username authentication accounts for Cashiers & Admins
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.staff_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL UNIQUE,
    pin_hash TEXT NOT NULL,
    role TEXT NOT NULL, -- 'admin', 'cashier'
    full_name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW())
);

-- ====================================================================
-- 8. TABLE: user_profiles
-- Customer user accounts linked to auth
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 9. TABLE: sms_outbox
-- Asynchronous SMS notification queue for wash completion
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.sms_outbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID,
    license_plate TEXT,
    recipient_phone TEXT NOT NULL,
    message_body TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    attempts INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    error_message TEXT
);
