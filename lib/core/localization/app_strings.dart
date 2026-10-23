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
    // App Bar & General
    'appName': {
      AppLanguage.en: 'BISHE Car Wash',
      AppLanguage.om: 'BISHE Dhiqannaa Konkolaataa',
      AppLanguage.am: 'ቢሼ የመኪና ማጠቢያ',
    },
    'tagline': {
      AppLanguage.en: 'Premier Auto Care in Bishoftu, Oromia',
      AppLanguage.om: 'Tajaajila Qulqullina Konkolaataa Bishoftuu, Oromiyaa',
      AppLanguage.am: 'ምርጥ የመኪና እንክብካቤ በቢሾፍቱ፣ ኦሮሚያ',
    },
    'roleCustomer': {
      AppLanguage.en: 'Customer',
      AppLanguage.om: 'Maamila',
      AppLanguage.am: 'ደንበኛ',
    },
    'roleCashier': {
      AppLanguage.en: 'Cashier',
      AppLanguage.om: 'Qabaa Qarshii',
      AppLanguage.am: 'ገንዘብ ያዥ',
    },
    'roleAdmin': {
      AppLanguage.en: 'Admin',
      AppLanguage.om: 'Bulchaa',
      AppLanguage.am: 'አስተዳዳሪ',
    },
    'staffLogin': {
      AppLanguage.en: 'Staff Access',
      AppLanguage.om: 'Seensa Hojjettootaa',
      AppLanguage.am: 'የሰራተኞች መግቢያ',
    },
    'enterPin': {
      AppLanguage.en: 'Enter 4-Digit Security PIN',
      AppLanguage.om: 'PIN Lakkoofsa 4 Galchaa',
      AppLanguage.am: 'ባለ 4 አሃዝ ፒን (PIN) ያስገቡ',
    },
    'unlock': {
      AppLanguage.en: 'Unlock',
      AppLanguage.om: 'Bani',
      AppLanguage.am: 'ክፈት',
    },
    'cancel': {
      AppLanguage.en: 'Cancel',
      AppLanguage.om: 'Dhiisi',
      AppLanguage.am: 'ይቅር',
    },
    'invalidPin': {
      AppLanguage.en: 'Invalid PIN code. Try again.',
      AppLanguage.om: 'PIN dogoggora. Irra deebi\'aa.',
      AppLanguage.am: 'የተሳሳተ ፒን። እንደገና ይሞክሩ።',
    },

    // Customer Screen
    'bookWash': {
      AppLanguage.en: 'Book Car Wash',
      AppLanguage.om: 'Dhiqannaa Qabadhaa',
      AppLanguage.am: 'መኪናዎን ያስመዝግቡ',
    },
    'trackWash': {
      AppLanguage.en: 'Live Status Tracker',
      AppLanguage.om: 'Hordoffii Yeroo Qajeelaa',
      AppLanguage.am: 'የቀጥታ ሁኔታ መከታተያ',
    },
    'queueInsight': {
      AppLanguage.en: 'Live Station Queue Status',
      AppLanguage.om: 'Haala Tarree Ammaa',
      AppLanguage.am: 'የወረፋው የቀጥታ ሁኔታ',
    },
    'carsAhead': {
      AppLanguage.en: 'Cars Ahead',
      AppLanguage.om: 'Konkolaattota Fuulduraa',
      AppLanguage.am: 'ከፊትዎ ያሉ መኪኖች',
    },
    'estimatedWait': {
      AppLanguage.en: 'Estimated Wait',
      AppLanguage.om: 'Yeroo Eegamu',
      AppLanguage.am: 'የሚገመተው የጥበቃ ጊዜ',
    },
    'recommendedArrival': {
      AppLanguage.en: 'Recommended Arrival',
      AppLanguage.om: 'Yeroo Dhuftuu Qabdan',
      AppLanguage.am: 'መድረስ ያለብዎት ሰዓት',
    },
    'selectServiceTier': {
      AppLanguage.en: 'Select Service & Vehicle Tier',
      AppLanguage.om: 'Gosa Tajaajilaafi Konkolaataa Filadhaa',
      AppLanguage.am: 'የአገልግሎትና የመኪና ዓይነት ይምረጡ',
    },
    'licensePlate': {
      AppLanguage.en: 'License Plate (e.g. 2-AA-A12345)',
      AppLanguage.om: 'Gabatee Konkolaataa (fkn 2-AA-A12345)',
      AppLanguage.am: 'የሰሌዳ ቁጥር (ምሳሌ፡ 2-AA-A12345)',
    },
    'phoneNumber': {
      AppLanguage.en: 'Phone Number (09... or 07...)',
      AppLanguage.om: 'Lakkoofsa Bilbilaa (09... ykn 07...)',
      AppLanguage.am: 'ስልክ ቁጥር (09... ወይም 07...)',
    },
    'paymentMethod': {
      AppLanguage.en: 'Payment Method',
      AppLanguage.om: 'Mala Kaffaltii',
      AppLanguage.am: 'የክፍያ ዘዴ',
    },
    'confirmBooking': {
      AppLanguage.en: 'Confirm Booking',
      AppLanguage.om: 'Mirkaneessi',
      AppLanguage.am: 'ምዝገባውን አረጋግጥ',
    },
    'bookingSuccess': {
      AppLanguage.en: 'Booking registered successfully! Track your plate below.',
      AppLanguage.om: 'Galmeen milkaa\'eera! Gabatee keessan hordofaa.',
      AppLanguage.am: 'ምዝገባው ተሳክቷል! የሰሌዳ ቁጥርዎን ከታች ይከታተሉ።',
    },
    'searchPlate': {
      AppLanguage.en: 'Enter Plate to Track',
      AppLanguage.om: 'Hordofuuf Gabatee Galchaa',
      AppLanguage.am: 'ለመከታተል የሰሌዳ ቁጥር ያስገቡ',
    },
    'search': {
      AppLanguage.en: 'Track Vehicle',
      AppLanguage.om: 'Hordofi',
      AppLanguage.am: 'ተከታተል',
    },
    'noActiveBooking': {
      AppLanguage.en: 'No active wash found for this plate.',
      AppLanguage.om: 'Konkolaataan gabatee kana qabu hin argamne.',
      AppLanguage.am: 'በዚህ የሰሌዳ ቁጥር የተመዘገበ መኪና አልተገኘም።',
    },

    // Progress Stages
    'statusQueued': {
      AppLanguage.en: 'Queued (Awaiting Bay)',
      AppLanguage.om: 'Tarree Keessa',
      AppLanguage.am: 'ወረፋ ላይ',
    },
    'statusInBay': {
      AppLanguage.en: 'In Bay (Washing)',
      AppLanguage.om: 'Kutaa Dhiqannaa Keessa',
      AppLanguage.am: 'በመታጠብ ላይ',
    },
    'statusDrying': {
      AppLanguage.en: 'Drying & Detailing',
      AppLanguage.om: 'Gogsuufi Qulqulleessuu',
      AppLanguage.am: 'በማድረቅና በማሳመር ላይ',
    },
    'statusCompleted': {
      AppLanguage.en: 'Completed (Ready for Pickup)',
      AppLanguage.om: 'Xumurameera (Fudhachuuf Qophii)',
      AppLanguage.am: 'ተጠናቋል (ለመረከብ ዝግጁ)',
    },

    // Cashier
    'cashierDashboard': {
      AppLanguage.en: 'Cashier Station Dashboard',
      AppLanguage.om: 'Daashboordii Qabaa Qarshii',
      AppLanguage.am: 'የገንዘብ ያዥ መቆጣጠሪያ ሰሌዳ',
    },
    'registerVehicle': {
      AppLanguage.en: 'Direct Vehicle Entry',
      AppLanguage.om: 'Konkolaataa Galmeessi',
      AppLanguage.am: 'መኪና አስመዝግብ',
    },
    'walkIn': {
      AppLanguage.en: 'Physical Gate Walk-in',
      AppLanguage.om: 'Dhaabbata Dhufe',
      AppLanguage.am: 'በአካል የመጣ (ጌት)',
    },
    'phoneCall': {
      AppLanguage.en: 'Phone Call Reservation',
      AppLanguage.om: 'Bilbilaan Qabame',
      AppLanguage.am: 'በስልክ የተያዘ ቀጠሮ',
    },
    'assignWashers': {
      AppLanguage.en: 'Assigned Washers (Select exactly 2)',
      AppLanguage.om: 'Hojjettoota Dhiqan (Qajeeltoon 2 filadhaa)',
      AppLanguage.am: 'የተመደቡ አጣቢዎች (በትክክል 2 ምረጡ)',
    },
    'advanceStatus': {
      AppLanguage.en: 'Advance Status',
      AppLanguage.om: 'Sadarkaa Fuulduratti',
      AppLanguage.am: 'ሁኔታውን አሻግር',
    },
    'activeBays': {
      AppLanguage.en: 'Station Physical Bays',
      AppLanguage.om: 'Kutaalee Dhiqannaa',
      AppLanguage.am: 'የመኪና ማጠቢያ ክፍሎች',
    },
    'bay1': {
      AppLanguage.en: 'Bay 1 (Station)',
      AppLanguage.om: 'Kutaa 1ffaa',
      AppLanguage.am: 'ክፍል 1',
    },
    'bay2': {
      AppLanguage.en: 'Bay 2 (Station)',
      AppLanguage.om: 'Kutaa 2ffaa',
      AppLanguage.am: 'ክፍል 2',
    },
    'mobileVan': {
      AppLanguage.en: 'Mobile Van Unit',
      AppLanguage.om: 'Makiinaa Socho\'aa (Maan)',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን መኪና',
    },
    'available': {
      AppLanguage.en: 'Available',
      AppLanguage.om: 'Qophiidha',
      AppLanguage.am: 'ክፍት ነው',
    },
    'occupied': {
      AppLanguage.en: 'Occupied',
      AppLanguage.om: 'Qabameera',
      AppLanguage.am: 'ተይዟል',
    },
    'phoneQueue': {
      AppLanguage.en: 'Phone Call Reservations Awaiting Arrival',
      AppLanguage.om: 'Qabinsa Bilbilaa Dhufaa Jiran',
      AppLanguage.am: 'የስልክ ቀጠሮዎች (እስኪደርሱ በመጠባበቅ ላይ)',
    },
    'completedToday': {
      AppLanguage.en: 'Completed Today',
      AppLanguage.om: 'Har\'a Kan Xumuraman',
      AppLanguage.am: 'ዛሬ የተጠናቀቁ',
    },

    // Admin
    'adminDashboard': {
      AppLanguage.en: 'Admin Management & Analytics',
      AppLanguage.om: 'Daashboordii Bulchiinsaa',
      AppLanguage.am: 'የአስተዳዳሪ መቆጣጠሪያ ሰሌዳ',
    },
    'todayRevenue': {
      AppLanguage.en: "Today's Revenue",
      AppLanguage.om: 'Galii Har\'aa',
      AppLanguage.am: 'የዛሬ ገቢ',
    },
    'vehiclesWashed': {
      AppLanguage.en: 'Vehicles Washed',
      AppLanguage.om: 'Konkolaattota Dhiqaman',
      AppLanguage.am: 'የታጠቡ መኪኖች',
    },
    'pricingManager': {
      AppLanguage.en: 'Dynamic Pricing Manager',
      AppLanguage.om: 'Gatii Jijjiiramaa',
      AppLanguage.am: 'የዋጋ ማስተካከያ',
    },
    'payrollCommissions': {
      AppLanguage.en: 'Washer Payroll & Commission Ledger',
      AppLanguage.om: 'Kaffaltii Hojjettootaafi Komishiinii',
      AppLanguage.am: 'የአጣቢዎች ክፍያና ኮሚሽን',
    },
    'settleCommission': {
      AppLanguage.en: 'Settle Commission',
      AppLanguage.om: 'Komishiinii Kaffali',
      AppLanguage.am: 'ኮሚሽን አጽድቅ',
    },
  };

  static String get(String key, AppLanguage lang) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.en] ?? key;
  }
}
