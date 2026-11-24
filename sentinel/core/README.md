# Sentinel > Core

## Overview
Core transaction processing, financial closing auditing, forensic validation, and event ingestion engines.

## Interface
- [closing_auditor.py:ShiftClosingAuditor] Class `ShiftClosingAuditor`
- [developer_projector.py:DeveloperProjector] Class `DeveloperProjector`
- [developer_projector.py:QuickWalkInSheet] Class `QuickWalkInSheet`
- [developer_projector.py:_QuickWalkInSheetState] Class `_QuickWalkInSheetState`
- [developer_projector.py:LoyaltyCardWidget] Class `LoyaltyCardWidget`
- [event_ingestion.py:EventIngestionEngine] Class `EventIngestionEngine`
- [forensic_engine.py:ForensicEngine] Class `ForensicEngine`
- [super_brain.py:SuperBrainController] Class `SuperBrainController`

## Invariants
- None

## Side Effects
- [developer_projector.py:filesystem] File I/O: Writes or updates local filesystem files
- [event_ingestion.py:network] Network I/O: Dispatches HTTP requests to external APIs or Supabase REST
- [super_brain.py:network] Network I/O: Dispatches HTTP requests to external APIs or Supabase REST

## Verification
- Run: `python -m unittest`
