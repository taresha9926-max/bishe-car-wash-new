"""
BISHE Super AI Sentinel — Zero-Impact Event Ingestion Engine
Streams incremental mutation events from Supabase sentinel_audit_ledger into local cold storage.
"""

import json
import urllib.request
import urllib.error
from datetime import datetime
from typing import Callable

from sentinel.config import SentinelConfig
from sentinel.storage.db import LocalAuditDB

class EventIngestionEngine:
    def __init__(self, config: SentinelConfig, db: LocalAuditDB, on_event_synced: Callable[[dict], None] = None):
        self.config = config
        self.db = db
        self.on_event_synced = on_event_synced
        self.is_connected = False
        self.last_sync_time = None
        self.last_sync_count = 0
        self.error_count = 0

    def sync_once(self) -> list[dict]:
        """Pulls a single incremental batch (WHERE id > last_synced_id ORDER BY id ASC LIMIT 50)."""
        last_id = self.db.get_last_synced_id()
        endpoint = f"sentinel_audit_ledger?id=gt.{last_id}&order=id.asc&limit={self.config.sync_batch_limit}"
        url = f"{self.config.supabase_url.rstrip('/')}/rest/v1/{endpoint}"

        auth_key = self.config.supabase_service_role_key or self.config.supabase_anon_key
        headers = {
            "apikey": auth_key,
            "Authorization": f"Bearer {auth_key}",
            "Content-Type": "application/json",
            "Prefer": "count=none"
        }

        req = urllib.request.Request(url, headers=headers)
        new_events = []

        try:
            with urllib.request.urlopen(req, timeout=12) as response:
                payload = json.loads(response.read().decode("utf-8"))
                if isinstance(payload, list):
                    new_events = payload
                self.is_connected = True
                self.error_count = 0
        except urllib.error.HTTPError as e:
            # 404 might mean sentinel_audit_ledger table is not yet migrated
            err_body = e.read().decode("utf-8") if hasattr(e, "read") else str(e)
            self.is_connected = False
            self.error_count += 1
            if e.code == 404 or "relation" in err_body.lower() or "does not exist" in err_body.lower():
                print(f"[Sentinel Ingestion] Note: sentinel_audit_ledger table pending migration on Supabase (HTTP {e.code}).")
            else:
                print(f"[Sentinel Ingestion] HTTP {e.code} Error: {err_body}")
            return []
        except Exception as e:
            self.is_connected = False
            self.error_count += 1
            print(f"[Sentinel Ingestion] Connection check failed: {e}")
            return []

        # Process and store newly fetched events
        max_seen_id = last_id
        stored_events = []

        for evt in new_events:
            evt_id = evt.get("id")
            if evt_id:
                if self.db.insert_audit_event(evt):
                    stored_events.append(evt)
                    if self.on_event_synced:
                        try:
                            self.on_event_synced(evt)
                        except Exception as e:
                            print(f"[Sentinel Ingestion] Error in event listener callback: {e}")
                if evt_id > max_seen_id:
                    max_seen_id = evt_id

        if max_seen_id > last_id:
            self.db.update_last_synced_id(max_seen_id)

        self.last_sync_time = datetime.now()
        self.last_sync_count = len(stored_events)
        return stored_events
