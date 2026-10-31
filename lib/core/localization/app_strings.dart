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
    'storekeeperRole': {
      AppLanguage.en: 'Storekeeper Desk',
      AppLanguage.om: 'Kuusaa Qulqullinaa',
      AppLanguage.am: 'ዕቃ ግምጃ ቤት',
    },
    'accountantRole': {
      AppLanguage.en: 'Accountant Hub',
      AppLanguage.om: 'Herrega & Faayinaansii',
      AppLanguage.am: 'ሂሳብ እና ኦዲት',
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

    // Vehicle Types (CarType: Type A Small, Type B Medium, Type C Large Trucks)
    'automobile': {
      AppLanguage.en: 'Type A (Small)',
      AppLanguage.om: 'Gosa A (Xiqqaa)',
      AppLanguage.am: 'ዓይነት ሀ (አነስተኛ)',
    },
    'minibus': {
      AppLanguage.en: 'Type B (Medium)',
      AppLanguage.om: 'Gosa B (Giddu-galeessa)',
      AppLanguage.am: 'ዓይነት ለ (መካከለኛ/ቪ8)',
    },
    'truck': {
      AppLanguage.en: 'Type C (Truck)',
      AppLanguage.om: 'Gosa C (Fe\'iisaa)',
      AppLanguage.am: 'ዓይነት ሐ (የጭነት/ኢሱዙ)',
    },
    'automobileSub': {
      AppLanguage.en: 'Corolla, Dzire, Yaris, Vitz, BYD',
      AppLanguage.om: 'Corolla, Dzire, Yaris, Vitz, BYD',
      AppLanguage.am: 'ኮሮላ፣ ዲዛየር፣ ያሪስ፣ ቪትዝ፣ ቢዋይዲ',
    },
    'minibusSub': {
      AppLanguage.en: 'V8, Bigstar, Hilux, Dolphin',
      AppLanguage.om: 'V8, Bigstar, Hilux, Dolphin',
      AppLanguage.am: 'ቪ8፣ ቢግስታር፣ ሃይሉክስ፣ ዶልፊን',
    },
    'truckSub': {
      AppLanguage.en: 'Isuzu 1200, FSR 1800',
      AppLanguage.om: 'Isuzu 1200, FSR 1800',
      AppLanguage.am: 'ኢሱዙ 1200፣ ኤፍኤስአር 1800',
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
    'servicePhoneCall': {
      AppLanguage.en: 'Phone Reservation',
      AppLanguage.om: 'Qabannaa Bilbilaa',
      AppLanguage.am: 'የስልክ ጥሪ ትዕዛዝ',
    },
    'servicePhoneCallSub': {
      AppLanguage.en: 'Pre-booked via Gate Phone Call',
      AppLanguage.om: 'Bilbilaan duraan qabame',
      AppLanguage.am: 'በስልክ ጥሪ አስቀድሞ የተያዘ',
    },

    // Welcome Screen & Portal
    'welcomeTitle': {
      AppLanguage.en: 'BISHE Car Wash Hub',
      AppLanguage.om: 'Giddugala Dhiqannaa BISHE',
      AppLanguage.am: 'ቢሼ የመኪና ማጠቢያ ማዕከል',
    },
    'welcomeSubtitle': {
      AppLanguage.en: 'Premier Auto Detailing & Care in Bishoftu',
      AppLanguage.om: 'Dhiqannaafi Kunuunsa Makiinaa Qulqulluu Bishooftuutti',
      AppLanguage.am: 'በቢሾፍቱ ምርጡ የዲቴይሊንግ እና የመኪና እንክብካቤ ማዕከል',
    },
    'carouselSlide1Title': {
      AppLanguage.en: 'Active Snow Foam Pre-Soak',
      AppLanguage.om: 'Dhiqannaa Hoomaa Qulqulluu',
      AppLanguage.am: 'ንክኪ-አልባ የሆም አረፋ እጥበት',
    },
    'carouselSlide1Desc': {
      AppLanguage.en: 'Scratch-free dirt breakdown with pH-neutral active shampoo',
      AppLanguage.om: 'Qulqullina olaanaa fi eegumsa rifeensa konkolaataa',
      AppLanguage.am: 'የመኪናውን ቀለም የማይጎዳ ጥልቅ ቆሻሻ ማስወገጃ',
    },
    'carouselSlide2Title': {
      AppLanguage.en: 'High-Pressure Chassis & Jet Steam',
      AppLanguage.om: 'Bishaan Dhiibbaa Ol-aanaa & Shassii',
      AppLanguage.am: 'ከፍተኛ ግፊት የታችኛው አካል እጥበት',
    },
    'carouselSlide2Desc': {
      AppLanguage.en: 'Deep wheel-well cleaning & high-power underside rinse',
      AppLanguage.om: 'Qulqullina gommaa fi jala konkolaataa cimaa',
      AppLanguage.am: 'የጎማ እና የታችኛው ክፍል ከባድ የጭቃ እጥበት',
    },
    'carouselSlide3Title': {
      AppLanguage.en: 'Diamond Polish & Ceramic Shield',
      AppLanguage.om: 'Poolishii Daayimandii & Eegumsa',
      AppLanguage.am: 'ዳይመንድ ፖሊሽ እና ሴራሚክ ከለላ',
    },
    'carouselSlide3Desc': {
      AppLanguage.en: 'Hydrophobic ceramic protection & showroom mirror gloss',
      AppLanguage.om: 'Calaqqisa addaa fi eegumsa aduu fi bishaanii',
      AppLanguage.am: 'የመስታወት ነፀብራቅ ወዝ እና የውሃ መከላከያ ከለላ',
    },
    'carouselSlide4Title': {
      AppLanguage.en: 'Rapid Express Bay Wash',
      AppLanguage.om: 'Tajaajila Dafee Qophaa\'u (Daqiiqaa 15)',
      AppLanguage.am: 'ፈጣን የ15 ደቂቃ ኤክስፕረስ እጥበት',
    },
    'carouselSlide4Desc': {
      AppLanguage.en: 'Fast automated rinse & wax with zero wait time',
      AppLanguage.om: 'Turtii malee tajaajila saffisaa fi ammayyaa',
      AppLanguage.am: 'ያለ ምንም ሰልፍ ፈጣን እና ዘመናዊ የእጥበት አገልግሎት',
    },
    'openGoogleMaps': {
      AppLanguage.en: 'Open in Google Maps 📍',
      AppLanguage.om: 'Kaartaa Google irratti Bani 📍',
      AppLanguage.am: 'በጉግል ካርታ ክፈት 📍',
    },
    'locateBisheStation': {
      AppLanguage.en: 'Locate BISHE Station',
      AppLanguage.om: 'Bakka BISHE Argadhaa',
      AppLanguage.am: 'የቢሼ ማጠቢያን መገኛ አግኝ',
    },
    'customerPortal': {
      AppLanguage.en: 'Customer Portal',
      AppLanguage.om: 'Balbala Maamiltootaa',
      AppLanguage.am: 'የደንበኞች መግቢያ',
    },
    'customerPortalDesc': {
      AppLanguage.en: 'Browse 10 packages, book wash & private live wash tracking',
      AppLanguage.om: 'Gosoota 10 ilaalaa, qabadhaa fi makiinaa keessan hordofaa',
      AppLanguage.am: '10 ፓኬጆችን ይመልከቱ፣ እጥበት ይዘዙ እና ሁኔታውን ይከታተሉ',
    },
    'cashierPortal': {
      AppLanguage.en: 'Cashier Gate Desk',
      AppLanguage.om: 'Kaffaltii & Seensa Balbalaa',
      AppLanguage.am: 'የካሸር በር ዴስክ',
    },
    'cashierPortalDesc': {
      AppLanguage.en: 'Gate walk-in check-in, phone call bookings & post-wash payments',
      AppLanguage.om: 'Galmee balbalaa, bilbila, adeemsa dhiqannaafi kaffaltii',
      AppLanguage.am: 'የበር መግቢያ ምዝገባ፣ የስልክ ጥሪ፣ የእጥበት ሂደትና የድህረ-እጥበት ክፍያ',
    },
    'adminPortal': {
      AppLanguage.en: 'Admin Console',
      AppLanguage.om: 'To\'annoo Bulchiinsaa',
      AppLanguage.am: 'የአስተዳዳሪ መቆጣጠሪያ',
    },
    'adminPortalDesc': {
      AppLanguage.en: 'Staff control, 15% washer team dividends, PINs & time reports',
      AppLanguage.om: 'Hojjattoota, komishiinii 15%, koodii duraafi gabaasa yeroo',
      AppLanguage.am: 'ሰራተኞች፣ የ15% አጣቢዎች ኮሚሽን፣ ሚስጥር ቁጥርና የጊዜ ሪፖርቶች',
    },
    'staffPortals': {
      AppLanguage.en: 'Staff Portals',
      AppLanguage.om: 'Balbala Hojjettootaa',
      AppLanguage.am: 'የሰራተኞች መግቢያ',
    },
    'staffMenuDesc': {
      AppLanguage.en: 'Staff & Admin Access Only',
      AppLanguage.om: 'Seensa Hojjettootaafi Bulchiinsaa Qofa',
      AppLanguage.am: 'የሰራተኞች እና የአስተዳዳሪ ብቻ',
    },
    'cashierPinBadge': {
      AppLanguage.en: 'Gate Desk',
      AppLanguage.om: 'Balbala Seensaa',
      AppLanguage.am: 'የመግቢያ በር',
    },
    'storekeeperPortal': {
      AppLanguage.en: 'Storekeeper Inventory',
      AppLanguage.om: 'Kuusaa Qulqullinaa',
      AppLanguage.am: 'የዕቃ ግምጃ ቤት',
    },
    'storekeeperPinBadge': {
      AppLanguage.en: 'Supplies & Assets',
      AppLanguage.om: 'Meeshaalee & Qabeenya',
      AppLanguage.am: 'እቃዎች እና ቋሚ ንብረቶች',
    },
    'accountantPortal': {
      AppLanguage.en: 'Accountant Hub',
      AppLanguage.om: 'Herrega & Faayinaansii',
      AppLanguage.am: 'የሂሳብ እና ፋይናንስ ማዕከል',
    },
    'accountantPinBadge': {
      AppLanguage.en: 'Audits & P&L',
      AppLanguage.om: 'Herrega & Bu\'aa',
      AppLanguage.am: 'ኦዲት እና ትርፍ/ኪሳራ',
    },
    'adminPinBadge': {
      AppLanguage.en: 'Super Admin Hub',
      AppLanguage.om: 'Giddugala Bulchiinsaa',
      AppLanguage.am: 'ዋና አስተዳዳሪ ማዕከል',
    },
    'enterCustomerPortal': {
      AppLanguage.en: 'Enter Customer Portal',
      AppLanguage.om: 'Gara Balbala Maamilaa Seenaa',
      AppLanguage.am: 'ወደ ደንበኛ መግቢያ ይግቡ',
    },
    'customerTrustPill': {
      AppLanguage.en: 'Instant Wash Booking • Live Queue Tracker',
      AppLanguage.om: 'Dhiqannaa Battalaa • Hordoffii Qophii Kallattii',
      AppLanguage.am: 'ፈጣን የእጥበት ትዕዛዝ • የቀጥታ የሰልፍ መከታተያ',
    },
    'tiktokReelsTitle': {
      AppLanguage.en: 'OFFICIAL TIKTOK REELS',
      AppLanguage.om: 'REEL TIKTOOKII OFFICIAL',
      AppLanguage.am: 'ይፋዊ የቲክቶክ ቪዲዮዎች',
    },
    'tapToWatchInTikTok': {
      AppLanguage.en: 'Tap to Watch in TikTok App',
      AppLanguage.om: 'App TikTok irratti daawwadhaa',
      AppLanguage.am: 'በቲክቶክ አፕ ይመልከቱ',
    },
    'openInTikTok': {
      AppLanguage.en: 'Open in TikTok 🎵',
      AppLanguage.om: 'TikTok irratti Bani 🎵',
      AppLanguage.am: 'በቲክቶክ ክፈት 🎵',
    },
    'redirectingToTikTok': {
      AppLanguage.en: 'Redirecting to TikTok app... 🎵',
      AppLanguage.om: 'Gara App TikToktti dabarsaa jira... 🎵',
      AppLanguage.am: 'ወደ ቲክቶክ አፕ በመሄድ ላይ... 🎵',
    },
    'stationBishoftuLocation': {
      AppLanguage.en: 'Bishoftu (Debre Zeyit), Oromia, Ethiopia',
      AppLanguage.om: 'Bishoftuu (Dabrazayiti), Oromiyaa, Itoophiyaa',
      AppLanguage.am: 'ቢሾፍቱ (ደብረ ዘይት)፣ ኦሮሚያ፣ ኢትዮጵያ',
    },
    'reelCounter': {
      AppLanguage.en: 'REEL',
      AppLanguage.om: 'REEL',
      AppLanguage.am: 'ቪዲዮ',
    },
    'ofWord': {
      AppLanguage.en: 'OF',
      AppLanguage.om: 'IRRAA',
      AppLanguage.am: 'ከ',
    },
    'publicAccess': {
      AppLanguage.en: 'PUBLIC ACCESS',
      AppLanguage.om: 'HUNDAAF BANAA',
      AppLanguage.am: 'ለሁሉም ክፍት',
    },
    'openBadge': {
      AppLanguage.en: 'OPEN NOW',
      AppLanguage.om: 'BANAA DA',
      AppLanguage.am: 'ክፍት ነው',
    },
    'stationCapBays': {
      AppLanguage.en: '2 Pressure Bays',
      AppLanguage.om: 'Iddoo Dhiqannaa 2',
      AppLanguage.am: '2 የማጠቢያ ክፍሎች',
    },
    'stationCapVan': {
      AppLanguage.en: '1 At-Home Van',
      AppLanguage.om: 'Makiinaa Manaa 1',
      AppLanguage.am: '1 የሞባይል ቫን',
    },
    'stationCapPackages': {
      AppLanguage.en: '10 Detailing Packages',
      AppLanguage.om: 'Paakeejii 10',
      AppLanguage.am: '10 ፓኬጆች',
    },

    // Readable Progression & Payment Lock
    'startWashAction': {
      AppLanguage.en: 'Start Wash 🚿',
      AppLanguage.om: 'Dhiqannaa Jalqabi 🚿',
      AppLanguage.am: 'እጥበት ጀምር 🚿',
    },
    'moveToDryingAction': {
      AppLanguage.en: 'Move to Drying 💨',
      AppLanguage.om: 'Gogsatti Dabarsi 💨',
      AppLanguage.am: 'ወደ ማድረቅ አሳልፍ 💨',
    },
    'markCompletedAction': {
      AppLanguage.en: 'Mark Completed 🚗',
      AppLanguage.om: 'Xumurameera Jedhi 🚗',
      AppLanguage.am: 'ተጠናቋል በል 🚗',
    },
    'collectPaymentAction': {
      AppLanguage.en: 'Collect Payment 💰',
      AppLanguage.om: 'Kaffaltii Fudhadhu 💰',
      AppLanguage.am: 'ክፍያ ተቀበል 💰',
    },
    'paymentLockedUntilCompleted': {
      AppLanguage.en: 'Payment unlocks after vehicle is marked completed',
      AppLanguage.om: 'Kaffaltiin kan banamu erga dhiqamee xumuramee qofa',
      AppLanguage.am: 'ክፍያ የሚፈቀደው እጥበቱ ተጠናቋል ተብሎ ከተረጋገጠ በኋላ ብቻ ነው',
    },
    'registerPhoneBooking': {
      AppLanguage.en: 'Register Phone Booking 📞',
      AppLanguage.om: 'Galmee Bilbilaa 📞',
      AppLanguage.am: 'የስልክ ጥሪ ትዕዛዝ መዝግብ 📞',
    },
    'phoneBookingCallerName': {
      AppLanguage.en: 'Caller / Customer Name',
      AppLanguage.om: 'Maqaa Maamilaa',
      AppLanguage.am: 'የደዋይ / ደንበኛ ስም',
    },
    'phoneBookingArrival': {
      AppLanguage.en: 'Expected Arrival Slot',
      AppLanguage.om: 'Yeroo Dhufan',
      AppLanguage.am: 'የሚመጡበት ሰዓት',
    },
    'paymentAtGateNote': {
      AppLanguage.en: 'No advance payment needed. Payment is settled at the gate once your vehicle is washed.',
      AppLanguage.om: 'Kaffaltii duroo hin barbaachisu. Kaffaltiin kan kaffalamu erga makiinaan dhiqamee booda.',
      AppLanguage.am: 'ቅድመ ክፍያ አያስፈልግም። ክፍያ የሚፈጸመው መኪናዎ ታጥቦ ሲጠናቀቅ በካሸር ዴስክ ላይ ነው።',
    },

    // Admin Time Filters & Seniority Commission
    'filterToday': {
      AppLanguage.en: 'Today (Daily)',
      AppLanguage.om: 'Har\'a (Guyyaa)',
      AppLanguage.am: 'ዛሬ (ዕለታዊ)',
    },
    'filterYesterday': {
      AppLanguage.en: 'Yesterday',
      AppLanguage.om: 'Kaleessa',
      AppLanguage.am: 'ትናንት',
    },
    'filterThisWeek': {
      AppLanguage.en: 'This Week (Weekly)',
      AppLanguage.om: 'Torban Kana (Torban)',
      AppLanguage.am: 'በዚህ ሳምንት (ሳምንታዊ)',
    },
    'filterThisMonth': {
      AppLanguage.en: 'This Month (Monthly)',
      AppLanguage.om: 'Ji\'a Kana (Ji\'a)',
      AppLanguage.am: 'በዚህ ወር (ወርሃዊ)',
    },
    'filterCustomRange': {
      AppLanguage.en: 'Custom Range',
      AppLanguage.om: 'Yeroo Filatame',
      AppLanguage.am: 'የተመረጠ የጊዜ ክልል',
    },
    'filterAllTime': {
      AppLanguage.en: 'All Time',
      AppLanguage.om: 'Yeroo Hunda',
      AppLanguage.am: 'ሁሉንም ጊዜ',
    },
    'teamCommissionDistribution': {
      AppLanguage.en: '15% Team Commission Seniority Distribution',
      AppLanguage.om: 'Qoqqoodama Komishiinii Garee 15% Sadarkaan',
      AppLanguage.am: 'የ15% የቡድን አጣቢዎች ኮሚሽን በደረጃ ክፍፍል',
    },
    'disburseCommission': {
      AppLanguage.en: 'Disburse Commission Pool',
      AppLanguage.om: 'Komishiinii Raabsi',
      AppLanguage.am: 'ኮሚሽን አከፋፍል',
    },
    'commissionDisbursedSuccess': {
      AppLanguage.en: 'Commission dividends successfully approved and logged!',
      AppLanguage.om: 'Komishiiniin milkaa\'inaan raabsamee galmaa\'eera!',
      AppLanguage.am: 'የኮሚሽን ክፍፍል በተሳካ ሁኔታ ጸድቆ ተመዝግቧል!',
    },
    'seniorityWeight': {
      AppLanguage.en: 'Seniority Weight',
      AppLanguage.om: 'Ulfaatina Sadarkaa',
      AppLanguage.am: 'የደረጃ ክብደት',
    },
    'cashVsDigital': {
      AppLanguage.en: 'Cash vs Digital Settlement',
      AppLanguage.om: 'Kaffaltii Qarshii fi Dijitaalaa',
      AppLanguage.am: 'የጥሬ ገንዘብ እና ዲጂታል ክፍያ ንፅፅር',
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
    'pkg_silver_name': {
      AppLanguage.en: 'Basic / Silver Package',
      AppLanguage.om: 'Paakeejii Bu\'uuraa / Meetaa',
      AppLanguage.am: 'ቤሲክ / ሲልቨር ፓኬጅ',
    },
    'pkg_silver_desc': {
      AppLanguage.en: 'Basic wash for exterior body and glass clean.',
      AppLanguage.om: 'Dhiqannaa bu\'uuraa qaama alaa fi fuula daawwitii.',
      AppLanguage.am: 'መሰረታዊ የውጭ አካል እና የመስታወት እጥበት።',
    },
    'pkg_gold_name': {
      AppLanguage.en: 'Gold Package (Polish)',
      AppLanguage.om: 'Paakeejii Warqee (Pooliishii)',
      AppLanguage.am: 'ጎልድ ፓኬጅ (ፖሊሽ)',
    },
    'pkg_gold_desc': {
      AppLanguage.en: 'Basic wash plus premium protective body polish.',
      AppLanguage.om: 'Dhiqannaa bu\'uuraa fi pooliishii qulqulluu eegumsa qaamaa.',
      AppLanguage.am: 'መሰረታዊ እጥበት ከፕሪሚየም የቦዲ ፖሊሽ ማብሪያ ጋር።',
    },
    'pkg_plat_interior_name': {
      AppLanguage.en: 'Platinum Interior Detailing',
      AppLanguage.om: 'Pulaatiiniyemii Dhiqannaa Keessoo Guutuu',
      AppLanguage.am: 'ፕላቲነም የውስጥ ሙሉ ዲቴይሊንግ',
    },
    'pkg_plat_interior_desc': {
      AppLanguage.en: 'Seat & floor carpet removed & washing + roof deep cleaning + dashboard detailing.',
      AppLanguage.om: 'Barcuma & karpeeta lafaa baasanii dhiqquu + baaxii qulqulleessuu + daashboordii.',
      AppLanguage.am: 'ወንበርና ምንጣፍ ወጥቶ የሚታጠብ + የጣሪያ ጥልቅ ጽዳት + የዳሽቦርድ ዲቴይሊንግ።',
    },
    'pkg_plat_ext_a_name': {
      AppLanguage.en: 'Platinum Exterior - A',
      AppLanguage.om: 'Pulaatiiniyemii Alaa - Paakeejii A',
      AppLanguage.am: 'ፕላቲነም የውጭ - ፓኬጅ ኤ',
    },
    'pkg_plat_ext_a_desc': {
      AppLanguage.en: 'Body Polish + Water Spot removal and gloss treatment.',
      AppLanguage.om: 'Pooliishii qaamaa + bakkoota bishaanii balleessuu fi calaqqisiisuu.',
      AppLanguage.am: 'የቦዲ ፖሊሽ እና የውሃ ምልክት ማጥፊያ ህክምና።',
    },
    'pkg_plat_ext_b_name': {
      AppLanguage.en: 'Platinum Exterior - B',
      AppLanguage.om: 'Pulaatiiniyemii Alaa - Paakeejii B',
      AppLanguage.am: 'ፕላቲነም የውጭ - ፓኬጅ ቢ',
    },
    'pkg_plat_ext_b_desc': {
      AppLanguage.en: 'Body + Water Spot + Tire Detailing & rim protection.',
      AppLanguage.om: 'Qaama + bakkoota bishaanii + dhiqannaa & eegumsa gommaa.',
      AppLanguage.am: 'የቦዲ + የውሃ ምልክት ማጥፊያ + የጎማ እና ሪም ዲቴይሊንግ።',
    },
    'pkg_plat_ext_c_name': {
      AppLanguage.en: 'Platinum Exterior - C',
      AppLanguage.om: 'Pulaatiiniyemii Alaa - Paakeejii C',
      AppLanguage.am: 'ፕላቲነም የውጭ - ፓኬጅ ሲ',
    },
    'pkg_plat_ext_c_desc': {
      AppLanguage.en: 'Body + Water Spot + Tire Detailing + Headlight restoration.',
      AppLanguage.om: 'Qaama + bishaan + gommaa + ifa ija konkolaataa haaromsuu.',
      AppLanguage.am: 'የቦዲ + የውሃ ምልክት + የጎማ ዲቴይሊንግ + የፊት መብራት ማብሪያ።',
    },
    'pkg_diamond_a_name': {
      AppLanguage.en: 'Diamond Package A',
      AppLanguage.om: 'Paakeejii Daayimandii A',
      AppLanguage.am: 'ዳይመንድ ፓኬጅ ኤ',
    },
    'pkg_diamond_a_desc': {
      AppLanguage.en: 'Interior Full Detailing & Body Polish + Water Spot treatment.',
      AppLanguage.om: 'Dhiqannaa keessoo guutuu & pooliishii qaamaa + bishaan dhabamsiisuu.',
      AppLanguage.am: 'የውስጥ ሙሉ ዲቴይሊንግ እና የቦዲ ፖሊሽ + የውሃ ምልክት ማጥፊያ።',
    },
    'pkg_diamond_b_name': {
      AppLanguage.en: 'Diamond Package B',
      AppLanguage.om: 'Paakeejii Daayimandii B',
      AppLanguage.am: 'ዳይመንድ ፓኬጅ ቢ',
    },
    'pkg_diamond_b_desc': {
      AppLanguage.en: 'Interior Full Detailing & Body + Water Spot + Tire Detailing.',
      AppLanguage.om: 'Dhiqannaa keessoo guutuu & qaama + bishaan + gommaa.',
      AppLanguage.am: 'የውስጥ ሙሉ ዲቴይሊንግ እና ቦዲ + የውሃ ምልክት + የጎማ ዲቴይሊንግ።',
    },
    'pkg_diamond_full_name': {
      AppLanguage.en: 'Diamond Package C (Full)',
      AppLanguage.om: 'Paakeejii Daayimandii C (Guutuu)',
      AppLanguage.am: 'ዳይመንድ ፓኬጅ ሲ (ሙሉ)',
    },
    'pkg_diamond_full_desc': {
      AppLanguage.en: 'Ultimate Interior Detailing + Exterior Comprehensive detailing suite.',
      AppLanguage.om: 'Dhiqannaa keessaa fi alaa sadarkaa olaanaa guutuu.',
      AppLanguage.am: 'የላቀ የውስጥ እና የውጭ የተሟላ የዲቴይሊንግ አገልግሎት።',
    },
    'pkg_engine_chem_name': {
      AppLanguage.en: 'Engine Chemical Cleaning',
      AppLanguage.om: 'Qulqullina Keemikaala Motoraa',
      AppLanguage.am: 'የሞተር ኬሚካል እጥበት',
    },
    'pkg_engine_chem_desc': {
      AppLanguage.en: 'Basic / Silver package wash + professional engine chemical degrease.',
      AppLanguage.om: 'Dhiqannaa bu\'uuraa meetaa + dhangala\'aa motoraa keemikaalaan qulqulleessuu.',
      AppLanguage.am: 'የቤሲክ / ሲልቨር እጥበት + የሞተር ኬሚካል ፍላሽ እና ዲግሪዝ።',
    },
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
    'pkg_executive_name': {
      AppLanguage.en: 'Executive Detailing & Wax',
      AppLanguage.om: 'Dhiqannaa Sadarkaa Olaanaa & Waaksii',
      AppLanguage.am: 'ልዩ የዲቴይሊንግ እና የሰም እጥበት',
    },
    'pkg_executive_desc': {
      AppLanguage.en: 'Showroom finish with clay treatment, machine paste wax, leather balm & underbody wash.',
      AppLanguage.om: 'Haala shooruumii wajjin yaala kileeyii, waaksii maashinii, baalmii gogaa fi dhiqannaa jalaa.',
      AppLanguage.am: 'የሾውሩም ደረጃ ማብሪያ፣ የማሽን ሰም ቅባት፣ የቆዳ ወንበር እንክብካቤ እና የታችኛው ክፍል እጥበት።',
    },
    'pkg_chassis_name': {
      AppLanguage.en: 'Chassis & Engine Flush',
      AppLanguage.om: 'Dhiqannaa Chaasii & Motoraa',
      AppLanguage.am: 'የቻሲስ እና የሞተር እጥበት',
    },
    'pkg_chassis_desc': {
      AppLanguage.en: 'Targeted high-pressure undercarriage rust prevention wash & safe steam engine bay degrease.',
      AppLanguage.om: 'Bishaan dhiibbaa guddaan jala makiinaa dhiqanii dhangala\'aa motoraa hurkaan qulqulleessuu.',
      AppLanguage.am: 'በከፍተኛ የውሃ ግፊት ዝገት መከላከያ የታችኛው ክፍል እጥበት እና የሞተር እንፋሎት ጽዳት።',
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
    'totalRevenue': {
      AppLanguage.en: 'Total Revenue',
      AppLanguage.om: 'Galii Waliigalaa',
      AppLanguage.am: 'ጠቅላላ ገቢ',
    },
    'washAndVehicleHistory': {
      AppLanguage.en: 'Wash & Vehicle History',
      AppLanguage.om: 'Seenaa Dhiqannaa & Konkolaataa',
      AppLanguage.am: 'የመኪና እጥበት እና ተሽከርካሪ ታሪክ',
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
    'clearAllBookings': {
      AppLanguage.en: 'Clear All Bookings',
      AppLanguage.om: 'Galmee Hundumaa Haqi',
      AppLanguage.am: 'ሁሉንም መዝገቦች አጽዳ',
    },
    'clearAllBookingsSubtitle': {
      AppLanguage.en: 'Reset active queue, history & relative data across the database',
      AppLanguage.om: 'Galmeewwan, seenaa fi database qulqulleessi',
      AppLanguage.am: 'የነቃ ወረፋ፣ ታሪክ እና መረጃዎችን ከዳታቤዝ አጽዳ',
    },
    'clearAllBookingsConfirm': {
      AppLanguage.en: 'Clear All Bookings & History?',
      AppLanguage.om: 'Galmeewwan fi Seenaa Hundumaa Haquu Barbaadduu?',
      AppLanguage.am: 'ሁሉንም መዝገቦች እና ታሪክ ማጽዳት ይፈልጋሉ?',
    },
    'clearAllBookingsDesc': {
      AppLanguage.en: 'This will permanently delete all active and historical bookings, commission logs, bank deposits, expenses, and handovers from the SQL database and reset washing bays to vacant for fresh testing. Master fixtures (tariffs, staff, inventory catalog) will NOT be affected.\n\nAre you sure you want to proceed?',
      AppLanguage.om: 'Kun galmeewwan dhiqannaa, komishiinii, baankii, baasii fi dabarsaa meeshaalee database SQL keessaa guutummaatti haqa. Tajaajilootaa fi miseensota hojii hin tuqu.\n\nDhuguma itti fufuu barbaadduu?',
      AppLanguage.am: 'ይህ ሁሉንም የቦታ ማስያዣዎች፣ የኮሚሽን መዝገቦች፣ የባንክ ገቢዎች፣ ወጪዎች እና የዕቃ ርክክቦችን ከ SQL ዳታቤዝ ሙሉ በሙሉ ያጠፋል፤ ማጠቢያ ክፍሎችንም ባዶ ያደርጋል። ዋና መረጃዎች (የአገልግሎት ዋጋ፣ ሠራተኞች፣ ዕቃዎች) አይነኩም።\n\nበእርግጥ መቀጠል ይፈልጋሉ?',
    },
    'clearAllBookingsSuccess': {
      AppLanguage.en: 'All bookings and operational history have been purged from the database and app screens!',
      AppLanguage.om: 'Galmeewwan dhiqannaa fi seenaan hundi database fi iskiriinii hunda irraa haqamaniiru!',
      AppLanguage.am: 'ሁሉም የቦታ ማስያዣዎች እና የሥራ ታሪኮች ከዳታቤዝ እና ከሁሉም ስክሪኖች ሙሉ በሙሉ ጸድተዋል!',
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
    // Queue & Real-Time Capacity
    'liveQueue': {
      AppLanguage.en: 'Live Queue',
      AppLanguage.om: 'Tarree Kallattii',
      AppLanguage.am: 'የቀጥታ ወረፋ',
    },
    'stationBaysTitle': {
      AppLanguage.en: 'Station (2 Bays)',
      AppLanguage.om: 'Dhaabbata (Kutaa 2)',
      AppLanguage.am: 'ዋና ጣቢያ (2 ክፍሎች)',
    },
    'mobileVanTitle': {
      AppLanguage.en: 'Mobile Van (1 Van)',
      AppLanguage.om: 'Makiinaa Sochooftuu (1)',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን (1)',
    },
    'readyNow': {
      AppLanguage.en: 'Ready Now',
      AppLanguage.om: 'Amma Qophiidha',
      AppLanguage.am: 'አሁን ዝግጁ ነው',
    },
    'vanReady': {
      AppLanguage.en: 'Van Ready',
      AppLanguage.om: 'Vaanichi Qophiidha',
      AppLanguage.am: 'ቫኑ ዝግጁ ነው',
    },
    'doorstepService': {
      AppLanguage.en: 'Doorstep service',
      AppLanguage.om: 'Tajaajila mana dhufaa',
      AppLanguage.am: 'እስከ ደጅ ድረስ አገልግሎት',
    },
    'carsAhead': {
      AppLanguage.en: 'ahead',
      AppLanguage.om: 'dura jiru',
      AppLanguage.am: 'ከፊት ያሉ',
    },
    'baysOpen': {
      AppLanguage.en: 'bays open',
      AppLanguage.om: 'kutaaleen banaadha',
      AppLanguage.am: 'ክፍሎች ክፍት ናቸው',
    },
    'minWait': {
      AppLanguage.en: 'min wait',
      AppLanguage.om: 'daqiiqaa eeggannaa',
      AppLanguage.am: 'ደቂቃ ጥበቃ',
    },
    'bay1': {
      AppLanguage.en: 'Bay 1',
      AppLanguage.om: 'Kutaa 1',
      AppLanguage.am: 'ክፍል 1',
    },
    'bay2': {
      AppLanguage.en: 'Bay 2',
      AppLanguage.om: 'Kutaa 2',
      AppLanguage.am: 'ክፍል 2',
    },
    'mobileVan': {
      AppLanguage.en: 'Mobile Van',
      AppLanguage.om: 'Makiinaa Sochooftuu',
      AppLanguage.am: 'ተንቀሳቃሽ ቫን',
    },
    'washer': {
      AppLanguage.en: 'Washer',
      AppLanguage.om: 'Dhiqaa',
      AppLanguage.am: 'አጣቢ',
    },
    'assignedTeam': {
      AppLanguage.en: 'Assigned Team',
      AppLanguage.om: 'Garee Ramadame',
      AppLanguage.am: 'የተመደበ ቡድን',
    },
    'pending': {
      AppLanguage.en: 'Pending',
      AppLanguage.om: 'Eeggachaa jira',
      AppLanguage.am: 'በመጠባበቅ ላይ',
    },
    'paid': {
      AppLanguage.en: 'PAID',
      AppLanguage.om: 'KAFFALAMEERA',
      AppLanguage.am: 'ተከፍሏል',
    },
    // Form Validations & Prompts
    'enterName': {
      AppLanguage.en: 'Please enter your name',
      AppLanguage.om: 'Maaloo maqaa keessan galchaa',
      AppLanguage.am: 'እባክዎ ስምዎን ያስገቡ',
    },
    'enterValidPhone': {
      AppLanguage.en: 'Please enter a valid phone number',
      AppLanguage.om: 'Maaloo lakkoofsa bilbilaa sirrii galchaa',
      AppLanguage.am: 'እባክዎ ትክክለኛ ስልክ ቁጥር ያስገቡ',
    },
    'enterPlate': {
      AppLanguage.en: 'Please enter license plate',
      AppLanguage.om: 'Maaloo gabatee makiinaa galchaa',
      AppLanguage.am: 'እባክዎ የሰሌዳ ቁጥር ያስገቡ',
    },
    'bookingSuccess': {
      AppLanguage.en: 'Booking created successfully!',
      AppLanguage.om: 'Dhiqannaan milkaa\'inaan qabameera!',
      AppLanguage.am: 'እጥበቱ በተሳካ ሁኔታ ተመዝግቧል!',
    },
    'bookingFailed': {
      AppLanguage.en: 'Failed to create booking',
      AppLanguage.om: 'Dhiqannaa qabachuun hin danda\'amne',
      AppLanguage.am: 'እጥበት መመዝገብ አልተሳካም',
    },
    // Admin & Security Staff PINs
    'staffPins': {
      AppLanguage.en: 'Staff PINs',
      AppLanguage.om: 'Koodii Hojjettootaa',
      AppLanguage.am: 'የሰራተኞች ሚስጥር ቁጥር',
    },
    'staffPinsSub': {
      AppLanguage.en: 'Admin & Cashier logins',
      AppLanguage.om: 'Galtee Bulchiinsaafi Kaffaltii',
      AppLanguage.am: 'የአስተዳዳሪና ገንዘብ ያዥ መግቢያ',
    },
    'staffPinsTitle': {
      AppLanguage.en: 'Staff Access & PIN Credentials',
      AppLanguage.om: 'Koodii Eenyummeessaafi Mirga Galtee',
      AppLanguage.am: 'የሰራተኞች መግቢያና የሚስጥር ቁጥሮች',
    },
    'staffPinsDesc': {
      AppLanguage.en: 'Configure security PINs for the Cashier desk and Admin dashboard. Only users with the designated PIN can enter these views.',
      AppLanguage.om: 'Koodii icciitii qabaa qarshiifi bulchiinsaa qindeessaa. Namni koodii qabu qofti seenuu danda\'a.',
      AppLanguage.am: 'ለገንዘብ ያዥና ለአስተዳዳሪ ክፍሎች የሚስጥር ቁጥር እዚህ ያዘጋጁ። ትክክለኛ ቁጥር ያለው ብቻ መግባት ይችላል።',
    },
    'editPin': {
      AppLanguage.en: 'Edit PIN',
      AppLanguage.om: 'Koodii Jijjiiri',
      AppLanguage.am: 'ሚስጥር ቁጥር ቀይር',
    },
    'changePin': {
      AppLanguage.en: 'Change PIN',
      AppLanguage.om: 'Koodii Jijjiiri',
      AppLanguage.am: 'ሚስጥር ቁጥር ቀይር',
    },
    'savePin': {
      AppLanguage.en: 'Save PIN',
      AppLanguage.om: 'Koodii Oolchi',
      AppLanguage.am: 'ሚስጥር ቁጥር አስቀምጥ',
    },
    'securityPin': {
      AppLanguage.en: 'Security PIN (Numeric)',
      AppLanguage.om: 'Koodii Icciitii (Lakkoofsa)',
      AppLanguage.am: 'የሚስጥር ቁጥር (በአሃዝ)',
    },
    'staffDisplayName': {
      AppLanguage.en: 'Staff Name / Display Name',
      AppLanguage.om: 'Maqaa Hojjetaa',
      AppLanguage.am: 'የሰራተኛው ሙሉ ስም',
    },
    'enterPinPrompt': {
      AppLanguage.en: 'Enter PIN',
      AppLanguage.om: 'Koodii galchaa',
      AppLanguage.am: 'ሚስጥር ቁጥር ያስገቡ',
    },
    'incorrectPin': {
      AppLanguage.en: 'Incorrect PIN code',
      AppLanguage.om: 'Koodiin dogoggora',
      AppLanguage.am: 'የተሳሳተ ሚስጥር ቁጥር',
    },
    'unlock': {
      AppLanguage.en: 'Unlock',
      AppLanguage.om: 'Bani',
      AppLanguage.am: 'ክፈት',
    },
    'digitalPayments': {
      AppLanguage.en: 'Digital payments',
      AppLanguage.om: 'Kaffaltii dijitaalaa',
      AppLanguage.am: 'የዲጂታል ክፍያዎች',
    },
    'atFrontDesk': {
      AppLanguage.en: 'At front desk',
      AppLanguage.om: 'Balbala duraatti',
      AppLanguage.am: 'በቀጥታ ፊት ለፊት',
    },
    'advanceStatus': {
      AppLanguage.en: 'Advance Status',
      AppLanguage.om: 'Sadarkaa Fuulduraa',
      AppLanguage.am: 'ደረጃውን አሻግር',
    },
    'afterPayrollCuts': {
      AppLanguage.en: 'After payroll cuts',
      AppLanguage.om: 'Kaffaltii komishiinii booda',
      AppLanguage.am: 'የሰራተኛ ኮሚሽን ከተቀነሰ በኋላ',
    },
    'washesToday': {
      AppLanguage.en: 'WASHES TODAY',
      AppLanguage.om: 'DHIQANNAA HAR\'AA',
      AppLanguage.am: 'የዛሬ እጥበቶች',
    },
    'priceInEtb': {
      AppLanguage.en: 'Price in ETB',
      AppLanguage.om: 'Gatii Qarshiin',
      AppLanguage.am: 'ዋጋ በብር',
    },
    'fullName': {
      AppLanguage.en: 'Full Name',
      AppLanguage.om: 'Maqaa Guutuu',
      AppLanguage.am: 'ሙሉ ስም',
    },
    'receiptImageError': {
      AppLanguage.en: 'Unable to load receipt image',
      AppLanguage.om: 'Suuraa nagahee fiduun hin danda\'amne',
      AppLanguage.am: 'የደረሰኙን ፎቶ ማሳየት አልተቻለም',
    },
    'trackMyCar': {
      AppLanguage.en: 'Track My Vehicle',
      AppLanguage.om: 'Dhiqannaa Konkolaataa Koo Hordofi',
      AppLanguage.am: 'የመኪናዬን እጥበት ሁኔታ ተከታተል',
    },
    'trackVehiclePrompt': {
      AppLanguage.en: 'Enter your plate number or phone to see your vehicle\'s live progress',
      AppLanguage.om: 'Haala dhiqannaa ilaaluuf gabatee makiinaa ykn bilbila keessan galchaa',
      AppLanguage.am: 'የመኪናዎን የቀጥታ ሁኔታ ለማየት የሰሌዳ ወይም የስልክ ቁጥር ያስገቡ',
    },
    'trackNow': {
      AppLanguage.en: 'Track Wash',
      AppLanguage.om: 'Hordofi',
      AppLanguage.am: 'ተከታተል',
    },
    'noActiveWashFound': {
      AppLanguage.en: 'No active wash found for this vehicle. Please verify your details or book a wash.',
      AppLanguage.om: 'Dhiqannaan adeemsarra jiru hin argamne. Odeeffannoo keessan mirkaneeffadhaa.',
      AppLanguage.am: 'ለዚህ መኪና ምንም በመከናወን ላይ ያለ እጥበት አልተገኘም። እባክዎ መረጃዎን ያረጋግጡ።',
    },
    'trackAnother': {
      AppLanguage.en: 'Track another vehicle',
      AppLanguage.om: 'Konkolaataa biraa hordofi',
      AppLanguage.am: 'ሌላ መኪና ፈልግ',
    },
    'plateOrPhoneHint': {
      AppLanguage.en: 'e.g. ET-3-B98124 or 0911...',
      AppLanguage.om: 'Fkn. ET-3-B98124 ykn 0911...',
      AppLanguage.am: 'ምሳሌ: ET-3-B98124 ወይም 0911...',
    },
    'noQueueImmediate': {
      AppLanguage.en: 'No queue • Immediate service available',
      AppLanguage.om: 'Tarreen hin jiru • Tajaajila battalaa',
      AppLanguage.am: 'ወረፋ የለም • ፈጣን አገልግሎት ዝግጁ ነው',
    },
    'vehiclesAhead': {
      AppLanguage.en: 'vehicle(s) currently ahead of you',
      AppLanguage.om: 'konkolaataan dura keessan jiru',
      AppLanguage.am: 'ተሽከርካሪ(ዎች) ከእርስዎ ፊት አሉ',
    },
    'bookByPhone': {
      AppLanguage.en: 'Call Station Gate',
      AppLanguage.om: 'Balbala Dhiqannaatti Bilbilaa',
      AppLanguage.am: 'ለጣቢያው በስልክ ይደውሉ',
    },
    'bookByPhoneSub': {
      AppLanguage.en: 'Call +251 91 123 4567 to book your wash instantly by phone',
      AppLanguage.om: 'Dhiqannaa battalatti qabachuuf +251 91 123 4567 irratti bilbilaa',
      AppLanguage.am: 'በስልክ ፈጣን ቀጠሮ ለመያዝ ወደ +251 91 123 4567 ይደውሉ',
    },
    'phoneCallBooking': {
      AppLanguage.en: 'Phone Call Booking',
      AppLanguage.om: 'Galmee Bilbilaan',
      AppLanguage.am: 'በስልክ የተያዘ ቀጠሮ',
    },
    'useGpsLocation': {
      AppLanguage.en: 'Use Current GPS Location',
      AppLanguage.om: 'Bakka GPS Ammaa Fayyadami',
      AppLanguage.am: 'የአሁኑን የጂፒኤስ መገኛ ተጠቀም',
    },
    'gpsLocationPinned': {
      AppLanguage.en: 'GPS Pinned',
      AppLanguage.om: 'GPS Qabameera',
      AppLanguage.am: 'ጂፒኤስ ተቀምጧል',
    },
    'openInMaps': {
      AppLanguage.en: 'Open in Maps',
      AppLanguage.om: 'Kaartaadhaan Bani',
      AppLanguage.am: 'በካርታ ክፈት',
    },
    'teamCommissionPool': {
      AppLanguage.en: 'Team Commission Pool (15%)',
      AppLanguage.om: 'Kuusaa Komishiinii Garee (15%)',
      AppLanguage.am: 'የቡድን አጣቢዎች ኮሚሽን ገንዳ (15%)',
    },
    'dividendBySeniority': {
      AppLanguage.en: 'Dividend by Seniority & Skill',
      AppLanguage.om: 'Qoodama Muuxannoo fi Ogummaan',
      AppLanguage.am: 'በልምድና ክህሎት የተከፋፈለ ድርሻ',
    },
    'teamRateLabel': {
      AppLanguage.en: 'Team Commission Rate (%)',
      AppLanguage.om: 'Hamma Komishiinii Garee (%)',
      AppLanguage.am: 'የቡድን ኮሚሽን ምጣኔ (%)',
    },
    'updateRate': {
      AppLanguage.en: 'Update Rate',
      AppLanguage.om: 'Hamma Jijjiiri',
      AppLanguage.am: 'ምጣኔ ቀይር',
    },
    'includedServices': {
      AppLanguage.en: 'Included Services:',
      AppLanguage.om: 'Tajaajiloota Dabalatan:',
      AppLanguage.am: 'የተካተቱ አገልግሎቶች፡',
    },

    // Financial Reports & Closing
    'financialReportsTitle': {
      AppLanguage.en: 'Financial Transactions & Closing Reports',
      AppLanguage.om: 'Gabaasa Faayinaansii fi Cufiinsa Herregaa',
      AppLanguage.am: 'የፋይናንስ ዝውውርና የሂሳብ መዝጊያ ሪፖርቶች',
    },
    'dailyFinancialClosing': {
      AppLanguage.en: 'Daily Financial Closing',
      AppLanguage.om: 'Cufiinsa Faayinaansii Guyyaa',
      AppLanguage.am: 'ዕለታዊ የፋይናንስ ሂሳብ መዝጊያ',
    },
    'confirmDailyClosing': {
      AppLanguage.en: 'Confirm Daily Closing',
      AppLanguage.om: 'Cufiinsa Guyyaa Mirkaneessi',
      AppLanguage.am: 'ዕለታዊ ሂሳብ መዝጊያን አረጋግጥ',
    },
    'dailyClosingConfirmed': {
      AppLanguage.en: 'Daily Closing Confirmed',
      AppLanguage.om: 'Cufiinsi Guyyaa Mirkanaa\'eera',
      AppLanguage.am: 'ዕለታዊ ሂሳብ ተዘግቷል',
    },
    'grossRevenue': {
      AppLanguage.en: 'Daily Gross Revenue',
      AppLanguage.om: 'Galii Dimshaashaa Guyyaa',
      AppLanguage.am: 'ዕለታዊ ጠቅላላ ገቢ',
    },
    'washerCommissionDeducted': {
      AppLanguage.en: 'Washer Commission Deducted (15%)',
      AppLanguage.om: 'Komishiinii Dhiqaa Hir\'ifame (15%)',
      AppLanguage.am: 'የተቆረጠ የአጣቢዎች ኮሚሽን (15%)',
    },
    'cashAtGate': {
      AppLanguage.en: 'Cash Handover at Gate',
      AppLanguage.om: 'Qarshii Harkaa Balbalaa',
      AppLanguage.am: 'በር ላይ የተሰበሰበ ካሽ',
    },
    'digitalChannels': {
      AppLanguage.en: 'Digital Channels Total',
      AppLanguage.om: 'Waliigala Karaalee Dijitaalaa',
      AppLanguage.am: 'ጠቅላላ የዲጂታል ክፍያዎች',
    },
    'digitalMoneyTransfer': {
      AppLanguage.en: 'Digital Money Transfer',
      AppLanguage.om: 'Dabarsa Qarshii Dijitaalaa',
      AppLanguage.am: 'የዲጂታል ገንዘብ ዝውውር',
    },
    'shiftLocked': {
      AppLanguage.en: 'Shift Locked ✓',
      AppLanguage.om: 'Hojiin Cufameera ✓',
      AppLanguage.am: 'ተዘግቷል ✓',
    },
    'smsSentSuccess': {
      AppLanguage.en: 'Completion SMS dispatched to customer',
      AppLanguage.om: 'Ergaan xumuramu maamiilaaf ergameera',
      AppLanguage.am: 'የማጠናቀቂያ አጭር የጽሑፍ መልዕክት (SMS) ለደንበኛው ተልኳል',
    },
    'smsGatewayPhone': {
      AppLanguage.en: 'Cashier SMS Gateway Phone',
      AppLanguage.om: 'Lakk. Bilbilaa Ergaa SMS Qabaa Qarshii',
      AppLanguage.am: 'የገንዘብ ያዥ የኤስኤምኤስ (SMS) መላኪያ ስልክ',
    },
    'cashInDrawer': {
      AppLanguage.en: 'Cash in Register Drawer',
      AppLanguage.om: 'Qarshii Saanduqa Keessaa',
      AppLanguage.am: 'በካዝና ውስጥ ያለ ጥሬ ገንዘብ',
    },
    'awaitingDeposit': {
      AppLanguage.en: 'Awaiting Bank Deposit',
      AppLanguage.om: 'Baankiitti Galchuuf Kan Eegu',
      AppLanguage.am: 'ወደ ባንክ ለመግባት የሚጠብቅ',
    },
    'closingRemarks': {
      AppLanguage.en: 'Closing Remarks / Notes',
      AppLanguage.om: 'Yaada Cufiinsaa / Qabxii',
      AppLanguage.am: 'የመዝጊያ አስተያየት / ማስታወሻ',
    },
    'closingCashierName': {
      AppLanguage.en: 'Closing Cashier Name',
      AppLanguage.om: 'Maqaa Qabaa Qarshii Cufuu',
      AppLanguage.am: 'ሂሳብ የዘጋችው ገንዘብ ያዥ ስም',
    },

    // Cash Bank Deposits
    'depositCashToBank': {
      AppLanguage.en: 'Deposit Cash to Owner Bank',
      AppLanguage.om: 'Qarshii Baankii Abbaa Qabeenyaatti Galchi',
      AppLanguage.am: 'ጥሬ ገንዘብ ለባለቤቱ ባንክ ገቢ አድርግ',
    },
    'ownerAccountA': {
      AppLanguage.en: 'Account A - Commercial Bank of Ethiopia (CBE)',
      AppLanguage.om: 'Herrega A - Baankii Daldala Itoophiyaa (CBE)',
      AppLanguage.am: 'አካውንት ኤ - የኢትዮጵያ ንግድ ባንክ (CBE)',
    },
    'ownerAccountB': {
      AppLanguage.en: 'Account B - Awash Bank',
      AppLanguage.om: 'Herrega B - Baankii Hawaash',
      AppLanguage.am: 'አካውንት ቢ - አዋሽ ባንክ',
    },
    'depositAmount': {
      AppLanguage.en: 'Deposit Amount (ETB)',
      AppLanguage.om: 'Hamma Qarshii Galfamu (ETB)',
      AppLanguage.am: 'የገቢ ገንዘብ መጠን (ብር)',
    },
    'depositAllCash': {
      AppLanguage.en: 'Deposit All Cash',
      AppLanguage.om: 'Qarshii Hunda Galchi',
      AppLanguage.am: 'ሁሉንም ካሽ ገቢ አድርግ',
    },
    'bankSlipNumber': {
      AppLanguage.en: 'Bank Deposit Slip / Ref Number',
      AppLanguage.om: 'Lakkoofsa Nagahee Baankii',
      AppLanguage.am: 'የባንክ ደረሰኝ / ማረጋገጫ ቁጥር',
    },
    'uploadDepositSlip': {
      AppLanguage.en: 'Bank Receipt Photo / Screenshot',
      AppLanguage.om: 'Suuraa Nagahee Baankii Qabsiisi',
      AppLanguage.am: 'የባንክ ደረሰኝ ፎቶ / ስክሪንሽት ጫን',
    },
    'confirmBankDeposit': {
      AppLanguage.en: 'Confirm & Record Bank Deposit',
      AppLanguage.om: 'Galii Baankii Mirkaneessi',
      AppLanguage.am: 'የባንክ ገቢውን አረጋግጥ',
    },
    'bankDepositsLog': {
      AppLanguage.en: 'Cash Bank Deposits (Owner Accounts A & B)',
      AppLanguage.om: 'Galmee Kaffaltii Baankii (Herrega A & B)',
      AppLanguage.am: 'የባንክ ገቢዎች መዝገብ (የባለቤቱ አካውንት ኤ እና ቢ)',
    },
    'viewDepositReceipt': {
      AppLanguage.en: 'View Receipt Slip',
      AppLanguage.om: 'Nagahee Ilaali',
      AppLanguage.am: 'ደረሰኝ ተመልከት',
    },

    // Weekly Commission & Washer Payroll
    'weeklyCommissionReportTitle': {
      AppLanguage.en: 'Weekly Washer Commission Report',
      AppLanguage.om: 'Gabaasa Komishiinii Torbanii Dhiqitootaa',
      AppLanguage.am: 'ሳምንታዊ የአጣቢዎች ኮሚሽን ሪፖርት',
    },
    'reportWeeklyCommissionToAdmin': {
      AppLanguage.en: 'Submit Weekly Commission Report to Admin',
      AppLanguage.om: 'Gabaasa Torbanii Bulchaatti Ergi',
      AppLanguage.am: 'ሳምንታዊ የኮሚሽን ሪፖርት ለአስተዳዳሪ ላክ',
    },
    'weeklyCommissionAccrual': {
      AppLanguage.en: 'Current Week Commission Accrual',
      AppLanguage.om: 'Kuusaa Komishiinii Torban Kanaa',
      AppLanguage.am: 'በዚህ ሳምንት የተጠራቀመ ኮሚሽን',
    },
    'monthlyBaseSalaryPool': {
      AppLanguage.en: 'Total Monthly Base Salary Pool',
      AppLanguage.om: 'Miindaa Bu\'uuraa Ji\'a Guutuu',
      AppLanguage.am: 'ጠቅላላ ወርሃዊ ቋሚ ደመወዝ',
    },
    'reportedByCashier': {
      AppLanguage.en: 'Reported by Cashier',
      AppLanguage.om: 'Qabaa Qarshiin Kan Gabaafame',
      AppLanguage.am: 'በገንዘብ ያዥ የቀረበ',
    },
    'disburseWeeklyCommission': {
      AppLanguage.en: 'Disburse & Report Weekly Commission',
      AppLanguage.om: 'Komishiinii Torbanii Kaffaliifi Gabaasi',
      AppLanguage.am: 'ሳምንታዊ ኮሚሽን ክፈልና ሪፖርት አድርግ',
    },
    'weeklyReportSuccess': {
      AppLanguage.en: 'Weekly washer commission report submitted successfully!',
      AppLanguage.om: 'Gabaasni komishiinii torbanii milkaa\'inaan ergameera!',
      AppLanguage.am: 'ሳምንታዊ የአጣቢዎች ኮሚሽን ሪፖርት በተሳካ ሁኔታ ተልኳል!',
    },
    'cashierCommissionNotice': {
      AppLanguage.en: 'Daily commission pool disbursement and cash reconciliation are managed directly from the Cashier Dashboard. Weekly amounts are verified and reported here for executive oversight.',
      AppLanguage.om: 'Kaffaltiin komishiinii guyyaa fi qorannoon qarshii kallattiin gabatee kaffaltii irraa gaggeeffama. Hammi torbanii to\'annoof asitti dhiyaata.',
      AppLanguage.am: 'ዕለታዊ የኮሚሽን ክፍፍልና የጥሬ ገንዘብ ቁጥጥር በቀጥታ በገንዘብ ያዥ ሰሌዳ ላይ ይከናወናል። ሳምንታዊ መጠኖች ለክትትል እዚህ ይቀርባሉ።',
    },

    // Petty Cash & Emergency
    'pettyCashExpense': {
      AppLanguage.en: 'Petty Cash & Emergency Spend',
      AppLanguage.om: 'Baasii Ariifachiisaa & Qusannaa',
      AppLanguage.am: 'አነስተኛ ወጪ እና ድንገተኛ ወጪዎች',
    },
    'logPettyCash': {
      AppLanguage.en: 'Log Petty Cash / Emergency',
      AppLanguage.om: 'Baasii Ariifachiisaa Galmeessi',
      AppLanguage.am: 'አነስተኛ ወጪ መዝግብ',
    },
    'pettyCashToday': {
      AppLanguage.en: 'Today Petty Cash Expenses',
      AppLanguage.om: 'Baasii Ariifachiisaa Har\'aa',
      AppLanguage.am: 'የዛሬ አነስተኛ ወጪዎች',
    },
    'pettyCashReason': {
      AppLanguage.en: 'Reason / Item Description',
      AppLanguage.om: 'Sababa / Ibsa Meeshaa',
      AppLanguage.am: 'ምክንያት / የዕቃው ማብራሪያ',
    },
    'pettyCategory': {
      AppLanguage.en: 'Expense Category',
      AppLanguage.om: 'Kutaalee Baasii',
      AppLanguage.am: 'የወጪ ዓይነት',
    },
    'pettyCategoryFuel': {
      AppLanguage.en: 'Fuel / Generator',
      AppLanguage.om: 'Bobaa / Jenereetara',
      AppLanguage.am: 'ነዳጅ / ጄኔሬተር',
    },
    'pettyCategoryPlumbing': {
      AppLanguage.en: 'Plumbing & Hardware Repair',
      AppLanguage.om: 'Ujummoo & Suphaa',
      AppLanguage.am: 'ቧንቧ እና ጥገና',
    },
    'pettyCategorySupplies': {
      AppLanguage.en: 'Urgent Consumables',
      AppLanguage.om: 'Meeshaalee Ariifachiisaa',
      AppLanguage.am: 'አስቸኳይ መገልገያ ዕቃዎች',
    },
    'pettyCategoryStaffLunch': {
      AppLanguage.en: 'Staff Welfare / Meals',
      AppLanguage.om: 'Nyaata Hojjattootaa',
      AppLanguage.am: 'የሰራተኞች ምግብ',
    },
    'pettyCategoryOther': {
      AppLanguage.en: 'Other Operational Emergency',
      AppLanguage.om: 'Baasii Biroo',
      AppLanguage.am: 'ሌሎች ድንገተኛ ወጪዎች',
    },
    'pettyCashSuccess': {
      AppLanguage.en: 'Petty cash expense recorded successfully!',
      AppLanguage.om: 'Baasiin ariifachiisaan galmaa\'eera!',
      AppLanguage.am: 'አነስተኛ ወጪ በተሳካ ሁኔታ ተመዝግቧል!',
    },
    'pettyCashScreenshotRequired': {
      AppLanguage.en: 'Physical receipt / voucher photo is required!',
      AppLanguage.om: 'Suuraan nagahee dirqama!',
      AppLanguage.am: 'የወጪ ደረሰኝ ፎቶ ግዴታ ነው!',
    },

    // Mandatory Proof
    'proofMandatoryNotice': {
      AppLanguage.en: 'Payment screenshot & reference number are mandatory for digital payments.',
      AppLanguage.om: 'Kaffaltii dijitaalaaf suuraan nagahee fi lakkoofsi mirkaneessaa dirqama.',
      AppLanguage.am: 'ለዲጂታል ክፍያዎች የደረሰኝ ስክሪንሾት እና የማረጋገጫ ቁጥር ግዴታ ነው።',
    },
    'depositSlipMandatoryNotice': {
      AppLanguage.en: 'Stamped bank deposit teller slip photo and reference number are strictly mandatory.',
      AppLanguage.om: 'Suuraan nagahee baankii mallatteeffamee fi lakkoofsi nagahee dirqama.',
      AppLanguage.am: 'የማህተም ያለበት የባንክ ደረሰኝ ፎቶና ቁጥር ግዴታ ነው።',
    },
    'pleaseUploadProof': {
      AppLanguage.en: 'Please attach receipt screenshot before proceeding',
      AppLanguage.om: 'Mee dura suuraa nagahee galchaa',
      AppLanguage.am: 'እባክዎ ከመቀጠልዎ በፊት የደረሰኝ ስክሪንሾት ያያይዙ',
    },
    'pleaseUploadDepositSlip': {
      AppLanguage.en: 'Please upload stamped bank deposit slip photo',
      AppLanguage.om: 'Mee suuraa nagahee baankii asitti fe\'aa',
      AppLanguage.am: 'እባክዎ የማህተም ያለበትን የባንክ ደረሰኝ ፎቶ ያያይዙ',
    },

    // Units of Measurement
    'unitOfMeasurement': {
      AppLanguage.en: 'Unit of Measurement',
      AppLanguage.om: 'Safartuu Meeshaa',
      AppLanguage.am: 'የመለኪያ አሃድ',
    },
    'totalCalculatedCost': {
      AppLanguage.en: 'Total Calculated Cost',
      AppLanguage.om: 'Waliigala Gatii Shallagame',
      AppLanguage.am: 'ጠቅላላ የተሰላ ዋጋ',
    },
    'unitLiters': {
      AppLanguage.en: 'Liters (L)',
      AppLanguage.om: 'Liitira (L)',
      AppLanguage.am: 'ሊትር (L)',
    },
    'unitPieces': {
      AppLanguage.en: 'Pieces (Pcs)',
      AppLanguage.om: 'Qodaa (Pcs)',
      AppLanguage.am: 'ፍሬ (Pcs)',
    },
    'unitCans': {
      AppLanguage.en: 'Cans / Tins',
      AppLanguage.om: 'Qorqoorroo',
      AppLanguage.am: 'ቆርቆሮ / ጣሳ',
    },
    'unitBottles': {
      AppLanguage.en: 'Bottles',
      AppLanguage.om: 'Qaruuraa',
      AppLanguage.am: 'ጠርሙስ',
    },
    'unitKg': {
      AppLanguage.en: 'Kilograms (Kg)',
      AppLanguage.om: 'Kiiloo (Kg)',
      AppLanguage.am: 'ኪሎግራም (Kg)',
    },
    'unitPacks': {
      AppLanguage.en: 'Packs / Boxes',
      AppLanguage.om: 'Saanduqa',
      AppLanguage.am: 'ፓኮ / ካርቶን',
    },
    'unitBars': {
      AppLanguage.en: 'Bars',
      AppLanguage.om: 'Kutaalee',
      AppLanguage.am: 'ሙልጭ / አሞሌ',
    },
    'categoryExchangeNote': {
      AppLanguage.en: 'Category A (Sealed Sprays): Empty-can exchange required',
      AppLanguage.om: 'Kutaa A (Farra Folii): Qorqoorroo duwwaa deebisuun dirqama',
      AppLanguage.am: 'ክፍል ሀ (ስፕሬዮች)፡ ባዶ ቆርቆሮ ሲመለስ ብቻ የሚተካ',
    },
    'categoryCountNote': {
      AppLanguage.en: 'Category B (Reusable Tools): Exact piece count in & out',
      AppLanguage.om: 'Kutaa B (Meeshaalee Hojii): Lakkoofsa qoodamee fi deebi\'e to\'adhu',
      AppLanguage.am: 'ክፍል ለ (የሚደገሙ ዕቃዎች)፡ የገቡና የወጡ ፍሬዎችን በትክክል መቁጠር',
    },
    'categoryLiquidNote': {
      AppLanguage.en: 'Category C (Bulk Liquids): 1L dispensers with car usage check',
      AppLanguage.om: 'Kutaa C (Dhangala\'aa): Qodaa 1L konkolaataa dhiqame wajjin madaali',
      AppLanguage.am: 'ክፍል ሐ (ፈሳሾች)፡ 1 ሊትር ዲስፔንሰር ከመኪኖች ብዛት ጋር ማነጻጸር',
    },

    // Tabular Mon-Sun Payroll Matrix
    'weeklyPayrollMatrix': {
      AppLanguage.en: 'Weekly Payroll & Attendance Matrix',
      AppLanguage.om: 'Gabatee Hojii fi Miindaa Torbanii',
      AppLanguage.am: 'ሳምንታዊ የደመወዝ እና የቅጥር ሰንጠረዥ',
    },
    'monShort': {
      AppLanguage.en: 'Mon',
      AppLanguage.om: 'Wix',
      AppLanguage.am: 'ሰኞ',
    },
    'tueShort': {
      AppLanguage.en: 'Tue',
      AppLanguage.om: 'Kib',
      AppLanguage.am: 'ማክ',
    },
    'wedShort': {
      AppLanguage.en: 'Wed',
      AppLanguage.om: 'Rob',
      AppLanguage.am: 'ረቡዕ',
    },
    'thuShort': {
      AppLanguage.en: 'Thu',
      AppLanguage.om: 'Kam',
      AppLanguage.am: 'ሐሙስ',
    },
    'friShort': {
      AppLanguage.en: 'Fri',
      AppLanguage.om: 'Jim',
      AppLanguage.am: 'አርብ',
    },
    'satShort': {
      AppLanguage.en: 'Sat',
      AppLanguage.om: 'San',
      AppLanguage.am: 'ቅዳሜ',
    },
    'sunShort': {
      AppLanguage.en: 'Sun',
      AppLanguage.om: 'Dil',
      AppLanguage.am: 'እሑድ',
    },
    'presentShort': {
      AppLanguage.en: 'P',
      AppLanguage.om: 'H',
      AppLanguage.am: 'ተገኝቷል',
    },
    'absentShort': {
      AppLanguage.en: 'A',
      AppLanguage.om: 'D',
      AppLanguage.am: 'ቀሪ',
    },
    'weeklyCommEarned': {
      AppLanguage.en: 'Weekly Commission',
      AppLanguage.om: 'Komishiinii Torbanii',
      AppLanguage.am: 'ሳምንታዊ ኮሚሽን',
    },
    'monthlySalary': {
      AppLanguage.en: 'Monthly Base Salary',
      AppLanguage.om: 'Miindaa Ji\'aa',
      AppLanguage.am: 'ወርሃዊ ቋሚ ደመወዝ',
    },
    'disburseWeeklyAction': {
      AppLanguage.en: 'Disburse Commission',
      AppLanguage.om: 'Komishiinii Kaffali',
      AppLanguage.am: 'ኮሚሽን ክፈል',
    },
    'disbursedStatus': {
      AppLanguage.en: 'Paid / Disbursed',
      AppLanguage.om: 'Kaffalameera',
      AppLanguage.am: 'ተከፍሏል',
    },
    'pendingDisbursal': {
      AppLanguage.en: 'Ready for Disbursal',
      AppLanguage.om: 'Kaffaltii Eegaa Jira',
      AppLanguage.am: 'ክፍያ ዝግጁ ነው',
    },

    // Tabs & Filters
    'attendanceAndCommission': {
      AppLanguage.en: 'Attendance & Commission Desk',
      AppLanguage.om: 'Galmee Hojii fi Komishiinii',
      AppLanguage.am: 'የሰራተኞች ገጽና የኮሚሽን ዴስክ',
    },
    'washHistory': {
      AppLanguage.en: 'Vehicle Wash History',
      AppLanguage.om: 'Seenaa Dhiqannaa Konkolaattotaa',
      AppLanguage.am: 'የታጠቡ መኪኖች ታሪክ',
    },
    'closingAndFinancialReports': {
      AppLanguage.en: 'Closing & Financial Reports',
      AppLanguage.om: 'Cufiinsa Faayinaansiifi Gabaasa',
      AppLanguage.am: 'የሂሳብ መዝጊያና የፋይናንስ ሪፖርቶች',
    },
    'searchPlateOrPhone': {
      AppLanguage.en: 'Search plate, customer name, or phone...',
      AppLanguage.om: 'Gabatee, maqaa maamilaa, ykn bilbila barbaadi...',
      AppLanguage.am: 'በሰሌዳ፣ በደንበኛ ስም ወይም በስልክ ቁጥር ፈልግ...',
    },
    'noVehiclesFound': {
      AppLanguage.en: 'No washed vehicles found for this period.',
      AppLanguage.om: 'Konkolaataan dhiqame yeroo kana keessatti hin argamne.',
      AppLanguage.am: 'በዚህ የጊዜ ክልል ውስጥ የታጠበ መኪና አልተገኘም።',
    },
    'markAllPresent': {
      AppLanguage.en: 'Mark All Present',
      AppLanguage.om: 'Hunda Hojirra Jedhi',
      AppLanguage.am: 'ሁሉንም አሉ በል',
    },
    'assignedCommissionShare': {
      AppLanguage.en: 'Assigned Commission Share',
      AppLanguage.om: 'Qooda Komishiinii Ramadame',
      AppLanguage.am: 'የተመደበ የኮሚሽን ድርሻ',
    },
    'totalCommissionAllocation': {
      AppLanguage.en: 'Total Commission Allocation',
      AppLanguage.om: 'Qooda Komishiinii Waliigalaa',
      AppLanguage.am: 'ጠቅላላ የኮሚሽን ድልድል',
    },
    'moneyReceivedBreakdown': {
      AppLanguage.en: 'Money Received Breakdown by Provider',
      AppLanguage.om: 'Gabaasa Qarshii Karaalee Kaffaltiitiin',
      AppLanguage.am: 'የገቢ ገንዘብ ዝርዝር በከፋይ ድርጅቶች',
    },
    'payBankOfAbyssinia': {
      AppLanguage.en: 'Bank of Abyssinia (BoA)',
      AppLanguage.om: 'Baankii Habashaa (BoA)',
      AppLanguage.am: 'አቢሲኒያ ባንክ (ቦአ)',
    },
    'payAwashBank': {
      AppLanguage.en: 'Awash Bank',
      AppLanguage.om: 'Baankii Hawaash',
      AppLanguage.am: 'አዋሽ ባንክ',
    },
    'payDashenBank': {
      AppLanguage.en: 'Dashen Bank (Amole)',
      AppLanguage.om: 'Baankii Daashen (Amoolee)',
      AppLanguage.am: 'ዳሽን ባንክ (አሞሌ)',
    },
    'weeklyCommissionReport': {
      AppLanguage.en: 'Weekly Washer Commission Report',
      AppLanguage.om: 'Gabaasa Komishiinii Hojjettoota Dhiqaa Torbaanii',
      AppLanguage.am: 'ሳምንታዊ የአጣቢዎች ኮሚሽን ሪፖርት',
    },
    'weeklyCommissionReportSub': {
      AppLanguage.en: 'Disbursed and reported weekly by cashier',
      AppLanguage.om: 'Qophaa\'ee fi kan gabaafame kaashiyariin torbaaniin',
      AppLanguage.am: 'በካሽየር የተዘጋጀ እና በየሳምንቱ የተላከ',
    },
    'noWeeklyCommissionReports': {
      AppLanguage.en: 'No weekly commission reports filed yet by cashier.',
      AppLanguage.om: 'Gabaasni komishiinii torbaanii kaashiyariin hin dhiyaanne.',
      AppLanguage.am: 'እስካሁን በገንዘብ ያዥ የቀረበ ሳምንታዊ የኮሚሽን ሪፖርት የለም።',
    },
    'totalCommissionDisbursed': {
      AppLanguage.en: 'Total Disbursed',
      AppLanguage.om: 'Waliigala Kan Kaffalame',
      AppLanguage.am: 'ጠቅላላ የተከፈለ',
    },
    'daysPresent': {
      AppLanguage.en: 'Days Present',
      AppLanguage.om: 'Guyyoota Argaman',
      AppLanguage.am: 'የተገኙባቸው ቀናት',
    },
    'staffAndSalaries': {
      AppLanguage.en: 'Staff & Salaries',
      AppLanguage.om: 'Hojjettoota & Miindaa',
      AppLanguage.am: 'ሰራተኞች እና ደመወዝ',
    },
    'dailyWasherCommissionPool': {
      AppLanguage.en: 'Daily Washer Commission Pool',
      AppLanguage.om: 'Kuusaa Komishiinii Dhiqitootaa Guyyaa',
      AppLanguage.am: 'ዕለታዊ የአጣቢዎች ኮሚሽን ገቢ',
    },
    'reportWeeklyCommission': {
      AppLanguage.en: 'Report Weekly Commission',
      AppLanguage.om: 'Komishiinii Torbanii Gabaasi',
      AppLanguage.am: 'ሳምንታዊ ኮሚሽን ሪፖርት አድርግ',
    },
    'attendanceDesk': {
      AppLanguage.en: 'Attendance & Commission',
      AppLanguage.om: 'Argama & Komishiinii',
      AppLanguage.am: 'የመገኘትና ኮሚሽን መዝገብ',
    },
  };

  static const Map<String, Map<AppLanguage, List<String>>> _packageFeatures = {
    'pkg_silver': {
      AppLanguage.en: [
        'High-pressure undercarriage & wheel arch pre-rinse',
        'Touchless snow foam body soak',
        'Hand wash with microfiber mitts',
        'Rims & tire surface cleaning',
        'Spot-free rinse & streak-free microfiber hand dry',
      ],
      AppLanguage.om: [
        'Jala makiinaafi naannoo gommaa dhiibbaa bishaaniin dhiqquu',
        'Hoomaa bishaaniitiin qaama makiinaa jiisuu',
        'Huccuu maayikiroofaayiberiin harkaan dhiqquu',
        'Qulqullina riimiifi fuula gommaa',
        'Bishaaniin dhiqanii haxaa\'uun gogsuu',
      ],
      AppLanguage.am: [
        'ከፍተኛ የውሃ ግፊት የመኪና ስር እና የጎማ ክልል ቅድመ-እጥበት',
        'የመኪና አካል በሳሙና አረፋ ማራስ',
        'በማይክሮፋይበር ስፖንጅ በእጅ በጥንቃቄ ማጠብ',
        'የሪምና የጎማ ውጫዊ ገጽታ ማጽዳት',
        'ውሃውን በሚገባ አውርዶ በማይክሮፋይበር ፎጣ ማድረቅ',
      ],
    },
    'pkg_gold': {
      AppLanguage.en: [
        'Complete Basic / Silver Wash included',
        'Machine high-gloss body polish application',
        'Long-lasting silicone tire dressing & shine',
        'Exterior glass polish & door jamb wipe-down',
      ],
      AppLanguage.om: [
        'Dhiqannaa Bu\'uuraa / Meetaa guutuun dabalameera',
        'Qaama makiinaa maashiniin pooliishii gochuun calaqqisiisuu',
        'Gommaa siilikooniin kuulee bareechuu',
        'Daawwitii alaa fi kutaalee balbalaa haxaa\'uu',
      ],
      AppLanguage.am: [
        'ሙሉ የቤሲክ / ሲልቨር እጥበት ተካቷል',
        'በማሽን የሚሰራ የቦዲ ፖሊሽ ማብሪያ',
        'ለረጅም ጊዜ የሚቆይ የጎማ ሲሊኮን ማብሪያ',
        'የውጭ መስታወት ፖሊሽ እና የበር ክፈፎች ጽዳት',
      ],
    },
    'pkg_plat_interior': {
      AppLanguage.en: [
        'All passenger seats removed for extraction',
        'Floor carpets shampooed & pressure washed',
        'Roof lining high-heat steam sanitization',
        'Dashboard, vents, glove box & console detailing',
        'Air conditioning duct deodorization',
        'Leather conditioning / upholstery UV shield',
      ],
      AppLanguage.om: [
        'Barcumti hundinuu keessaa baafamee dhiqama',
        'Karpeetiin lafaa shaampuudhaan dhiqamee miicawa',
        'Baaxiin makiinaa hurka bishaaniitiin (istiimii) qulqullaa\'a',
        'Daashboordii, ujummoo qilleensaa fi saanduqa qulqulleessuu',
        'Fooyya\'iinsa qilleensa koondeeshinara keessoo',
        'Gogaa barcumaa eeguufi qulqulleessuu',
      ],
      AppLanguage.am: [
        'ሁሉም የመኪናው ወንበሮች ወጥተው በጥልቅ ይታጠባሉ',
        'የወለል ምንጣፎች በሻምፑ እና በውሃ ግፊት ይታጠባሉ',
        'የመኪናው ጣሪያ በከፍተኛ የእንፋሎት ሙቀት ማጽዳት',
        'ዳሽቦርድ፣ የአየር ማስገቢያዎችና የጓንት ሳጥን ዝርዝር ጽዳት',
        'የአየር ማቀዝቀዣ ቱቦዎች ጀርም ማጥፋትና ሽታ ማስወገድ',
        'የቆዳ ወንበሮች እንክብካቤ እና የፀሐይ መከላከያ ቅባት',
      ],
    },
    'pkg_plat_ext_a': {
      AppLanguage.en: [
        'Full exterior hand wash & clay bar decontamination',
        'Machine paint correction & gloss enhancement',
        'Chemical removal of Bishoftu lake water spots',
        'Hydrophobic paint sealant protection',
      ],
      AppLanguage.om: [
        'Dhiqannaa alaa guutuu fi xurii dhabamsiisuu',
        'Halluu makiinaa maashiniin haaromsuu fi calaqqisiisuu',
        'Mallattoo bishaan haroo Bishooftuu keemikaalaan balleessuu',
        'Eegumsa halluu makiinaa bishaan ittisu',
      ],
      AppLanguage.am: [
        'ሙሉ የውጭ እጥበት እና የቆሻሻ ማጽጃ ህክምና',
        'በማሽን የቀለም ማስተካከል እና የማብራት ስራ',
        'የቢሾፍቱ ሀይቅ ውሃ ምልክቶችን በኬሚካል ማስወገድ',
        'ውሃ የማያሲዝ የቀለም መከላከያ ሽፋን',
      ],
    },
    'pkg_plat_ext_b': {
      AppLanguage.en: [
        'All Platinum Exterior Level A services included',
        'Brake dust removal & wheel well acid wash',
        'Ceramic rim protective gloss coating',
        'Exterior plastic trim & bumper restoration',
      ],
      AppLanguage.om: [
        'Tajaajilli Pulaatiiniyemii Alaa Paakeejii A hundi dabalameera',
        'Xurii biriikii fi naannoo gommaa asidiin qulqulleessuu',
        'Riimii makiinaa pooliishiidhaan eeguu',
        'Pilaastikoota alaa fi baamperii haaromsuu',
      ],
      AppLanguage.am: [
        'ሁሉም የፕላቲነም ውጭ ፓኬጅ ኤ አገልግሎቶች ተካተዋል',
        'የፍሬን አቧራ እና የጎማ ስር በልዩ አሲድ ማጠብ',
        'የሴራሚክ ሪም መከላከያ እና ማብሪያ ሽፋን',
        'የውጭ ፕላስቲኮች እና ባምፐር ማደስ',
      ],
    },
    'pkg_plat_ext_c': {
      AppLanguage.en: [
        'All Platinum Exterior Level A & B services included',
        'Dual-stage headlight wet-sanding & UV yellowing removal',
        'Chrome & metal trim brightening polish',
        'Hydrophobic rain-repellent windshield treatment',
      ],
      AppLanguage.om: [
        'Tajaajilli Pulaatiiniyemii Alaa Paakeejii A fi B hundi dabalameera',
        'Ifa fuulduraa (foolii) qulqulleessuu fi keelloo balleessuu',
        'Sibilaafi kiroomii makiinaa calaqqisiisuu',
        'Daawwitii fuulduraa bishaan ittisuun yaaluu',
      ],
      AppLanguage.am: [
        'ሁሉም የፕላቲነም ውጭ ፓኬጅ ኤ እና ቢ አገልግሎቶች ተካተዋል',
        'የፊት መብራት ማጽዳት፣ ማከክ እና ቢጫነትን ማስወገድ',
        'የክሮም እና የብረት ክፍሎችን የማብራት ፖሊሽ',
        'ለፊት መስታወት የዝናብ ውሃ መከላከያ ህክምና',
      ],
    },
    'pkg_diamond_a': {
      AppLanguage.en: [
        'Full Platinum Interior Detailing (seats & carpets out)',
        'Machine body polish & paint correction',
        'Mineral hard water spot removal',
        'Cabin antibacterial steam sanitization',
      ],
      AppLanguage.om: [
        'Pulaatiiniyemii Keessoo Guutuu (barcumtiifi karpeetiin baafamee)',
        'Qaama makiinaa maashiniin pooliishii gochuufi halluu haaromsuu',
        'Mallattoo bishaanii keemikaalaan balleessuu',
        'Keessa makiinaa hurka bishaaniin baakteeriyaa balleessuu',
      ],
      AppLanguage.am: [
        'ሙሉ የፕላቲነም የውስጥ ዲቴይሊንግ (ወንበርና ምንጣፍ ወጥቶ)',
        'በማሽን የቦዲ ፖሊሽ እና የቀለም ማስተካከል',
        'የውሃ እና የጨው ምልክቶችን በኬሚካል ማጥፋት',
        'የመኪናውን ውስጠኛ ክፍል በእንፋሎት ጀርም ማጽዳት',
      ],
    },
    'pkg_diamond_b': {
      AppLanguage.en: [
        'Full Platinum Interior Detailing (seats & carpets out)',
        'Machine body polish & water spot removal',
        'Deep wheel arch, rim & tire detailing',
        'Engine compartment dress & UV interior balm',
      ],
      AppLanguage.om: [
        'Pulaatiiniyemii Keessoo Guutuu (barcumtiifi karpeetiin baafamee)',
        'Qaama makiinaa pooliishii gochuufi bishaan balleessuu',
        'Naannoo gommaa, riimiifi gommaa gadi-fageenyaan qulqulleessuu',
        'Kutaa motoraa bareechuu fi keessoo eeguu',
      ],
      AppLanguage.am: [
        'ሙሉ የፕላቲነም የውስጥ ዲቴይሊንግ (ወንበርና ምንጣፍ ወጥቶ)',
        'በማሽን የቦዲ ፖሊሽ እና የውሃ ምልክት ማጥፋት',
        'የጎማ ስር፣ የሪምና የጎማ ጥልቅ ዲቴይሊንግ',
        'የሞተር ክፍል ማጽዳትና የውስጥ ፕላስቲክ መከላከያ ቅባት',
      ],
    },
    'pkg_diamond_full': {
      AppLanguage.en: [
        'Complete Platinum Interior Detailing (seats & carpets out)',
        'Complete Platinum Exterior Level C Suite',
        'Dual-stage headlight restoration & ceramic seal',
        'Complete air conditioning deodorization & engine wipe',
      ],
      AppLanguage.om: [
        'Pulaatiiniyemii Keessoo Guutuu (barcumtiifi karpeetiin baafamee)',
        'Pulaatiiniyemii Alaa Sadarkaa C guutummaatti',
        'Ifa fuulduraa haaromsuu fi eegumsa seeraamikii',
        'Koondeeshinara qulqulleessuu fi motora haxaa\'uu',
      ],
      AppLanguage.am: [
        'የተሟላ የፕላቲነም የውስጥ ዲቴይሊንግ (ወንበርና ምንጣፍ ወጥቶ)',
        'የተሟላ የፕላቲነም የውጭ ደረጃ ሲ አገልግሎት',
        'የፊት መብራትን ሙሉ በሙሉ ማደስና ሴራሚክ ማበብ',
        'ሙሉ የአየር ማቀዝቀዣ ሽታ ማስወገድና የሞተር ጽዳት',
      ],
    },
    'pkg_engine_chem': {
      AppLanguage.en: [
        'Basic / Silver exterior body wash included',
        'Safe chemical degreaser on engine block & firewall',
        'Low-pressure controlled grime rinse',
        'Silicone hose & rubber component conditioning',
      ],
      AppLanguage.om: [
        'Dhiqannaa alaa Bu\'uuraa / Meetaa dabalameera',
        'Motoora keemikaalaan dhiqquu fi zayita dhabamsiisuu',
        'Bishaaniin to\'atamee gogsuu',
        'Ujummoolee gommaa fi qodaa motooraa haaromsuu',
      ],
      AppLanguage.am: [
        'የቤሲክ / ሲልቨር የውጭ እጥበት ተካቷል',
        'የሞተር ብሎክን ደህንነቱ በተጠበቀ ኬሚካል ማጠብና ቅባት ማስወገድ',
        'በቁጥጥር ስር ባለ ዝቅተኛ የውሃ ግፊት ማጠብ',
        'የሞተር ቱቦዎችን እና የጎማ ክፍሎችን በሲሊኮን ማደስ',
      ],
    },
  };

  static String get(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? _strings[key]?[AppLanguage.en] ?? key;
  }

  static List<String> getPackageFeatures(String pkgKey, AppLanguage lang) {
    final pkgMap = _packageFeatures[pkgKey];
    if (pkgMap != null) {
      return pkgMap[lang] ?? pkgMap[AppLanguage.en] ?? const [];
    }
    return const [];
  }
}
