# Sentinel > Storage

## Overview
Local persistence layer and SQLite storage interface for Sentinel operational logs.

## Interface
- [db.py:LocalAuditDB] Class `LocalAuditDB`

## Invariants
- None

## Side Effects
- [db.py:sqlite] Disk I/O: Reads/writes local SQLite database

## Verification
- Run: `python -m unittest`
