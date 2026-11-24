# Supabase

## Overview
Supabase backend configuration, PostgreSQL database DDL schema, and automated migration scripts.

## Interface
### Subdirectories
- [migrations](./migrations/README.md): PostgreSQL database migrations configuring tables, foreign keys, RLS security policies, and stored procedure RPCs.

### Public Symbols
- [schema.sql:public] Table `public`

## Invariants
- [schema.sql:pk] Entity uniqueness enforced via PRIMARY KEY constraints
- [schema.sql:fk] Referential integrity enforced via FOREIGN KEY constraints

## Side Effects
- [schema.sql:ddl] Schema Mutation: Alters Supabase PostgreSQL database catalog and schema

## Verification
- Run: `supabase test db`
