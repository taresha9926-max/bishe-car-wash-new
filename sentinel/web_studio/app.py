"""
BISHE Super AI Sentinel — Local Developer Cockpit (Web Studio)
Runs on http://127.0.0.1:8088
Provides real-time forensic feeds, yield tracking, shift reconciliation, and natural language AI studio.
"""

import os
import json
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading

class SentinelWebHandler(BaseHTTPRequestHandler):
    config = None
    db = None
    forensic_engine = None
    closing_auditor = None
    developer_projector = None
    super_brain = None
    ingestion_engine = None

    def log_message(self, format, *args):
        # Keep terminal clean; silence routine asset queries
        pass

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path in ["/", "/index.html"]:
            html_file = os.path.join(os.path.dirname(__file__), "templates", "index.html")
            if os.path.exists(html_file):
                with open(html_file, "rb") as f:
                    content = f.read()
                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_response(404)
                self.end_headers()
        elif path == "/api/status":
            last_id = self.db.get_last_synced_id()
            anomalies = self.db.get_unresolved_anomalies()
            total_events = self.db.get_total_events_count()
            live_bookings = self.super_brain.get_today_bookings() if self.super_brain else []
            self._serve_json({
                "status": "online",
                "last_synced_id": last_id,
                "unresolved_anomalies_count": len(anomalies),
                "total_cached_events": total_events,
                "today_live_bookings_count": len(live_bookings),
                "telegram_configured": bool(self.config.telegram_bot_token and self.config.telegram_chat_id),
                "gemini_active": bool(self.config.gemini_api_key),
                "port": self.config.web_port
            })
        elif path == "/api/events":
            query_params = urllib.parse.parse_qs(parsed.query)
            limit = int(query_params.get("limit", [50])[0])
            events = self.db.get_recent_events(limit=limit)
            self._serve_json(events)
        elif path == "/api/anomalies":
            anomalies = self.db.get_unresolved_anomalies()
            self._serve_json(anomalies)
        elif path == "/api/closing":
            live_bookings = self.super_brain.get_today_bookings() if self.super_brain else None
            report = self.closing_auditor.compile_shift_audit("day_shift", live_bookings=live_bookings)
            self._serve_json(report)
        elif path == "/api/yield":
            bookings = self.super_brain.get_today_bookings() if self.super_brain else []
            total_evu = 0.0
            cars_count = 0
            for b in bookings:
                cars_count += 1
                ctype = str(b.get("car_type", "")).lower()
                if b.get("is_carpet"):
                    area = float(b.get("carpet_area_sq_meters") or 12.0)
                    total_evu += round(area * 0.25, 2)
                elif any(k in ctype for k in ["truck", "heavy"]):
                    total_evu += 2.5
                elif any(k in ctype for k in ["minibus", "van"]):
                    total_evu += 1.8
                elif any(k in ctype for k in ["suv", "pickup"]):
                    total_evu += 1.4
                else:
                    total_evu += 1.0

            shampoo_liters = (total_evu * 125.0) / 1000.0
            perfume_ml = total_evu * 5.0
            self._serve_json({
                "total_evu": round(total_evu, 1),
                "cars_count": cars_count,
                "shampoo_liters_consumed": round(shampoo_liters, 2),
                "shampoo_canisters_estimated": round(shampoo_liters / 5.0, 2),
                "perfume_ml_consumed": round(perfume_ml, 0),
                "perfume_bottles_estimated": round(perfume_ml / 500.0, 2),
                "chemical_cost_etb": round(total_evu * 28.50, 2)
            })
        elif path == "/api/refresh":
            synced_count = 0
            if self.ingestion_engine:
                try:
                    new_events = self.ingestion_engine.sync_once()
                    synced_count = len(new_events) if new_events else 0
                except Exception as e:
                    print(f"[Sentinel Web Studio] Sync error on refresh: {e}")

            if self.super_brain:
                self.super_brain.refresh_all_live_data()
            live_bookings = self.super_brain.get_today_bookings(force_refresh=True) if self.super_brain else []
            closing_report = self.closing_auditor.compile_shift_audit("day_shift", live_bookings=live_bookings) if self.closing_auditor else {}

            self._serve_json({
                "success": True,
                "synced_events_count": synced_count,
                "live_bookings_count": len(live_bookings),
                "gross_revenue": closing_report.get("gross_revenue", 0.0),
                "ebitda": closing_report.get("ebitda", 0.0),
                "cash_drawer": closing_report.get("cash_drawer", 0.0),
                "telebirr_total": closing_report.get("telebirr_total", 0.0),
                "cbe_total": closing_report.get("cbe_total", 0.0),
                "audit_summary": closing_report.get("audit_summary", "")
            })
        elif path == "/api/proposals":
            suggestions = self.developer_projector.detect_ux_friction_patterns(self.db.get_recent_events(limit=50))
            self._serve_json(suggestions)
        elif path == "/api/chat_history":
            history = self.super_brain.conversation_history if self.super_brain else []
            self._serve_json(history)
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
        payload = json.loads(body) if body else {}

        if path == "/api/resolve_anomaly":
            anom_id = int(payload.get("anomaly_id", 0))
            notes = payload.get("notes", "Resolved by developer")
            success = self.db.resolve_anomaly(anom_id, "Tare (Lead Developer)", notes)
            self._serve_json({"success": success})
        elif path == "/api/delete_anomaly":
            anom_id = int(payload.get("anomaly_id", 0))
            success = self.db.delete_anomaly(anom_id)
            self._serve_json({"success": success, "anomaly_id": anom_id})
        elif path == "/api/clear_anomalies":
            cleared = self.db.clear_all_anomalies()
            self._serve_json({"success": True, "cleared_count": cleared})
        elif path == "/api/delete_event":
            event_id = int(payload.get("event_id", 0))
            success = self.db.delete_audit_event(event_id)
            self._serve_json({"success": success, "event_id": event_id})
        elif path == "/api/clear_events":
            cleared = self.db.clear_all_audit_events()
            self._serve_json({"success": True, "cleared_count": cleared})
        elif path == "/api/prune_events":
            keep = int(payload.get("keep_latest", 50))
            pruned = self.db.prune_events(keep_latest=keep)
            self._serve_json({"success": True, "pruned_count": pruned})
        elif path == "/api/delete_chat_message":
            idx = int(payload.get("index", -1))
            if self.super_brain and 0 <= idx < len(self.super_brain.conversation_history):
                self.super_brain.conversation_history.pop(idx)
            self._serve_json({"success": True})
        elif path == "/api/project":
            feature_name = payload.get("feature_name", "quick-walkin")
            result = self.developer_projector.scaffold_feature(feature_name)
            self._serve_json(result)
        elif path == "/api/ask":
            query = payload.get("query", "").strip()
            if not query:
                self._serve_json({"answer": "Please ask a question."})
                return
            if self.super_brain:
                result = self.super_brain.ask(query)
                self._serve_json(result)
            else:
                self._serve_json({"answer": "Super AI Brain initializing..."})
        elif path == "/api/clear_chat":
            if self.super_brain:
                self.super_brain.conversation_history = []
            self._serve_json({"status": "cleared"})
        elif path == "/api/refresh":
            synced_count = 0
            if self.ingestion_engine:
                try:
                    new_events = self.ingestion_engine.sync_once()
                    synced_count = len(new_events) if new_events else 0
                except Exception as e:
                    print(f"[Sentinel Web Studio] Sync error on refresh: {e}")

            if self.super_brain:
                self.super_brain.refresh_all_live_data()
            live_bookings = self.super_brain.get_today_bookings(force_refresh=True) if self.super_brain else []
            closing_report = self.closing_auditor.compile_shift_audit("day_shift", live_bookings=live_bookings) if self.closing_auditor else {}

            self._serve_json({
                "success": True,
                "synced_events_count": synced_count,
                "live_bookings_count": len(live_bookings),
                "gross_revenue": closing_report.get("gross_revenue", 0.0),
                "ebitda": closing_report.get("ebitda", 0.0),
                "cash_drawer": closing_report.get("cash_drawer", 0.0),
                "telebirr_total": closing_report.get("telebirr_total", 0.0),
                "cbe_total": closing_report.get("cbe_total", 0.0),
                "audit_summary": closing_report.get("audit_summary", "")
            })
        else:
            self.send_response(404)
            self.end_headers()

    def _serve_json(self, data, status=200):
        content = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

def start_sentinel_web_studio(config, db, forensic, closing, projector, super_brain, ingestion=None, port=8088):
    SentinelWebHandler.config = config
    SentinelWebHandler.db = db
    SentinelWebHandler.forensic_engine = forensic
    SentinelWebHandler.closing_auditor = closing
    SentinelWebHandler.developer_projector = projector
    SentinelWebHandler.super_brain = super_brain
    SentinelWebHandler.ingestion_engine = ingestion

    server_address = ("127.0.0.1", port)
    try:
        httpd = HTTPServer(server_address, SentinelWebHandler)
    except OSError:
        port = port + 1
        server_address = ("127.0.0.1", port)
        httpd = HTTPServer(server_address, SentinelWebHandler)

    t = threading.Thread(target=httpd.serve_forever, daemon=True)
    t.start()
    return httpd, port
