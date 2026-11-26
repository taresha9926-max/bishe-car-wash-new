import urllib.request
import urllib.error
import json
import os
import sys
import uuid
from datetime import datetime, timedelta, timezone

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 'agent', 'config.json')
with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
    config = json.load(f)

SUPABASE_URL = config['supabase_url']
SUPABASE_KEY = config['supabase_anon_key']
HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': f"Bearer {SUPABASE_KEY}",
    'Content-Type': 'application/json',
    'Prefer': 'resolution=merge-duplicates,return=minimal'
}

LEDGER_PATH = os.path.join(os.path.dirname(__file__), 'historical_master_ledger.json')
with open(LEDGER_PATH, 'r', encoding='utf-8') as f:
    days_data = json.load(f)

NAMESPACE_BISHE = uuid.UUID('6ba7b810-9dad-11d1-80b4-00c04fd430c8')

def classify_car_type(vehicle_str):
    v = vehicle_str.lower()
    if any(k in v for k in ['pickup', 'hilux', 'tucson', 'prado', 'landcruiser', 'land cruiser', 'byd', 'tank', 'fortuner', 'creta', 'suv']):
        return 'suv'
    elif any(k in v for k in ['highroof', 'starex', 'isuzu', 'van', 'abadula', 'dolphin']):
        return 'truck'
    elif 'bajaj' in v or 'ባጃጅ' in v:
        return 'bajaj'
    else:
        return 'automobile'

def parse_time_to_minutes(time_str):
    if not time_str or time_str.strip() in ['—', '-', '']:
        return None
    try:
        parts = time_str.strip().split(':')
        h = int(parts[0])
        m = int(parts[1]) if len(parts) > 1 else 0
        # Ethiopian local daytime: 1 is 7 AM, ..., 12 is 6 PM
        standard_h = (h + 6) % 24
        return standard_h * 60 + m
    except Exception:
        return None

def compute_timestamps(date_str, start_str, end_str, row_no, is_special):
    # Base fallback if start time missing
    fallback_start_min = 7 * 60 + 30 + ((row_no * 17) % (10 * 60)) # between 7:30 AM and 5:30 PM
    
    start_min = parse_time_to_minutes(start_str)
    if start_min is None:
        start_min = fallback_start_min
        
    end_min = parse_time_to_minutes(end_str)
    
    # Typical wash duration
    default_duration = 60 if is_special else 40
    if end_min is None or end_min <= start_min:
        end_min = start_min + default_duration
    
    # If duration unrealistic (> 180 min), cap at realistic duration for logging
    duration = end_min - start_min
    if duration <= 0 or duration > 240:
        duration = default_duration
        end_min = start_min + duration

    start_h = (start_min // 60) % 24
    start_m = start_min % 60
    end_h = (end_min // 60) % 24
    end_m = end_min % 60

    start_iso = f"{date_str}T{start_h:02d}:{start_m:02d}:00+00:00"
    comp_iso = f"{date_str}T{end_h:02d}:{end_m:02d}:00+00:00"
    
    start_display = f"{start_h:02d}:{start_m:02d}"
    comp_display = f"{end_h:02d}:{end_m:02d}"

    return start_iso, comp_iso, duration, start_display, comp_display

def run_ingestion(target_year=2026):
    print(f"=== Preparing Bishe Car Wash Historical Ingestion (Target Year: {target_year}) ===")
    
    total_bookings = []
    total_commissions = []
    total_closings = []

    for day in days_data:
        date_str = day['date_gc_2026'] if target_year == 2026 else day['date_gc_2024']
        day_idx = day['day_index']
        
        # 1. Prepare Daily Closing Record
        closing_id = f"closing-{date_str}-day"
        cbe_tot = day.get('cbe_total', 0)
        tele_tot = day.get('tele_total', 0)
        boa_tot = day.get('boa_total', 0)
        digital_tot = cbe_tot + tele_tot + boa_tot
        cash_tot = day.get('cash_total', 0)
        
        shower_rev = day.get('shower_revenue', 0)
        shower_count = int(shower_rev / 50) if shower_rev > 0 else 0
        carpet_rev = day.get('carpet_revenue', 0)
        
        closing_record = {
            "id": closing_id,
            "closing_date": f"{date_str}T18:00:00.000+00:00",
            "closed_at": f"{date_str}T18:00:00.000+00:00",
            "cashier_name": "Station Gate Cashier",
            "gross_revenue": day['gross_total'],
            "cash_revenue": cash_tot,
            "digital_revenue": digital_tot,
            "cars_washed_count": day['cars_count'],
            "commission_pool": round(day['wash_revenue'] * 0.85 * 0.15, 2),
            "net_station_profit": day['net_total'],
            "cash_deposited": 0,
            "petty_cash_expenses": day['total_expenses'],
            "cash_remaining": cash_tot,
            "provider_breakdown": {
                "CBE": cbe_tot,
                "Telebirr": tele_tot,
                "Bank of Abyssinia": boa_tot,
                "Cash": cash_tot
            },
            "washer_dividends": day.get('staff_payouts', {}),
            "notes": f"Paper log audit: {day['date_ec']} E.C. Reconciled net: {day['net_total']} ETB.\n[HANDOVER_META:{json.dumps({'shiftType':'day','closedByRole':'cashier','handoverTo':'Operational Manager','handoverCashAmount':cash_tot,'isHandoverAccepted':True,'acceptedByName':'Operational Manager','acceptedAt':f'{date_str}T18:05:00.000','carriedCashAmount':0,'handoverMethod':'paper_slip','handoverOtp':'0000','bankAccountName':None,'bankAccountNumber':None,'depositSlipRef':None,'carpetsCleanedCount':1 if carpet_rev > 0 else 0,'carpetRevenue':carpet_rev,'showerUsersCount':shower_count,'showerRevenue':shower_rev,'totalTipsAmount':0,'expenses':day['expenses']})}]",
            "is_confirmed": True,
            "created_at": f"{date_str}T18:00:00.000+00:00",
            "shift_type": "day_shift",
            "vat_collected": 0.0,
            "net_base_revenue": float(day['wash_revenue']),
            "is_cash_handed_over": True,
            "cash_in_drawer_current": float(cash_tot)
        }
        total_closings.append(closing_record)

        # 2. Prepare Wash Bookings & Commission Logs
        for veh in day['vehicles']:
            row_no = veh['no']
            booking_uuid = str(uuid.uuid5(NAMESPACE_BISHE, f"bishe-wash-{target_year}-{day_idx}-{row_no}"))
            
            is_carpet = 'carpet' in veh['service'].lower() or 'ምንጣፍ' in veh['vehicle'].lower()
            is_polish = 'polish' in veh['service'].lower() or 'detail' in veh['service'].lower()
            is_special = is_carpet or is_polish
            
            # Start and Completed Timestamps
            start_iso, comp_iso, duration, start_disp, comp_disp = compute_timestamps(
                date_str,
                veh.get('start', ''),
                veh.get('end', ''),
                row_no,
                is_special
            )
            
            price = float(veh['price'])
            comm_amt = round(price * 0.85 * 0.15, 2) if price > 0 else 0.0
            
            pay_str = veh['payment'].lower()
            if 'cbe' in pay_str:
                pay_method = 'cbe'
                pay_cat = 'digital'
                dig_prov = 'cbe'
            elif 'tele' in pay_str:
                pay_method = 'telebirr'
                pay_cat = 'digital'
                dig_prov = 'telebirr'
            elif 'boa' in pay_str:
                pay_method = 'boa'
                pay_cat = 'digital'
                dig_prov = 'boa'
            else:
                pay_method = 'cash'
                pay_cat = 'cash'
                dig_prov = None

            car_cat = classify_car_type(veh['vehicle'])

            booking = {
                "id": booking_uuid,
                "owner_name": veh['vehicle'],
                "car_type": car_cat,
                "service_type": "walkInStation",
                "package_id": "a0000000-0000-0000-0000-000000000103",
                "assigned_bay_id": None,
                "assigned_washer_id": None,
                "status": "completed",
                "payment_method": pay_method,
                "total_amount": price,
                "commission_amount": comm_amt,
                "created_at": start_iso,
                "completed_at": comp_iso,
                "scheduled_time": start_iso,
                "license_plate": veh['plate'] if veh['plate'] and veh['plate'] != '—' else f"P-{day_idx}-{row_no:02d}",
                "customer_phone": veh.get('phone', ''),
                "delivery_location": f"Services: {veh['service']}\n[WASH_TIMELINE: Started {start_disp}, Completed {comp_disp} ({duration} mins)]\n[HISTORICAL_LOG: Day {day_idx} ({day['date_ec']} E.C.) Line {row_no}]",
                "booking_origin": "cashier_pos",
                "preferred_language": "am",
                "washer_1_name": veh.get('washer', 'Brightn') or 'Brightn',
                "is_paid": True,
                "payment_category": pay_cat,
                "digital_provider": dig_prov,
                "commission_logged": True,
                "is_carpet": is_carpet,
                "custom_total_price": price,
                "is_vat_applicable": True,
                "vat_rate": 0.15,
                "vat_amount": 0.0,
                "net_base_revenue": price,
                "payment_meta": {
                    "wash_started_at": start_iso,
                    "wash_completed_at": comp_iso,
                    "duration_minutes": duration,
                    "entry_time_amharic": veh.get('start', ''),
                    "exit_time_amharic": veh.get('end', ''),
                    "paper_verified": True,
                    "date_ec": day['date_ec']
                }
            }
            total_bookings.append(booking)

            # Commission log
            washer_name = veh.get('washer', '').strip()
            if not washer_name:
                washer_name = "Brightn" if row_no % 2 == 1 else "Alex"
                
            comm_uuid = str(uuid.uuid5(NAMESPACE_BISHE, f"bishe-comm-{target_year}-{day_idx}-{row_no}"))
            comm_log = {
                "id": comm_uuid,
                "booking_id": booking_uuid,
                "staff_id": None,
                "staff_name": washer_name,
                "car_type": car_cat,
                "service_name": veh['service'],
                "earned_amount": comm_amt,
                "logged_at": comp_iso,
                "license_plate": booking['license_plate'],
                "is_settled": True,
                "settled_at": comp_iso
            }
            total_commissions.append(comm_log)

    print(f"Generated {len(total_closings)} daily closings, {len(total_bookings)} wash bookings, and {len(total_commissions)} commission logs.")
    return total_closings, total_bookings, total_commissions

def post_batch(table_name, records, chunk_size=50):
    url = f"{SUPABASE_URL}/rest/v1/{table_name}"
    print(f"Posting {len(records)} records to '{table_name}' in chunks of {chunk_size}...")
    
    for i in range(0, len(records), chunk_size):
        chunk = records[i:i + chunk_size]
        data = json.dumps(chunk).encode('utf-8')
        req = urllib.request.Request(url, data=data, headers=HEADERS, method='POST')
        try:
            with urllib.request.urlopen(req) as resp:
                print(f"  Chunk {i // chunk_size + 1}: HTTP {resp.status} OK ({len(chunk)} rows)")
        except urllib.error.HTTPError as e:
            err_msg = e.read().decode('utf-8')
            print(f"  Chunk {i // chunk_size + 1} Error: HTTP {e.code} - {err_msg}")
            raise e

if __name__ == '__main__':
    year = 2026
    if len(sys.argv) > 1 and sys.argv[1] in ['2024', '2026']:
        year = int(sys.argv[1])
    
    closings, bookings, commissions = run_ingestion(target_year=year)
    
    if '--execute' in sys.argv:
        post_batch('daily_closings', closings, chunk_size=10)
        post_batch('wash_bookings', bookings, chunk_size=50)
        post_batch('commission_logs', commissions, chunk_size=50)
        print("=== All Historical Station Data Successfully Ingested into Supabase! ===")
    else:
        print("\nDry-run mode completed. To execute live ingestion, pass --execute.")
