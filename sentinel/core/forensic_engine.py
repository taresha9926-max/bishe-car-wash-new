"""
BISHE Super AI Sentinel — Station Forensic Engine
Grounded in BISHE_OPERATIONS_MANUAL.md
Analyzes station events, verifies physical ground truths, and flags theft & operational discrepancies.
"""

import json
from datetime import datetime
from typing import Callable

from sentinel.config import SentinelConfig
from sentinel.storage.db import LocalAuditDB

class ForensicEngine:
    def __init__(self, config: SentinelConfig, db: LocalAuditDB, on_alert: Callable[[dict], None] = None):
        self.config = config
        self.db = db
        self.on_alert = on_alert

    def analyze_event(self, event: dict) -> list[dict]:
        """Runs the event through all ground-truth audit rules and returns detected anomalies."""
        anomalies = []
        table = event.get("table_name")
        action = event.get("action")
        old_rec = event.get("old_record") or {}
        new_rec = event.get("new_record") or {}
        actor = event.get("actor_name") or "Unknown Actor"

        if isinstance(old_rec, str):
            try:
                old_rec = json.loads(old_rec)
            except Exception:
                old_rec = {}
        if isinstance(new_rec, str):
            try:
                new_rec = json.loads(new_rec)
            except Exception:
                new_rec = {}

        # ---------------------------------------------------------------------
        # 1. WASH BOOKINGS FORENSICS
        # ---------------------------------------------------------------------
        if table == "wash_bookings":
            # Rule 1A: Vehicle Downgrade After Wash Started or Paid (Theft Signature)
            if action == "UPDATE":
                old_type = str(old_rec.get("car_type", "")).lower()
                new_type = str(new_rec.get("car_type", "")).lower()
                is_settled = old_rec.get("is_paid") or old_rec.get("status") in ["washing", "drying", "completed"]

                if old_type in ["minibus", "truck", "suv", "pickup", "medium", "heavy"] and new_type in ["automobile", "small", "sedan"]:
                    if is_settled:
                        anomalies.append({
                            "event_id": event.get("id"),
                            "category": "VEHICLE_CLASSIFICATION_FRAUD",
                            "severity": "CRITICAL_THEFT",
                            "actor_name": actor,
                            "description": f"Vehicle category downgraded from '{old_type}' to '{new_type}' on active/settled ticket #{new_rec.get('id', '')[:8]}.",
                            "details": {
                                "old_type": old_type,
                                "new_type": new_type,
                                "plate": new_rec.get("license_plate"),
                                "total_amount": new_rec.get("total_amount"),
                                "reason": "Potential cash skimming: customer billed for SUV/Truck, but recorded as sedan to pocket difference."
                            }
                        })

                # Rule 1B: Post-Payment Price Reduction
                old_amt = float(old_rec.get("total_amount") or 0.0)
                new_amt = float(new_rec.get("total_amount") or 0.0)
                if old_amt > new_amt and (old_rec.get("is_paid") or old_rec.get("status") == "completed"):
                    diff = old_amt - new_amt
                    anomalies.append({
                        "event_id": event.get("id"),
                        "category": "POST_PAYMENT_PRICE_REDUCTION",
                        "severity": "CRITICAL_THEFT",
                        "actor_name": actor,
                        "description": f"Settled booking amount reduced from {old_amt:,.2f} ETB to {new_amt:,.2f} ETB (-{diff:,.2f} ETB discrepancy).",
                        "details": {
                            "old_amount": old_amt,
                            "new_amount": new_amt,
                            "diff": diff,
                            "plate": new_rec.get("license_plate")
                        }
                    })

                # Rule 1C: Retroactive Ticket Cancellation or Status Reversal
                if old_rec.get("status") == "completed" and new_rec.get("status") in ["pending", "queued", "cancelled"]:
                    anomalies.append({
                        "event_id": event.get("id"),
                        "category": "COMPLETED_TICKET_REVERSAL",
                        "severity": "CRITICAL_THEFT",
                        "actor_name": actor,
                        "description": f"Completed wash ticket #{new_rec.get('id', '')[:8]} retroactively changed back to '{new_rec.get('status')}'.",
                        "details": {
                            "old_status": old_rec.get("status"),
                            "new_status": new_rec.get("status"),
                            "plate": new_rec.get("license_plate"),
                            "amount": new_rec.get("total_amount")
                        }
                    })

            # Rule 1D: Below Minimum Station Tariff (Underbilling)
            if action in ["INSERT", "UPDATE"]:
                ctype = str(new_rec.get("car_type", "")).lower()
                amt = float(new_rec.get("total_amount") or 0.0)
                is_carpet = new_rec.get("is_carpet", False)
                service = str(new_rec.get("service_type", "")).lower()

                if not is_carpet and "shower" not in service:
                    min_price = 300.0
                    if any(t in ctype for t in ["truck", "heavy"]):
                        min_price = 600.0
                    elif any(t in ctype for t in ["minibus", "suv", "pickup"]):
                        min_price = 450.0

                    if amt > 0 and amt < min_price:
                        anomalies.append({
                            "event_id": event.get("id"),
                            "category": "TARIFF_UNDERCUTTING",
                            "severity": "WARNING",
                            "actor_name": actor,
                            "description": f"Service billed at {amt:,.2f} ETB, below the station minimum tariff of {min_price:,.2f} ETB for category '{ctype}'.",
                            "details": {"billed_amount": amt, "min_tariff": min_price, "car_type": ctype}
                        })

            # Rule 1E: 15% Statutory VAT Tampering
            if action in ["INSERT", "UPDATE"]:
                service = str(new_rec.get("service_type", "")).lower()
                is_shower = "shower" in service
                is_vat = new_rec.get("is_vat_applicable", True)
                vat_rate = float(new_rec.get("vat_rate") or 0.15)

                if not is_shower and (not is_vat or vat_rate < 0.15):
                    anomalies.append({
                        "event_id": event.get("id"),
                        "category": "STATUTORY_TAX_VIOLATION",
                        "severity": "WARNING",
                        "actor_name": actor,
                        "description": f"Vehicle wash order #{new_rec.get('id', '')[:8]} billed without required 15% statutory VAT (vat_applicable={is_vat}, rate={vat_rate}).",
                        "details": {"service_type": service, "vat_rate": vat_rate, "is_vat_applicable": is_vat}
                    })

        # ---------------------------------------------------------------------
        # 2. SHIFT HANDOVER & CASH CUSTODY (OTP DUAL CUSTODY)
        # ---------------------------------------------------------------------
        elif table == "cash_handovers":
            if action in ["INSERT", "UPDATE"]:
                gross = float(new_rec.get("gross_cash_collected") or 0.0)
                exp = float(new_rec.get("urgent_expenses_deducted") or 0.0)
                net = float(new_rec.get("net_cash_handed_over") or 0.0)

                # Check math balance
                if round(gross - exp, 2) != round(net, 2):
                    anomalies.append({
                        "event_id": event.get("id"),
                        "category": "HANDOVER_ARITHMETIC_MISMATCH",
                        "severity": "CRITICAL_THEFT",
                        "actor_name": actor,
                        "description": f"Handover calculation discrepancy: Gross ({gross:,.2f}) - OpEx ({exp:,.2f}) != Net Cash ({net:,.2f} ETB). Discrepancy: {gross - exp - net:,.2f} ETB.",
                        "details": {"gross": gross, "expenses": exp, "net": net}
                    })

                # Check excessive expenses
                if exp > 2500.0:
                    anomalies.append({
                        "event_id": event.get("id"),
                        "category": "HIGH_PETTY_CASH_DEDUCTION",
                        "severity": "WARNING",
                        "actor_name": actor,
                        "description": f"High petty cash expense ({exp:,.2f} ETB) claimed during shift handover.",
                        "details": {"claimed_expenses": exp, "gross_collected": gross}
                    })

        # ---------------------------------------------------------------------
        # 3. STAFF COMMISSIONS INTEGRITY (2% to 25% boundary)
        # ---------------------------------------------------------------------
        elif table == "staff_members":
            if action in ["INSERT", "UPDATE"]:
                rate = float(new_rec.get("commission_rate") or 0.15)
                if rate < self.config.min_commission_rate or rate > self.config.max_commission_rate:
                    anomalies.append({
                        "event_id": event.get("id"),
                        "category": "UNAUTHORIZED_COMMISSION_OVERRIDE",
                        "severity": "WARNING",
                        "actor_name": actor,
                        "description": f"Staff member '{new_rec.get('name')}' commission rate modified to {rate*100:.1f}% (Station policy allows strictly 2% to 25%).",
                        "details": {"staff_name": new_rec.get("name"), "rate": rate}
                    })

        # Save anomalies to SQLite and dispatch alert callbacks
        for anom in anomalies:
            anom_id = self.db.insert_anomaly(anom)
            anom["id"] = anom_id
            if self.on_alert:
                try:
                    self.on_alert(anom)
                except Exception as e:
                    print(f"[ForensicEngine] Alert dispatch error: {e}")

        return anomalies
