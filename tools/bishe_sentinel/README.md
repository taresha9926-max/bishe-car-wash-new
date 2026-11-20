# Bishe PayGuard Sentinel: Standalone Android Companion

A dedicated, lightweight Android service app designed to run silently on the phone with the official SIM card (or Admin's phone) to automate real-time digital payment cross-referencing for Bishe Car Wash.

---

## 🚀 How It Works

1. **Passive SMS Interception**:
   - Listens for incoming SMS from **Ethio Telecom Telebirr** (`127`, `telebirr`) and **Commercial Bank of Ethiopia** (`CBE`, `CBEMB`).
   - Runs with priority `999` using `android.provider.Telephony.SMS_RECEIVED`.

2. **Zero-Latency Ingestion into Supabase**:
   - Immediately forwards raw SMS to the Supabase backend RPC:
     `POST /rest/v1/rpc/ingest_bank_sms`
   - Supabase parses:
     - Exact Transaction Reference (e.g. `DKK0G3C37O` for Telebirr, or CBE receipt URL `mbreciept.cbe.com.et/v2-hfHCx...`).
     - Transferred Amount (ETB).
     - Payer Name & Phone.
     - Automatically matches any pending wash booking awaiting payment!

3. **Continuous Background Heartbeat**:
   - Reports device battery % and online heartbeat every 5 minutes to Supabase `rpc/update_sentinel_heartbeat`.
   - The Admin Dashboard and Cashier Screen instantly display Sentinel status (`ONLINE 🟢` vs `OFFLINE 🔴`).

---

## 🛠 Prerequisites & Installation

### Option 1: Open in Android Studio
1. Open Android Studio -> **Open an Existing Project** -> Select `tools/bishe_sentinel`.
2. Connect your Android test phone via USB with USB Debugging enabled.
3. Click **Run 'app'** (Green play button).

### Option 2: Build APK via Terminal
```bash
cd tools/bishe_sentinel
./gradlew assembleRelease
# The APK will be generated at: app/build/outputs/apk/release/app-release.apk
```

---

## 🔋 Android Battery Optimization Settings (CRITICAL)

To ensure Android does not kill the Sentinel service when the phone screen is off or in deep sleep:

1. **In Bishe Sentinel App**:
   - Tap **"Disable Battery Optimization"** -> Select **"Allow" / "No Restrictions"**.
2. **On Xiaomi / Redmi / POCO (MIUI / HyperOS)**:
   - Go to **Settings** > **Apps** > **Manage Apps** > **Bishe Sentinel**.
   - Enable **Autostart**.
   - Under **Battery Saver**, select **No Restrictions**.
3. **On Samsung (One UI)**:
   - Go to **Settings** > **Battery and device care** > **Battery** > **Background usage limits**.
   - Add **Bishe Sentinel** to **Never sleeping apps**.
4. **On Tecno / Infinix (HiOS / XOS)**:
   - Go to **Phone Master** > **Auto-start management** > Allow **Bishe Sentinel**.

---

## 🧪 Built-in Simulation & Testing

The app includes 2 diagnostic buttons in the UI:
1. **"Test Mock Telebirr SMS (350 ETB)"**: Sends a sample Telebirr credit alert to Supabase.
2. **"Test Mock CBE SMS (1,200 ETB)"**: Sends a sample CBE credit alert with receipt link to Supabase.

You can verify instant reception in the Admin Dashboard under **"Bank SMS Feed"**!
