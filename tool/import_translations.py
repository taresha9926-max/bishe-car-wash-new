import csv
import re
import os
import sys

def main():
    desktop_csv = r"C:\Users\Tare\Desktop\bishe_translations.csv"
    project_csv = r"c:\Users\Tare\Desktop\Flutter App\bishe_translations.csv"
    csv_file = desktop_csv if os.path.exists(desktop_csv) else project_csv
    dart_file = r"c:\Users\Tare\Desktop\Flutter App\lib\core\localization\app_strings.dart"

    if not os.path.exists(csv_file):
        print(f"Error: CSV file not found at {csv_file}")
        sys.exit(1)

    print(f"Reading translations from: {csv_file}")
    with open(csv_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        translations = {
            row['Key'].strip(): (row['English'].strip(), row['Afaan_Oromoo'].strip(), row['Amharic'].strip())
            for row in reader if row.get('Key')
        }

    print(f"Loaded {len(translations)} translation keys.")

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
    print("app_strings.dart updated successfully!")

if __name__ == '__main__':
    main()
