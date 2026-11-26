import urllib.request
import urllib.error
import json
import base64
import os
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 'agent', 'config.json')
with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
    config = json.load(f)

API_KEY = config.get('gemini_api_key', '')
OUT_DIR = os.path.join(os.path.dirname(__file__), 'transcriptions')
os.makedirs(OUT_DIR, exist_ok=True)

PROMPT = """You are an expert handwriting transcription specialist for Bishe Car Wash station logs in Bishoftu, Ethiopia.
Analyze this handwritten ledger page with extreme precision and fidelity.

Columns on the ledger:
1. Row / No (ተ.ቁ)
2. Vehicle model/type (የመኪና አይነት) e.g. DX, Corolla, Vitz, Pickup, Hilux, BYD, Tucson, Suzuki, Glory, Starex, Abadula, Dolphin, Prado, Land Cruiser, Bajaj, ምንጣፍ (Carpet), etc.
3. Plate number (የመኪና ሰሌዳ) e.g. 35821, C24202, B76419, A46461, etc.
4. Service type (የተሰጠው አገልግሎት) e.g. Normal (መደበኛ), Polish/Detailing (ፖሊሽ), Engine (ሞተር), Underwash (ከስር), Vacuum (ቫክዩም), Seats washed (ወንበር), etc.
5. Entry / Start time (የገባበት ሰዓት) e.g. 1:50, 2:30
6. Exit / Finish time (የወጣበት ሰዓት) e.g. 2:50, 3:40
7. Price / Amount (ዋጋ) in Ethiopian Birr (ETB) - numbers e.g. 500, 700, 1000, 1200, 1500, 2100, 2700, 3200, 5600, etc.
8. Payment method (የክፍያ ሁኔታ) - transcribe exactly as Cash, CBE (የንግድ ባንክ), or Telebirr (tele / ቴሌብር)
9. Washer / Staff assigned (የአጣቢው ስም) e.g. Brightn, Alex, etc., or washer codes
10. Customer phone number (የደንበኛ ስልክ ቁጥር) if recorded (e.g. 09...)

Look carefully at the top of the page for:
- Date in Ethiopian Calendar (e.g. 03-03-2017, 04-03-2017, 06-03-2017, 07-03-2017, 08-03-2017, 09-03-2017, 10-03-2017, 11-03-2017, 12-03-2017 E.C.)
- Page number / multi-page indicator if any

Look carefully at the bottom of the page for daily financial calculations (if present on this sheet):
- Car wash revenue (የመኪና እጥበት ገቢ)
- Shower revenue (የሻወር ገቢ)
- Carpet revenue (የምንጣፍ ገቢ)
- Gross revenue
- Expenses / Deductions (ወጪ) - e.g. የስልክ ካርድ 400, ለሰራተኞች/አጣቢዎች የተሰጠ, etc.
- Net total
- Payment breakdown: CBE Total, Telebirr Total, Cash Total
- Staff breakdown: Brightn, Alex

Return strictly valid JSON matching this schema:
{
  "date_ec": "DD-MM-YYYY",
  "sheet_title": "...",
  "page_no": 1,
  "rows": [
    {
      "no": 1,
      "vehicle_type": "...",
      "plate": "...",
      "service": "...",
      "start_time": "...",
      "end_time": "...",
      "price": 500,
      "payment_method": "Cash",
      "washer": "...",
      "phone": "..."
    }
  ],
  "summary": {
    "has_summary": true,
    "wash_revenue": 0,
    "shower_revenue": 0,
    "carpet_revenue": 0,
    "gross_total": 0,
    "expenses": [
      {"name": "...", "amount": 0}
    ],
    "net_total": 0,
    "cbe_total": 0,
    "telebirr_total": 0,
    "cash_total": 0,
    "staff_payouts": {
      "Brightn": 0,
      "Alex": 0
    }
  }
}
"""

def transcribe_file(img_path):
    base_name = os.path.basename(img_path)
    out_file = os.path.join(OUT_DIR, f"{base_name}.json")
    if os.path.exists(out_file) and os.path.getsize(out_file) > 100:
        print(f"Skipping already transcribed: {base_name}")
        with open(out_file, 'r', encoding='utf-8') as f:
            return json.load(f)

    print(f"Starting transcription: {base_name} ({os.path.getsize(img_path)} bytes)...")
    with open(img_path, 'rb') as f:
        img_b64 = base64.b64encode(f.read()).decode('utf-8')

    models = ["gemini-flash-lite-latest", "gemini-3.1-flash-lite", "gemini-flash-latest"]
    for model in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={API_KEY}"
        payload = {
            "contents": [{
                "parts": [
                    {"text": PROMPT},
                    {"inline_data": {"mime_type": "image/jpeg", "data": img_b64}}
                ]
            }],
            "generationConfig": {
                "response_mime_type": "application/json"
            }
        }
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                res = json.loads(resp.read().decode('utf-8'))
                raw_text = res['candidates'][0]['content']['parts'][0]['text']
                data = json.loads(raw_text)
                data['source_file'] = base_name
                with open(out_file, 'w', encoding='utf-8') as out_f:
                    json.dump(data, out_f, indent=2, ensure_ascii=False)
                print(f"Successfully transcribed {base_name} (Date: {data.get('date_ec')}, Rows: {len(data.get('rows', []))})")
                return data
        except Exception as e:
            print(f"  [{base_name}] Model {model} error: {e}")
            time.sleep(1)

    print(f"Failed to transcribe {base_name}")
    return None

UNIQUE_IMAGES = [
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632792931_611ed88a.jpg", # 03-03-2017
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632806157_cc819270.jpg", # 04-03-2017
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632819122_2dc6ba38.jpg", # 05-03-2017
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632830495_9b47030a.jpg", # 06-03-2017 p1
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632841113_e741a6fe.jpg", # 06-03-2017 p2
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632852544_347cbeea.jpg", # 07-03-2017 p1
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632862770_3b952600.jpg", # 07-03-2017 p2
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632779987_ceb516b9.jpg", # 08-03-2017
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632884503_e1056e70.jpg", # 09-03-2017
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632894897_8c8886e4.jpg", # 10-03-2017
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632904746_34629b72.jpg", # 11-03-2017 p1
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632914344_013027b7.jpg", # 11-03-2017 p2
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632924782_ccfb4404.jpg", # 12-03-2017 p1
    r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632935389_6afab830.jpg", # 12-03-2017 p2
]

if __name__ == '__main__':
    print(f"Batch transcribing {len(UNIQUE_IMAGES)} log sheets with 4 parallel workers...")
    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(transcribe_file, path): path for path in UNIQUE_IMAGES}
        for future in as_completed(futures):
            p = futures[future]
            try:
                res = future.result()
            except Exception as e:
                print(f"Error on {p}: {e}")
    print("Batch transcription completed.")
