import csv
import re
import os
import sys

def import_translations():
    desktop_xlsx = r"C:\Users\Tare\Desktop\bishe_customer_translations.xlsx"
    desktop_customer_csv = r"C:\Users\Tare\Desktop\bishe_customer_translations.csv"
    desktop_full_csv = r"C:\Users\Tare\Desktop\bishe_translations.csv"
    project_csv = r"c:\Users\Tare\Desktop\Flutter App\bishe_translations.csv"
    dart_file = r"c:\Users\Tare\Desktop\Flutter App\lib\core\localization\app_strings.dart"

    translations = {}

    # 1. Try reading Excel .xlsx if openpyxl is installed and file exists
    if os.path.exists(desktop_xlsx):
        try:
            import openpyxl
            wb = openpyxl.load_workbook(desktop_xlsx)
            print(f"Reading from Excel workbook: {desktop_xlsx}")
            for sheetname in wb.sheetnames:
                ws = wb[sheetname]
                for row in ws.iter_rows(min_row=4, values_only=True):
                    if not row or len(row) < 5 or not row[1]:
                        continue
                    key = str(row[1]).strip()
                    en = str(row[2] or '').strip()
                    om = str(row[3] or '').strip()
                    am = str(row[4] or '').strip()
                    translations[key] = (en, om, am)
            print(f"Loaded {len(translations)} customer keys from Excel (.xlsx).")
        except Exception as e:
            print(f"Could not read xlsx: {e}")

    # 2. If no xlsx keys loaded, try customer CSV
    if not translations and os.path.exists(desktop_customer_csv):
        print(f"Reading from customer CSV: {desktop_customer_csv}")
        with open(desktop_customer_csv, 'r', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            for row in reader:
                if row.get('Key'):
                    key = row['Key'].strip()
                    translations[key] = (row.get('English','').strip(), row.get('Afaan_Oromoo','').strip(), row.get('Amharic','').strip())

    # 3. Fallback to full CSV
    if not translations:
        fallback = desktop_full_csv if os.path.exists(desktop_full_csv) else project_csv
        if os.path.exists(fallback):
            print(f"Reading from full CSV: {fallback}")
            with open(fallback, 'r', encoding='utf-8-sig') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    if row.get('Key'):
                        key = row['Key'].strip()
                        translations[key] = (row.get('English','').strip(), row.get('Afaan_Oromoo','').strip(), row.get('Amharic','').strip())

    if not translations:
        print("No translations found to import.")
        return

    # Update app_strings.dart
    with open(dart_file, 'r', encoding='utf-8') as f:
        content = f.read()

    def replacer(match):
        key = match.group(1)
        if key in translations:
            en, om, am = translations[key]
            en_esc = en.replace("'", r"\'")
            om_esc = om.replace("'", r"\'")
            am_esc = am.replace("'", r"\'")
            return f"'{key}': {{\n      AppLanguage.en: '{en_esc}',\n      AppLanguage.om: '{om_esc}',\n      AppLanguage.am: '{am_esc}',\n    }}"
        return match.group(0)

    pattern = re.compile(r"'([a-zA-Z0-9_]+)':\s*\{[^}]*\}", re.DOTALL)
    new_content, count = pattern.subn(replacer, content)

    print(f"Successfully matched and updated {count} entries in {dart_file}.")
    with open(dart_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Done!")

if __name__ == '__main__':
    import_translations()
