# BISHE Car Wash — Executive AI Agent (Option A)
**Location:** Bishoftu (Debre Zeyit), Oromia, Ethiopia

A high-performance, lightweight local AI agent running on your laptop. Connects live to your station's Supabase database and answers operational queries on demand.

---

## ⚡ Quick Start

### 1. Launch with One Click
Double-click `run_agent.bat` in the project root. It automatically detects Python 3.12 and opens the interactive executive terminal.

### 2. Or Run via PowerShell / Command Prompt
```powershell
python agent/bishe_agent.py
```

---

## 📊 Command-Line Switches

You can run instant one-off commands without entering the interactive menu:

| Command | Description |
| :--- | :--- |
| `python agent/bishe_agent.py --pnl` | Today's P&L, 15% VAT, washer labor COGS, chemical COGS, and EBITDA |
| `python agent/bishe_agent.py --cars` | Vehicle volume breakdown (Sedans $1.0\times$, SUVs $1.4\times$, Minibuses $1.8\times$, Trucks $2.5\times$, Carpets) |
| `python agent/bishe_agent.py --washers` | Active washer roster, completed washes, and earned commissions |
| `python agent/bishe_agent.py --yield-audit` | Chemical container benchmarks (5L shampoo canister ~40 cars, 500ml perfume) |
| `python agent/bishe_agent.py --alerts` | Warehouse re-order safety thresholds & shift handover integrity |
| `python agent/bishe_agent.py --ask "query"` | Ask any custom question in natural language (English, Amharic, Afaan Oromoo) |
| `python agent/bishe_agent.py --telegram` | Start the live Telegram Bot background listener |

---

## 📱 How to Receive Reports on Your Phone via Telegram (Optional)

You can chat with your station database from anywhere on your phone using Telegram:

1. Open Telegram on your phone and search for `@BotFather`.
2. Type `/newbot` and follow the prompts to create your bot (e.g. `BisheCarWashBot`).
3. Copy the HTTP API token provided by BotFather (looks like `123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ`).
4. Paste it into `agent/config.json` under `"telegram_bot_token"`, or run the agent and select **Option [8] Configure API Keys**.
5. Start the bot by running:
   ```powershell
   python agent/bishe_agent.py --telegram
   ```
6. Open your bot in Telegram and send `/pnl`, `/cars`, or any question!

---

## 🛡️ Supabase Bandwidth Economy Guarantees

This agent adheres to strict network egress economics:
- **No Unbounded Polling**: Never queries full tables or runs `select=*` on growing collections.
- **Selective Projections**: Only requests minimal necessary columns (`id`, `license_plate`, `car_type`, `total_amount`, `status`, `created_at`), transferring $<400$ bytes per query.
- **In-Memory TTL Caching**: The staff roster is cached for 15 minutes in memory, eliminating redundant calls.
- **Zero Heavy Dependencies**: Written entirely in pure Python standard library (`urllib`, `json`, `datetime`) — no external package downloads required.
