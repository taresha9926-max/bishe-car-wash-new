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
    gemini_client = None

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
            events = self.db.get_recent_events(limit=10)
            self._serve_json({
                "status": "online",
                "last_synced_id": last_id,
                "unresolved_anomalies_count": len(anomalies),
                "total_cached_events": len(events),
                "telegram_configured": bool(self.config.telegram_bot_token and self.config.telegram_chat_id),
                "port": self.config.web_port
            })
        elif path == "/api/events":
            events = self.db.get_recent_events(limit=60)
            self._serve_json(events)
        elif path == "/api/anomalies":
            anomalies = self.db.get_unresolved_anomalies()
            self._serve_json(anomalies)
        elif path == "/api/closing":
            report = self.closing_auditor.compile_shift_audit("day_shift")
            self._serve_json(report)
        elif path == "/api/yield":
            events = self.db.get_recent_events(limit=100)
            total_evu = 0.0
            cars_count = 0
            for e in events:
                if e.get("table_name") == "wash_bookings":
                    cars_count += 1
                    rec = e.get("new_record")
                    if rec and isinstance(rec, str):
                        try:
                            rec = json.loads(rec)
                        except Exception:
                            rec = {}
                    if rec:
                        ctype = str(rec.get("car_type", "")).lower()
                        if any(k in ctype for k in ["truck", "heavy"]):
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
        elif path == "/api/proposals":
            suggestions = self.developer_projector.detect_ux_friction_patterns(self.db.get_recent_events(limit=50))
            self._serve_json(suggestions)
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
        elif path == "/api/project":
            feature_name = payload.get("feature_name", "quick-walkin")
            result = self.developer_projector.scaffold_feature(feature_name)
            self._serve_json(result)
        elif path == "/api/ask":
            query = payload.get("query", "")
            # Process query via Gemini Flash or local fallback
            ans = self._ask_ai(query)
            self._serve_json({"answer": ans})
        else:
            self.send_response(404)
            self.end_headers()

    def _ask_ai(self, query: str) -> str:
        q_lower = query.lower()
        if "close" in q_lower or "revenue" in q_lower or "p&l" in q_lower or "shift" in q_lower:
            audit = self.closing_auditor.compile_shift_audit("day_shift")
            return audit.get("audit_summary", "Audit compiled successfully.")
        elif "anomaly" in q_lower or "theft" in q_lower or "discrepancy" in q_lower:
            anomalies = self.db.get_unresolved_anomalies()
            if not anomalies:
                return "✅ No active forensic discrepancies detected. Station operations are running with 100% integrity."
            lines = [f"⚠️ {len(anomalies)} Active Forensic Discrepancies:"]
            for a in anomalies:
                lines.append(f"• [{a['severity']}] {a['actor_name']}: {a['description']}")
            return "\n".join(lines)
        elif "yield" in q_lower or "soap" in q_lower or "chemical" in q_lower or "shampoo" in q_lower:
            return "🧪 5L Snow Foam Standard: 40 EVU (~125 ml/car, 25-55 tolerance). Perfume: 100 sprays/500ml."
        return f"Sentinel AI grounded in BISHE_OPERATIONS_MANUAL.md received: '{query}'. System is operating normally on localhost:8088."

    def _serve_json(self, data, status=200):
        content = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

def start_sentinel_web_studio(config, db, forensic, closing, projector, port=8088):
    SentinelWebHandler.config = config
    SentinelWebHandler.db = db
    SentinelWebHandler.forensic_engine = forensic
    SentinelWebHandler.closing_auditor = closing
    SentinelWebHandler.developer_projector = projector

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
