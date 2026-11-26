import urllib.request
import urllib.error
import json
import os
import sys
from datetime import datetime, timezone

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 'agent', 'config.json')
with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
    config = json.load(f)

SUPABASE_URL = config['supabase_url']
SUPABASE_KEY = config['supabase_anon_key']

TIMESTAMP = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
BACKUP_DIR = os.path.join(os.path.dirname(__file__), '..', 'backups', f'supabase_live_backup_{TIMESTAMP}')
os.makedirs(BACKUP_DIR, exist_ok=True)

TABLES_TO_EXPORT = [
    'wash_bookings',
    'daily_closings',
    'commission_logs',
    'staff_credentials',
    'station_bays',
    'wash_packages',
    'bank_incoming_transactions',
    'sentinel_audit_ledger'
]

HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': f"Bearer {SUPABASE_KEY}"
}

print(f"=== Starting Live Supabase Full Database Backup to: {BACKUP_DIR} ===")

manifest = {
    "timestamp": TIMESTAMP,
    "supabase_url": SUPABASE_URL,
    "tables": {}
}

total_records = 0

for table in TABLES_TO_EXPORT:
    url = f"{SUPABASE_URL}/rest/v1/{table}?select=*"
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            out_path = os.path.join(BACKUP_DIR, f"{table}.json")
            with open(out_path, 'w', encoding='utf-8') as out_f:
                json.dump(data, out_f, indent=2, ensure_ascii=False)
            
            row_count = len(data)
            total_records += row_count
            manifest["tables"][table] = {
                "count": row_count,
                "file": f"{table}.json",
                "bytes": os.path.getsize(out_path)
            }
            print(f"  ✓ Exported '{table}': {row_count} records ({os.path.getsize(out_path):,} bytes)")
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode('utf-8')
        print(f"  ✗ Failed to export '{table}': HTTP {e.code} - {err_msg}")
        manifest["tables"][table] = {"error": f"HTTP {e.code}: {err_msg}"}

manifest_path = os.path.join(BACKUP_DIR, "manifest.json")
with open(manifest_path, 'w', encoding='utf-8') as mf:
    json.dump(manifest, mf, indent=2)

print(f"\n=== Full Database Backup Complete: {total_records} records saved across {len(TABLES_TO_EXPORT)} tables. ===")
print(f"Backup Location: {os.path.abspath(BACKUP_DIR)}")
