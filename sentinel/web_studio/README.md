# Sentinel > Web_Studio

## Overview
Lightweight web management console for monitoring Sentinel background tasks and digital payment events.

## Interface
- [app.py:SentinelWebHandler] Class `SentinelWebHandler`
- [app.py:start_sentinel_web_studio] Function `start_sentinel_web_studio()`

## Invariants
- None

## Side Effects
- [app.py:telegram] Network Messaging: Communicates with Telegram Bot API

## Verification
- Run: `python -m unittest`
