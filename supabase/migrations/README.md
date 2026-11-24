# Supabase > Migrations

## Overview
PostgreSQL database migrations configuring tables, foreign keys, RLS security policies, and stored procedure RPCs.

## Interface
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] Function `public()`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Public can view wash packages` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Allow updating packages` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Public can view station bays` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Allow updating bays` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Public can view bookings` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Public can create bookings` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Allow updating bookings` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Public can view staff` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Allow modifying staff` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Public can view commission logs` on `public`
- [20261030_enable_rls_and_rpc_pin_verification.sql:public] RLS Policy `Allow inserting commission logs` on `public`
- [20261031_clear_all_bookings.sql:public] Function `public()`
- [20261031_clear_all_bookings.sql:public] RLS Policy `Allow deleting bookings` on `public`
- [20261031_clear_all_bookings.sql:public] RLS Policy `Allow deleting commission logs` on `public`
- [20261031_clear_all_bookings.sql:public] RLS Policy `Allow deleting sms_outbox` on `public`
- [20261031_fix_verify_staff_pin.sql:public] Function `public()`
- [20261031_fix_verify_staff_pin.sql:public] RLS Policy `Allow anon manage tiktok reels config` on `public`
- [20261031_fix_verify_staff_pin.sql:public] RLS Policy `Allow updating staff credentials` on `public`
- [20261031_fix_verify_staff_pin.sql:public] RLS Policy `Allow inserting staff credentials` on `public`
- [20261101_staff_pins_and_daily_closings.sql:public] Table `public`
- [20261101_staff_pins_and_daily_closings.sql:public] Function `public()`
- [20261101_staff_pins_and_daily_closings.sql:public] RLS Policy `Allow public select daily closings` on `public`
- [20261101_staff_pins_and_daily_closings.sql:public] RLS Policy `Allow public insert daily closings` on `public`
- [20261101_staff_pins_and_daily_closings.sql:public] RLS Policy `Allow public update daily closings` on `public`
- [20261106_allow_delete_daily_closings.sql:public] Function `public()`
- [20261106_allow_delete_daily_closings.sql:public] RLS Policy `Allow public delete daily closings` on `public`
- [20261106_allow_delete_daily_closings.sql:public] RLS Policy `Allow public update daily closings` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `daily_closings_public_select` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `daily_closings_public_insert` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `daily_closings_public_update` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `daily_closings_public_delete` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `Allow updating bookings` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `Allow public delete bookings` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `Allow updating commission logs` on `public`
- [20261111_fix_rls_closings_and_bookings.sql:public] RLS Policy `Allow deleting commission logs` on `public`
- [20261113_financial_engine_handovers_and_vat.sql:public] Table `public`
- [20261113_financial_engine_handovers_and_vat.sql:public] Function `public()`
- [20261113_financial_engine_handovers_and_vat.sql:public] RLS Policy `Public select cash_handovers` on `public`
- [20261113_financial_engine_handovers_and_vat.sql:public] RLS Policy `Public insert cash_handovers` on `public`
- *(... and 33 additional public symbols)*

## Invariants
- [20261030_enable_rls_and_rpc_pin_verification.sql:check] Domain value validity enforced via CHECK constraints
- [20261031_fix_verify_staff_pin.sql:check] Domain value validity enforced via CHECK constraints
- [20261101_staff_pins_and_daily_closings.sql:pk] Entity uniqueness enforced via PRIMARY KEY constraints
- [20261101_staff_pins_and_daily_closings.sql:check] Domain value validity enforced via CHECK constraints
- [20261106_allow_delete_daily_closings.sql:check] Domain value validity enforced via CHECK constraints
- [20261111_fix_rls_closings_and_bookings.sql:check] Domain value validity enforced via CHECK constraints
- [20261113_financial_engine_handovers_and_vat.sql:pk] Entity uniqueness enforced via PRIMARY KEY constraints
- [20261113_financial_engine_handovers_and_vat.sql:fk] Referential integrity enforced via FOREIGN KEY constraints
- [20261113_financial_engine_handovers_and_vat.sql:check] Domain value validity enforced via CHECK constraints
- [20261120_allow_select_staff_credentials.sql:check] Domain value validity enforced via CHECK constraints
- [20261120_digital_payment_sentinel_and_cross_ref.sql:pk] Entity uniqueness enforced via PRIMARY KEY constraints
- [20261120_digital_payment_sentinel_and_cross_ref.sql:check] Domain value validity enforced via CHECK constraints
- [20261120_fix_staff_credentials_role_check.sql:check] Domain value validity enforced via CHECK constraints
- [20261121_fix_payment_meta_and_ingest_bank_sms.sql:check] Domain value validity enforced via CHECK constraints
- [20261122_sentinel_audit_ledger_and_triggers.sql:pk] Entity uniqueness enforced via PRIMARY KEY constraints
- [20261122_sentinel_audit_ledger_and_triggers.sql:check] Domain value validity enforced via CHECK constraints

## Side Effects
- [20261030_enable_rls_and_rpc_pin_verification.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261030_enable_rls_and_rpc_pin_verification.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables
- [20261031_clear_all_bookings.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261031_fix_verify_staff_pin.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261101_staff_pins_and_daily_closings.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261101_staff_pins_and_daily_closings.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables
- [20261106_allow_delete_daily_closings.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261107_carpet_cleaning_support.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261111_fix_rls_closings_and_bookings.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261111_fix_rls_closings_and_bookings.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables
- [20261113_financial_engine_handovers_and_vat.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261113_financial_engine_handovers_and_vat.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables
- [20261120_allow_select_staff_credentials.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261120_allow_select_staff_credentials.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables
- [20261120_digital_payment_sentinel_and_cross_ref.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261120_digital_payment_sentinel_and_cross_ref.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables
- [20261120_fix_staff_credentials_role_check.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261121_fix_payment_meta_and_ingest_bank_sms.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261122_fix_bank_sms_and_receipt_delete_policies.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema
- [20261122_fix_bank_sms_and_receipt_delete_policies.sql:rls] Security Boundary: Enforces PostgreSQL Row Level Security on database tables

## Verification
- Run: `supabase test db`
