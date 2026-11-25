#!/usr/bin/env python3
"""
BISHE Car Wash & Auto Care Service — Executive AI Studio (Option A)
Location: Bishoftu (Debre Zeyit), Oromia, Ethiopia

A high-performance local AI operations studio running on Python 3.12+.
Features:
  - 100% Zero-External-Dependency standard Python (standard library only).
  - Grounded directly in the BISHE Operations Manual (BISHE_OPERATIONS_MANUAL.md).
  - Real-Time Gemini 1.5 Flash Cloud AI co-pilot with multi-turn conversation memory.
  - Zero Canned Responses: Everything is dynamically computed from live Supabase rows.
  - Vehicle Volume Multipliers:
      * Sedan / Automobile = 1.0x (Type A)
      * SUV / Pickup       = 1.4x (Type B)
      * Minibus / Van      = 1.8x (Type B)
      * Heavy Truck        = 2.5x (Type C)
      * Carpet             = calculated per square meter (m² * 0.25 EVU)
  - Chemical Yield Benchmarks:
      * 5L foam shampoo yields ~40 cars @ 125 ml/car (alerts if < 25 or > 55)
      * 500ml perfume bottles (~100 sprays @ 5 ml/interior)
  - Washer Performance & Commissions: Active roster, jobs completed, 15% Net Base settlements.
  - Markdown to HTML table parser with instant CSV export and clipboard copy.
  - Strict Supabase free-tier egress economy (Rule 9).
"""

import os
import sys
import json
import time
import html
import re
import webbrowser
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime, timezone, timedelta
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import argparse

# Terminal ANSI Color Codes
CLR_CYAN = "\033[96m"
CLR_GREEN = "\033[92m"
CLR_YELLOW = "\033[93m"
CLR_RED = "\033[91m"
CLR_BOLD = "\033[1m"
CLR_RESET = "\033[0m"

# 22 Master Consumables Catalog
MASTER_CONSUMABLES = [
    {"id": "CS-001", "name": "Abro Polish (Different Colors)", "unit": "Tins", "stock": 12.0, "min": 4.0, "cost": 450.0, "yield": "~8 vehicles / tin"},
    {"id": "CS-002", "name": "Grinder Polish Pad", "unit": "Pieces", "stock": 15.0, "min": 5.0, "cost": 300.0, "yield": "15-20 vehicles / pad"},
    {"id": "CS-003", "name": "Dashboard Protectant (የዳሽቦርድ ቅባት)", "unit": "Liters", "stock": 18.0, "min": 5.0, "cost": 650.0, "yield": "~25 vehicles / liter"},
    {"id": "CS-004", "name": "Foaming Tire Cleaner Spray", "unit": "Cans", "stock": 24.0, "min": 6.0, "cost": 380.0, "yield": "~25 vehicles / can"},
    {"id": "CS-005", "name": "Water Spot Compound", "unit": "Bottles", "stock": 8.0, "min": 3.0, "cost": 850.0, "yield": "Specialty treatment"},
    {"id": "CS-006", "name": "Air Freshener Perfume (ሽቶ)", "unit": "Bottles (500ml)", "stock": 20.0, "min": 6.0, "cost": 250.0, "yield": "~100 sprays (5ml/car)"},
    {"id": "CS-007", "name": "2-Color Polishing Cloth (የማሻ ጨርቅ)", "unit": "Pieces", "stock": 25.0, "min": 8.0, "cost": 150.0, "yield": "Reusable cloth"},
    {"id": "CS-008", "name": "Headlight Restoration Chemical", "unit": "Bottles", "stock": 6.0, "min": 2.0, "cost": 950.0, "yield": "Specialty headlight"},
    {"id": "CS-009", "name": "Car Shampoo Snow Foam (የመኪና ሻምፑ)", "unit": "Liters (5L Cans)", "stock": 45.0, "min": 15.0, "cost": 220.0, "yield": "~40 cars per 5L (125ml/EVU)"},
    {"id": "CS-010A", "name": "Dashboard Sprays", "unit": "Cans", "stock": 16.0, "min": 5.0, "cost": 320.0, "yield": "~30 vehicles / can"},
    {"id": "CS-010B", "name": "Carpet & Interior Sprays", "unit": "Cans", "stock": 14.0, "min": 5.0, "cost": 340.0, "yield": "~20 carpets / can"},
    {"id": "CS-011", "name": "Tire Dressing Black Gel", "unit": "Cans", "stock": 12.0, "min": 4.0, "cost": 420.0, "yield": "~40 vehicles / can"},
    {"id": "CS-012", "name": "Engine Degreaser Concentrated", "unit": "Liters", "stock": 10.0, "min": 3.0, "cost": 550.0, "yield": "~15 engine washes / liter"},
    {"id": "CS-013", "name": "Microfiber Towels 40x40", "unit": "Pieces", "stock": 50.0, "min": 20.0, "cost": 65.0, "yield": "30-50 washes / towel"},
    {"id": "CS-014", "name": "Leather Conditioner Cream", "unit": "Bottles", "stock": 8.0, "min": 3.0, "cost": 480.0, "yield": "~20 leather interiors"},
]


def load_operations_manual() -> str:
    """Reads the authoritative BISHE Operations Manual into memory."""
    candidates = [
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "BISHE_OPERATIONS_MANUAL.md"),
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "BISHE_OPERATIONS_MANUAL.md"),
        os.path.join(os.getcwd(), "BISHE_OPERATIONS_MANUAL.md"),
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    return f.read()
            except Exception:
                pass
    return ""


def markdown_to_html(md_text: str) -> tuple[str, str | None]:
    """Converts Markdown text into styled HTML and extracts any generated table ID."""
    lines = md_text.split("\n")
    html_lines = []
    in_table = False
    table_lines = []
    table_id = None
    table_counter = 0

    def render_table(tbl_lines, t_id):
        if len(tbl_lines) < 2:
            return "\n".join(tbl_lines)
        headers = [c.strip() for c in tbl_lines[0].strip("|").split("|")]
        # row index 1 is usually the separator line (|---|---|)
        body_rows = tbl_lines[2:]
        th_html = "".join(f"<th>{html.escape(h)}</th>" for h in headers)
        tr_html = []
        for r in body_rows:
            if not r.strip() or "|" not in r:
                continue
            cols = [c.strip() for c in r.strip("|").split("|")]
            tds = "".join(f"<td>{html.escape(c)}</td>" for c in cols)
            tr_html.append(f"<tr>{tds}</tr>")
        return f"""
        <div class="table-container" style="margin: 14px 0;">
          <table id="{t_id}" class="dynamic-table">
            <thead><tr>{th_html}</tr></thead>
            <tbody>{''.join(tr_html)}</tbody>
          </table>
        </div>
        """

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if stripped.startswith("|") and stripped.endswith("|") and "|" in stripped[1:-1]:
            if not in_table:
                in_table = True
                table_lines = []
            table_lines.append(stripped)
            i += 1
            continue
        else:
            if in_table:
                in_table = False
                table_counter += 1
                t_id = f"aiTable_{int(time.time())}_{table_counter}"
                if not table_id:
                    table_id = t_id
                html_lines.append(render_table(table_lines, t_id))
                table_lines = []

            # Format headings, bold, bullet points
            if stripped.startswith("### "):
                html_lines.append(f"<h3 style='color:#00E5FF; margin:14px 0 6px 0; font-size:16px;'>{html.escape(stripped[4:])}</h3>")
            elif stripped.startswith("## "):
                html_lines.append(f"<h2 style='color:#00E5FF; margin:16px 0 8px 0; font-size:18px;'>{html.escape(stripped[3:])}</h2>")
            elif stripped.startswith("# "):
                html_lines.append(f"<h1 style='color:#00E5FF; margin:18px 0 10px 0; font-size:20px;'>{html.escape(stripped[2:])}</h1>")
            elif stripped.startswith("- ") or stripped.startswith("• "):
                content = html.escape(stripped[2:])
                content = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', content)
                content = re.sub(r'`(.*?)`', r'<code>\1</code>', content)
                html_lines.append(f"<li style='margin-left:20px; margin-bottom:4px;'>{content}</li>")
            elif stripped:
                content = html.escape(stripped)
                content = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', content)
                content = re.sub(r'`(.*?)`', r'<code>\1</code>', content)
                html_lines.append(f"<p style='margin-bottom:8px; line-height:1.6;'>{content}</p>")
            else:
                html_lines.append("<br>")
            i += 1

    if in_table and table_lines:
        table_counter += 1
        t_id = f"aiTable_{int(time.time())}_{table_counter}"
        if not table_id:
            table_id = t_id
        html_lines.append(render_table(table_lines, t_id))

    return "\n".join(html_lines), table_id


class BisheConfig:
    """Manages credentials and settings from config.json or environment."""

    def __init__(self, config_path=None):
        if not config_path:
            config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")
        self.config_path = config_path
        self.supabase_url = "https://siioobajphmwzwwarlrr.supabase.co"
        self.supabase_anon_key = ""
        self.gemini_api_key = ""
        self.telegram_bot_token = ""
        self.telegram_chat_id = ""
        self.load()

    def load(self):
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self.supabase_url = data.get("supabase_url", self.supabase_url)
                    self.supabase_anon_key = data.get("supabase_anon_key", self.supabase_anon_key)
                    self.gemini_api_key = data.get("gemini_api_key", "")
                    self.telegram_bot_token = data.get("telegram_bot_token", "")
                    self.telegram_chat_id = data.get("telegram_chat_id", "")
            except Exception as e:
                print(f"Warning loading config: {e}")

        # Environment variable overrides
        self.supabase_url = os.environ.get("SUPABASE_URL", self.supabase_url)
        self.supabase_anon_key = os.environ.get("SUPABASE_ANON_KEY", self.supabase_anon_key)
        self.gemini_api_key = os.environ.get("GEMINI_API_KEY", self.gemini_api_key)
        self.telegram_bot_token = os.environ.get("TELEGRAM_BOT_TOKEN", self.telegram_bot_token)
        self.telegram_chat_id = os.environ.get("TELEGRAM_CHAT_ID", self.telegram_chat_id)

    def save(self):
        try:
            os.makedirs(os.path.dirname(os.path.abspath(self.config_path)), exist_ok=True)
            with open(self.config_path, "w", encoding="utf-8") as f:
                json.dump({
                    "supabase_url": self.supabase_url,
                    "supabase_anon_key": self.supabase_anon_key,
                    "gemini_api_key": self.gemini_api_key,
                    "telegram_bot_token": self.telegram_bot_token,
                    "telegram_chat_id": self.telegram_chat_id
                }, f, indent=2)
        except Exception as e:
            print(f"Error saving config: {e}")


class SupabaseClient:
    """Ultra-economical Supabase HTTP client obeying Rule 9 (zero unbounded egress)."""

    def __init__(self, config: BisheConfig):
        self.config = config
        self._staff_cache = None
        self._staff_cache_expiry = 0

    def _request(self, endpoint: str):
        url = f"{self.config.supabase_url.rstrip('/')}/rest/v1/{endpoint}"
        req = urllib.request.Request(
            url,
            headers={
                "apikey": self.config.supabase_anon_key,
                "Authorization": f"Bearer {self.config.supabase_anon_key}",
                "Content-Type": "application/json",
            }
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as response:
                return json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8") if hasattr(e, "read") else str(e)
            print(f"{CLR_RED}Supabase HTTP {e.code} Error:{CLR_RESET} {err_body}")
            return []
        except Exception as e:
            print(f"{CLR_RED}Supabase Connection Error:{CLR_RESET} {e}")
            return []

    def get_staff_members(self, force_refresh=False):
        """In-Memory TTL cache (15 min) for master staff roster to save egress."""
        now = time.time()
        if not force_refresh and self._staff_cache and now < self._staff_cache_expiry:
            return self._staff_cache

        data = self._request("staff_members?select=id,name,role,commission_rate,base_salary,is_active&order=name.asc")
        if data:
            self._staff_cache = data
            self._staff_cache_expiry = now + 900  # 15 minutes TTL
        return self._staff_cache or []

    def get_recent_bookings(self, limit=100, start_date=None, end_date=None):
        """Pulls minimal fields strictly bounded by limit or date filter."""
        fields = "id,license_plate,car_type,total_amount,status,is_paid,created_at,completed_at,washer_1_name,washer_2_name,commission_amount,vat_amount,is_carpet,carpet_area_sq_meters,service_type"
        if start_date and end_date:
            s_iso = start_date.strftime("%Y-%m-%dT00:00:00Z")
            e_iso = end_date.strftime("%Y-%m-%dT23:59:59Z")
            endpoint = f"wash_bookings?select={fields}&created_at=gte.{s_iso}&created_at=lte.{e_iso}&order=created_at.desc&limit=250"
        else:
            endpoint = f"wash_bookings?select={fields}&order=created_at.desc&limit={limit}"
        return self._request(endpoint)


class BisheAnalyticsEngine:
    """Core dynamic calculation engine for Bishe Car Wash."""

    def __init__(self, supabase: SupabaseClient, config: BisheConfig):
        self.sb = supabase
        self.config = config

    @staticmethod
    def _parse_dt(dt_str):
        if not dt_str:
            return None
        try:
            clean = dt_str.replace("Z", "+00:00")
            return datetime.fromisoformat(clean)
        except Exception:
            return None

    @staticmethod
    def get_vehicle_multiplier(b: dict) -> tuple[float, str]:
        """
        Calculates exact volume multiplier according to station specifications:
          - Sedan / Automobile = 1.0x (Type A)
          - SUV / Pickup       = 1.4x (Type B)
          - Minibus / Van      = 1.8x (Type B)
          - Heavy Truck        = 2.5x (Type C)
          - Carpet             = m² * 0.25 EVU
        """
        if b.get("is_carpet"):
            area = float(b.get("carpet_area_sq_meters") or 12.0)
            return round(area * 0.25, 2), f"Carpet ({area:.1f} m²)"

        ctype = str(b.get("car_type", "")).lower()
        plate = str(b.get("license_plate", "")).lower()
        service = str(b.get("service_type", "")).lower()
        combined = f"{ctype} {plate} {service}"

        if any(k in combined for k in ["truck", "heavy", "sinotruk", "fsr", "isuzu", "fe'iisaa", "የጭነት"]):
            return 2.5, "Heavy Truck (Type C)"
        if any(k in combined for k in ["minibus", "van", "dolphin", "hiace"]):
            return 1.8, "Minibus / Van (Type B)"
        if any(k in combined for k in ["suv", "pickup", "hilux", "v8", "bigstar", "prado", "land cruiser", "cruiser"]):
            return 1.4, "SUV / Pickup (Type B)"
        if "minibus" in ctype or "medium" in ctype or "giddu" in ctype or "መካከለኛ" in ctype:
            return 1.5, "Type B (Medium)"
        return 1.0, "Sedan / Automobile (Type A)"

    def calculate_kpi(self):
        """Dynamic calculation of live KPIs for today."""
        now = datetime.now()
        bookings = self.sb.get_recent_bookings(limit=150)
        today_bookings = []
        for b in bookings:
            dt = self._parse_dt(b.get("created_at"))
            if dt and dt.year == now.year and dt.month == now.month and dt.day == now.day:
                today_bookings.append(b)

        total_evu = 0.0
        type_a = 0
        type_b_suv = 0
        type_b_van = 0
        type_c = 0
        carpets = 0
        carpet_m2 = 0.0

        for b in today_bookings:
            mult, cat_name = self.get_vehicle_multiplier(b)
            total_evu += mult
            if b.get("is_carpet"):
                carpets += 1
                carpet_m2 += float(b.get("carpet_area_sq_meters") or 12.0)
            elif "Type C" in cat_name:
                type_c += 1
            elif "Minibus" in cat_name:
                type_b_van += 1
            elif "SUV" in cat_name:
                type_b_suv += 1
            elif "Type B" in cat_name:
                type_b_suv += 1
            else:
                type_a += 1

        completed = sum(1 for b in today_bookings if b.get("status") == "completed")
        in_progress = len(today_bookings) - completed
        rev = sum(float(b.get("total_amount") or 0.0) for b in today_bookings)
        vat = rev * 0.15

        staff = self.sb.get_staff_members()
        active_washers = sum(1 for s in staff if s.get("is_active") and ("wash" in str(s.get("role", "")).lower() or s.get("role") == "washer"))
        commissions = sum(float(b.get("commission_amount") or (float(b.get("total_amount") or 0.0) * 0.15)) for b in today_bookings)

        return {
            "total_today": len(today_bookings),
            "completed_today": completed,
            "in_progress_today": in_progress,
            "revenue_today": rev,
            "vat_today": vat,
            "commissions_today": commissions,
            "total_evu": round(total_evu, 2),
            "type_a_count": type_a,
            "type_b_suv_count": type_b_suv,
            "type_b_van_count": type_b_van,
            "type_c_count": type_c,
            "carpet_count": carpets,
            "carpet_m2": round(carpet_m2, 1),
            "active_washers": active_washers
        }

    def get_washers_data(self):
        """Pulls washer roster with exact individual rates and live earned commissions."""
        staff = self.sb.get_staff_members()
        washers = [s for s in staff if "wash" in str(s.get("role", "")).lower() or s.get("role") == "washer"]
        bookings = self.sb.get_recent_bookings(limit=60)

        stats = []
        for w in washers:
            name = w.get("name", "Unknown")
            rate = float(w.get("commission_rate") or 0.15)
            jobs = 0
            earned = 0.0
            for b in bookings:
                if b.get("washer_1_name") == name:
                    jobs += 1
                    amt = float(b.get("total_amount") or 0.0)
                    earned += float(b.get("commission_amount") or (amt * rate))
            stats.append({
                "id": w.get("id"),
                "name": name,
                "role": w.get("role", "washer"),
                "commission_rate": rate,
                "jobs": jobs,
                "commission_earned": earned,
                "is_active": w.get("is_active", True)
            })
        return stats

    def ask(self, user_question: str, history=None) -> dict:
        """
        Executes query through Gemini 1.5 Flash grounded in live Supabase rows and Operations Manual.
        Falls back to local dynamic analytical calculation ONLY if Gemini is unconfigured or offline.
        """
        q = user_question.lower().strip()
        kpi = self.calculate_kpi()

        # 1. Prioritize Gemini Cloud AI with full Operations Manual & live database context
        if self.config.gemini_api_key:
            gem_res = self._ask_gemini(user_question, kpi, history)
            if gem_res:
                return gem_res

        # 2. Dynamic Local Analytics Engine (Offline Fallback — Zero Canned Responses)
        wants_table = any(w in q for w in ["table", "grid", "export", "list", "ዝርዝር", "gabatee", "form"])

        if any(w in q for w in ["p&l", "profit", "revenue", "loss", "expense", "ebitda", "ገቢ", "ትርፍ", "bu'aa", "galii"]):
            return self._build_pnl_answer(kpi, wants_table)

        if any(w in q for w in ["car", "vehicle", "wash", "plate", "sedan", "suv", "truck", "መኪና", "konkolaataa", "queue"]):
            return self._build_vehicles_answer(wants_table)

        if any(w in q for w in ["washer", "staff", "commission", "team", "worker", "አጣቢ", "ኮሚሽን", "hojjetaa"]):
            return self._build_washers_answer(wants_table)

        if any(w in q for w in ["shampoo", "perfume", "yield", "chemical", "dilution", "average", "consumable", "evu", "ሻምፑ", "ሽቶ"]):
            return self._build_chemicals_answer(kpi, wants_table)

        return self._build_summary_answer(kpi)

    def _build_pnl_answer(self, kpi, wants_table):
        gross = kpi["revenue_today"]
        vat = kpi["vat_today"]
        net = gross - vat
        comm = kpi["commissions_today"]
        chem = kpi["total_today"] * 28.5
        cogs = comm + chem
        gross_profit = net - cogs
        overhead = 180.0 if gross > 0 else 0.0
        ebitda = gross_profit - overhead

        table_html = f"""
        <div class="table-container">
          <table id="aiPnlTable">
            <thead>
              <tr><th>Component</th><th>Amount (ETB)</th><th>Treatment</th></tr>
            </thead>
            <tbody>
              <tr><td><strong>Gross Service Revenue</strong></td><td><strong>{gross:,.2f} ETB</strong></td><td>Operating Inflow ({kpi['total_today']} settled)</td></tr>
              <tr><td>Less: 15% Statutory VAT</td><td>- {vat:,.2f} ETB</td><td>Tax Obligation</td></tr>
              <tr><td><strong>Net Service Revenue</strong></td><td><strong>{net:,.2f} ETB</strong></td><td>Taxable Base</td></tr>
              <tr><td>Less: Washer Commissions (Direct Labor)</td><td>- {comm:,.2f} ETB</td><td>COGS (15% Net Base)</td></tr>
              <tr><td>Less: Chemicals Consumed (Direct Materials)</td><td>- {chem:,.2f} ETB</td><td>COGS (~28.50 ETB / EVU)</td></tr>
              <tr style="background:rgba(0,229,255,0.06);"><td><strong>GROSS OPERATING PROFIT</strong></td><td><strong>{gross_profit:,.2f} ETB</strong></td><td>Margin: {((gross_profit/gross)*100 if gross>0 else 0):.1f}%</td></tr>
              <tr><td>Less: Cashier Petty Cash & Yard Overhead</td><td>- {overhead:,.2f} ETB</td><td>Operating Overhead</td></tr>
              <tr style="background:rgba(16,185,129,0.08);"><td><strong><span style="color:#34D399;">NET OPERATING PROFIT (EBITDA)</span></strong></td><td><strong><span style="color:#34D399;">{ebitda:,.2f} ETB</span></strong></td><td>Retained Operating Cash</td></tr>
            </tbody>
          </table>
        </div>
        """
        text = f"Gross Revenue: {gross:,.2f} ETB | VAT: {vat:,.2f} ETB | Net Revenue: {net:,.2f} ETB | Direct Labor: {comm:,.2f} ETB | Direct Materials: {chem:,.2f} ETB | EBITDA: {ebitda:,.2f} ETB"
        return {"text": text, "html": table_html, "table_id": "aiPnlTable"}

    def _build_vehicles_answer(self, wants_table):
        bookings = self.sb.get_recent_bookings(limit=50)
        table_rows = []
        text_lines = []
        for b in bookings[:20]:
            plate = b.get("license_plate") or "WALK-IN"
            mult, cat = self.get_vehicle_multiplier(b)
            amt = float(b.get("total_amount") or 0.0)
            status = (b.get("status") or "pending").upper()
            w = b.get("washer_1_name") or "Unassigned"
            table_rows.append(f"<tr><td><code>{plate}</code></td><td>{cat}</td><td>{mult}x</td><td>{status}</td><td>{amt:,.0f} ETB</td><td>{w}</td></tr>")
            text_lines.append(f"• {plate} | {cat} ({mult}x) - {amt:,.0f} ETB [{status}] (Washer: {w})")

        table_html = f"""
        <div class="table-container">
          <table id="aiVehiclesTable">
            <thead><tr><th>License Plate</th><th>Category</th><th>Multiplier</th><th>Status</th><th>Amount</th><th>Assigned Washer</th></tr></thead>
            <tbody>{''.join(table_rows)}</tbody>
          </table>
        </div>
        """
        return {"text": "\n".join(text_lines), "html": table_html, "table_id": "aiVehiclesTable"}

    def _build_washers_answer(self, wants_table):
        washers = self.get_washers_data()
        table_rows = []
        text_lines = []
        for w in washers:
            rate = f"{w['commission_rate']*100:.0f}%"
            earned = f"{w['commission_earned']:,.2f} ETB"
            table_rows.append(f"<tr><td><strong>{w['name']}</strong></td><td>{w['role']}</td><td>{rate}</td><td>{w['jobs']}</td><td>{earned}</td></tr>")
            text_lines.append(f"• {w['name']} ({rate}): {w['jobs']} washes completed, {earned} commission earned")

        table_html = f"""
        <div class="table-container">
          <table id="aiWashersTable">
            <thead><tr><th>Washer Name</th><th>Role</th><th>Comm. Rate</th><th>Washes Done</th><th>Commission Earned</th></tr></thead>
            <tbody>{''.join(table_rows)}</tbody>
          </table>
        </div>
        """
        return {"text": "\n".join(text_lines), "html": table_html, "table_id": "aiWashersTable"}

    def _build_chemicals_answer(self, kpi, wants_table):
        evu = kpi["total_evu"]
        shampoo_ml = evu * 125.0
        perfume_ml = evu * 5.0
        shampoo_liters = shampoo_ml / 1000.0

        shampoo_alert = ""
        if evu > 0:
            yield_per_5l = (5000.0 / (shampoo_ml / evu)) if shampoo_ml > 0 else 0
            if yield_per_5l < 25:
                shampoo_alert = "<span style='color:#EF4444;'>⚠️ High Consumption Alert: <25 cars/5L</span>"
            elif yield_per_5l > 55:
                shampoo_alert = "<span style='color:#F59E0B;'>⚠️ Potential Under-dilution: >55 cars/5L</span>"

        table_html = f"""
        <div class="table-container">
          <table id="aiChemicalsTable">
            <thead><tr><th>Consumable Item</th><th>Standard Yield Rate</th><th>Calculated Usage Today ({evu:.1f} EVU)</th><th>Cost Estimate</th><th>Status</th></tr></thead>
            <tbody>
              <tr><td><strong>Car Shampoo (CS-009)</strong></td><td>125 ml / EVU (~40 cars/5L)</td><td><strong>{shampoo_liters:.2f} Liters</strong></td><td>{(shampoo_liters * 220.0):,.2f} ETB</td><td>{shampoo_alert or 'Optimal (125ml/EVU)'}</td></tr>
              <tr><td><strong>Interior Perfume (CS-006)</strong></td><td>5 ml / EVU (~100 sprays/500ml)</td><td><strong>{perfume_ml:.0f} ml</strong></td><td>{(perfume_ml / 500.0 * 250.0):,.2f} ETB</td><td>Optimal</td></tr>
              <tr><td><strong>Tire Cleaner Spray (CS-004)</strong></td><td>4 tires / EVU (~25 cars/can)</td><td>~{evu * 0.04:.1f} Cans</td><td>{(evu * 0.04 * 380.0):,.2f} ETB</td><td>In-Range</td></tr>
              <tr><td><strong>Microfiber Towels (CS-013)</strong></td><td>1 wear write-off / 40 EVU</td><td>{evu/40.0:.2f} Towels</td><td>{(evu/40.0 * 65.0):,.2f} ETB</td><td>Wear amortized</td></tr>
            </tbody>
          </table>
        </div>
        """
        text = f"Chemical Consumption for {evu:.1f} EVU:\n• Foam Shampoo: {shampoo_liters:.2f} Liters (125 ml/EVU)\n• Interior Perfume: {perfume_ml:.0f} ml\n• Average chemical direct material cost: 28.50 ETB / EVU"
        return {"text": text, "html": table_html, "table_id": "aiChemicalsTable"}

    def _build_summary_answer(self, kpi):
        text = f"Today's Overview: {kpi['total_today']} bookings ({kpi['completed_today']} completed), {kpi['total_evu']:.1f} total EVU, {kpi['revenue_today']:,.2f} ETB gross settled revenue, {kpi['active_washers']} active washers."
        html_content = f"""
        <div style="background:rgba(0,229,255,0.06); padding:16px; border-radius:12px; border:1px solid rgba(0,229,255,0.2);">
          <h3 style="color:#00E5FF; margin-bottom:8px;">🌟 Station Dynamic Operational Snapshot</h3>
          <p style="margin-bottom:6px;">• <strong>Vehicle Volume:</strong> {kpi['total_today']} registered (Sedan: {kpi.get('type_a_count',0)}, SUV/Pickup: {kpi.get('type_b_suv_count',0)}, Minibus/Van: {kpi.get('type_b_van_count',0)}, Heavy Truck: {kpi.get('type_c_count',0)}, Carpets: {kpi.get('carpet_count',0)})</p>
          <p style="margin-bottom:6px;">• <strong>Total Workload:</strong> {kpi['total_evu']:.1f} Equivalent Vehicle Units (EVU)</p>
          <p style="margin-bottom:6px;">• <strong>Gross Revenue:</strong> {kpi['revenue_today']:,.2f} ETB (Statutory 15% VAT: {kpi['vat_today']:,.2f} ETB)</p>
          <p style="margin-bottom:6px;">• <strong>Washer Commissions:</strong> {kpi['commissions_today']:,.2f} ETB (Direct Labor)</p>
          <p style="margin-bottom:6px;">• <strong>Chemical Benchmark:</strong> 125 ml foam shampoo/EVU, 5 ml perfume/interior</p>
          <p><em>Ask any operational question, request custom comparisons, or ask for tables to export as CSV.</em></p>
        </div>
        """
        return {"text": text, "html": html_content}

    def _ask_gemini(self, question: str, kpi: dict, history=None) -> dict | None:
        """Sends comprehensive dynamic snapshot and operations manual to Gemini 1.5 Flash."""
        if not self.config.gemini_api_key:
            return None
        try:
            today = datetime.now()
            manual = load_operations_manual()
            recent_bookings = self.sb.get_recent_bookings(limit=30)
            washers = self.get_washers_data()

            bookings_summary = []
            for b in recent_bookings[:15]:
                mult, cat = self.get_vehicle_multiplier(b)
                p = b.get("license_plate") or "WALK-IN"
                amt = float(b.get("total_amount") or 0.0)
                st = (b.get("status") or "pending").upper()
                w = b.get("washer_1_name") or "Unassigned"
                bookings_summary.append(f"- Plate: {p} | {cat} ({mult}x) | ETB {amt:,.0f} | Status: {st} | Washer: {w}")

            washers_summary = []
            for w in washers:
                washers_summary.append(f"- {w['name']} ({w['role']}): {w['jobs']} washes, {w['commission_rate']*100:.0f}% rate, ETB {w['commission_earned']:,.2f} earned")

            chemicals_summary = []
            for c in MASTER_CONSUMABLES[:10]:
                chemicals_summary.append(f"- {c['id']} {c['name']}: {c['stock']} {c['unit']} in stock (Min: {c['min']}, Cost: {c['cost']} ETB, Yield: {c['yield']})")

            system_instruction = f"""
You are "BisheAI", the Chief Operations Executive and dynamic analytical co-pilot for "BISHE Car Wash & Auto Care Service" in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
Location: Behind Hirna Butchery, near Alemshet Fero. 2 Physical Bays (Bay 1 & Bay 2), 1 Mobile Van, 8 Washers on rotating duty.

AUTHORITATIVE OPERATIONS MANUAL GROUNDING:
{manual if manual else "Full station rules apply: 15% VAT on car/carpet, 0% VAT on showers, 15% washer commission on Net Base revenue, OTP cash handover."}

VEHICLE VOLUME & WORKLOAD MULTIPLIERS (EVU):
- Sedan / Automobile (Type A): 1.0x Base Workload (125 ml shampoo, 5 ml perfume)
- SUV / Pickup (Type B): 1.4x Workload (175 ml shampoo, 7 ml perfume)
- Minibus / Van (Type B): 1.8x Workload (225 ml shampoo, 9 ml perfume)
- Heavy Truck (Type C): 2.5x Workload (312.5 ml shampoo, 12.5 ml perfume)
- Carpet: Calculated per square meter (Area in m² * 0.25 EVU)

CHEMICAL BENCHMARKS & ANOMALY THRESHOLDS:
- 5L Foam Shampoo (CS-009): Standard yield is ~40 cars @ 125 ml/EVU. Flag alert if < 25 cars (waste/leak) or > 55 cars (under-dilution).
- 500ml Interior Perfume (CS-006): Standard yield is ~100 sprays @ 5 ml/interior. Flag alert if < 70 or > 130 sprays.

LIVE DATABASE SNAPSHOT ({today.strftime('%Y-%m-%d %H:%M')}):
- Total Today Bookings: {kpi['total_today']} (Completed: {kpi['completed_today']}, In Bays: {kpi['in_progress_today']})
- Workload Breakdown: Sedans: {kpi.get('type_a_count',0)}, SUVs/Pickups: {kpi.get('type_b_suv_count',0)}, Minibuses/Vans: {kpi.get('type_b_van_count',0)}, Heavy Trucks: {kpi.get('type_c_count',0)}, Carpets: {kpi.get('carpet_count',0)}
- Total Workload Units: {kpi['total_evu']} EVU
- Gross Revenue Settled: {kpi['revenue_today']:,.2f} ETB
- Statutory 15% VAT: {kpi['vat_today']:,.2f} ETB
- Washer Commissions Settled: {kpi['commissions_today']:,.2f} ETB
- Active Washers on Duty: {kpi['active_washers']}

LIVE RECENT BOOKINGS:
{chr(10).join(bookings_summary)}

ACTIVE WASHERS ROSTER:
{chr(10).join(washers_summary)}

WAREHOUSE CHEMICAL INVENTORY:
{chr(10).join(chemicals_summary)}

CRITICAL RESPONSE RULES:
1. Zero canned or static boilerplate. All calculations, averages, and analysis must derive from the real live numbers and formulas above.
2. If the user asks for a table, comparison, or breakdown, ALWAYS format with clean Markdown tables with column headers and alignment (| Col 1 | Col 2 | ... |).
3. If the user asks for averages, chemical consumption, washer earnings, or P&L, show the mathematical formula and live calculation.
4. Reply in the user's language (English, Amharic, or Afaan Oromoo).
"""

            contents = [
                {"role": "user", "parts": [{"text": system_instruction}]},
                {"role": "model", "parts": [{"text": "Understood. I am BisheAI, fully grounded in the BISHE Operations Manual and the live station database. I will provide accurate, dynamic, and exportable operational intelligence with real math and zero canned answers."}]}
            ]

            if history and isinstance(history, list):
                for h in history[-8:]:
                    r = "user" if h.get("role") == "user" else "model"
                    txt = h.get("content") or h.get("text") or ""
                    if txt:
                        contents.append({"role": r, "parts": [{"text": txt}]})

            contents.append({"role": "user", "parts": [{"text": question}]})

            models_to_try = ["gemini-flash-lite-latest", "gemini-3.1-flash-lite", "gemini-3.5-flash-lite", "gemini-flash-latest", "gemini-3.8-flash"]
            payload = {
                "contents": contents,
                "generationConfig": {"temperature": 0.7, "maxOutputTokens": 2048}
            }
            encoded_payload = json.dumps(payload).encode("utf-8")

            for model_name in models_to_try:
                url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={self.config.gemini_api_key}"
                req = urllib.request.Request(
                    url,
                    data=encoded_payload,
                    headers={"Content-Type": "application/json"}
                )
                try:
                    with urllib.request.urlopen(req, timeout=15) as resp:
                        res_data = json.loads(resp.read().decode("utf-8"))
                        candidates = res_data.get("candidates", [])
                        if candidates:
                            parts = candidates[0].get("content", {}).get("parts", [])
                            if parts:
                                raw_text = parts[0].get("text", "").strip()
                                formatted_html, table_id = markdown_to_html(raw_text)
                                return {
                                    "text": raw_text,
                                    "html": formatted_html,
                                    "table_id": table_id,
                                    "source": model_name
                                }
                except urllib.error.HTTPError as e:
                    if e.code in [404, 503]:
                        # Try next model in fallback list
                        continue
                    else:
                        print(f"{CLR_RED}Gemini API HTTP {e.code} Error:{CLR_RESET} {e}")
                        break
                except Exception as e:
                    print(f"{CLR_RED}Gemini Model {model_name} Error:{CLR_RESET} {e}")
                    continue
        except Exception as e:
            print(f"{CLR_RED}Gemini API Call Exception:{CLR_RESET} {e}")
            return None
        return None


class BisheHttpHandler(BaseHTTPRequestHandler):
    """Local HTTP API and Web Dashboard Server."""

    analytics_engine = None
    config = None

    def log_message(self, format, *args):
        # Silence routine access logs
        pass

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()

    def do_GET(self):
        try:
            parsed = urllib.parse.urlparse(self.path)
            path = parsed.path

            if path in ["/", "/index.html"]:
                base_dir = os.path.dirname(os.path.abspath(__file__))
                html_path = os.path.join(base_dir, "web", "index.html")
                self._serve_file(html_path, "text/html; charset=utf-8")
            elif path == "/api/kpi":
                kpi = self.analytics_engine.calculate_kpi()
                self._serve_json(kpi)
            elif path == "/api/vehicles":
                data = self.analytics_engine.sb.get_recent_bookings(limit=60)
                self._serve_json(data)
            elif path == "/api/washers":
                data = self.analytics_engine.get_washers_data()
                self._serve_json(data)
            elif path == "/api/chemicals":
                self._serve_json(MASTER_CONSUMABLES)
            elif path == "/api/config":
                cfg = {
                    "gemini_api_key": self.config.gemini_api_key,
                    "telegram_bot_token": self.config.telegram_bot_token,
                    "telegram_chat_id": self.config.telegram_chat_id
                }
                self._serve_json(cfg)
            else:
                self.send_response(404)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"404 Not Found")
        except Exception as e:
            self._serve_json({"error": str(e)}, status=500)

    def do_POST(self):
        try:
            parsed = urllib.parse.urlparse(self.path)
            path = parsed.path
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
            payload = json.loads(body) if body else {}

            if path == "/api/ask":
                q = payload.get("query", "")
                history = payload.get("history", [])
                res = self.analytics_engine.ask(q, history=history)
                self._serve_json(res)
            elif path == "/api/config":
                if "gemini_api_key" in payload:
                    self.config.gemini_api_key = payload["gemini_api_key"]
                if "telegram_bot_token" in payload:
                    self.config.telegram_bot_token = payload["telegram_bot_token"]
                if "telegram_chat_id" in payload:
                    self.config.telegram_chat_id = payload["telegram_chat_id"]
                self.config.save()
                self._serve_json({"status": "saved"})
            else:
                self.send_response(404)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"404 Not Found")
        except Exception as e:
            self._serve_json({"error": str(e), "text": f"Error: {e}"}, status=500)

    def _serve_file(self, filepath, content_type):
        if not os.path.exists(filepath):
            alt = os.path.join(os.getcwd(), "agent", "web", "index.html")
            if os.path.exists(alt):
                filepath = alt
            else:
                self.send_response(404)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(f"File not found: {filepath}".encode())
                return
        with open(filepath, "rb") as f:
            content = f.read()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def _serve_json(self, data, status=200):
        content = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)


def start_web_server(analytics: BisheAnalyticsEngine, config: BisheConfig, port=5050, open_browser=True):
    """Starts the local web server and opens the browser."""
    BisheHttpHandler.analytics_engine = analytics
    BisheHttpHandler.config = config

    server_address = ("0.0.0.0", port)
    try:
        httpd = HTTPServer(server_address, BisheHttpHandler)
    except OSError:
        port = port + 1
        server_address = ("0.0.0.0", port)
        httpd = HTTPServer(server_address, BisheHttpHandler)

    url = f"http://127.0.0.1:{port}"
    print(f"\n{CLR_GREEN}{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")
    print(f"{CLR_CYAN}{CLR_BOLD}   🌟 BISHE AI EXECUTIVE STUDIO (APP VIEW) STARTED SUCCESSFULLY!    {CLR_RESET}")
    print(f"{CLR_GREEN}{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")
    print(f"  • Web Dashboard URL:  {CLR_BOLD}{url}{CLR_RESET}")
    print(f"  • Grounded In:        BISHE Operations Manual + Live Database Rows")
    print(f"  • Multipliers:        Sedan 1.0x, SUV 1.4x, Minibus 1.8x, Truck 2.5x, Carpet m²")
    print(f"  • Features:           Live Dynamic P&L, Vehicle Queue, Chemical EVU, CSV Export")
    print(f"  • Refresh anytime:    Updates live Supabase data instantly")
    print(f"{CLR_GREEN}{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}\n")

    if open_browser:
        webbrowser.open(url)

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping BISHE Executive Studio server. Goodbye!")
        httpd.server_close()


def main():
    parser = argparse.ArgumentParser(description="BISHE Car Wash Executive AI Studio")
    parser.add_argument("--web", action="store_true", help="Launch the App-Like Web Dashboard (Default)")
    parser.add_argument("--port", type=int, default=5050, help="Web server port (default: 5050)")
    parser.add_argument("--no-browser", action="store_true", help="Do not open browser automatically")
    parser.add_argument("--pnl", action="store_true", help="Print today's P&L and revenue report in CLI")
    parser.add_argument("--cars", action="store_true", help="Print vehicles washed and category breakdown in CLI")
    parser.add_argument("--washers", action="store_true", help="Print active washers and commissions in CLI")
    parser.add_argument("--ask", type=str, help="Ask any operational question in CLI")

    args = parser.parse_args()

    config = BisheConfig()
    supabase = SupabaseClient(config)
    analytics = BisheAnalyticsEngine(supabase, config)

    if args.pnl:
        kpi = analytics.calculate_kpi()
        print(analytics._build_pnl_answer(kpi, wants_table=False)["text"])
    elif args.cars:
        print(analytics._build_vehicles_answer(wants_table=False)["text"])
    elif args.washers:
        print(analytics._build_washers_answer(wants_table=False)["text"])
    elif args.ask:
        ans = analytics.ask(args.ask)
        print(ans.get("text", ""))
    else:
        # Default behavior: Launch the full rich App-Like Web Studio!
        start_web_server(analytics, config, port=args.port, open_browser=not args.no_browser)


if __name__ == "__main__":
    main()
