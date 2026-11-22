#!/usr/bin/env python3
"""
BISHE Super AI Sentinel — Master Laptop Daemon & Entrypoint
Runs locally on your laptop:
  - Streams mutations from Supabase every 60s
  - Evaluates forensic rules & ground truths
  - Dispatches Windows toast & Telegram alerts
  - Hosts Local Web Studio on http://127.0.0.1:8088
  - Hosts Developer Master Terminal CLI
"""

import os
import sys
import time
import threading
import webbrowser
import argparse

# Ensure current directory is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sentinel.config import SentinelConfig
from sentinel.storage.db import LocalAuditDB
from sentinel.core.event_ingestion import EventIngestionEngine
from sentinel.core.forensic_engine import ForensicEngine
from sentinel.core.closing_auditor import ShiftClosingAuditor
from sentinel.core.developer_projector import DeveloperProjector
from sentinel.alerts.telegram_notifier import TelegramNotifier
from sentinel.alerts.desktop_notifier import DesktopNotifier
from sentinel.web_studio.app import start_sentinel_web_studio
from sentinel.cli_terminal import run_cli_loop

def run_sync_worker(ingestion_engine: EventIngestionEngine, interval: int = 60):
    """Background thread that pulls new events every interval seconds."""
    while True:
        try:
            ingestion_engine.sync_once()
        except Exception as e:
            print(f"[Sentinel Daemon Worker] Sync cycle exception: {e}")
        time.sleep(interval)

def main():
    parser = argparse.ArgumentParser(description="BISHE Super AI Sentinel")
    parser.add_argument("--cli", action="store_true", help="Launch interactive Developer Master CLI Terminal")
    parser.add_argument("--no-browser", action="store_true", help="Do not automatically open browser on launch")
    parser.add_argument("--port", type=int, default=8088, help="Web Studio port (default: 8088)")
    parser.add_argument("--project", type=str, help="Scaffold a specific feature directly (e.g. --project quick-walkin)")
    args = parser.parse_args()

    # 1. Initialize Configuration & Local Database
    config = SentinelConfig()
    if args.port:
        config.web_port = args.port

    db = LocalAuditDB()
    telegram = TelegramNotifier(config)
    desktop = DesktopNotifier()

    # 2. Wire Forensic Alert Handlers
    def handle_forensic_alert(anomaly: dict):
        severity = anomaly.get("severity", "WARNING")
        is_crit = severity == "CRITICAL_THEFT"
        # Desktop Toast
        desktop.show_alert(
            title=f"🚨 BISHE SENTINEL: {anomaly.get('category', 'ANOMALY')}",
            message=anomaly.get("description", ""),
            is_critical=is_crit
        )
        # Encrypted Telegram
        telegram.send_anomaly_alert(anomaly)

    forensic = ForensicEngine(config, db, on_alert=handle_forensic_alert)

    # 3. Wire Event Ingestion Callback
    def on_event_synced(event: dict):
        forensic.analyze_event(event)

    ingestion = EventIngestionEngine(config, db, on_event_synced=on_event_synced)
    closing = ShiftClosingAuditor(config, db)
    projector = DeveloperProjector()

    # Fast Scaffold Command Line Switch
    if args.project:
        res = projector.scaffold_feature(args.project)
        print(f"Scaffolded {args.project} into {res['target_dir']}")
        sys.exit(0)

    # 4. Initial Sync Run
    print("\n[Sentinel Daemon] Running initial incremental sync from Supabase...")
    ingestion.sync_once()

    # 5. Start Background Ingestion Worker Thread
    sync_thread = threading.Thread(
        target=run_sync_worker,
        args=(ingestion, config.sync_interval_seconds),
        daemon=True
    )
    sync_thread.start()

    # 6. Start Local Web Studio (http://127.0.0.1:8088)
    httpd, port = start_sentinel_web_studio(
        config=config,
        db=db,
        forensic=forensic,
        closing=closing,
        projector=projector,
        port=config.web_port
    )
    config.web_port = port

    # 7. Open Browser
    studio_url = f"http://127.0.0.1:{port}"
    if not args.no_browser:
        try:
            webbrowser.open(studio_url)
        except Exception:
            pass

    # 8. Run Master CLI Terminal or Wait
    if args.cli or sys.stdin.isatty():
        run_cli_loop(config, db, ingestion, forensic, closing, projector, telegram, desktop)
    else:
        print(f"[Sentinel Daemon] Running in background on {studio_url}. Press Ctrl+C to stop.")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nShutting down Sentinel Daemon.")

if __name__ == "__main__":
    main()
