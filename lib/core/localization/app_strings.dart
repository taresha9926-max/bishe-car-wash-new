enum AppLanguage {
  en('English', 'EN'),
  om('Afaan Oromoo', 'OM'),
  am('አማርኛ', 'AM');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _strings = {
    'appName': {
      AppLanguage.en: 'BISHE Car Wash',
      AppLanguage.om: 'BISHE Dhiqannaa',
      AppLanguage.am: 'ቢሼ የመኪና ማጠቢያ',
    },
    'bishoftu': {
      AppLanguage.en: 'Bishoftu • Oromia, Ethiopia',
      AppLanguage.om: 'Bishoftuu • Oromiyaa, Itoophiyaa',
      AppLanguage.am: 'ቢሾፍቱ • ኦሮሚያ፣ ኢትዮጵያ',
    },
    'driveInStation': {
      AppLanguage.en: 'Drive-in Station',
      AppLanguage.om: 'Kutaa Dhiqannaa',
      AppLanguage.am: 'የማጠቢያ ክፍል',
    },
    'atHomeMobile': {
      AppLanguage.en: 'At-Home Mobile Van',
      AppLanguage.om: 'Makiinaa Socho\'aa',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን መኪና',
    },
    'bookThisWash': {
      AppLanguage.en: 'Book This Wash',
      AppLanguage.om: 'Dhiqannaa Qabadhaa',
      AppLanguage.am: 'ይህንን እጥበት ይዘዙ',
    },
    'myHistory': {
      AppLanguage.en: 'My History',
      AppLanguage.om: 'Seenaa Koo',
      AppLanguage.am: 'የቀደመ ታሪክ',
    },
    'activeWashingBays': {
      AppLanguage.en: 'Active Washing Bays',
      AppLanguage.om: 'Kutaalee Dhiqannaa',
      AppLanguage.am: 'የመኪና ማጠቢያ ክፍሎች',
    },
    'newWalkIn': {
      AppLanguage.en: 'New Walk-In Entry',
      AppLanguage.om: 'Galmee Haaraa',
      AppLanguage.am: 'አዲስ ምዝገባ',
    },
    'totalRevenue': {
      AppLanguage.en: 'Total Revenue',
      AppLanguage.om: 'Galii Waliigalaa',
      AppLanguage.am: 'አጠቃላይ ገቢ',
    },
    'pricingMatrix': {
      AppLanguage.en: 'Pricing Matrix',
      AppLanguage.om: 'Gatii Tajaajilaa',
      AppLanguage.am: 'የዋጋ ማስተካከያ',
    },
    'staffPayroll': {
      AppLanguage.en: 'Staff Payroll',
      AppLanguage.om: 'Kaffaltii Hojjettootaa',
      AppLanguage.am: 'የሰራተኞች ደመወዝ',
    },
  };

  static String get(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? _strings[key]?[AppLanguage.en] ?? key;
  }
}
