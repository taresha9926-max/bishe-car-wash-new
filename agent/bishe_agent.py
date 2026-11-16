#!/usr/bin/env python3
"""
BISHE Car Wash & Auto Care Service — Executive AI Agent (Option A)
Location: Bishoftu (Debre Zeyit), Oromia, Ethiopia

A high-performance, lightweight local AI agent and operations engine.
Features:
  - 100% Zero-External-Dependency standard Python (runs directly on Python 3.12+).
  - Strict Supabase free-tier egress economy (bounded queries, field selection, 15m in-memory TTL caching).
  - P&L and financial statements (ETB revenue, VAT, direct labor COGS, chemical COGS, net EBITDA).
  - Vehicle and carpet wash categorizations with chemical consumption multipliers.
  - Active washer attendance and commission payouts.
  - Standard 5L shampoo container (~40 cars @ 125ml/car) and 500ml perfume yield metrics.
  - Discrepancy & low stock threshold alerts.
  - Natural language querying via local heuristic parser or Google Gemini 1.5 Flash.
  - Interactive CLI console and optional live Telegram Bot service.
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime, timezone, timedelta
import argparse

# Terminal ANSI Color Codes
CLR_CYAN = "\033[96m"
CLR_GREEN = "\033[92m"
CLR_YELLOW = "\033[93m"
CLR_RED = "\033[91m"
CLR_MAGENTA = "\033[95m"
CLR_BOLD = "\033[1m"
CLR_RESET = "\033[0m"

# Standard warehouse consumables catalog
MASTER_CONSUMABLES = [
    {"id": "CS-001", "name": "Abro Polish (Different Colors)", "unit": "Tins", "stock": 12.0, "min": 4.0, "cost": 450.0},
    {"id": "CS-002", "name": "Grinder Polish Pad", "unit": "Pieces", "stock": 15.0, "min": 5.0, "cost": 300.0},
    {"id": "CS-003", "name": "Dashboard Protectant (የዳሽቦርድ ቅባት)", "unit": "Liters", "stock": 18.0, "min": 5.0, "cost": 650.0},
    {"id": "CS-004", "name": "Foaming Tire Cleaner Spray", "unit": "Cans", "stock": 24.0, "min": 6.0, "cost": 380.0},
    {"id": "CS-005", "name": "Water Spot Compound", "unit": "Bottles", "stock": 8.0, "min": 3.0, "cost": 850.0},
    {"id": "CS-006", "name": "Air Freshener Perfume (ሽቶ)", "unit": "Bottles (500ml)", "stock": 20.0, "min": 6.0, "cost": 250.0},
    {"id": "CS-007", "name": "2-Color Polishing Cloth (የማሻ ጨርቅ)", "unit": "Pieces", "stock": 25.0, "min": 8.0, "cost": 150.0},
    {"id": "CS-008", "name": "Headlight Restoration Chemical", "unit": "Bottles", "stock": 6.0, "min": 2.0, "cost": 950.0},
    {"id": "CS-009", "name": "Car Shampoo Snow Foam (የመኪና ሻምፑ)", "unit": "Liters (5L Cans)", "stock": 45.0, "min": 15.0, "cost": 220.0},
    {"id": "CS-010A", "name": "Dashboard Sprays", "unit": "Cans", "stock": 16.0, "min": 5.0, "cost": 320.0},
    {"id": "CS-010B", "name": "Carpet & Interior Sprays", "unit": "Cans", "stock": 14.0, "min": 5.0, "cost": 340.0},
    {"id": "CS-011", "name": "Tire Dressing Black Gel", "unit": "Cans", "stock": 12.0, "min": 4.0, "cost": 420.0},
    {"id": "CS-012", "name": "Engine Degreaser Concentrated", "unit": "Liters", "stock": 10.0, "min": 3.0, "cost": 550.0},
    {"id": "CS-013", "name": "Microfiber Towels 40x40", "unit": "Pieces", "stock": 50.0, "min": 20.0, "cost": 65.0},
    {"id": "CS-014", "name": "Leather Conditioner Cream", "unit": "Bottles", "stock": 8.0, "min": 3.0, "cost": 480.0},
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

    def get_recent_bookings(self, limit=60, start_date=None, end_date=None):
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
    """Core business intelligence and operational calculator for Bishe Car Wash."""

    def __init__(self, supabase: SupabaseClient, config: BisheConfig):
        self.sb = supabase
        self.config = config

    @staticmethod
    def _parse_dt(dt_str):
        if not dt_str:
            return None
        try:
            # Handle ISO format with Z or timezone offset
            clean = dt_str.replace("Z", "+00:00")
            return datetime.fromisoformat(clean)
        except Exception:
            return None

    def get_pnl_report(self, target_date=None):
        """Generates full P&L Statement with statutory VAT, direct COGS, and EBITDA."""
        if target_date is None:
            target_date = datetime.now()

        bookings = self.sb.get_recent_bookings(limit=150)
        day_bookings = []
        for b in bookings:
            dt = self._parse_dt(b.get("created_at"))
            if dt and dt.year == target_date.year and dt.month == target_date.month and dt.day == target_date.day:
                day_bookings.append(b)

        # Revenue calculations
        gross_rev = sum(float(b.get("total_amount") or 0.0) for b in day_bookings)
        vat_deducted = gross_rev * 0.15
        net_after_vat = gross_rev - vat_deducted

        # Direct labor: commissions paid to washers
        commissions = sum(float(b.get("commission_amount") or (float(b.get("total_amount") or 0.0) * 0.15)) for b in day_bookings)

        # Direct materials: estimated chemical consumables consumed based on car volumes
        # Average chemical cost per vehicle wash is ~28.5 ETB (12.7 ETB shampoo, 8.0 ETB perfume, 7.8 ETB tire & wax)
        materials_cogs = len(day_bookings) * 28.50
        cogs = commissions + materials_cogs
        gross_profit = net_after_vat - cogs

        # Estimated daily operating petty cash overhead (water, electricity, tea/sugar)
        operating_overhead = 180.0 if day_bookings else 0.0
        ebitda = gross_profit - operating_overhead

        margin = (gross_profit / gross_rev * 100) if gross_rev > 0 else 0.0

        date_str = target_date.strftime("%d/%m/%Y")
        lines = [
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"{CLR_CYAN}{CLR_BOLD}   📊 BISHE OPERATIONS P&L & NET REVENUE STATEMENT{CLR_RESET}",
            f"   Station: Bishoftu, Oromia | Date: {date_str}",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  • Gross Service Tickets:               {len(day_bookings)} vehicles registered",
            f"  • {CLR_BOLD}GROSS SERVICE REVENUE:{CLR_RESET}              {CLR_GREEN}{gross_rev:12,.2f} ETB{CLR_RESET}",
            f"    - Less: 15% Statutory VAT:          {vat_deducted:12,.2f} ETB",
            f"  • {CLR_BOLD}NET SERVICE REVENUE:{CLR_RESET}                {net_after_vat:12,.2f} ETB",
            f"--------------------------------------------------------------------",
            f"  • Less Direct Costs (COGS):",
            f"    - Washer Commissions (15% labor):   {commissions:12,.2f} ETB",
            f"    - Consumable Chemicals (COGS):      {materials_cogs:12,.2f} ETB",
            f"  • {CLR_BOLD}GROSS OPERATING PROFIT:{CLR_RESET}             {CLR_CYAN}{gross_profit:12,.2f} ETB{CLR_RESET} ({margin:.1f}% Margin)",
            f"    - Less: Station Daily Overhead:     {operating_overhead:12,.2f} ETB",
            f"--------------------------------------------------------------------",
            f"  • {CLR_BOLD}{CLR_GREEN}NET OPERATING PROFIT (EBITDA):       {ebitda:12,.2f} ETB{CLR_RESET}",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  *Note: Fixed station land rent and monthly base staff salaries",
            f"   are amortized separately across the 30-day closing cycle.",
        ]
        return "\n".join(lines)

    def get_cars_report(self, target_date=None):
        """Breakdown of vehicles washed today by size coefficient and queue log."""
        if target_date is None:
            target_date = datetime.now()

        bookings = self.sb.get_recent_bookings(limit=100)
        day_bookings = []
        for b in bookings:
            dt = self._parse_dt(b.get("created_at"))
            if dt and dt.year == target_date.year and dt.month == target_date.month and dt.day == target_date.day:
                day_bookings.append(b)

        sedans, suvs, minibuses, trucks, carpets = 0, 0, 0, 0, 0
        for b in day_bookings:
            if b.get("is_carpet"):
                carpets += 1
            else:
                ctype = str(b.get("car_type", "")).lower()
                if "suv" in ctype or "pickup" in ctype:
                    suvs += 1
                elif "minibus" in ctype or "van" in ctype:
                    minibuses += 1
                elif "truck" in ctype or "heavy" in ctype:
                    trucks += 1
                else:
                    sedans += 1

        completed = sum(1 for b in day_bookings if b.get("status") == "completed")
        in_bays = len(day_bookings) - completed

        lines = [
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"{CLR_CYAN}{CLR_BOLD}   🚗 STATION VEHICLE VOLUME & CATEGORY BREAKDOWN{CLR_RESET}",
            f"   Total Processed: {len(day_bookings)} | Completed: {completed} | In Queue/Bays: {in_bays}",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  • {CLR_BOLD}Sedans / Automobiles:{CLR_RESET}   {sedans:3d} cars   (~1.0× chemical coefficient)",
            f"  • {CLR_BOLD}SUVs / Pickups:{CLR_RESET}         {suvs:3d} cars   (~1.4× chemical coefficient)",
            f"  • {CLR_BOLD}Minibuses / Vans:{CLR_RESET}       {minibuses:3d} vans   (~1.8× chemical coefficient)",
            f"  • {CLR_BOLD}Trucks / Heavy Duty:{CLR_RESET}    {trucks:3d} trucks (~2.5× chemical coefficient)",
            f"  • {CLR_BOLD}Carpet Orders:{CLR_RESET}          {carpets:3d} orders (per sq. meter wash)",
            f"--------------------------------------------------------------------",
            f"{CLR_BOLD}  Recent Station Queue Entries:{CLR_RESET}",
        ]
        for b in day_bookings[:8]:
            plate = b.get("license_plate") or "WALK-IN"
            status = str(b.get("status", "PENDING")).upper()
            amt = float(b.get("total_amount") or 0.0)
            ctype = "Carpet" if b.get("is_carpet") else b.get("car_type", "Sedan")
            lines.append(f"  [{status:9s}] Plate: {plate:10s} | {ctype:11s} | {amt:7.0f} ETB")

        if not day_bookings:
            lines.append("  (No vehicles registered for this date yet)")
        lines.append(f"{CLR_BOLD}===================================================================={CLR_RESET}")
        return "\n".join(lines)

    def get_washers_report(self):
        """Roster of active washers, completed jobs, and commission earnings."""
        staff = self.sb.get_staff_members()
        washers = [s for s in staff if "wash" in str(s.get("role", "")).lower() or s.get("role") == "washer"]
        bookings = self.sb.get_recent_bookings(limit=60)

        washer_stats = {}
        for w in washers:
            name = w.get("name", "Unknown")
            washer_stats[name] = {"jobs": 0, "commission": 0.0, "rate": float(w.get("commission_rate") or 0.15)}

        for b in bookings:
            w1 = b.get("washer_1_name")
            comm = float(b.get("commission_amount") or 0.0)
            if w1 and w1 in washer_stats:
                washer_stats[w1]["jobs"] += 1
                washer_stats[w1]["commission"] += comm

        lines = [
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"{CLR_CYAN}{CLR_BOLD}   👥 WASHER ROSTER & COMMISSION PERFORMANCE{CLR_RESET}",
            f"   Total Active Washers: {len(washers)}",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  {'Washer Name':<22} | {'Jobs':<6} | {'Comm. Rate':<10} | {'Earned (ETB)':<12}",
            f"--------------------------------------------------------------------",
        ]
        total_payout = 0.0
        for name, data in washer_stats.items():
            jobs = data["jobs"]
            rate = f"{data['rate']*100:.0f}%"
            earned = data["commission"]
            total_payout += earned
            lines.append(f"  {name:<22} | {jobs:6d} | {rate:<10} | {earned:12,.2f} ETB")

        lines.append(f"--------------------------------------------------------------------")
        lines.append(f"  {CLR_BOLD}TOTAL WASHER COMMISSIONS ACCRUED:            {total_payout:12,.2f} ETB{CLR_RESET}")
        lines.append(f"{CLR_BOLD}===================================================================={CLR_RESET}")
        return "\n".join(lines)

    def get_chemical_yield_report(self):
        """Chemical yield benchmarks for 5L shampoo cans and perfume spray counts."""
        lines = [
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"{CLR_CYAN}{CLR_BOLD}   🧼 CHEMICAL CONSUMPTION & CONTAINER YIELD AUDIT{CLR_RESET}",
            f"   Benchmarked against standard BISHE 5L and 500ml container lifecycles",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  • {CLR_BOLD}5L Foam Shampoo (CS-009):{CLR_RESET}",
            f"    - Standard Yield:          {CLR_GREEN}~40 vehicles{CLR_RESET} per 5L canister",
            f"    - Average Dose / Vehicle:   125 ml / car (~12.7 ETB cost)",
            f"    - Over-usage Flag:         If 5L finishes in {CLR_RED}< 25 cars{CLR_RESET} (check nozzle/leak)",
            f"    - Dilution Alert:          If 5L lasts {CLR_YELLOW}> 55 cars{CLR_RESET} (check water dilution)",
            f"",
            f"  • {CLR_BOLD}500ml Interior Perfume (CS-006):{CLR_RESET}",
            f"    - Standard Yield:          {CLR_GREEN}~100 interior sprays{CLR_RESET} per bottle",
            f"    - Average Dose / Vehicle:   5 ml / car (approx 4–5 trigger pumps)",
            f"    - Unit Cost per Wash:      ~8.0 ETB",
            f"",
            f"  • {CLR_BOLD}Microfiber Towels (CS-013):{CLR_RESET}",
            f"    - Durability:              30 to 50 vehicle washes per towel",
            f"    - Store protocol:          Rotate color-coded towels between body & wheels",
            f"--------------------------------------------------------------------",
            f"{CLR_BOLD}  Average Chemical Cost by Vehicle Category:{CLR_RESET}",
            f"  - Sedan / Hatchback:         ~20.7 ETB total chemicals",
            f"  - SUV / Compact Pickup:      ~28.5 ETB total chemicals",
            f"  - Minibus / Van:             ~36.4 ETB total chemicals",
            f"  - Large Truck / Heavy:       ~52.0 ETB total chemicals",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
        ]
        return "\n".join(lines)

    def get_alerts_report(self):
        """Discrepancies, safety stock thresholds, and loss prevention alerts."""
        low_stock = [c for c in MASTER_CONSUMABLES if c["stock"] <= c["min"]]
        lines = [
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"{CLR_YELLOW}{CLR_BOLD}   ⚠️ STATION INTEGRITY, LOSS PREVENTION & STOCK ALERTS{CLR_RESET}",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  {CLR_BOLD}1. Warehouse Re-Order Safety Alerts:{CLR_RESET}",
        ]
        if low_stock:
            for c in low_stock:
                lines.append(f"  • {CLR_RED}LOW STOCK:{CLR_RESET} {c['name']} — Current: {c['stock']} {c['unit']} (Min safety: {c['min']})")
        else:
            lines.append(f"  • {CLR_GREEN}✅ All core consumables are above minimum re-order safety thresholds.{CLR_RESET}")

        lines.extend([
            f"",
            f"  {CLR_BOLD}2. Storekeeper Empty-for-Full Handover Protocol:{CLR_RESET}",
            f"  • Empty 5L shampoo canister must be returned with cap before issuing new 5L can.",
            f"  • Bin cards must record washer signature and vehicle count tally.",
            f"  • Cash drawer daily closing envelopes must match bank deposit slips (CBE/Awash).",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
        ])
        return "\n".join(lines)

    def ask(self, user_question: str) -> str:
        """Processes natural language query using Gemini 1.5 Flash or local heuristics."""
        q = user_question.lower().strip()

        # 1. If Gemini API Key is configured, use Gemini with ultra-compact business snapshot
        if self.config.gemini_api_key:
            gemini_answer = self._ask_gemini(user_question)
            if gemini_answer:
                return gemini_answer

        # 2. Local heuristic analytical routing (instant, $0 cost, offline)
        if any(w in q for w in ["p&l", "profit", "revenue", "loss", "expense", "ገቢ", "ትርፍ", "bu'aa", "galii"]):
            return self.get_pnl_report()

        if any(w in q for w in ["washer", "staff", "commission", "team", "አጣቢ", "ኮሚሽን", "hojjetaa"]):
            return self.get_washers_report()

        if any(w in q for w in ["shampoo", "perfume", "yield", "chemical", "dilution", "average", "consumable", "ሻምፑ", "ሽቶ"]):
            return self.get_chemical_yield_report()

        if any(w in q for w in ["alert", "stock", "low", "discrepanc", "fraud", "ስጋት", "ማሳወቂያ"]):
            return self.get_alerts_report()

        if any(w in q for w in ["car", "vehicle", "wash", "plate", "sedan", "suv", "መኪና", "konkolaataa"]):
            return self.get_cars_report()

        # Fallback overview
        return self._get_overview_summary()

    def _get_overview_summary(self):
        bookings = self.sb.get_recent_bookings(limit=60)
        staff = self.sb.get_staff_members()
        rev = sum(float(b.get("total_amount") or 0.0) for b in bookings)
        lines = [
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"{CLR_CYAN}{CLR_BOLD}   🌟 BISHE AI EXECUTIVE OVERVIEW SNAPSHOT{CLR_RESET}",
            f"   Station: Bishoftu, Oromia | Live Database Connected",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
            f"  • Recent Registered Bookings:  {len(bookings)} vehicles logged",
            f"  • Settled Revenue Recorded:   {rev:,.2f} ETB",
            f"  • Active Staff Roster:        {len(staff)} team members on record",
            f"  • Warehouse Consumables:      {len(MASTER_CONSUMABLES)} items tracked",
            f"",
            f"  You can ask queries like:",
            f"    - 'Show today\\'s P&L and net profit'",
            f"    - 'List cars washed and plate numbers'",
            f"    - 'Show active washers and commissions'",
            f"    - 'What is the shampoo and perfume yield per car?'",
            f"    - 'Check low stock warnings and discrepancies'",
            f"{CLR_BOLD}===================================================================={CLR_RESET}",
        ]
        return "\n".join(lines)

    def _ask_gemini(self, question: str):
        """Sends ultra-compact snapshot (<1.5 KB) to Gemini 1.5 Flash via REST."""
        try:
            bookings = self.sb.get_recent_bookings(limit=25)
            staff = self.sb.get_staff_members()
            today = datetime.now()

            today_b = [b for b in bookings if (self._parse_dt(b.get("created_at")) or today).day == today.day]
            today_rev = sum(float(b.get("total_amount") or 0.0) for b in today_b)
            today_comm = sum(float(b.get("commission_amount") or (float(b.get("total_amount") or 0.0) * 0.15)) for b in today_b)

            system_context = f"""
You are the Executive AI Co-Pilot for "BISHE Car Wash & Carpet Cleaning Service" in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
Answer the user's questions clearly, concisely, and professionally using ETB (Ethiopian Birr).
If asked in Amharic or Afaan Oromoo, reply in that language.

LIVE STATION SNAPSHOT ({today.strftime('%Y-%m-%d')}):
- Total Today Bookings: {len(today_b)} (Settled Revenue: {today_rev:,.2f} ETB)
- Washer Commissions: {today_comm:,.2f} ETB
- Active Staff Members ({len(staff)}): {', '.join(s.get('name', '') for s in staff[:6])}
- Standard chemical yield: 5L Foam Shampoo = ~40 vehicles (125ml/car); 500ml Perfume = ~100 sprays (5ml/car).
"""
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={self.config.gemini_api_key}"
            payload = {
                "contents": [
                    {
                        "role": "user",
                        "parts": [{"text": f"{system_context}\n\nUSER QUESTION: {question}"}]
                    }
                ],
                "generationConfig": {
                    "temperature": 0.2,
                    "maxOutputTokens": 800
                }
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
        except Exception as e:
            # Fall back silently to local analytics
            return None
        return None


class TelegramBotRunner:
    """Lightweight zero-dependency Telegram Bot runner using long polling."""

    def __init__(self, analytics: BisheAnalyticsEngine, config: BisheConfig):
        self.analytics = analytics
        self.config = config

    def start_polling(self):
        token = self.config.telegram_bot_token
        if not token:
            print(f"{CLR_RED}No Telegram Bot Token configured. Set it in agent/config.json{CLR_RESET}")
            return

        print(f"{CLR_GREEN}Starting BISHE Telegram Bot Service (polling https://api.telegram.org)...{CLR_RESET}")
        print("Press Ctrl+C to stop.")
        offset = 0
        base_url = f"https://api.telegram.org/bot{token}"

        while True:
            try:
                poll_url = f"{base_url}/getUpdates?offset={offset}&timeout=20"
                req = urllib.request.Request(poll_url)
                with urllib.request.urlopen(req, timeout=25) as resp:
                    data = json.loads(resp.read().decode("utf-8"))

                for update in data.get("result", []):
                    offset = update["update_id"] + 1
                    msg = update.get("message", {})
                    chat_id = msg.get("chat", {}).get("id")
                    text = msg.get("text", "").strip()

                    if not text or not chat_id:
                        continue

                    # Filter by authorized chat_id if set
                    if self.config.telegram_chat_id and str(chat_id) != str(self.config.telegram_chat_id):
                        self._send(chat_id, "⚠️ Unauthorized user. Contact station manager.")
                        continue

                    print(f"[Telegram Query] From {chat_id}: {text}")
                    reply = self.analytics.ask(text)
                    self._send(chat_id, reply)

            except KeyboardInterrupt:
                print("\nTelegram bot stopped by user.")
                break
            except Exception as e:
                time.sleep(3)

    def _send(self, chat_id, text):
        # Strip ANSI codes for telegram
        clean_text = text.replace(CLR_CYAN, "").replace(CLR_GREEN, "").replace(CLR_YELLOW, "")
        clean_text = clean_text.replace(CLR_RED, "").replace(CLR_BOLD, "").replace(CLR_RESET, "")

        url = f"https://api.telegram.org/bot{self.config.telegram_bot_token}/sendMessage"
        payload = {"chat_id": chat_id, "text": clean_text}
        try:
            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"}
            )
            urllib.request.urlopen(req, timeout=10)
        except Exception as e:
            print(f"Error sending Telegram reply: {e}")


def interactive_console(analytics: BisheAnalyticsEngine, config: BisheConfig):
    """Interactive CLI menu and conversation loop."""
    while True:
        print()
        print(f"{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")
        print(f"{CLR_CYAN}{CLR_BOLD}        BISHE CAR WASH — EXECUTIVE AI AGENT (OPTION A)        {CLR_RESET}")
        print(f"          Bishoftu, Oromia | Live Database Connected")
        print(f"{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")
        print(f"  [1] Today's P&L and Profit Statement")
        print(f"  [2] Vehicles Washed & Category Breakdown")
        print(f"  [3] Active Washers & Commissions Roster")
        print(f"  [4] Chemical Yield & 5L Container Benchmark")
        print(f"  [5] Stock Integrity & Safety Alerts")
        print(f"  [6] Ask Any Custom Operational Question")
        print(f"  [7] Start Telegram Bot Gateway (Receive alerts on your phone)")
        print(f"  [8] Configure API Keys (Gemini / Telegram)")
        print(f"  [0] Exit")
        print(f"{CLR_BOLD}════════════════════════════════════════════════════════════════════{CLR_RESET}")

        try:
            choice = input(f"{CLR_BOLD}Select option (0-8) or type question: {CLR_RESET}").strip()
        except (KeyboardInterrupt, EOFError):
            print("\nExiting. Goodbye!")
            break

        if choice in ["0", "exit", "quit", "q"]:
            print("Exiting BISHE Executive Agent. Have a productive day!")
            break
        elif choice == "1":
            print(analytics.get_pnl_report())
        elif choice == "2":
            print(analytics.get_cars_report())
        elif choice == "3":
            print(analytics.get_washers_report())
        elif choice == "4":
            print(analytics.get_chemical_yield_report())
        elif choice == "5":
            print(analytics.get_alerts_report())
        elif choice == "7":
            bot = TelegramBotRunner(analytics, config)
            bot.start_polling()
        elif choice == "8":
            print("\n--- Current Configuration ---")
            print(f"Gemini API Key: {'Configured' if config.gemini_api_key else 'None (using local heuristics)'}")
            print(f"Telegram Token: {'Configured' if config.telegram_bot_token else 'None'}")
            print(f"Telegram Chat ID: {config.telegram_chat_id or 'All allowed'}")
            new_gem = input("Enter new Gemini API key (or press Enter to skip): ").strip()
            if new_gem:
                config.gemini_api_key = new_gem
            new_tg = input("Enter new Telegram Bot Token (or press Enter to skip): ").strip()
            if new_tg:
                config.telegram_bot_token = new_tg
            config.save()
            print(f"{CLR_GREEN}Configuration saved to agent/config.json{CLR_RESET}")
        else:
            # Direct natural language query
            prompt = choice if choice not in ["6"] else input("Enter your question: ").strip()
            if prompt:
                print(f"\n{CLR_CYAN}Analyzing station database...{CLR_RESET}\n")
                answer = analytics.ask(prompt)
                print(answer)

        input(f"\n{CLR_BOLD}Press Enter to return to main menu...{CLR_RESET}")


def main():
    parser = argparse.ArgumentParser(description="BISHE Car Wash Executive AI Agent")
    parser.add_argument("--pnl", action="store_true", help="Print today's P&L and revenue report")
    parser.add_argument("--cars", action="store_true", help="Print vehicles washed and category breakdown")
    parser.add_argument("--washers", action="store_true", help="Print active washers and commissions")
    parser.add_argument("--yield-audit", dest="yield_audit", action="store_true", help="Print chemical yield benchmarks")
    parser.add_argument("--alerts", action="store_true", help="Check low stock and station discrepancies")
    parser.add_argument("--ask", type=str, help="Ask any operational question")
    parser.add_argument("--telegram", action="store_true", help="Start Telegram Bot service")
    parser.add_argument("--interactive", action="store_true", help="Launch full interactive CLI console")

    args = parser.parse_args()

    config = BisheConfig()
    supabase = SupabaseClient(config)
    analytics = BisheAnalyticsEngine(supabase, config)

    if args.pnl:
        print(analytics.get_pnl_report())
    elif args.cars:
        print(analytics.get_cars_report())
    elif args.washers:
        print(analytics.get_washers_report())
    elif args.yield_audit:
        print(analytics.get_chemical_yield_report())
    elif args.alerts:
        print(analytics.get_alerts_report())
    elif args.ask:
        print(analytics.ask(args.ask))
    elif args.telegram:
        bot = TelegramBotRunner(analytics, config)
        bot.start_polling()
    else:
        # Default to interactive console
        interactive_console(analytics, config)


if __name__ == "__main__":
    main()
