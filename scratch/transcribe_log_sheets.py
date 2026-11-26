import urllib.request
import urllib.error
import json
import base64
import os
import sys

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 'agent', 'config.json')
with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
    config = json.load(f)

API_KEY = config.get('gemini_api_key', '')
if not API_KEY:
    print("Error: Gemini API key missing from agent/config.json")
    sys.exit(1)

PROMPT = """You are an expert handwriting transcription specialist for Bishe Car Wash station logs in Ethiopia.
Analyze this handwritten station ledger page thoroughly.

Columns typically are:
1. Row / No (ተ.ቁ)
2. Vehicle model/type (የመኪና አይነት) e.g. DX, Corolla, Vitz, Pickup, BYD, Tucson, Suzuki, Glory, Starex, Abadula, Dolphin, Bajaj, ምንጣፍ (Carpet), etc.
3. Plate number (የመኪና ሰሌዳ) e.g. 35821, C24202, B76419, etc.
4. Service type (የተሰጠው አገልግሎት) e.g. Normal, Polish/Detailing, Engine, Underwash, Seat wash, etc.
5. Entry / Start time (የገባበት ሰዓት) e.g. 1:50, 2:30
6. Exit / Finish time (የወጣበት ሰዓት) e.g. 2:50, 3:40
7. Price / Amount (ዋጋ) in Ethiopian Birr (ETB)
8. Payment method (የክፍያ ሁኔታ) - usually Cash, CBE, or Telebirr (tele)
9. Washer / Assigned staff name (የአጣቢው ስም) e.g. Brightn, Alex, etc.
10. Customer phone number (የደንበኛ ስልክ ቁጥር) if recorded

Also carefully transcribe the daily financial settlement / closing calculation section at the bottom (if present on this sheet):
- Car wash revenue (የመኪና እጥበት ገቢ)
- Shower revenue (የሻወር ገቢ)
- Carpet revenue (የምንጣፍ ገቢ) if separated
- Gross revenue
- Expenses / Deductions (ወጪ) - list each expense item and amount (e.g. Card/Airtime, soap, staff allowance, etc.)
- Net total
- Payment breakdown: CBE Total, Telebirr Total, Cash Total
- Staff breakdown: Brightn amount, Alex amount, etc.

Return ONLY valid JSON matching this schema:
{
  "date_ec": "DD-MM-YYYY",
  "page_no": 1,
  "is_multi_page": false,
  "rows": [
    {
      "no": 1,
      "vehicle_type": "DX",
      "plate": "35821",
      "service": "Normal",
      "start_time": "1:50",
      "end_time": "2:50",
      "price": 500,
      "payment_method": "Cash",
      "washer": "",
      "phone": ""
    }
  ],
  "summary": {
    "has_summary": true,
    "wash_revenue": 20850,
    "shower_revenue": 150,
    "carpet_revenue": 0,
    "gross_total": 21000,
    "expenses": [
      {"name": "የስልክ ካርድ", "amount": 400}
    ],
    "net_total": 20600,
    "cbe_total": 12650,
    "telebirr_total": 2750,
    "cash_total": 5200,
    "staff_payouts": {
      "Brightn": 0,
      "Alex": 0
    }
  }
}
"""

def transcribe_image(image_path):
    print(f"Transcribing {os.path.basename(image_path)}...")
    with open(image_path, 'rb') as f:
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
            with urllib.request.urlopen(req, timeout=45) as resp:
                res = json.loads(resp.read().decode('utf-8'))
                raw_text = res['candidates'][0]['content']['parts'][0]['text']
                data = json.loads(raw_text)
                return data
        except Exception as e:
            print(f"  Attempt with model {model} failed: {e}")
            continue

    return None

if __name__ == '__main__':
    test_img = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\Tare\.gemini\antigravity\brain\27d5991d-6692-4e2a-a83d-3f82c7fe60a6\.user_uploaded\media_1795632779987_ceb516b9.jpg"
    result = transcribe_image(test_img)
    print(json.dumps(result, indent=2, ensure_ascii=False))
