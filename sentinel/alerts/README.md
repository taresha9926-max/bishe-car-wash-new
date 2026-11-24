# Sentinel > Alerts

## Overview
Notification dispatchers sending desktop operating system alerts and Telegram bot notifications for digital bank payments.

## Interface
- [desktop_notifier.py:DesktopNotifier] Class `DesktopNotifier`
- [telegram_notifier.py:TelegramNotifier] Class `TelegramNotifier`

## Invariants
- None

## Side Effects
- [desktop_notifier.py:subprocess] OS Process: Spawns shell subprocess commands
- [telegram_notifier.py:network] Network I/O: Dispatches HTTP requests to external APIs or Supabase REST
- [telegram_notifier.py:telegram] Network Messaging: Communicates with Telegram Bot API

## Verification
- Run: `python -m unittest`
