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

def run_cli_loop(config, db, ingestion, forensic, closing, projector, telegram, notifier, super_brain=None):
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
            
            sub = input(f"\n{CLR_YELLOW}[d] Delete event | [c] Clear all events | [p] Prune to latest 20 | [Enter] Return: {CLR_RESET}").strip().lower()
            if sub == "d":
                eid = input("Enter Event ID to delete: ").strip()
                if eid.isdigit():
                    ok = db.delete_audit_event(int(eid))
                    print(f"{CLR_GREEN}Event #{eid} deleted.{CLR_RESET}" if ok else f"{CLR_RED}Event not found.{CLR_RESET}")
            elif sub == "c":
                confirm = input("Confirm delete ALL events? (y/N): ").strip().lower()
                if confirm == "y":
                    cnt = db.clear_all_audit_events()
                    print(f"{CLR_GREEN}Cleared {cnt} events.{CLR_RESET}")
            elif sub == "p":
                cnt = db.prune_events(keep_latest=20)
                print(f"{CLR_GREEN}Pruned {cnt} older events.{CLR_RESET}")

        elif choice == "2":
            print(f"\n{CLR_RED}{CLR_BOLD}--- Station Forensic Audit (Active Discrepancies) ---{CLR_RESET}")
            anomalies = db.get_unresolved_anomalies()
            if not anomalies:
                print(f"{CLR_GREEN}✅ ZERO DISCREPANCIES: Station operating with 100% integrity.{CLR_RESET}")
            else:
                for a in anomalies:
                    print(f"\n{CLR_RED}🚨 [{a['severity']}] #{a['id']} {a['category']}{CLR_RESET}")
                    print(f"   Actor: {a['actor_name']} | Time: {a['detected_at']}")
                    print(f"   Event: {a['description']}")
            
            sub = input(f"\n{CLR_YELLOW}[d] Delete anomaly | [c] Clear all anomalies | [Enter] Return: {CLR_RESET}").strip().lower()
            if sub == "d":
                aid = input("Enter Anomaly ID to delete: ").strip()
                if aid.isdigit():
                    ok = db.delete_anomaly(int(aid))
                    print(f"{CLR_GREEN}Anomaly #{aid} deleted.{CLR_RESET}" if ok else f"{CLR_RED}Anomaly not found.{CLR_RESET}")
            elif sub == "c":
                confirm = input("Confirm delete ALL anomalies? (y/N): ").strip().lower()
                if confirm == "y":
                    cnt = db.clear_all_anomalies()
                    print(f"{CLR_GREEN}Cleared {cnt} anomalies.{CLR_RESET}")

        elif choice == "3":
            print(f"\n{CLR_GREEN}--- Consumables Yield & Chemical Benchmarks ---{CLR_RESET}")
            if super_brain:
                ans = super_brain.ask("Show chemical consumables and yield audit")
                print(ans.get("answer", ""))
            else:
                print("Yield engine loading...")
            input("\nPress Enter to return to menu...")

        elif choice == "4":
            print(f"\n{CLR_YELLOW}--- Developer Telemetry & System Status ---{CLR_RESET}")
            last_id = db.get_last_synced_id()
            print(f"• Supabase Sync Cursor: last_id = {last_id}")
            print(f"• Supabase Cloud URL: {config.supabase_url}")
            print(f"• Web Studio URL: http://127.0.0.1:{config.web_port}")
            print(f"• Local Cold Storage: {db.db_path}")
            print(f"• Gemini Flash AI: {'CONFIGURED & ACTIVE' if config.gemini_api_key else 'OFFLINE (Local math fallback active)'}")
            print(f"• Telegram Alerts: {'CONFIGURED' if telegram.is_configured() else 'NOT CONFIGURED (Add token in config.json)'}")
            input("\nPress Enter to return to menu...")

        elif choice == "5":
            print(f"\n{CLR_CYAN}{CLR_BOLD}=== BISHE SUPER AI CHAT TERMINAL (EN / OM / AM) ==={CLR_RESET}")
            print("Type your question (e.g. 'List of cars washed today', 'Washer commissions', 'P&L', 'Suggest features') or 'exit' to return:")
            while True:
                q = input(f"\n{CLR_YELLOW}Tare> {CLR_RESET}").strip()
                if not q or q.lower() in ["exit", "quit", "q"]:
                    break
                print(f"{CLR_CYAN}Sentinel is thinking...{CLR_RESET}\n")
                if super_brain:
                    res = super_brain.ask(q)
                    print(f"{CLR_BOLD}Sentinel [{res.get('source','ai')}]:{CLR_RESET}\n{res.get('answer','')}\n")
                else:
                    print("Brain engine initializing...")

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
