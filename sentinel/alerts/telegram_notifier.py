"""
BISHE Super AI Sentinel — Encrypted Telegram Push Notifier
Delivers instant forensic alerts and evening closing executive briefings to your phone.
"""

import json
import urllib.request
import urllib.parse
from datetime import datetime

from sentinel.config import SentinelConfig

class TelegramNotifier:
    def __init__(self, config: SentinelConfig):
        self.config = config

    def is_configured(self) -> bool:
        return bool(self.config.telegram_bot_token and self.config.telegram_chat_id)

    def send_message(self, text: str) -> bool:
        if not self.is_configured():
            return False

        url = f"https://api.telegram.org/bot{self.config.telegram_bot_token}/sendMessage"
        payload = {
            "chat_id": self.config.telegram_chat_id,
            "text": text,
            "parse_mode": "HTML"
        }

        try:
            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                return resp.status == 200
        except Exception as e:
            print(f"[TelegramNotifier] Error sending Telegram message: {e}")
            return False

    def send_anomaly_alert(self, anomaly: dict):
        severity = anomaly.get("severity", "WARNING")
        icon = "🚨" if severity == "CRITICAL_THEFT" else "⚠️"
        actor = anomaly.get("actor_name", "Unknown")
        category = anomaly.get("category", "FORENSIC_DISCREPANCY")
        desc = anomaly.get("description", "")
        time_str = datetime.now().strftime("%H:%M:%S")

        msg = (
            f"<b>{icon} BISHE SENTINEL AUDIT ALERT</b>\n"
            f"<b>Time:</b> {time_str} | <b>Level:</b> {severity}\n"
            f"<b>Actor:</b> <code>{actor}</code>\n"
            f"<b>Category:</b> {category}\n"
            f"<b>Event:</b> {desc}\n"
        )

        details = anomaly.get("details")
        if details and isinstance(details, dict):
            msg += "\n<b>Forensic Details:</b>\n"
            for k, v in details.items():
                msg += f"• <i>{k}</i>: {v}\n"

        self.send_message(msg)

    def send_closing_briefing(self, closing: dict):
        summary = closing.get("audit_summary", "")
        msg = f"📊 <b>BISHE EXECUTIVE SHIFT BRIEFING</b>\n\n<pre>{summary}</pre>"
        self.send_message(msg)

    def send_wakeup_digest(self, missed_count: int, anomaly_count: int):
        msg = (
            f"🔄 <b>SENTINEL RECONNECTED</b>\n"
            f"Laptop resumed active monitoring.\n"
            f"• Backlog Events Audited: {missed_count}\n"
            f"• New Anomalies Detected: {anomaly_count}\n"
        )
        self.send_message(msg)
