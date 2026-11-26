import json
import os

day11 = {
    "day_index": 11,
    "date_ec": "13-03-2017",
    "date_gc_2024": "2024-11-22",
    "date_gc_2026": "2026-11-22",
    "weekday": "Friday",
    "source_images": ["media_1795694333712_1f5f3819.jpg"],
    "cars_count": 31,
    "wash_revenue": 20900,
    "shower_revenue": 0,
    "carpet_revenue": 0,
    "gross_total": 20900,
    "expenses": [
        {"name": "የስልክ የቀን ክፍያ (Airtime)", "amount": 400}
    ],
    "total_expenses": 400,
    "net_total": 20500,
    "cbe_total": 8300,
    "tele_total": 5600,
    "cash_total": 6600,
    "staff_payouts": {
        "Brightn": {"total": 12500},
        "Alex": {"total": 8000}
    },
    "vehicles": [
        {"no": 1, "vehicle": "DX", "plate": "58838", "service": "Normal", "start": "1:30", "end": "2:40", "price": 500, "payment": "CBE", "washer": "", "phone": ""},
        {"no": 2, "vehicle": "DX", "plate": "46291", "service": "Normal", "start": "1:40", "end": "2:45", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 3, "vehicle": "Yaris", "plate": "AA 11073", "service": "Normal", "start": "1:55", "end": "6:35", "price": 500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 4, "vehicle": "Jetour", "plate": "C5332", "service": "Normal", "start": "2:25", "end": "4:22", "price": 700, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 5, "vehicle": "Peugeot", "plate": "B99627", "service": "Normal", "start": "2:40", "end": "6:14", "price": 700, "payment": "Cash", "washer": "", "phone": "0912829055"},
        {"no": 6, "vehicle": "Corolla", "plate": "A81435", "service": "Normal", "start": "2:40", "end": "", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 7, "vehicle": "Tucson", "plate": "B73054", "service": "Normal", "start": "3:18", "end": "4:34", "price": 700, "payment": "Cash", "washer": "", "phone": "0911050312"},
        {"no": 8, "vehicle": "DX", "plate": "11611", "service": "Normal", "start": "3:30", "end": "4:37", "price": 500, "payment": "Telebirr", "washer": "Brightn", "phone": ""},
        {"no": 9, "vehicle": "Yaris", "plate": "C41487", "service": "Normal", "start": "3:35", "end": "", "price": 500, "payment": "Cash", "washer": "", "phone": "0911667990"},
        {"no": 10, "vehicle": "Vitz", "plate": "B19216", "service": "Normal", "start": "3:40", "end": "5:10", "price": 500, "payment": "Telebirr", "washer": "", "phone": "0913349646"},
        {"no": 11, "vehicle": "BYD", "plate": "C70854", "service": "Normal", "start": "3:55", "end": "5:05", "price": 500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 12, "vehicle": "Corolla", "plate": "A07854", "service": "Normal", "start": "4:08", "end": "11:32", "price": 500, "payment": "Telebirr", "washer": "Brightn", "phone": "092907893"},
        {"no": 13, "vehicle": "Suzuki", "plate": "C13195", "service": "Seat Normal", "start": "4:08", "end": "8:30", "price": 1500, "payment": "CBE", "washer": "Brightn", "phone": "0923342245"},
        {"no": 14, "vehicle": "Hilux Pickup", "plate": "B41695", "service": "Normal", "start": "4:41", "end": "6:00", "price": 700, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 15, "vehicle": "Pickup Hilux", "plate": "62237", "service": "Normal", "start": "4:41", "end": "6:51", "price": 700, "payment": "Telebirr", "washer": "Brightn", "phone": "0973772581"},
        {"no": 16, "vehicle": "BYD", "plate": "AAA 8311", "service": "Normal", "start": "4:41", "end": "11:32", "price": 500, "payment": "Telebirr", "washer": "", "phone": "0912782677"},
        {"no": 17, "vehicle": "Pickup Hilux", "plate": "08701", "service": "Normal", "start": "4:55", "end": "7:59", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 18, "vehicle": "Pickup Hilux", "plate": "A01426", "service": "Normal", "start": "4:55", "end": "", "price": 700, "payment": "Telebirr", "washer": "Brightn", "phone": ""},
        {"no": 19, "vehicle": "Suzuki", "plate": "C00818", "service": "Normal", "start": "4:55", "end": "7:25", "price": 500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 20, "vehicle": "Vitz", "plate": "B66894", "service": "Normal", "start": "5:18", "end": "7:28", "price": 500, "payment": "CBE", "washer": "Brightn", "phone": "0910588783"},
        {"no": 21, "vehicle": "BYD", "plate": "C54936", "service": "Normal", "start": "6:19", "end": "7:25", "price": 700, "payment": "CBE", "washer": "Brightn", "phone": "0911852699"},
        {"no": 22, "vehicle": "DX", "plate": "66454", "service": "Polish Normal", "start": "6:25", "end": "8:30", "price": 1500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 23, "vehicle": "Suzuki", "plate": "C49363", "service": "Normal", "start": "7:09", "end": "9:54", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 24, "vehicle": "Pickup Hilux", "plate": "09625", "service": "Normal", "start": "", "end": "8:44", "price": 700, "payment": "Telebirr", "washer": "Brightn", "phone": ""},
        {"no": 25, "vehicle": "Pickup", "plate": "06903", "service": "Normal", "start": "", "end": "8:44", "price": 700, "payment": "Cash", "washer": "Brightn", "phone": ""},
        {"no": 26, "vehicle": "Pickup", "plate": "A66603", "service": "Normal", "start": "", "end": "9:32", "price": 700, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 27, "vehicle": "Corolla", "plate": "A44457", "service": "Normal", "start": "", "end": "9:25", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 28, "vehicle": "Suzuki", "plate": "C35380", "service": "Normal", "start": "", "end": "10:20", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 29, "vehicle": "Corolla", "plate": "C83547", "service": "Normal", "start": "", "end": "9:25", "price": 700, "payment": "Cash", "washer": "Brightn", "phone": ""},
        {"no": 30, "vehicle": "Pickup", "plate": "10946", "service": "Normal", "start": "8:30", "end": "10:49", "price": 700, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 31, "vehicle": "BYD", "plate": "AAB0269", "service": "Polish Normal", "start": "9:15", "end": "10:18", "price": 1500, "payment": "Telebirr", "washer": "Brightn", "phone": ""}
    ]
}

day12 = {
    "day_index": 12,
    "date_ec": "14-03-2017",
    "date_gc_2024": "2024-11-23",
    "date_gc_2026": "2026-11-23",
    "weekday": "Saturday",
    "source_images": ["media_1795694345965_cd181c3b.jpg"],
    "cars_count": 27,
    "wash_revenue": 25300,
    "shower_revenue": 100,
    "carpet_revenue": 0,
    "gross_total": 25400,
    "expenses": [
        {"name": "የስልክ የቀን ክፍያ (Airtime)", "amount": 400},
        {"name": "የዕቃ አቅርቦት እና Delivery (Supplies & Delivery)", "amount": 2000}
    ],
    "total_expenses": 2400,
    "net_total": 23000,
    "cbe_total": 14600,
    "tele_total": 4900,
    "cash_total": 3500,
    "staff_payouts": {
        "Brightn": {"cbe": 11200, "tele": 4900, "total": 16100},
        "Alex": {"cbe": 3400, "tele": 0, "total": 3400}
    },
    "vehicles": [
        {"no": 1, "vehicle": "KIA", "plate": "B10472", "service": "Normal", "start": "2:20", "end": "5:20", "price": 500, "payment": "CBE", "washer": "", "phone": ""},
        {"no": 2, "vehicle": "BZ", "plate": "C51846", "service": "Normal", "start": "2:20", "end": "3:20", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 3, "vehicle": "Yaris", "plate": "B70812", "service": "Normal", "start": "2:30", "end": "3:30", "price": 500, "payment": "CBE", "washer": "", "phone": ""},
        {"no": 4, "vehicle": "Bajaj", "plate": "A55996", "service": "Normal", "start": "2:20", "end": "3:10", "price": 350, "payment": "Telebirr", "washer": "", "phone": ""},
        {"no": 5, "vehicle": "Bajaj", "plate": "A00186", "service": "Normal", "start": "2:20", "end": "2:50", "price": 200, "payment": "Telebirr", "washer": "", "phone": ""},
        {"no": 6, "vehicle": "Pickup", "plate": "06457", "service": "Normal", "start": "3:55", "end": "4:50", "price": 700, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 7, "vehicle": "Damas Dzire", "plate": "47644", "service": "Normal", "start": "4:20", "end": "5:40", "price": 700, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 8, "vehicle": "Suzuki Dzire", "plate": "B07743", "service": "Polish Detail", "start": "4:30", "end": "6:00", "price": 6000, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 9, "vehicle": "Bajaj", "plate": "39998", "service": "Normal", "start": "4:50", "end": "6:00", "price": 350, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 10, "vehicle": "Yaris", "plate": "A15887", "service": "Normal", "start": "4:50", "end": "5:50", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 11, "vehicle": "Pickup", "plate": "05736", "service": "Normal", "start": "5:00", "end": "6:10", "price": 700, "payment": "Telebirr", "washer": "Brightn", "phone": ""},
        {"no": 12, "vehicle": "Corolla Dzire", "plate": "C24823", "service": "Normal", "start": "5:10", "end": "6:00", "price": 500, "payment": "CBE", "washer": "", "phone": ""},
        {"no": 13, "vehicle": "Suzuki", "plate": "C03575", "service": "Polish Normal", "start": "7:00", "end": "8:00", "price": 1500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 14, "vehicle": "Yaris", "plate": "A76138", "service": "Headlight Normal", "start": "7:10", "end": "8:20", "price": 2500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 15, "vehicle": "Tank", "plate": "C90426", "service": "Normal", "start": "7:00", "end": "8:30", "price": 700, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 16, "vehicle": "Pickup", "plate": "08588", "service": "Normal", "start": "6:30", "end": "7:50", "price": 700, "payment": "Telebirr", "washer": "Brightn", "phone": ""},
        {"no": 17, "vehicle": "Yaris Dzire", "plate": "A39227", "service": "Polish Normal", "start": "8:20", "end": "10:00", "price": 2000, "payment": "Telebirr", "washer": "Brightn", "phone": ""},
        {"no": 18, "vehicle": "Suzuki", "plate": "C30355", "service": "Normal", "start": "8:20", "end": "9:30", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 19, "vehicle": "Hyundai", "plate": "A29714", "service": "Normal", "start": "8:30", "end": "9:30", "price": 500, "payment": "Cash", "washer": "Brightn", "phone": ""},
        {"no": 20, "vehicle": "Corolla", "plate": "B6897", "service": "Normal", "start": "9:40", "end": "10:30", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 21, "vehicle": "Pickup", "plate": "C7698", "service": "Normal", "start": "9:50", "end": "10:30", "price": 700, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 22, "vehicle": "Hyundai", "plate": "C13356", "service": "Normal", "start": "10:00", "end": "11:30", "price": 500, "payment": "CBE", "washer": "", "phone": ""},
        {"no": 23, "vehicle": "Corolla Dzire", "plate": "B11964", "service": "Body wash Normal", "start": "11:30", "end": "12:30", "price": 500, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 24, "vehicle": "Suzuki Dzire", "plate": "B99391", "service": "Polish Normal", "start": "11:40", "end": "12:40", "price": 1500, "payment": "CBE", "washer": "Brightn", "phone": ""},
        {"no": 25, "vehicle": "Suzuki Swift", "plate": "C64882", "service": "Normal", "start": "", "end": "", "price": 500, "payment": "Telebirr", "washer": "", "phone": "0911807..."},
        {"no": 26, "vehicle": "Pickup", "plate": "10826", "service": "Normal", "start": "", "end": "", "price": 700, "payment": "Cash", "washer": "", "phone": ""},
        {"no": 27, "vehicle": "Pickup", "plate": "10418", "service": "Normal", "start": "", "end": "", "price": 700, "payment": "CBE", "washer": "", "phone": ""}
    ]
}

ledger_path = os.path.join(os.path.dirname(__file__), "historical_master_ledger.json")
with open(ledger_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Keep first 10 days
data = [d for d in data if d["day_index"] <= 10]
data.append(day11)
data.append(day12)

with open(ledger_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

total_cars = sum(d["cars_count"] for d in data)
total_gross = sum(d["gross_total"] for d in data)
total_net = sum(d["net_total"] for d in data)

print(f"Updated Master Ledger: {len(data)} Days, {total_cars} Total Vehicles.")
print(f"Total Gross Revenue: {total_gross:,} ETB")
print(f"Total Net Reconciled: {total_net:,} ETB")
