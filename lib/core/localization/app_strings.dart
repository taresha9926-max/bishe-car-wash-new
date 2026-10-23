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
    'back': {
      AppLanguage.en: 'Back',
      AppLanguage.om: 'Deebi\'i',
      AppLanguage.am: 'ተመለስ',
    },
    'close': {
      AppLanguage.en: 'Close',
      AppLanguage.om: 'Cufi',
      AppLanguage.am: 'ዝጋ',
    },
    'cancel': {
      AppLanguage.en: 'Cancel',
      AppLanguage.om: 'Dhiisi',
      AppLanguage.am: 'ሰርዝ',
    },
    'save': {
      AppLanguage.en: 'Save',
      AppLanguage.om: 'Oolchi',
      AppLanguage.am: 'አስቀምጥ',
    },
    'confirm': {
      AppLanguage.en: 'Confirm',
      AppLanguage.om: 'Mirkaneessi',
      AppLanguage.am: 'አረጋግጥ',
    },
    'all': {
      AppLanguage.en: 'All',
      AppLanguage.om: 'Hunda',
      AppLanguage.am: 'ሁሉም',
    },
    'refresh': {
      AppLanguage.en: 'Refresh',
      AppLanguage.om: 'Haaromsi',
      AppLanguage.am: 'አድስ',
    },

    // Customer Screen & Home
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

    // Vehicle Types (CarType)
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
    'automobileSub': {
      AppLanguage.en: 'Sedan, Hatchback, Compact',
      AppLanguage.om: 'Sedan, Hatchback, Xiqqaa',
      AppLanguage.am: 'ሴዳን፣ ሃችባክ፣ አነስተኛ',
    },
    'minibusSub': {
      AppLanguage.en: 'Toyota HiAce, Dolphin, 12-16 seats',
      AppLanguage.om: 'Toyota HiAce, Dolphin, Teessuma 12-16',
      AppLanguage.am: 'ቶዮታ ሃይአይስ፣ ዶልፊን፣ 12-16 መቀመጫ',
    },
    'truckSub': {
      AppLanguage.en: 'Pickup, Heavy SUV, Light Truck',
      AppLanguage.om: 'Pikaappi, Makiinaa Guddaa, V8',
      AppLanguage.am: 'ፒክአፕ፣ ከባድ ቪ8፣ አነስተኛ የጭነት',
    },

    // Wash Statuses (WashStatus)
    'statusPending': {
      AppLanguage.en: 'Pending Approval',
      AppLanguage.om: 'Eeyyama Eegaa',
      AppLanguage.am: 'ፍቃድ በመጠባበቅ ላይ',
    },
    'statusConfirmed': {
      AppLanguage.en: 'Confirmed',
      AppLanguage.om: 'Mirkanaa\'e',
      AppLanguage.am: 'ተረጋግጧል',
    },
    'statusAssignedToBay': {
      AppLanguage.en: 'Queued in Bay',
      AppLanguage.om: 'Kutaa Keessatti Qophaa\'e',
      AppLanguage.am: 'ክፍል ውስጥ ተሰይሟል',
    },
    'statusWashing': {
      AppLanguage.en: 'Washing in Progress',
      AppLanguage.om: 'Dhiqamaa Jira',
      AppLanguage.am: 'እየታጠበ ነው',
    },
    'statusDrying': {
      AppLanguage.en: 'Drying & Detailing',
      AppLanguage.om: 'Gogsamaa fi Qulqullaa\'aa Jira',
      AppLanguage.am: 'እየደረቀና እየጸዳ ነው',
    },
    'statusReadyForPickup': {
      AppLanguage.en: 'Ready for Pickup',
      AppLanguage.om: 'Fudhachuuf Qophiidha',
      AppLanguage.am: 'ለመረከብ ዝግጁ ነው',
    },
    'statusCompleted': {
      AppLanguage.en: 'Completed',
      AppLanguage.om: 'Xumurameera',
      AppLanguage.am: 'ተጠናቋል',
    },
    'statusCancelled': {
      AppLanguage.en: 'Cancelled',
      AppLanguage.om: 'Haqameera',
      AppLanguage.am: 'ተሰርዟል',
    },

    // Service Types (ServiceType)
    'serviceWalkIn': {
      AppLanguage.en: 'Walk-in Station',
      AppLanguage.om: 'Kutaa Dhiqannaa',
      AppLanguage.am: 'የጣቢያ እጥበት',
    },
    'serviceAtHome': {
      AppLanguage.en: 'At-Home Mobile Service',
      AppLanguage.om: 'Tajaajila Makiinaa Socho\'aa',
      AppLanguage.am: 'ተንቀሳቃሽ የቤት ለቤት አገልግሎት',
    },

    // Bay Types (BayType)
    'bay1Name': {
      AppLanguage.en: 'Bay 1 (Station)',
      AppLanguage.om: 'Kutaa 1 (Dhiqannaa)',
      AppLanguage.am: 'ክፍል 1 (ማጠቢያ)',
    },
    'bay2Name': {
      AppLanguage.en: 'Bay 2 (Station)',
      AppLanguage.om: 'Kutaa 2 (Dhiqannaa)',
      AppLanguage.am: 'ክፍል 2 (ማጠቢያ)',
    },
    'bayVanName': {
      AppLanguage.en: 'Mobile Van 1 (At-Home)',
      AppLanguage.om: 'Makiinaa Socho\'aa 1 (Mana)',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን 1 (ቤት ለቤት)',
    },

    // Payment Methods (PaymentMethod)
    'payCash': {
      AppLanguage.en: 'Cash (Gate / Handover)',
      AppLanguage.om: 'Qarshii Harkaa',
      AppLanguage.am: 'በጥሬ ገንዘብ (ካሽ)',
    },
    'payTelebirr': {
      AppLanguage.en: 'Telebirr (Ethio Telecom)',
      AppLanguage.om: 'Telebirr (Ityoo Telekom)',
      AppLanguage.am: 'ቴሌብር (ኢትዮ ቴሌኮም)',
    },
    'payCbeBirr': {
      AppLanguage.en: 'CBE Birr (Commercial Bank)',
      AppLanguage.om: 'CBE Birr (Baankii Daldala)',
      AppLanguage.am: 'ሲቢኢ ብር (ንግድ ባንክ)',
    },
    'payBank': {
      AppLanguage.en: 'Bank Transfer / Mobile Banking',
      AppLanguage.om: 'Dabarsa Baankii',
      AppLanguage.am: 'በባንክ ሒሳብ ማስተላለፍ',
    },

    // Database / SQL Packages Localization
    'pkg_express_name': {
      AppLanguage.en: 'Express Foam Wash',
      AppLanguage.om: 'Dhiqannaa Hoomaa Saffisaa',
      AppLanguage.am: 'አጭር የሳሙና አረፋ እጥበት',
    },
    'pkg_express_desc': {
      AppLanguage.en: 'High-pressure water rinse, active snow foam soak, tire shine & hand dry.',
      AppLanguage.om: 'Bishaan dhiibbaa guddaa, hoomaa dhiqannaa, gogaa gommaa fi qoorsuu harkaa.',
      AppLanguage.am: 'በከፍተኛ የውሃ ግፊት ማጠብ፣ ንቁ የሳሙና አረፋ፣ የጎማ ማብሪያና ማድረቅ።',
    },
    'pkg_standard_name': {
      AppLanguage.en: 'Standard Clean & Vacuum',
      AppLanguage.om: 'Qulqullina Idilee & Vaakiyuumii',
      AppLanguage.am: 'መደበኛ ሙሉ እጥበትና ቫኪዩም',
    },
    'pkg_standard_desc': {
      AppLanguage.en: 'Complete exterior body wash plus deep interior vacuum, dashboard wipe & glass cleaning.',
      AppLanguage.om: 'Dhiqannaa alaa guutuu, keessa vaakiyuumii gochuu, daashboordii fi fuula daawwitii qulqulleessuu.',
      AppLanguage.am: 'ሙሉ የውጭ አካል እጥበት፣ የውስጥ ቫኪዩም፣ ዳሽቦርድ ማፅዳትና መስታወት ማብራት።',
    },
    'pkg_deluxe_name': {
      AppLanguage.en: 'Deluxe Spa & Engine Detail',
      AppLanguage.om: 'Ispaa Dilaaksii & Qulqullina Motoraa',
      AppLanguage.am: 'ልዩ ስፓ እና የሞተር እጥበት',
    },
    'pkg_deluxe_desc': {
      AppLanguage.en: 'Comprehensive exterior hand polish, high-temperature interior steam sanitize, engine bay shampoo & synthetic spray wax.',
      AppLanguage.om: 'Pooliishii harkaa, hurka ho\'aan keessa qulqulleessuu, saamunaa motoraa fi waaksii alaa.',
      AppLanguage.am: 'የእጅ ፖሊሽ፣ በከፍተኛ ሙቀት እንፋሎት የውስጥ ማፅዳት፣ የሞተር ሻምፑና የሰም ቅባት።',
    },
    'pkg_mobile_name': {
      AppLanguage.en: 'Mobile At-Home Express Van',
      AppLanguage.om: 'Makiinaa Socho\'aa Mana Keessanitti',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን (ቤትዎ ድረስ)',
    },
    'pkg_mobile_desc': {
      AppLanguage.en: 'Doorstep wash anywhere in Bishoftu. Onboard high-pressure system, spotless deionized water & silent generator.',
      AppLanguage.om: 'Bishoftuu keessatti bakka jirtanitti dhiqannaa. Bishaan qulqulluu fi jenereetara sagalee hin qabne.',
      AppLanguage.am: 'ቢሾፍቱ ውስጥ ባሉበት ቦታ ድረስ መጥቶ ማጠብ። የራሱ የውሃ ታንክና ፀጥተኛ ጄነሬተር ያለው።',
    },

    // Staff Roles
    'roleWasher': {
      AppLanguage.en: 'Car Washer',
      AppLanguage.om: 'Dhiqaa Konkolaataa',
      AppLanguage.am: 'መኪና አጣቢ',
    },
    'roleCashier': {
      AppLanguage.en: 'Cashier Desk',
      AppLanguage.om: 'Qabaa Qarshii',
      AppLanguage.am: 'ገንዘብ ያዥ',
    },
    'roleAdmin': {
      AppLanguage.en: 'Admin / Manager',
      AppLanguage.om: 'Bulchaa / Hojii Geggeessaa',
      AppLanguage.am: 'አስተዳዳሪ / ስራ አስኪያጅ',
    },
    'roleLeadDetailer': {
      AppLanguage.en: 'Lead Detailer',
      AppLanguage.om: 'Gaggeessaa Qulqullinaa',
      AppLanguage.am: 'ዋና የእጥበት ባለሙያ',
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
    'digitalReceiptsTitle': {
      AppLanguage.en: 'Digital Receipts & Verification',
      AppLanguage.om: 'Nagahee Dijitaalaafi Qorannoo',
      AppLanguage.am: 'የዲጂታል ደረሰኞችና ማረጋገጫ',
    },
    'noDigitalReceipts': {
      AppLanguage.en: 'No digital payments recorded yet today.',
      AppLanguage.om: 'Kaffaltiin dijitaalaa har\'aa hin jiru.',
      AppLanguage.am: 'ዛሬ የተመዘገበ የዲጂታል ክፍያ የለም።',
    },
    'viewReceipt': {
      AppLanguage.en: 'View Receipt',
      AppLanguage.om: 'Nagahee Ilaali',
      AppLanguage.am: 'ደረሰኝ እይ',
    },
    'noReceipt': {
      AppLanguage.en: 'No Receipt',
      AppLanguage.om: 'Nagahee Hin Qabu',
      AppLanguage.am: 'ደረሰኝ የለም',
    },
    'pricingManagementTitle': {
      AppLanguage.en: 'Service Pricing by Car Type',
      AppLanguage.om: 'Gatii Tajaajilaa Konkolaataan',
      AppLanguage.am: 'የእጥበት ዋጋ እንደ መኪናው ዓይነት',
    },
    'staffManagementTitle': {
      AppLanguage.en: 'Staff & Salaries Management',
      AppLanguage.om: 'Bulchiinsa Hojjettootaafi Miindaa',
      AppLanguage.am: 'የሰራተኞችና ደመወዝ አስተዳደር',
    },
    'commissionLogsTitle': {
      AppLanguage.en: 'Washer Commission Logs',
      AppLanguage.om: 'Galmee Komishiinii Dhiqaa',
      AppLanguage.am: 'የአጣቢዎች ኮሚሽን ዝርዝር መዝገብ',
    },
    'addStaff': {
      AppLanguage.en: 'Add Staff',
      AppLanguage.om: 'Hojjetaa Dabali',
      AppLanguage.am: 'ሰራተኛ መዝግብ',
    },
    'liveTrackingTitle': {
      AppLanguage.en: 'Live Wash Tracking',
      AppLanguage.om: 'Hordoffii Dhiqannaa Kallattii',
      AppLanguage.am: 'የቀጥታ እጥበት ሁኔታ መከታተያ',
    },
    'bookWashTitle': {
      AppLanguage.en: 'Book Car Wash',
      AppLanguage.om: 'Dhiqannaa Qabadhaa',
      AppLanguage.am: 'መኪና እጥበት ይዘዙ',
    },
    'walkInTitle': {
      AppLanguage.en: 'Gate Walk-In Registration',
      AppLanguage.om: 'Galmee Balbala Duraa',
      AppLanguage.am: 'የበር ላይ መኪና ምዝገባ',
    },
    'paymentDialogTitle': {
      AppLanguage.en: 'Process Payment',
      AppLanguage.om: 'Kaffaltii Raawwadhu',
      AppLanguage.am: 'ክፍያ ተቀበል',
    },
    'historyTitle': {
      AppLanguage.en: 'My Wash History',
      AppLanguage.om: 'Seenaa Dhiqannaa Koo',
      AppLanguage.am: 'የቀደመ እጥበት ታሪኬ',
    },
    'noRecords': {
      AppLanguage.en: 'No booking records available',
      AppLanguage.om: 'Galmeen dhiqannaa hin jiru',
      AppLanguage.am: 'ምንም የተመዘገበ ታሪክ የለም',
    },
    'total': {
      AppLanguage.en: 'Total',
      AppLanguage.om: 'Waliigala',
      AppLanguage.am: 'ጠቅላላ',
    },
    'licensePlate': {
      AppLanguage.en: 'License Plate',
      AppLanguage.om: 'Gabatee Makiinaa',
      AppLanguage.am: 'የሰሌዳ ቁጥር',
    },
    'customerName': {
      AppLanguage.en: 'Customer Name',
      AppLanguage.om: 'Maqaa Maamilaa',
      AppLanguage.am: 'የደንበኛው ስም',
    },
    'customerPhone': {
      AppLanguage.en: 'Phone Number',
      AppLanguage.om: 'Lakkoofsa Bilbilaa',
      AppLanguage.am: 'ስልክ ቁጥር',
    },
    'locationArea': {
      AppLanguage.en: 'Delivery Location / Bishoftu Area',
      AppLanguage.om: 'Iddoo Geessisaa / Bishoftuu',
      AppLanguage.am: 'የሚታጠብበት አድራሻ (ቢሾፍቱ)',
    },
    'paymentMethod': {
      AppLanguage.en: 'Payment Method',
      AppLanguage.om: 'Mala Kaffaltii',
      AppLanguage.am: 'የክፍያ ዘዴ',
    },
    'transactionRef': {
      AppLanguage.en: 'Transfer Reference (Optional)',
      AppLanguage.om: 'Koodii Dabarsaa (Dirqama Miti)',
      AppLanguage.am: 'የክፍያ ማረጋገጫ ቁጥር (አስፈላጊ ከሆነ)',
    },
    'uploadReceipt': {
      AppLanguage.en: 'Upload Payment Screenshot',
      AppLanguage.om: 'Suuraa Nagahee Galchaa',
      AppLanguage.am: 'የደረሰኝ ፎቶ / ስክሪንሽት ጫን',
    },
    'receiptUploaded': {
      AppLanguage.en: 'Receipt screenshot attached',
      AppLanguage.om: 'Suuraan nagahee qabsiifameera',
      AppLanguage.am: 'የደረሰኙ ፎቶ በተሳካ ሁኔታ ተያይዟል',
    },
    'confirmAndPay': {
      AppLanguage.en: 'Confirm & Complete Payment',
      AppLanguage.om: 'Mirkaneessiitii Kaffali',
      AppLanguage.am: 'አረጋግጥና ክፍያ ፈፅም',
    },
    'assignBayWasher': {
      AppLanguage.en: 'Assign Bay / Washer',
      AppLanguage.om: 'Kutaa / Dhiqaa Ramadi',
      AppLanguage.am: 'ክፍልና አጣቢ መድብ',
    },
    'baseMonthlySalary': {
      AppLanguage.en: 'BASE MONTHLY SALARY',
      AppLanguage.om: 'MIINDAA JIOOTAA BU\'UURAA',
      AppLanguage.am: 'ወርሃዊ ቋሚ ደመወዝ',
    },
    'commissionRate': {
      AppLanguage.en: 'COMMISSION RATE',
      AppLanguage.om: 'HAMMA KOMISHIINII',
      AppLanguage.am: 'የኮሚሽን ምጣኔ',
    },
  };

  static String get(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? _strings[key]?[AppLanguage.en] ?? key;
  }
}
