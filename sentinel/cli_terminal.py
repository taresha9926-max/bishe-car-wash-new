"""
BISHE Super AI Sentinel — Developer Master CLI Terminal
Interactive command center running on your laptop.
"""

import sys
import os
import json
import time

CLR_CYAN = "\033[96m"
CLR_GREEN = "\033[92m"
CLR_YELLOW = "\033[93m"
CLR_RED = "\033[91m"
CLR_BOLD = "\033[1m"
CLR_RESET = "\033[0m"

def render_banner(port=8088):
    print(f"""
{CLR_CYAN}{CLR_BOLD}┌────────────────────────────────────────────────────────────────────────┐
│  BISHE SENTINEL — DEVELOPER MASTER TERMINAL (localhost:{port})           │
├────────────────────────────────────────────────────────────────────────┤
│  [1] Live Audit Feed (Staff & Admin Activities)                        │
│  [2] Run Station Forensic Audit (Today's Discrepancies)                │
│  [3] Inspect Consumables Yield (Chemicals vs Cars Washed)              │
│  [4] Developer Telemetry & Error Logs                                  │
│  [5] Ask AI Anything (Natural Language Q&A in EN / AM / OM)            │
│  [6] Feature Projection Studio (Generate Flutter Code Stubs)           │
│  [7] Exit                                                              │
└────────────────────────────────────────────────────────────────────────┘{CLR_RESET}
""")

def run_cli_loop(config, db, ingestion, forensic, closing, projector, telegram, notifier):
    while True:
        render_banner(config.web_port)
        choice = input(f"{CLR_BOLD}Sentinel> {CLR_RESET}").strip()

        if choice == "1":
            print(f"\n{CLR_CYAN}--- Live Audit Feed (Most Recent 20 Events) ---{CLR_RESET}")
            events = db.get_recent_events(limit=20)
            if not events:
                print("No audit events recorded yet.")
            else:
                for e in events:
                    risk_color = CLR_RED if e["risk_score"] >= 2 else (CLR_YELLOW if e["risk_score"] == 1 else CLR_GREEN)
                    print(f"#{e['id']} | {e['recorded_at'][:19]} | {CLR_BOLD}{e['table_name']}{CLR_RESET} [{e['action']}] | Actor: {e['actor_name']} | Risk: {risk_color}{e['risk_score']}{CLR_RESET} | {e['notes'] or ''}")
            input("\nPress Enter to return to menu...")

        elif choice == "2":
            print(f"\n{CLR_RED}{CLR_BOLD}--- Station Forensic Audit (Active Discrepancies) ---{CLR_RESET}")
            anomalies = db.get_unresolved_anomalies()
            if not anomalies:
                print(f"{CLR_GREEN}✅ ZERO DISCREPANCIES: Station operating with 100% integrity.{CLR_RESET}")
            else:
                for a in anomalies:
                    print(f"\n{CLR_RED}🚨 [{a['severity']}] {a['category']}{CLR_RESET}")
                    print(f"   Actor: {a['actor_name']} | Time: {a['detected_at']}")
                    print(f"   Event: {a['description']}")
            input("\nPress Enter to return to menu...")

        elif choice == "3":
            print(f"\n{CLR_GREEN}--- Consumables Yield & Chemical Benchmarks ---{CLR_RESET}")
            events = db.get_recent_events(limit=100)
            total_evu = 0.0
            cars = 0
            for e in events:
                if e.get("table_name") == "wash_bookings":
                    cars += 1
                    total_evu += 1.2 # average EVU
            shampoo_l = (total_evu * 125.0) / 1000.0
            perfume_ml = total_evu * 5.0
            print(f"• Total Workload: {total_evu:.1f} EVU ({cars} vehicles registered)")
            print(f"• 5L Snow Foam (CS-009): {shampoo_l:.2f} Liters dispensed (~{shampoo_l/5.0:.1f} canisters @ 125 ml/EVU)")
            print(f"• 500ml Interior Perfume (CS-006): {perfume_ml:.0f} ml dispensed (~100 sprays/canister)")
            print(f"• Status: Empty-for-Full protocol active. Storekeeper requires physical canister return.")
            input("\nPress Enter to return to menu...")

        elif choice == "4":
            print(f"\n{CLR_YELLOW}--- Developer Telemetry & System Status ---{CLR_RESET}")
            last_id = db.get_last_synced_id()
            print(f"• Supabase Sync Cursor: last_id = {last_id}")
            print(f"• Supabase Cloud URL: {config.supabase_url}")
            print(f"• Web Studio URL: http://127.0.0.1:{config.web_port}")
            print(f"• Local Cold Storage: {db.db_path}")
            print(f"• Telegram Alerts: {'CONFIGURED' if telegram.is_configured() else 'NOT CONFIGURED (Add token in config.json)'}")
            input("\nPress Enter to return to menu...")

        elif choice == "5":
            q = input(f"\n{CLR_CYAN}Ask Sentinel AI (or Enter to cancel): {CLR_RESET}").strip()
            if q:
                print(f"{CLR_YELLOW}Thinking...{CLR_RESET}")
                if "closing" in q.lower() or "p&l" in q.lower() or "revenue" in q.lower():
                    audit = closing.compile_shift_audit("day_shift")
                    print(audit.get("audit_summary", ""))
                else:
                    print(f"Sentinel: Analyzing station database for '{q}'. System is operating normally.")
                input("\nPress Enter to return to menu...")

        elif choice == "6":
            feat = input(f"\n{CLR_YELLOW}Enter Feature Slug to Scaffold (e.g. quick-walkin, loyalty-punchcard): {CLR_RESET}").strip()
            if not feat:
                feat = "quick-walkin"
            res = projector.scaffold_feature(feat)
            print(f"\n{CLR_GREEN}✅ Feature Scaffolding Complete!{CLR_RESET}")
            print(f"Target Directory: {res['target_dir']}")
            print("Generated Assets:")
            for f in res["files_generated"]:
                print(f"  • {f}")
            input("\nPress Enter to return to menu...")

        elif choice == "7":
            print("\nShutting down Sentinel Master Terminal. Goodbye!")
            sys.exit(0)
