"""
BISHE Super AI Sentinel — Master Configuration & Station Ground Truth
Location: Bishoftu (Debre Zeyit), Oromia, Ethiopia
Authoritative Grounding: BISHE_OPERATIONS_MANUAL.md
"""

import os
import json

class SentinelConfig:
    def __init__(self, config_path=None):
        if not config_path:
            # Look in multiple candidate locations
            candidates = [
                os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json"),
                os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "agent", "config.json"),
                os.path.join(os.getcwd(), "agent", "config.json"),
                os.path.join(os.getcwd(), "sentinel", "config.json"),
            ]
            for p in candidates:
                if os.path.exists(p):
                    config_path = p
                    break
            if not config_path:
                config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")

        self.config_path = config_path

        # Live Supabase Production Configuration
        self.supabase_url = "https://siioobajphmwzwwarlrr.supabase.co"
        self.supabase_anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpaW9vYmFqcGhtd3p3d2FybHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1OTA3MjksImV4cCI6MjEwODE2NjcyOX0.7ilkYS4N8m_b-uy3ExxnE-SJidumg-Zk8hkHP8CgD4U"
        self.supabase_service_role_key = ""

        # AI & Telegram Channels (loaded from config.json or environment)
        self.gemini_api_key = ""
        self.telegram_bot_token = ""
        self.telegram_chat_id = ""

        # Sentinel Daemon Parameters
        self.sync_interval_seconds = 60
        self.sync_batch_limit = 50
        self.web_port = 8088

        # Ground Truth Operational Benchmarks (BISHE_OPERATIONS_MANUAL.md)
        self.vat_rate = 0.15
        self.default_washer_commission = 0.15
        self.min_commission_rate = 0.02
        self.max_commission_rate = 0.25

        # EVU Multipliers
        self.evu_multipliers = {
            "automobile": 1.0,
            "sedan": 1.0,
            "small": 1.0,
            "suv": 1.4,
            "pickup": 1.4,
            "minibus": 1.8,
            "van": 1.8,
            "truck": 2.5,
            "heavy": 2.5,
        }

        # Minimum Base Tariffs (ETB)
        self.min_tariffs = {
            "automobile": 300.0,
            "minibus": 450.0,
            "truck": 600.0,
            "carpet_m2": 80.0,
        }

        # Consumable Yield Benchmarks
        self.foam_shampoo_yield_standard = 40.0   # 40 EVU cars per 5L (125 ml/EVU)
        self.foam_shampoo_yield_min = 25.0        # < 25 indicates leakage or overuse
        self.foam_shampoo_yield_max = 55.0        # > 55 indicates under-dilution
        self.perfume_yield_standard = 100.0       # 100 sprays per 500ml (5 ml/interior)

        self.load()

    def load(self):
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self.supabase_url = data.get("supabase_url", self.supabase_url)
                    self.supabase_anon_key = data.get("supabase_anon_key", self.supabase_anon_key)
                    self.supabase_service_role_key = data.get("supabase_service_role_key", self.supabase_service_role_key)
                    self.gemini_api_key = data.get("gemini_api_key", self.gemini_api_key)
                    self.telegram_bot_token = data.get("telegram_bot_token", self.telegram_bot_token)
                    self.telegram_chat_id = data.get("telegram_chat_id", self.telegram_chat_id)
                    self.web_port = data.get("web_port", self.web_port)
            except Exception as e:
                print(f"[SentinelConfig] Notice loading config: {e}")

        # Environment variable overrides
        self.supabase_url = os.environ.get("SUPABASE_URL", self.supabase_url)
        self.supabase_anon_key = os.environ.get("SUPABASE_ANON_KEY", self.supabase_anon_key)
        self.supabase_service_role_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", self.supabase_service_role_key)
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
                    "supabase_service_role_key": self.supabase_service_role_key,
                    "gemini_api_key": self.gemini_api_key,
                    "telegram_bot_token": self.telegram_bot_token,
                    "telegram_chat_id": self.telegram_chat_id,
                    "web_port": self.web_port,
                }, f, indent=2)
        except Exception as e:
            print(f"[SentinelConfig] Error saving config: {e}")
