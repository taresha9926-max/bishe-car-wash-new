enum AppLanguage {
  en('English', 'EN'),
  om('Afaan Oromoo', 'OM'),
  am('አማርኛ', 'AM');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);

  static AppLanguage fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'OM':
        return AppLanguage.om;
      case 'AM':
        return AppLanguage.am;
      default:
        return AppLanguage.en;
    }
  }
}

class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _strings = {
    // App Header & Global
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
    'tagline': {
      AppLanguage.en: 'Premier Auto Care near Crater Lakes',
      AppLanguage.om: 'Tajaajila Qulqullina Konkolaataa Bishoftuu',
      AppLanguage.am: 'ምርጥ የመኪና እጥበት እና እንክብካቤ',
    },
    'customerRole': {
      AppLanguage.en: 'Customer',
      AppLanguage.om: 'Maamila',
      AppLanguage.am: 'ደንበኛ',
    },
    'cashierRole': {
      AppLanguage.en: 'Cashier Desk',
      AppLanguage.om: 'Qabaa Qarshii',
      AppLanguage.am: 'ገንዘብ ያዥ',
    },
    'adminRole': {
      AppLanguage.en: 'Admin Hub',
      AppLanguage.om: 'Bulchiinsa',
      AppLanguage.am: 'አስተዳዳሪ',
    },

    // Customer Screen
    'selectServiceMode': {
      AppLanguage.en: 'Select Service Mode',
      AppLanguage.om: 'Gosa Tajaajilaa Filadhaa',
      AppLanguage.am: 'የአገልግሎት ዓይነት ይምረጡ',
    },
    'driveInStation': {
      AppLanguage.en: 'Drive-in Station',
      AppLanguage.om: 'Kutaa Dhiqannaa',
      AppLanguage.am: 'የማጠቢያ ክፍል (ጣቢያ)',
    },
    'driveInSub': {
      AppLanguage.en: '2 Pressure Wash Bays',
      AppLanguage.om: 'Kutaalee dhiqannaa 2',
      AppLanguage.am: '2 የማጠቢያ ክፍሎች አሉ',
    },
    'atHomeMobile': {
      AppLanguage.en: 'At-Home Mobile Van',
      AppLanguage.om: 'Makiinaa Socho\'aa',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን (ቤት ድረስ)',
    },
    'atHomeSub': {
      AppLanguage.en: 'Doorstep in Bishoftu',
      AppLanguage.om: 'Mana keessanitti',
      AppLanguage.am: 'ቢሾፍቱ ውስጥ ቤትዎ ድረስ',
    },
    'availableNow': {
      AppLanguage.en: 'Available',
      AppLanguage.om: 'Qophiidha',
      AppLanguage.am: 'ክፍት ነው',
    },
    'busyWashing': {
      AppLanguage.en: 'Busy Washing',
      AppLanguage.om: 'Hojjataa Jira',
      AppLanguage.am: 'በመታጠብ ላይ',
    },
    'servicePackages': {
      AppLanguage.en: 'Service Packages & Pricing',
      AppLanguage.om: 'Gosa Dhiqannaafi Gatii',
      AppLanguage.am: 'የእጥበት ዓይነቶችና ዋጋቸው',
    },
    'myHistory': {
      AppLanguage.en: 'My History',
      AppLanguage.om: 'Seenaa Koo',
      AppLanguage.am: 'የቀደመ ታሪክ',
    },
    'bookThisWash': {
      AppLanguage.en: 'Book This Wash',
      AppLanguage.om: 'Dhiqannaa Qabadhaa',
      AppLanguage.am: 'ይህንን እጥበት ይዘዙ',
    },
    'bookNow': {
      AppLanguage.en: 'Book Now',
      AppLanguage.om: 'Amma Qabadhaa',
      AppLanguage.am: 'አሁን ይዘዙ',
    },
    'automobile': {
      AppLanguage.en: 'Automobile',
      AppLanguage.om: 'Konkolaataa Xiqqaa',
      AppLanguage.am: 'አውቶሞቢል',
    },
    'minibus': {
      AppLanguage.en: 'Minibus',
      AppLanguage.om: 'Minibaasii',
      AppLanguage.am: 'ሚኒባስ',
    },
    'truck': {
      AppLanguage.en: 'Truck / SUV',
      AppLanguage.om: 'Makiinaa Guddaa',
      AppLanguage.am: 'ትራክ / ፒክአፕ / ቪ8',
    },
    'activeWashTitle': {
      AppLanguage.en: 'Active Wash Tracking',
      AppLanguage.om: 'Hordoffii Dhiqannaa Ammaa',
      AppLanguage.am: 'የአሁኑ እጥበት ሁኔታ መከታተያ',
    },
    'openFullTracker': {
      AppLanguage.en: 'Open Full Live Tracker',
      AppLanguage.om: 'Hordoffii Guutuu Bani',
      AppLanguage.am: 'ሙሉ መከታተያውን ክፈት',
    },

    // Cashier Screen
    'cashierTitle': {
      AppLanguage.en: 'Cashier Station Operations',
      AppLanguage.om: 'Hojii Qabaa Qarshii',
      AppLanguage.am: 'የገንዘብ ያዥ የሥራ ሰሌዳ',
    },
    'newWalkIn': {
      AppLanguage.en: 'New Walk-In Entry',
      AppLanguage.om: 'Galmee Haaraa',
      AppLanguage.am: 'አዲስ መኪና አስመዝግብ',
    },
    'todayRevenue': {
      AppLanguage.en: 'Today Revenue',
      AppLanguage.om: 'Galii Har\'aa',
      AppLanguage.am: 'የዛሬ ገቢ',
    },
    'carsWashed': {
      AppLanguage.en: 'cars washed',
      AppLanguage.om: 'konkolaataa dhiqaman',
      AppLanguage.am: 'የታጠቡ መኪኖች',
    },
    'digitalPay': {
      AppLanguage.en: 'Telebirr / CBE',
      AppLanguage.om: 'Telebirr / CBE',
      AppLanguage.am: 'ቴሌብር / ሲቢኢ',
    },
    'cashCollected': {
      AppLanguage.en: 'Cash Collected',
      AppLanguage.om: 'Qarshii Harkaa',
      AppLanguage.am: 'በካሽ የተሰበሰበ',
    },
    'activeWashingBays': {
      AppLanguage.en: 'Active Washing Bays',
      AppLanguage.om: 'Kutaalee Dhiqannaa',
      AppLanguage.am: 'የመኪና ማጠቢያ ክፍሎች',
    },
    'assignVehicle': {
      AppLanguage.en: 'Assign Vehicle',
      AppLanguage.om: 'Makiinaa Ramadi',
      AppLanguage.am: 'መኪና መድብ',
    },
    'startWashing': {
      AppLanguage.en: 'Start Washing',
      AppLanguage.om: 'Dhiqannaa Jalqabi',
      AppLanguage.am: 'ማጠብ ጀምር',
    },
    'setToDrying': {
      AppLanguage.en: 'Set to Drying',
      AppLanguage.om: 'Gogsutti Jijjiiri',
      AppLanguage.am: 'ወደ ማድረቅ ቀይር',
    },
    'markReady': {
      AppLanguage.en: 'Mark Ready for Pickup',
      AppLanguage.om: 'Fudhachuuf Qophii',
      AppLanguage.am: 'ለመረከብ ዝግጁ አድርግ',
    },
    'completeArchive': {
      AppLanguage.en: 'Complete & Archive',
      AppLanguage.om: 'Xumuri',
      AppLanguage.am: 'አጠናቅቅ',
    },
    'queueAndVehicles': {
      AppLanguage.en: 'Queue & Vehicles',
      AppLanguage.om: 'Tarree Konkolaattotaa',
      AppLanguage.am: 'የመኪኖች ወረፋ',
    },
    'filterAll': {
      AppLanguage.en: 'All Active',
      AppLanguage.om: 'Hunda',
      AppLanguage.am: 'ሁሉም',
    },
    'filterPending': {
      AppLanguage.en: 'Pending Bay',
      AppLanguage.om: 'Kutaa Eegaa',
      AppLanguage.am: 'ክፍል የሚጠብቁ',
    },
    'filterInService': {
      AppLanguage.en: 'In Service',
      AppLanguage.om: 'Dhiqamaa Jira',
      AppLanguage.am: 'በእጥበት ላይ',
    },
    'filterUnpaid': {
      AppLanguage.en: 'Unpaid Only',
      AppLanguage.om: 'Kaffaltii Qofa',
      AppLanguage.am: 'ያልተከፈሉ ብቻ',
    },
    'payButton': {
      AppLanguage.en: 'Pay',
      AppLanguage.om: 'Kaffali',
      AppLanguage.am: 'ክፈል',
    },

    // Admin Screen
    'adminTitle': {
      AppLanguage.en: 'Executive Administration Hub',
      AppLanguage.om: 'Wiirtuu Bulchiinsaa',
      AppLanguage.am: 'የአስተዳዳሪ መቆጣጠሪያ ማዕከል',
    },
    'totalRevenueAdmin': {
      AppLanguage.en: 'Total Revenue',
      AppLanguage.om: 'Galii Waliigalaa',
      AppLanguage.am: 'አጠቃላይ ገቢ',
    },
    'commissionsPaid': {
      AppLanguage.en: 'Commissions',
      AppLanguage.om: 'Komishiinii',
      AppLanguage.am: 'ኮሚሽን',
    },
    'netStationProfit': {
      AppLanguage.en: 'Net Station Profit',
      AppLanguage.om: 'Bu\'aa Qulqulluu',
      AppLanguage.am: 'የተጣራ ትርፍ',
    },
    'activeWashers': {
      AppLanguage.en: 'Active Washers',
      AppLanguage.om: 'Hojjettoota Hojirra Jiran',
      AppLanguage.am: 'ንቁ አጣቢዎች',
    },
    'managementOperations': {
      AppLanguage.en: 'Management Operations',
      AppLanguage.om: 'Hojiiwwan Bulchiinsaa',
      AppLanguage.am: 'የአስተዳደር ስራዎች',
    },
    'pricingMatrix': {
      AppLanguage.en: 'Pricing Matrix',
      AppLanguage.om: 'Gatii Tajaajilaa',
      AppLanguage.am: 'የዋጋ ማስተካከያ',
    },
    'pricingSubtitle': {
      AppLanguage.en: 'Edit ETB tariffs for Type A, B, and C',
      AppLanguage.om: 'Gatii konkolaataa jijjiiraa',
      AppLanguage.am: 'ዋጋዎችን እንደ መኪናው ዓይነት ያስተካክሉ',
    },
    'staffPayroll': {
      AppLanguage.en: 'Staff Payroll',
      AppLanguage.om: 'Kaffaltii Hojjettootaa',
      AppLanguage.am: 'የሰራተኞች ደመወዝ',
    },
    'staffPayrollSub': {
      AppLanguage.en: 'Base wages & commission rates',
      AppLanguage.om: 'Miindaa fi komishiinii',
      AppLanguage.am: 'ወርሃዊ ደመወዝና የኮሚሽን ምጣኔ',
    },
    'recentCommissions': {
      AppLanguage.en: 'Recent Washer Commission Splits',
      AppLanguage.om: 'Komishiinii Dhiheenyaa',
      AppLanguage.am: 'የቅርብ ጊዜ የአጣቢዎች ኮሚሽን',
    },
    'viewAll': {
      AppLanguage.en: 'View All',
      AppLanguage.om: 'Hunda Ilaali',
      AppLanguage.am: 'ሁሉንም እይ',
    },
  };

  static String get(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? _strings[key]?[AppLanguage.en] ?? key;
  }
}
