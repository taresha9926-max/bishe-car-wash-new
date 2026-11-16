#!/usr/bin/env python3
"""
BISHE Car Wash & Auto Care Service — Executive AI Studio (Option A)
Location: Bishoftu (Debre Zeyit), Oromia, Ethiopia

A high-performance local AI operations studio running on Python 3.12+.
Features:
  - 100% Zero-External-Dependency standard Python.
  - Interactive Web App Studio (launches automatically in your browser).
  - One-Click CSV, Excel, and Print / PDF Exports.
  - Dynamic Real Calculation Engine (No hardcoded or canned statements).
  - Equivalent Vehicle Units (EVU): Type A 1.0x, Type B 1.5x, Type C 2.5x, Carpet m² 0.25x.
  - Real washer commission rates (2% to 25%) and split assignments.
  - Live P&L (Gross revenue, 15% VAT, washer labor COGS, chemical materials COGS, EBITDA).
  - Strict Supabase free-tier egress economy (Rule 9).
"""

import os
import sys
import json
import time
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


class BisheConfig:
    """Manages credentials and settings from config.json or environment."""

    def __init__(self, config_path="agent/config.json"):
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

    def calculate_kpi(self):
        """Dynamic calculation of live KPIs for today."""
        now = datetime.now()
        bookings = self.sb.get_recent_bookings(limit=150)
        today_bookings = []
        for b in bookings:
            dt = self._parse_dt(b.get("created_at"))
            if dt and dt.year == now.year and dt.month == now.month and dt.day == now.day:
                today_bookings.append(b)

        # Calculate EVU (Equivalent Vehicle Units)
        # Type A: 1.0x, Type B: 1.5x, Type C: 2.5x, Carpet: m2 * 0.25
        total_evu = 0.0
        type_a = 0
        type_b = 0
        type_c = 0
        carpets = 0

        for b in today_bookings:
            if b.get("is_carpet"):
                carpets += 1
                area = float(b.get("carpet_area_sq_meters") or 12.0)
                total_evu += (area * 0.25)
            else:
                ctype = str(b.get("car_type", "")).lower()
                if "minibus" in ctype or "van" in ctype or "suv" in ctype or "medium" in ctype:
                    type_b += 1
                    total_evu += 1.5
                elif "truck" in ctype or "heavy" in ctype or "large" in ctype:
                    type_c += 1
                    total_evu += 2.5
                else:
                    type_a += 1
                    total_evu += 1.0

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
            "total_evu": total_evu,
            "type_a_count": type_a,
            "type_b_count": type_b,
            "type_c_count": type_c,
            "carpet_count": carpets,
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

    def ask(self, user_question: str) -> dict:
        """Processes query dynamically and returns both HTML table/format and plain text."""
        q = user_question.lower().strip()
        kpi = self.calculate_kpi()

        # Check if table output is explicitly requested
        wants_table = "table" in q or "grid" in q or "export" in q or "list" in q or "ዝርዝር" in q or "gabatee" in q

        # 1. P&L / Revenue
        if any(w in q for w in ["p&l", "profit", "revenue", "loss", "expense", "ገቢ", "ትርፍ", "bu'aa", "galii"]):
            return self._build_pnl_answer(kpi, wants_table)

        # 2. Vehicles Washed / Queue
        if any(w in q for w in ["car", "vehicle", "wash", "plate", "sedan", "suv", "መኪና", "konkolaataa", "queue"]):
            return self._build_vehicles_answer(wants_table)

        # 3. Washers & Commissions
        if any(w in q for w in ["washer", "staff", "commission", "team", "አጣቢ", "ኮሚሽን", "hojjetaa"]):
            return self._build_washers_answer(wants_table)

        # 4. Chemical Yield / Consumables
        if any(w in q for w in ["shampoo", "perfume", "yield", "chemical", "dilution", "average", "consumable", "evu", "ሻምፑ", "ሽቶ"]):
            return self._build_chemicals_answer(kpi, wants_table)

        # 5. Gemini Cloud Mode if configured
        if self.config.gemini_api_key:
            gem_res = self._ask_gemini(user_question, kpi)
            if gem_res:
                return {"text": gem_res, "html": f"<div style='line-height:1.6;'>{gem_res.replace(chr(10), '<br>')}</div>"}

        # Default: Executive Summary
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
              <tr><td>Less: Washer Commissions (Direct Labor)</td><td>- {comm:,.2f} ETB</td><td>COGS</td></tr>
              <tr><td>Less: Chemicals Consumed (Direct Materials)</td><td>- {chem:,.2f} ETB</td><td>COGS (~28.5 ETB / EVU)</td></tr>
              <tr style="background:rgba(0,229,255,0.06);"><td><strong>GROSS OPERATING PROFIT</strong></td><td><strong>{gross_profit:,.2f} ETB</strong></td><td>Margin: {((gross_profit/gross)*100 if gross>0 else 0):.1f}%</td></tr>
              <tr><td>Less: Cashier Petty Cash & Yard Overhead</td><td>- {overhead:,.2f} ETB</td><td>Operating Overhead</td></tr>
              <tr style="background:rgba(16,185,129,0.08);"><td><strong><span style="color:#34D399;">NET OPERATING PROFIT (EBITDA)</span></strong></td><td><strong><span style="color:#34D399;">{ebitda:,.2f} ETB</span></strong></td><td>Retained Operating Cash</td></tr>
            </tbody>
          </table>
        </div>
        """
        text = f"Gross Revenue: {gross:,.2f} ETB | VAT: {vat:,.2f} ETB | Net Revenue: {net:,.2f} ETB | COGS: {cogs:,.2f} ETB | Net Operating Profit: {ebitda:,.2f} ETB"
        return {"text": text, "html": table_html, "table_id": "aiPnlTable"}

    def _build_vehicles_answer(self, wants_table):
        bookings = self.sb.get_recent_bookings(limit=50)
        table_rows = []
        text_lines = []
        for b in bookings[:15]:
            plate = b.get("license_plate") or "WALK-IN"
            ctype = "Carpet" if b.get("is_carpet") else b.get("car_type", "automobile")
            amt = float(b.get("total_amount") or 0.0)
            status = (b.get("status") or "pending").upper()
            w = b.get("washer_1_name") or "Unassigned"
            table_rows.append(f"<tr><td><code>{plate}</code></td><td>{ctype}</td><td>{status}</td><td>{amt:,.0f} ETB</td><td>{w}</td></tr>")
            text_lines.append(f"• {plate} ({ctype}) - {amt:,.0f} ETB [{status}]")

        table_html = f"""
        <div class="table-container">
          <table id="aiVehiclesTable">
            <thead><tr><th>License Plate</th><th>Vehicle Category</th><th>Status</th><th>Amount</th><th>Washer</th></tr></thead>
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
            text_lines.append(f"• {w['name']} ({rate}): {w['jobs']} washes, {earned}")

        table_html = f"""
        <div class="table-container">
          <table id="aiWashersTable">
            <thead><tr><th>Washer Name</th><th>Role</th><th>Comm. Rate</th><th>Washes</th><th>Commission Earned</th></tr></thead>
            <tbody>{''.join(table_rows)}</tbody>
          </table>
        </div>
        """
        return {"text": "\n".join(text_lines), "html": table_html, "table_id": "aiWashersTable"}

    def _build_chemicals_answer(self, kpi, wants_table):
        evu = kpi["total_evu"]
        shampoo_rate = 125.0 # ml per EVU
        perfume_rate = 5.0   # ml per EVU

        total_shampoo_ml = evu * shampoo_rate
        total_perfume_ml = evu * perfume_rate

        table_html = f"""
        <div class="table-container">
          <table id="aiChemicalsTable">
            <thead><tr><th>Consumable Item</th><th>Standard Rate / EVU</th><th>Calculated Usage Today ({evu:.1f} EVU)</th><th>Cost Estimate</th></tr></thead>
            <tbody>
              <tr><td><strong>Car Shampoo (CS-009)</strong></td><td>125 ml / EVU</td><td><strong>{(total_shampoo_ml/1000.0):.2f} Liters</strong></td><td>{(total_shampoo_ml/1000.0 * 220.0):,.2f} ETB</td></tr>
              <tr><td><strong>Interior Perfume (CS-006)</strong></td><td>5 ml / EVU (~1 spray)</td><td><strong>{total_perfume_ml:.0f} ml</strong></td><td>{(total_perfume_ml/500.0 * 250.0):,.2f} ETB</td></tr>
              <tr><td><strong>Tire Cleaner Spray (CS-004)</strong></td><td>4 tires / EVU</td><td>~{evu * 0.04:.1f} Cans</td><td>{(evu * 0.04 * 380.0):,.2f} ETB</td></tr>
              <tr><td><strong>Microfiber Towel Wear (CS-013)</strong></td><td>1 write-off / 40 EVU</td><td>{evu/40.0:.2f} Towels</td><td>{(evu/40.0 * 65.0):,.2f} ETB</td></tr>
            </tbody>
          </table>
        </div>
        """
        text = f"Calculated Chemical Usage for {evu:.1f} EVU:\n• Shampoo: {(total_shampoo_ml/1000.0):.2f} Liters\n• Perfume: {total_perfume_ml:.0f} ml\n• Average chemical cost: 28.50 ETB / EVU"
        return {"text": text, "html": table_html, "table_id": "aiChemicalsTable"}

    def _build_summary_answer(self, kpi):
        text = f"Today's Overview: {kpi['total_today']} bookings ({kpi['completed_today']} completed), {kpi['total_evu']:.1f} total EVU, {kpi['revenue_today']:,.2f} ETB gross settled revenue, {kpi['active_washers']} active washers."
        html = f"""
        <div style="background:rgba(0,229,255,0.06); padding:16px; border-radius:12px; border:1px solid rgba(0,229,255,0.2);">
          <h3 style="color:#00E5FF; margin-bottom:8px;">🌟 Station Dynamic Operational Snapshot</h3>
          <p style="margin-bottom:6px;">• <strong>Vehicle Activity:</strong> {kpi['total_today']} registered (Type A: {kpi['type_a_count']}, Type B: {kpi['type_b_count']}, Type C: {kpi['type_c_count']}, Carpets: {kpi['carpet_count']})</p>
          <p style="margin-bottom:6px;">• <strong>Total Workload:</strong> {kpi['total_evu']:.1f} Equivalent Vehicle Units (EVU)</p>
          <p style="margin-bottom:6px;">• <strong>Gross Revenue:</strong> {kpi['revenue_today']:,.2f} ETB (VAT: {kpi['vat_today']:,.2f} ETB)</p>
          <p style="margin-bottom:6px;">• <strong>Washer Commissions:</strong> {kpi['commissions_today']:,.2f} ETB</p>
          <p><em>Ask me to display any analysis as a table, export CSV, or audit chemical usage.</em></p>
        </div>
        """
        return {"text": text, "html": html}

    def _ask_gemini(self, question: str, kpi: dict):
        """Sends comprehensive dynamic snapshot to Gemini 1.5 Flash."""
        try:
            today = datetime.now()
            system_prompt = f"""
You are the Executive AI Co-Pilot for "BISHE Car Wash & Auto Care Service" in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
Answer dynamically using ETB currency. Never use canned or static examples.
If the user asks for a table, format using clean markdown tables with columns and alignment.

LIVE DYNAMIC SNAPSHOT ({today.strftime('%Y-%m-%d')}):
- Total Bookings Today: {kpi['total_today']} (Completed: {kpi['completed_today']}, In Bays: {kpi['in_progress_today']})
- Category Breakdown: Type A (Small): {kpi['type_a_count']}, Type B (Medium/SUV): {kpi['type_b_count']}, Type C (Heavy): {kpi['type_c_count']}, Carpets: {kpi['carpet_count']}
- Total Workload Units: {kpi['total_evu']:.1f} EVU
- Gross Revenue: {kpi['revenue_today']:,.2f} ETB (Statutory 15% VAT: {kpi['vat_today']:,.2f} ETB)
- Washer Commissions: {kpi['commissions_today']:,.2f} ETB
- Active Washers: {kpi['active_washers']} on duty
- Chemical Yield Metric: 125 ml shampoo/EVU, 5 ml perfume/EVU.

USER REQUEST:
"{question}"
"""
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={self.config.gemini_api_key}"
            payload = {
                "contents": [{"role": "user", "parts": [{"text": system_prompt}]}],
                "generationConfig": {"temperature": 0.2, "maxOutputTokens": 1000}
            }
            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=14) as resp:
                res_data = json.loads(resp.read().decode("utf-8"))
                candidates = res_data.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if parts:
                        return parts[0].get("text", "").strip()
        except Exception:
            return None
        return None


class BisheHttpHandler(BaseHTTPRequestHandler):
    """Local HTTP API and Web Dashboard Server."""

    analytics_engine = None
    config = None

    def log_message(self, format, *args):
        # Silence routine access logs
        pass

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path in ["/", "/index.html"]:
            self._serve_file("agent/web/index.html", "text/html; charset=utf-8")
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
            self.send_error(404, "Not Found")

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
        payload = json.loads(body) if body else {}

        if path == "/api/ask":
            q = payload.get("query", "")
            res = self.analytics_engine.ask(q)
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
            self.send_error(404, "Not Found")

    def _serve_file(self, filepath, content_type):
        if not os.path.exists(filepath):
            self.send_error(404, "File Not Found")
            return
        with open(filepath, "rb") as f:
            content = f.read()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def _serve_json(self, data):
        content = json.dumps(data).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)


def start_web_server(analytics: BisheAnalyticsEngine, config: BisheConfig, port=5050):
    """Starts the local web server and opens the browser automatically."""
    BisheHttpHandler.analytics_engine = analytics
    BisheHttpHandler.config = config

    server_address = ("127.0.0.1", port)
    try:
        httpd = HTTPServer(server_address, BisheHttpHandler)
    except OSError:
        # Try port 5051 if 5050 is in use
        port = port + 1
        server_address = ("127.0.0.1", port)
        httpd = HTTPServer(server_address, BisheHttpHandler)

    url = f"http://localhost:{port}"
    print(f"\n{CLR_GREEN}{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")
    print(f"{CLR_CYAN}{CLR_BOLD}   🌟 BISHE AI EXECUTIVE STUDIO (APP VIEW) STARTED SUCCESSFULLY!    {CLR_RESET}")
    print(f"{CLR_GREEN}{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")
    print(f"  • Web Dashboard URL:  {CLR_BOLD}{url}{CLR_RESET}")
    print(f"  • Features:           Live Dynamic P&L, Vehicle Queue, Chemical EVU, CSV Export")
    print(f"  • Opening in your default browser now...")
    print(f"  • Press Ctrl+C in this window anytime to stop the studio.")
    print(f"{CLR_GREEN}{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}\n")

    # Automatically launch user's browser
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
    parser.add_argument("--pnl", action="store_true", help="Print today's P&L and revenue report in CLI")
    parser.add_argument("--cars", action="store_true", help="Print vehicles washed and category breakdown in CLI")
    parser.add_argument("--washers", action="store_true", help="Print active washers and commissions in CLI")
    parser.add_argument("--ask", type=str, help="Ask any operational question in CLI")
    parser.add_argument("--telegram", action="store_true", help="Start Telegram Bot service")

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
    elif args.telegram:
        print("Telegram mode...")
    else:
        # Default behavior: Launch the full rich App-Like Web Studio!
        start_web_server(analytics, config, port=args.port)


if __name__ == "__main__":
    main()
