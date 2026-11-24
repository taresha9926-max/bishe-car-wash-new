# Sentinel

## Overview
Bishe PayGuard Sentinel Python backend suite providing automated bank SMS ingestion, closing audits, and alert dispatchers.

## Interface
### Subdirectories
- [alerts](./alerts/README.md): Notification dispatchers sending desktop operating system alerts and Telegram bot notifications for digital bank payments.
- [core](./core/README.md): Core transaction processing, financial closing auditing, forensic validation, and event ingestion engines.
- [storage](./storage/README.md): Local persistence layer and SQLite storage interface for Sentinel operational logs.
- [web_studio](./web_studio/README.md): Lightweight web management console for monitoring Sentinel background tasks and digital payment events.

### Public Symbols
- [cli_terminal.py:render_banner] Function `render_banner()`
- [cli_terminal.py:run_cli_loop] Function `run_cli_loop()`
- [config.py:SentinelConfig] Class `SentinelConfig`
- [sentinel_daemon.py:run_sync_worker] Function `run_sync_worker()`
- [sentinel_daemon.py:main] Function `main()`

## Invariants
- None

## Side Effects
- [cli_terminal.py:telegram] Network Messaging: Communicates with Telegram Bot API
- [config.py:filesystem] File I/O: Writes or updates local filesystem files
- [config.py:telegram] Network Messaging: Communicates with Telegram Bot API
- [sentinel_daemon.py:telegram] Network Messaging: Communicates with Telegram Bot API

## Verification
- Run: `python -m unittest`
