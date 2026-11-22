"""
BISHE Super AI Sentinel — Local SQLite Cold Storage
Maintains complete offline audit history on your laptop with zero network egress.
"""

import os
import sqlite3
import json
from datetime import datetime

class LocalAuditDB:
    def __init__(self, db_path=None):
        if not db_path:
            db_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")
            os.makedirs(db_dir, exist_ok=True)
            db_path = os.path.join(db_dir, "bishe_sentinel_local.db")
        self.db_path = db_path
        self._init_db()

    def _get_connection(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self):
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            # 1. Sync Cursor
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS sync_cursor (
                key TEXT PRIMARY KEY,
                last_id INTEGER NOT NULL DEFAULT 0,
                updated_at TEXT NOT NULL
            );
            """)

            # 2. Local Audit Ledger (Infinite Cold Storage on Laptop)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS audit_events (
                id INTEGER PRIMARY KEY,
                recorded_at TEXT NOT NULL,
                table_name TEXT NOT NULL,
                action TEXT NOT NULL,
                record_id TEXT,
                actor_id TEXT,
                actor_role TEXT,
                actor_name TEXT,
                old_record TEXT,
                new_record TEXT,
                risk_score INTEGER NOT NULL DEFAULT 0,
                anomaly_flags TEXT,
                notes TEXT,
                synced_at TEXT NOT NULL
            );
            """)
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_audit_table ON audit_events(table_name);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_audit_risk ON audit_events(risk_score);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_audit_recorded ON audit_events(recorded_at);")

            # 3. Flagged Forensic Anomalies
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS forensic_anomalies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                event_id INTEGER,
                detected_at TEXT NOT NULL,
                category TEXT NOT NULL,
                severity TEXT NOT NULL, -- 'WARNING', 'CRITICAL_THEFT'
                actor_name TEXT,
                description TEXT NOT NULL,
                details TEXT,
                is_resolved INTEGER NOT NULL DEFAULT 0,
                resolved_at TEXT,
                resolved_by TEXT,
                resolution_notes TEXT,
                FOREIGN KEY (event_id) REFERENCES audit_events(id)
            );
            """)

            # 4. Daily Closing Reconciliations (8:30 PM & 6:00 AM)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS closing_audits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                shift_type TEXT NOT NULL, -- 'day_shift', 'night_shift'
                closed_at TEXT NOT NULL,
                gross_revenue REAL NOT NULL,
                vat_amount REAL NOT NULL,
                net_revenue REAL NOT NULL,
                cash_drawer REAL NOT NULL,
                telebirr_total REAL NOT NULL,
                cbe_total REAL NOT NULL,
                commissions_total REAL NOT NULL,
                consumables_cogs REAL NOT NULL,
                petty_cash_expenses REAL NOT NULL,
                ebitda REAL NOT NULL,
                total_evu REAL NOT NULL,
                cars_count INTEGER NOT NULL,
                discrepancy_amount REAL NOT NULL DEFAULT 0.0,
                notes TEXT,
                audit_summary TEXT NOT NULL
            );
            """)

            # 5. Developer Telemetry & UX Friction Points
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS developer_telemetry (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                event_type TEXT NOT NULL,
                feature_name TEXT,
                friction_score INTEGER NOT NULL DEFAULT 1,
                metadata TEXT
            );
            """)

            conn.commit()

    def get_last_synced_id(self) -> int:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT last_id FROM sync_cursor WHERE key = 'sentinel_audit_ledger'")
            row = cursor.fetchone()
            return row["last_id"] if row else 0

    def update_last_synced_id(self, last_id: int):
        now = datetime.now().isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            INSERT INTO sync_cursor (key, last_id, updated_at) 
            VALUES ('sentinel_audit_ledger', ?, ?)
            ON CONFLICT(key) DO UPDATE SET last_id = excluded.last_id, updated_at = excluded.updated_at
            """, (last_id, now))
            conn.commit()

    def insert_audit_event(self, event: dict) -> bool:
        """Inserts an event into local cold storage. Returns True if inserted, False if already exists."""
        event_id = event.get("id")
        if not event_id:
            return False

        now = datetime.now().isoformat()
        old_rec = json.dumps(event.get("old_record")) if event.get("old_record") is not None else None
        new_rec = json.dumps(event.get("new_record")) if event.get("new_record") is not None else None
        flags = json.dumps(event.get("anomaly_flags") or [])

        with self._get_connection() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute("""
                INSERT OR IGNORE INTO audit_events (
                    id, recorded_at, table_name, action, record_id, 
                    actor_id, actor_role, actor_name, old_record, new_record, 
                    risk_score, anomaly_flags, notes, synced_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    event_id,
                    event.get("recorded_at") or now,
                    event.get("table_name", "unknown"),
                    event.get("action", "UNKNOWN"),
                    str(event.get("record_id") or ""),
                    str(event.get("actor_id") or ""),
                    str(event.get("actor_role") or ""),
                    str(event.get("actor_name") or ""),
                    old_rec,
                    new_rec,
                    int(event.get("risk_score") or 0),
                    flags,
                    event.get("notes") or "",
                    now
                ))
                inserted = cursor.rowcount > 0
                conn.commit()
                return inserted
            except Exception as e:
                print(f"[LocalAuditDB] Insert error for event #{event_id}: {e}")
                return False

    def insert_anomaly(self, anomaly: dict) -> int:
        now = datetime.now().isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            INSERT INTO forensic_anomalies (
                event_id, detected_at, category, severity, actor_name, description, details, is_resolved
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 0)
            """, (
                anomaly.get("event_id"),
                anomaly.get("detected_at") or now,
                anomaly.get("category", "GENERAL"),
                anomaly.get("severity", "WARNING"),
                anomaly.get("actor_name", "Unknown"),
                anomaly.get("description", ""),
                json.dumps(anomaly.get("details") or {}),
            ))
            anomaly_id = cursor.lastrowid
            conn.commit()
            return anomaly_id

    def get_recent_events(self, limit=50) -> list[dict]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            SELECT * FROM audit_events ORDER BY id DESC LIMIT ?
            """, (limit,))
            rows = cursor.fetchall()
            return [dict(r) for r in rows]

    def get_unresolved_anomalies(self) -> list[dict]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            SELECT * FROM forensic_anomalies WHERE is_resolved = 0 ORDER BY id DESC
            """)
            rows = cursor.fetchall()
            return [dict(r) for r in rows]

    def resolve_anomaly(self, anomaly_id: int, resolved_by: str, notes: str) -> bool:
        now = datetime.now().isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            UPDATE forensic_anomalies 
            SET is_resolved = 1, resolved_at = ?, resolved_by = ?, resolution_notes = ?
            WHERE id = ?
            """, (now, resolved_by, notes, anomaly_id))
            conn.commit()
            return cursor.rowcount > 0

    def insert_closing_audit(self, closing: dict) -> int:
        now = datetime.now().isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            INSERT INTO closing_audits (
                shift_type, closed_at, gross_revenue, vat_amount, net_revenue,
                cash_drawer, telebirr_total, cbe_total, commissions_total,
                consumables_cogs, petty_cash_expenses, ebitda, total_evu,
                cars_count, discrepancy_amount, notes, audit_summary
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                closing.get("shift_type", "day_shift"),
                closing.get("closed_at") or now,
                closing.get("gross_revenue", 0.0),
                closing.get("vat_amount", 0.0),
                closing.get("net_revenue", 0.0),
                closing.get("cash_drawer", 0.0),
                closing.get("telebirr_total", 0.0),
                closing.get("cbe_total", 0.0),
                closing.get("commissions_total", 0.0),
                closing.get("consumables_cogs", 0.0),
                closing.get("petty_cash_expenses", 0.0),
                closing.get("ebitda", 0.0),
                closing.get("total_evu", 0.0),
                closing.get("cars_count", 0),
                closing.get("discrepancy_amount", 0.0),
                closing.get("notes", ""),
                closing.get("audit_summary", "")
            ))
            row_id = cursor.lastrowid
            conn.commit()
            return row_id

    def get_closing_audits(self, limit=10) -> list[dict]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            SELECT * FROM closing_audits ORDER BY id DESC LIMIT ?
            """, (limit,))
            return [dict(r) for r in cursor.fetchall()]
