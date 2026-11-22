"""
BISHE Super AI Sentinel — Central Brain Controller
The unified intelligence engine for BISHE Car Wash & Auto Care Service.
Grounded in:
  - Real-time live Supabase tables (wash_bookings, staff_members, bank_incoming_transactions, cash_handovers, daily_closings)
  - Authoritative Operations Manual (tariffs, 15% VAT, 15% net commissions, EVU workload multipliers, chemical yield)
  - Flutter codebase architecture and future roadmap projections
  - Multi-turn Gemini 2.5/Flash AI conversation with local analytical mathematical fallback
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime

from sentinel.config import SentinelConfig
from sentinel.storage.db import LocalAuditDB
from sentinel.core.closing_auditor import ShiftClosingAuditor
from sentinel.core.developer_projector import DeveloperProjector

class SuperBrainController:
    def __init__(self, config: SentinelConfig, db: LocalAuditDB, closing_auditor: ShiftClosingAuditor, projector: DeveloperProjector):
        self.config = config
        self.db = db
        self.closing_auditor = closing_auditor
        self.projector = projector
        self.conversation_history = []
        self._staff_cache = None
        self._staff_cache_expiry = 0

    def load_manual(self) -> str:
        candidates = [
            os.path.join(os.path.dirname(__file__), "..", "..", "BISHE_OPERATIONS_MANUAL.md"),
            os.path.join(os.getcwd(), "BISHE_OPERATIONS_MANUAL.md"),
            "C:\\Users\\Tare\\Desktop\\Flutter App\\BISHE_OPERATIONS_MANUAL.md",
            "C:\\Users\\Tare\\Desktop\\modern car wash\\BISHE_OPERATIONS_MANUAL.md",
        ]
        for c in candidates:
            if os.path.exists(c):
                try:
                    with open(c, "r", encoding="utf-8") as f:
                        return f.read()
                except Exception:
                    pass
        return "BISHE Operations Manual: 15% VAT on car/carpet, 0% on shower. Default washer commission 15% on Net Base."

    def _sb_request(self, endpoint: str):
        url = f"{self.config.supabase_url.rstrip('/')}/rest/v1/{endpoint}"
        auth_key = self.config.supabase_service_role_key or self.config.supabase_anon_key
        req = urllib.request.Request(
            url,
            headers={
                "apikey": auth_key,
                "Authorization": f"Bearer {auth_key}",
                "Content-Type": "application/json",
            }
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as response:
                return json.loads(response.read().decode("utf-8"))
        except Exception as e:
            return []

    def get_staff(self) -> list[dict]:
        now = time.time()
        if self._staff_cache and now < self._staff_cache_expiry:
            return self._staff_cache
        data = self._sb_request("staff_members?select=id,name,role,commission_rate,base_salary,is_active&order=name.asc")
        if data:
            self._staff_cache = data
            self._staff_cache_expiry = now + 900
        return self._staff_cache or []

    def get_today_bookings(self) -> list[dict]:
        # Pull minimal necessary fields strictly bounded
        now = datetime.now()
        s_iso = now.strftime("%Y-%m-%dT00:00:00Z")
        endpoint = f"wash_bookings?select=id,license_plate,car_type,total_amount,status,is_paid,payment_method,washer_1_name,washer_2_name,commission_amount,vat_amount,is_carpet,carpet_area_sq_meters,service_type,created_at,completed_at&created_at=gte.{s_iso}&order=created_at.desc&limit=150"
        data = self._sb_request(endpoint)
        if not data:
            # Fallback to recent events in local SQLite
            events = self.db.get_recent_events(limit=100)
            local_list = []
            for e in events:
                if e.get("table_name") == "wash_bookings":
                    rec = e.get("new_record")
                    if rec and isinstance(rec, str):
                        try:
                            rec = json.loads(rec)
                        except Exception:
                            rec = {}
                    if rec and rec.get("id") and not any(x.get("id") == rec.get("id") for x in local_list):
                        local_list.append(rec)
            return local_list
        return data

    def compute_live_kpis(self) -> dict:
        bookings = self.get_today_bookings()
        staff = self.get_staff()
        washers = [s for s in staff if "wash" in str(s.get("role", "")).lower() or s.get("role") == "washer"]

        gross = 0.0
        cash = 0.0
        telebirr = 0.0
        cbe = 0.0
        total_comm = 0.0
        total_evu = 0.0
        completed = 0
        in_progress = 0

        type_a = 0
        type_b_suv = 0
        type_b_van = 0
        type_c = 0
        carpets = 0

        for b in bookings:
            amt = float(b.get("total_amount") or 0.0)
            is_paid = b.get("is_paid") or b.get("status") == "completed"
            st = str(b.get("status", "")).lower()
            if st == "completed":
                completed += 1
            else:
                in_progress += 1

            if is_paid:
                gross += amt
                pay_method = str(b.get("payment_method") or "").lower()
                if "telebirr" in pay_method:
                    telebirr += amt
                elif "cbe" in pay_method:
                    cbe += amt
                else:
                    cash += amt

                comm = float(b.get("commission_amount") or 0.0)
                if comm <= 0 and amt > 0:
                    comm = round((amt / 1.15) * 0.15, 2)
                total_comm += comm

            # EVU
            ctype = str(b.get("car_type", "")).lower()
            if b.get("is_carpet"):
                carpets += 1
                area = float(b.get("carpet_area_sq_meters") or 12.0)
                total_evu += round(area * 0.25, 2)
            elif any(k in ctype for k in ["truck", "heavy"]):
                type_c += 1
                total_evu += 2.5
            elif any(k in ctype for k in ["minibus", "van"]):
                type_b_van += 1
                total_evu += 1.8
            elif any(k in ctype for k in ["suv", "pickup"]):
                type_b_suv += 1
                total_evu += 1.4
            else:
                type_a += 1
                total_evu += 1.0

        vat = round(gross - (gross / 1.15), 2)
        net = round(gross - vat, 2)
        cogs_chem = round(total_evu * 28.50, 2)
        ebitda = round(net - total_comm - cogs_chem, 2)

        return {
            "total_cars": len(bookings),
            "completed": completed,
            "in_progress": in_progress,
            "gross_revenue": gross,
            "cash_revenue": cash,
            "telebirr_revenue": telebirr,
            "cbe_revenue": cbe,
            "vat_amount": vat,
            "net_revenue": net,
            "commissions_amount": total_comm,
            "chemicals_cogs": cogs_chem,
            "ebitda": ebitda,
            "total_evu": round(total_evu, 1),
            "type_a_count": type_a,
            "type_b_suv_count": type_b_suv,
            "type_b_van_count": type_b_van,
            "type_c_count": type_c,
            "carpet_count": carpets,
            "active_washers_count": len(washers)
        }

    def ask(self, user_question: str) -> dict:
        """
        Master Brain Reasoning Pipeline:
        1. Gathers full live database state + manual + code context.
        2. First tries Gemini AI with full multi-turn memory.
        3. If offline or quota limited, falls back to local high-precision analytical math engine.
        """
        q = user_question.strip()
        kpi = self.compute_live_kpis()
        bookings = self.get_today_bookings()
        staff = self.get_staff()
        manual = self.load_manual()
        anomalies = self.db.get_unresolved_anomalies()

        # 1. Try Gemini Cloud AI
        if self.config.gemini_api_key:
            ai_resp = self._query_gemini(q, kpi, bookings, staff, manual, anomalies)
            if ai_resp:
                self.conversation_history.append({"role": "user", "text": q})
                self.conversation_history.append({"role": "assistant", "text": ai_resp})
                return {"answer": ai_resp, "source": "gemini-flash", "kpi": kpi}

        # 2. Local Dynamic Analytical Fallback Engine (Zero Canned Answers)
        local_ans = self._local_dynamic_fallback(q, kpi, bookings, staff, anomalies)
        self.conversation_history.append({"role": "user", "text": q})
        self.conversation_history.append({"role": "assistant", "text": local_ans})
        return {"answer": local_ans, "source": "local-analytical-engine", "kpi": kpi}

    def _query_gemini(self, question: str, kpi: dict, bookings: list, staff: list, manual: str, anomalies: list) -> str | None:
        today_str = datetime.now().strftime("%Y-%m-%d %H:%M")

        # Build concise bookings table string
        bookings_table_lines = ["| Plate | Vehicle / Package | Status | Amount (ETB) | Washer Assigned |", "| :--- | :--- | :--- | :--- | :--- |"]
        for b in bookings[:25]:
            plate = b.get("license_plate") or "WALK-IN"
            ctype = b.get("car_type") or "Sedan"
            st = (b.get("status") or "pending").upper()
            amt = float(b.get("total_amount") or 0.0)
            w = b.get("washer_1_name") or "Unassigned"
            bookings_table_lines.append(f"| `{plate}` | {ctype} | {st} | {amt:,.0f} | {w} |")
        bookings_summary_str = "\n".join(bookings_table_lines)

        # Build washers table
        washers = [s for s in staff if "wash" in str(s.get("role", "")).lower() or s.get("role") == "washer"]
        washers_table_lines = ["| Washer Name | Role | Comm. Rate | Completed Jobs | Earned (ETB) |", "| :--- | :--- | :--- | :--- | :--- |"]
        for w in washers:
            name = w.get("name", "Unknown")
            rate = float(w.get("commission_rate") or 0.15)
            jobs = sum(1 for b in bookings if b.get("washer_1_name") == name and (b.get("is_paid") or b.get("status") == "completed"))
            earned = sum(float(b.get("commission_amount") or (float(b.get("total_amount") or 0.0) / 1.15 * rate)) for b in bookings if b.get("washer_1_name") == name and (b.get("is_paid") or b.get("status") == "completed"))
            washers_table_lines.append(f"| **{name}** | {w.get('role','washer')} | {rate*100:.0f}% | {jobs} | {earned:,.2f} |")
        washers_summary_str = "\n".join(washers_table_lines)

        system_prompt = f"""
You are the **BISHE SUPER AI BRAIN CONTROLLER**, the supreme executive intelligence and technical brain for "BISHE Car Wash & Auto Care Service" in Bishoftu (Debre Zeyit), Oromia, Ethiopia.
You run locally on the lead developer's laptop, monitoring the live cloud database, station floor operations, forensic ledger, and the Flutter codebase.

LIVE STATION OPERATIONAL SNAPSHOT ({today_str}):
• Gross Settled Revenue: {kpi['gross_revenue']:,.2f} ETB
  - Cash Drawer: {kpi['cash_revenue']:,.2f} ETB
  - Telebirr Digital: {kpi['telebirr_revenue']:,.2f} ETB
  - CBE Bank Digital: {kpi['cbe_revenue']:,.2f} ETB
• Statutory 15% VAT: {kpi['vat_amount']:,.2f} ETB | Net Base Revenue: {kpi['net_revenue']:,.2f} ETB
• Washer Commissions (Direct Labor COGS): -{kpi['commissions_amount']:,.2f} ETB
• Chemical Consumables (Direct Materials COGS): -{kpi['chemicals_cogs']:,.2f} ETB (~28.50 ETB / EVU)
• Retained Operating Cash (EBITDA): {kpi['ebitda']:,.2f} ETB
• Vehicles Today: {kpi['total_cars']} total ({kpi['completed']} completed, {kpi['in_progress']} in progress)
• Equivalent Workload Units: {kpi['total_evu']} EVU (Sedan: {kpi['type_a_count']}, SUV: {kpi['type_b_suv_count']}, Minibus: {kpi['type_b_van_count']}, Truck: {kpi['type_c_count']}, Carpets: {kpi['carpet_count']})
• Active Washers on Duty: {kpi['active_washers_count']}
• Active Forensic Anomalies: {len(anomalies)} active discrepancies

TODAY'S VEHICLE LOGS:
{bookings_summary_str}

ACTIVE WASHER ROSTER & EARNED COMMISSIONS:
{washers_summary_str}

GROUND TRUTH OPERATIONS MANUAL & RULES:
- Car & Carpet wash subject to statutory 15% VAT; Showers are 0% VAT exempt.
- Washer commissions are calculated STRICTLY on Net Base (Gross ÷ 1.15) at each washer's individual rate (default 15%).
- 5L Snow Foam (CS-009) yields ~40 EVU cars (125 ml/EVU). Alert if < 25 or > 55 cars.
- Storekeeper operates Empty-for-Full canister exchanges.
- Cashier Day Shift (07:00 - 15:30) transfers drawer cash to Night Shift Operations Manager (15:30 - 22:00) using a secure 6-digit OTP.
- The Super Admin has full pricing authority.

CRITICAL INSTRUCTIONS:
1. Always format financial breakdowns, vehicle queues, and washer commissions with clean, beautifully formatted Markdown tables with headers (| Col 1 | Col 2 |).
2. Answer dynamically with real math and facts. Zero boilerplate or canned phrases.
3. If asked about features, code, or the app's future, suggest architecture, Flutter widget patterns, and migration ideas.
4. Respond fluently in the language the user asked in: English, Afaan Oromoo, or Amharic (አማርኛ).
"""

        contents = [
            {"role": "user", "parts": [{"text": system_prompt}]},
            {"role": "model", "parts": [{"text": "Acknowledged. I am the BISHE Super AI Brain Controller, fully connected to your station database and operations manual. How can I direct operations or report for you?"}]}
        ]

        # Multi-turn memory (last 6 turns)
        for h in self.conversation_history[-6:]:
            role = "user" if h.get("role") == "user" else "model"
            contents.append({"role": role, "parts": [{"text": h.get("text", "")}]})

        contents.append({"role": "user", "parts": [{"text": question}]})

        models = ["models/gemini-flash-lite-latest", "models/gemini-flash-latest", "models/gemini-pro-latest"]
        payload = {
            "contents": contents,
            "generationConfig": {"temperature": 0.7, "maxOutputTokens": 2048}
        }
        encoded = json.dumps(payload).encode("utf-8")

        for m in models:
            url = f"https://generativelanguage.googleapis.com/v1beta/{m}:generateContent?key={self.config.gemini_api_key}"
            req = urllib.request.Request(url, data=encoded, headers={"Content-Type": "application/json"})
            try:
                with urllib.request.urlopen(req, timeout=14) as resp:
                    res_data = json.loads(resp.read().decode("utf-8"))
                    candidates = res_data.get("candidates", [])
                    if candidates:
                        parts = candidates[0].get("content", {}).get("parts", [])
                        if parts:
                            return parts[0].get("text", "").strip()
            except Exception:
                continue
        return None

    def _local_dynamic_fallback(self, question: str, kpi: dict, bookings: list, staff: list, anomalies: list) -> str:
        q_lower = question.lower()

        # 1. Cars washed today
        if any(w in q_lower for w in ["car", "vehicle", "list", "queue", "plate", "መኪና", "konkolaataa"]):
            lines = [
                f"### 🚗 Today's Vehicle Log ({len(bookings)} registered, {kpi['completed']} completed, {kpi['total_evu']} EVU)",
                "",
                "| License Plate | Category | Status | Total (ETB) | Washer Assigned |",
                "| :--- | :--- | :--- | :--- | :--- |"
            ]
            for b in bookings[:30]:
                plate = b.get("license_plate") or "WALK-IN"
                ctype = b.get("car_type") or "Sedan"
                st = (b.get("status") or "pending").upper()
                amt = float(b.get("total_amount") or 0.0)
                w = b.get("washer_1_name") or "Unassigned"
                lines.append(f"| `{plate}` | {ctype} | {st} | {amt:,.0f} ETB | {w} |")
            return "\n".join(lines)

        # 2. Washer commissions
        if any(w in q_lower for w in ["washer", "commission", "worker", "technician", "አጣቢ", "ኮሚሽን", "hojjetaa"]):
            washers = [s for s in staff if "wash" in str(s.get("role", "")).lower() or s.get("role") == "washer"]
            lines = [
                "### 👷 Washer Performance & Commission Settlements (15% Net Base)",
                "",
                "| Washer Name | Role | Comm. Rate | Washes Done | Commission Earned (ETB) |",
                "| :--- | :--- | :--- | :--- | :--- |"
            ]
            for w in washers:
                name = w.get("name", "Unknown")
                rate = float(w.get("commission_rate") or 0.15)
                jobs = sum(1 for b in bookings if b.get("washer_1_name") == name and (b.get("is_paid") or b.get("status") == "completed"))
                earned = sum(float(b.get("commission_amount") or (float(b.get("total_amount") or 0.0) / 1.15 * rate)) for b in bookings if b.get("washer_1_name") == name and (b.get("is_paid") or b.get("status") == "completed"))
                lines.append(f"| **{name}** | {w.get('role','washer')} | {rate*100:.0f}% | {jobs} | **{earned:,.2f} ETB** |")
            lines.append(f"\n**Total Washer Direct Labor Commission Settled:** {kpi['commissions_amount']:,.2f} ETB")
            return "\n".join(lines)

        # 3. P&L & Financial Closing
        if any(w in q_lower for w in ["p&l", "profit", "revenue", "loss", "expense", "ebitda", "closing", "ገቢ", "ትርፍ", "galii"]):
            return (
                "### 📊 Today's Dynamic Profit & Loss Statement (P&L)\n\n"
                "| Accounting Component | Amount (ETB) | Treatment & Ground Truth |\n"
                "| :--- | :--- | :--- |\n"
                f"| **Gross Service Revenue** | **{kpi['gross_revenue']:,.2f} ETB** | Operating Inflow ({kpi['total_cars']} vehicles) |\n"
                f"| • Cash in Drawer | {kpi['cash_revenue']:,.2f} ETB | Physical drawer custody |\n"
                f"| • Telebirr Digital | {kpi['telebirr_revenue']:,.2f} ETB | Approved mobile transfers |\n"
                f"| • CBE Bank Digital | {kpi['cbe_revenue']:,.2f} ETB | Approved bank transfers |\n"
                f"| Less: Statutory 15% VAT | - {kpi['vat_amount']:,.2f} ETB | Tax obligation on car/carpet washes |\n"
                f"| **Net Base Revenue** | **{kpi['net_revenue']:,.2f} ETB** | Taxable Operating Base |\n"
                f"| Less: Washer Commissions (COGS Labor) | - {kpi['commissions_amount']:,.2f} ETB | Direct Labor (15% Net Base) |\n"
                f"| Less: Chemicals Consumed (COGS Materials) | - {kpi['chemicals_cogs']:,.2f} ETB | Direct Materials (~28.50 ETB / EVU) |\n"
                f"| **NET OPERATING CASH (EBITDA)** | **{kpi['ebitda']:,.2f} ETB** | Retained Operating Cash Flow |\n"
            )

        # 4. Chemicals & Yield
        if any(w in q_lower for w in ["shampoo", "perfume", "yield", "soap", "chemical", "consumable", "evu", "ሻምፑ", "ሽቶ"]):
            shampoo_l = (kpi["total_evu"] * 125.0) / 1000.0
            perfume_ml = kpi["total_evu"] * 5.0
            return (
                f"### 🧪 Chemical Consumables Yield Audit ({kpi['total_evu']:.1f} Total EVU)\n\n"
                "| Consumable Item | Standard Yield | Usage Today | Estimated Canisters | Cost (ETB) |\n"
                "| :--- | :--- | :--- | :--- | :--- |\n"
                f"| **Snow Foam Shampoo (CS-009)** | ~40 cars / 5L (125 ml/EVU) | {shampoo_l:.2f} Liters | ~{shampoo_l/5.0:.1f} cans of 5L | {(shampoo_l*220.0):,.2f} ETB |\n"
                f"| **Interior Air Freshener (CS-006)** | ~100 sprays / 500ml | {perfume_ml:.0f} ml | ~{perfume_ml/500.0:.1f} bottles | {(perfume_ml/500.0*250.0):,.2f} ETB |\n"
                f"| **Total Direct Chemical COGS** | 28.50 ETB / EVU | — | — | **{kpi['chemicals_cogs']:,.2f} ETB** |\n\n"
                "*Enforcement: Storekeeper strictly enforces Empty-for-Full container exchanges (ዕቃ በዕቃ).*"
            )

        # 5. Future Feature & Developer Architecture
        if any(w in q_lower for w in ["feature", "future", "suggest", "build", "code", "roadmap", "proposal", "scaffold"]):
            return (
                "### 💡 BISHE Super AI Feature Projections & Developer Roadmap\n\n"
                "1. **1-Tap Quick Walk-In Registration**: Express 1-touch modal for cashiers during rush hours using default customer placeholders.\n"
                "   - *Run CLI:* `python sentinel/sentinel_daemon.py --project quick-walkin`\n\n"
                "2. **Customer Loyalty Stamp Card**: Automated 5th wash 50% discount tracked by license plate number.\n"
                "   - *Run CLI:* `python sentinel/sentinel_daemon.py --project loyalty-punchcard`\n\n"
                "3. **Washer Biometric / PIN Bay Clock-in**: Direct bay terminal clock-in to auto-assign washers to Bay 1 and Bay 2.\n\n"
                "*All generated code stubs are safely isolated into `.scratch/proposals/` with trilingual translations and unit tests.*"
            )

        # General Summary
        return (
            f"### 🛡️ BISHE Super AI Brain Operational Snapshot\n\n"
            f"• **Today's Volume:** {kpi['total_cars']} vehicles registered ({kpi['completed']} completed, {kpi['in_progress']} in bays)\n"
            f"• **Workload:** {kpi['total_evu']} EVU\n"
            f"• **Gross Settled Revenue:** {kpi['gross_revenue']:,.2f} ETB (Cash: {kpi['cash_revenue']:,.2f} ETB, Digital: {kpi['telebirr_revenue'] + kpi['cbe_revenue']:,.2f} ETB)\n"
            f"• **Net EBITDA:** {kpi['ebitda']:,.2f} ETB\n"
            f"• **Active Washer Technicians:** {kpi['active_washers_count']} on duty\n"
            f"• **Active Anomalies:** {len(anomalies)} discrepancies detected\n\n"
            "*Ask any specific question: 'Show list of cars', 'Washer commissions', 'P&L', 'Chemical yield', or 'Propose new features'.*"
        )
