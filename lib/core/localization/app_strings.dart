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
      AppLanguage.om: 'Kaashiyara (Herregduu)',
      AppLanguage.am: 'ገንዘብ ያዥ (ካሺየር)',
    },
    'managerRole': {
      AppLanguage.en: 'Operational Manager',
      AppLanguage.om: 'Maneejara Hojii (Geggeessaa)',
      AppLanguage.am: 'ኦፕሬሽን ስራ አስኪያጅ',
    },
    'storekeeperRole': {
      AppLanguage.en: 'Storekeeper Desk',
      AppLanguage.om: 'Eegaa Kuusaa & Meeshaa',
      AppLanguage.am: 'የዕቃ ግምጃ ቤት ኃላፊ',
    },
    'accountantRole': {
      AppLanguage.en: 'Accountant Hub',
      AppLanguage.om: 'Ogeessa Herregaa & Faayinaansii',
      AppLanguage.am: 'የሂሳብና ፋይናንስ ክፍል',
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
      AppLanguage.en: 'At Station',
      AppLanguage.om: 'Buufata Keessatti',
      AppLanguage.am: 'በጣቢያው ውስጥ',
    },
    'driveInSub': {
      AppLanguage.en: 'Drive in to Bishoftu Station bays',
      AppLanguage.om: 'Buufata Bishooftuutti dhiqadhaa',
      AppLanguage.am: 'ወደ ቢሾፍቱ ጣቢያ ማጠቢያ ክፍሎች በመምጣት',
    },
    'atHomeMobile': {
      AppLanguage.en: 'At Customer Home (Van Wash)',
      AppLanguage.om: 'Mana Maamilaatti (Makiinaa Socho\'aa)',
      AppLanguage.am: 'በደንበኛ ቤት (ተንቀሳቃሽ ቫን)',
    },
    'atHomeSub': {
      AppLanguage.en: 'Equipped mobile van washes the vehicle at customer home',
      AppLanguage.om: 'Makiinaan bishaanii fi jeneretara qabu mana keessanitti dhiqa',
      AppLanguage.am: 'የውሃ ታንከር እና ጄነሬተር የታጠቀ ቫን እቤትዎ ድረስ መጥቶ ያጥባል',
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
      AppLanguage.en: 'Booking Approved',
      AppLanguage.om: 'Ajajni Mirkanaa\'eera',
      AppLanguage.am: 'ቦታ ማስያዝ ጸድቋል',
    },
    'statusConfirmed': {
      AppLanguage.en: 'Approved & Arrived at Station',
      AppLanguage.om: 'Mirkanaa\'ee Buufata Gaheera',
      AppLanguage.am: 'ጸድቆ ጣቢያ ደርሷል',
    },
    'statusAssignedToBay': {
      AppLanguage.en: 'Queued in Bay',
      AppLanguage.om: 'Iddoo Dhiqaatti Qophaa\'e',
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
    'serviceValetPickUp': {
      AppLanguage.en: 'VIP Driver Pick-up & Return',
      AppLanguage.om: 'Konkolaachisaa VIP (Fuudhee Deebisa)',
      AppLanguage.am: 'የቪአይፒ ሹፌር መውሰድና መመለስ (VIP)',
    },
    'serviceValetPickUpSub': {
      AppLanguage.en: 'Driver from BISHE Car Wash takes vehicle from home to the station, washes, and returns it back.',
      AppLanguage.om: 'Konkolaachisaan BISHE makiinaa mana keessanii fuudhee, buufatatti dhiqee mana keessanitti deebisa.',
      AppLanguage.am: 'የቢሼ አሽከርካሪ መኪናውን ከቤት ወስዶ ጣቢያ ካጠበ በኋላ መልሶ ያደርሳል።',
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
    'serviceWalkInCapacity': {
      AppLanguage.en: '2 Bays Available at Bishoftu Station',
      AppLanguage.om: 'Iddoowwan Dhiqa Konkolaataa 2 Bishooftuutti Qophii',
      AppLanguage.am: 'በቢሾፍቱ ጣቢያ 2 የማጠቢያ ክፍሎች ዝግጁ ናቸው',
    },
    'serviceAtHomeCapacity': {
      AppLanguage.en: '1 Mobile Van Available (Bishoftu Area)',
      AppLanguage.om: 'Makiinaa Socho\'aa 1 Qophii (Bishooftuu)',
      AppLanguage.am: '1 ተንቀሳቃሽ ቫን ዝግጁ ነው (ቢሾፍቱ)',
    },
    'serviceValetCapacity': {
      AppLanguage.en: 'Driver Dispatched to Your GPS Location',
      AppLanguage.om: 'Konkolaachisaan Bakka GPS Keessanitti Ergame',
      AppLanguage.am: 'አሽከርካሪ ወደ ጂፒኤስ መገኛዎ ይላካል',
    },
    'servicePhoneCapacity': {
      AppLanguage.en: 'Call-in Booking via Gate Reception',
      AppLanguage.om: 'Galmee Bilbilaan Balbala Seensaatti',
      AppLanguage.am: 'የስልክ ጥሪ ምዝገባ በበሩ ዴስክ',
    },
    'serviceWalkInDesc': {
      AppLanguage.en: 'Drive in to our Bishoftu main facility with dedicated pressure washing bays.',
      AppLanguage.om: 'Kutaa dhiqannaa keenya Bishooftuutti qophaa\'etti dhuftanii dhiqadhaa.',
      AppLanguage.am: 'በቢሾፍቱ ዋና ማዕከላችን ባሉ ዘመናዊ የማጠቢያ ክፍሎች መኪናዎን ያጥቡ።',
    },
    'serviceAtHomeDesc': {
      AppLanguage.en: 'Our fully equipped water-tank & power generator van comes right to your doorstep.',
      AppLanguage.om: 'Makiinaan keenya bishaaniifi jeneretara guutuu qabate mana keessanitti dhufa.',
      AppLanguage.am: 'የውሃ ታንከርና ጄነሬተር የታጠቀው ተንቀሳቃሽ ቫን እርስዎ ደጃፍ ድረስ ይመጣል።',
    },
    'serviceValetDesc': {
      AppLanguage.en: 'A dedicated driver picks up your vehicle from your location, brings it to the station for wash, and returns it safely to your doorstep.',
      AppLanguage.om: 'Konkolaachisaan keenya makiinaa keessan bakka jirtanirraa fuudhee, dhiqee qulqullinaan mana keessanitti deebisa.',
      AppLanguage.am: 'አሽከርካሪ መጥቶ መኪናዎን ካሉበት ተረክቦ፣ ወደ ማጠቢያ ጣቢያ ወስዶ ካጠበ በኋላ በታማኝነት ደጃፍዎ ድረስ ይመልሳል።',
    },
    'servicePhoneDesc': {
      AppLanguage.en: 'Pre-booked reservation received via station phone call.',
      AppLanguage.om: 'Qabannaa bilbilaan duraan qabame.',
      AppLanguage.am: 'በስልክ ጥሪ አስቀድሞ የተያዘ ቦታ።',
    },
    'valetServiceAvailable': {
      AppLanguage.en: 'Valet Service Available',
      AppLanguage.om: 'Tajaajilli Konkolaachisaa Qophiidha',
      AppLanguage.am: 'የአሽከርካሪ አገልግሎት ዝግጁ ነው',
    },
    'valetBadge': {
      AppLanguage.en: 'Valet Pick-up',
      AppLanguage.om: 'Fuudhuu & Deebisuu',
      AppLanguage.am: 'የአሽከርካሪ አገልግሎት',
    },
    'driverPickUpLocation': {
      AppLanguage.en: 'Driver Pick-up Location',
      AppLanguage.om: 'Iddoo Konkolaachisaan Itti Fudhatu',
      AppLanguage.am: 'አሽከርካሪ መኪናውን የሚረከብበት ቦታ',
    },
    'streetLandmark': {
      AppLanguage.en: 'Street / Landmark',
      AppLanguage.om: 'Daandii / Mallattoo Iddoo',
      AppLanguage.am: 'ጎዳና / መለያ ምልክት',
    },
    'streetLandmarkHint': {
      AppLanguage.en: 'e.g. Near Asham Africa Resort, House 420',
      AppLanguage.om: 'Fkn. Gammoojjii Asham Africa Resort bira, Mana 420',
      AppLanguage.am: 'ምሳሌ፡ አሻም አፍሪካ ሪዞርት አጠገብ፣ የቤት ቁጥር 420',
    },
    'streetLandmarkRequired': {
      AppLanguage.en: 'Please provide street / residence landmark in Bishoftu',
      AppLanguage.om: 'Mee daandii ykn mallattoo iddoo Bishooftuu galchaa',
      AppLanguage.am: 'እባክዎ በቢሾፍቱ ያለውን ጎዳና ወይም የመኖሪያ መለያ ምልክት ያስገቡ',
    },
    'valetPickupInBishoftu': {
      AppLanguage.en: 'Valet Pick-up in Bishoftu',
      AppLanguage.om: 'Bishooftuutti Konkolaachisaan Fuudhuu',
      AppLanguage.am: 'በቢሾፍቱ በአሽከርካሪ መኪና መረከብ',
    },
    'bishoftuMobileVan': {
      AppLanguage.en: 'Bishoftu Mobile Van',
      AppLanguage.om: 'Makiinaa Socho\'aa Bishooftuu',
      AppLanguage.am: 'የቢሾፍቱ ተንቀሳቃሽ ቫን',
    },
    'serviceMode': {
      AppLanguage.en: 'Service Mode',
      AppLanguage.om: 'Haala Tajaajilaa',
      AppLanguage.am: 'የአገልግሎት ዓይነት',
    },
    'driveInStationBays': {
      AppLanguage.en: 'Drive-in Station (Bays)',
      AppLanguage.om: 'Kutaa Dhiqannaa (Bay)',
      AppLanguage.am: 'የጣቢያ እጥበት (ቤይ)',
    },
    'atHomeMobileVan': {
      AppLanguage.en: 'At-Home Mobile Van',
      AppLanguage.om: 'Makiinaa Socho\'aa (Mana)',
      AppLanguage.am: 'ተንቀሳቃሽ የቤት ለቤት ቫን',
    },
    'houseOrLandmark': {
      AppLanguage.en: 'House / Landmark',
      AppLanguage.om: 'Mana / Mallattoo Iddoo',
      AppLanguage.am: 'የቤት ቁጥር / መለያ ምልክት',
    },
    'landmarkHintExample': {
      AppLanguage.en: 'e.g. Near Babogaya Resort',
      AppLanguage.om: 'Fkn. Haroo Baabogayyaa bira',
      AppLanguage.am: 'ምሳሌ፡ ባቦጋያ ሪዞርት አጠገብ',
    },
    'selectedWashPackage': {
      AppLanguage.en: 'Selected Wash Package',
      AppLanguage.om: 'Pakeejii Dhiqannaa Filatame',
      AppLanguage.am: 'የተመረጠ የእጥበት ፓኬጅ',
    },
    'confirmPhoneReservation': {
      AppLanguage.en: 'Confirm Phone Reservation',
      AppLanguage.om: 'Qabannaa Bilbilaa Mirkaneessi',
      AppLanguage.am: 'የስልክ ቀጠሮውን አረጋግጥ',
    },
    'arrivalSlotHint': {
      AppLanguage.en: 'e.g. Today 3:00 PM',
      AppLanguage.om: 'Fkn. Har\'a Sa\'aatii 9:00',
      AppLanguage.am: 'ምሳሌ፡ ዛሬ ከሰዓት 9:00',
    },
    'callerNameHint': {
      AppLanguage.en: 'e.g. Almaz Bekele',
      AppLanguage.om: 'Fkn. Almaz Baqqalaa',
      AppLanguage.am: 'ምሳሌ፡ አልማዝ በቀለ',
    },
    'enterCallerName': {
      AppLanguage.en: 'Please enter caller name',
      AppLanguage.om: 'Mee maqaa bilbilaa galchaa',
      AppLanguage.am: 'እባክዎ የደዋዩን ስም ያስገቡ',
    },

    // Entrance Splash Screen
    'entranceGreeting': {
      AppLanguage.en: 'Welcome to BISHE Car Wash',
      AppLanguage.om: 'Baga Nagaan Dhuftan Giddugala BISHE',
      AppLanguage.am: 'ወደ ቢሼ የመኪና ማጠቢያ በደህና መጡ',
    },
    'entranceTagline': {
      AppLanguage.en: 'Crater Lake Auto Detailing & Care Studio',
      AppLanguage.om: 'Istudiyoo Dhiqannaa fi Kunuunsa Konkolaataa Bishooftuu',
      AppLanguage.am: 'የቢሾፍቱ ሃይቆች መኪና እጥበትና ዲቴይሊንግ ስቱዲዮ',
    },
    'entranceLocation': {
      AppLanguage.en: 'Bishoftu / Debre Zeit • Near Lake Hora, Oromia',
      AppLanguage.om: 'Bishooftuu • Haroo Hoolaa cinaa, Oromiyaa',
      AppLanguage.am: 'ቢሾፍቱ / ደብረ ዘይት • ሆራ ሐይቅ አጠገብ፣ ኦሮሚያ',
    },
    'enterStationPortal': {
      AppLanguage.en: 'Enter Station Portal',
      AppLanguage.om: 'Gara Giddugalaatti Seenaa',
      AppLanguage.am: 'ወደ ማዕከሉ ይግቡ',
    },
    'tapToContinue': {
      AppLanguage.en: 'Tap anywhere to continue',
      AppLanguage.om: 'Itti fufuuf tuqaa',
      AppLanguage.am: 'ለመቀጠል ይንኩ',
    },
    'socialConnect': {
      AppLanguage.en: 'Connect With Us',
      AppLanguage.om: 'Nu Qunnamaa',
      AppLanguage.am: 'ያግኙን',
    },
    'callUs': {
      AppLanguage.en: 'Direct Call',
      AppLanguage.om: 'Bilbila Kallattii',
      AppLanguage.am: 'ቀጥታ ስልክ',
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
    'welcomeHub': {
      AppLanguage.en: 'Welcome Hub',
      AppLanguage.om: 'Wiirtuu Simannaa',
      AppLanguage.am: 'የመግቢያ ማዕከል',
    },
    'backToWelcome': {
      AppLanguage.en: 'Back to Welcome Hub',
      AppLanguage.om: 'Gara Wiirtuu Simannaatti Deebi\'i',
      AppLanguage.am: 'ወደ መግቢያ ማዕከል ተመለስ',
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
      AppLanguage.am: 'ያለ ምንም ተራ ፈጣን እና ዘመናዊ የእጥበት አገልግሎት',
    },
    'carouselCarpetSlide1Title': {
      AppLanguage.en: 'Rotary Deep Jet Carpet Shampoo',
      AppLanguage.om: 'Dhiqannaa Karpeetii Hoomaa Cimaa',
      AppLanguage.am: 'ጥልቅ የንጣፍ ሻምፑ እና ጄት እጥበት',
    },
    'carouselCarpetSlide1Desc': {
      AppLanguage.en: 'Commercial rotary fiber scrubbing & anti-bacterial stain lift',
      AppLanguage.om: 'Qulqullina olaanaa fi eegumsa rifeensa karpeetii',
      AppLanguage.am: 'የጨርቅ እና ፀጉር ጥልቅ ቆሻሻ ማስወገጃ ቴክኖሎጂ',
    },
    'carouselCarpetSlide2Title': {
      AppLanguage.en: 'Spin Dehydration & Odor Extraction',
      AppLanguage.om: 'Bishaan Cabaqsuu & Urgooftuu',
      AppLanguage.am: 'የውሃ ማድረቂያ ስፒን እና ሽታ ማስወገጃ',
    },
    'carouselCarpetSlide2Desc': {
      AppLanguage.en: 'High-RPM centrifugal moisture extraction for fresh scent',
      AppLanguage.om: 'Saffisaan bishaan keessaa baasuu fi foolii gaarii',
      AppLanguage.am: 'በሴንትሪፊዩጋል ማድረቂያ እርጥበትን በደቂቃዎች ውስጥ ማድረቅ',
    },
    'carouselCarpetSlide3Title': {
      AppLanguage.en: 'Heated Drying Racks & Fiber Grooming',
      AppLanguage.om: 'Muka Goggogsuu & Qulqulleessuu',
      AppLanguage.am: 'በማድረቂያ መደርደሪያዎች ላይ ማድረቅ',
    },
    'carouselCarpetSlide3Desc': {
      AppLanguage.en: '100% dust-free indoor drying chambers & fiber grooming',
      AppLanguage.om: 'Bakka eegamaatti guutummaatti goggogsuu',
      AppLanguage.am: 'ከአቧራ ነፃ በሆነ ንፁህ ክፍል ውስጥ 100% ማድረቅ',
    },
    'carouselCarpetSlide4Title': {
      AppLanguage.en: 'VIP Doorstep Carpet Pick-Up & Delivery',
      AppLanguage.om: 'Fidanii Geessuu Qophii Karpeetii',
      AppLanguage.am: 'ከቤት ወስዶ አጥቦ በነፃ የማድረስ አገልግሎት',
    },
    'carouselCarpetSlide4Desc': {
      AppLanguage.en: 'Convenient pickup from your home & free delivery in Bishoftu',
      AppLanguage.om: 'Mana keessanirraa fuunnee dhiquun deebifna',
      AppLanguage.am: 'ከቤትዎ ተቀብለን አጥበን በታሸገ ሁኔታ ወደ ቤትዎ እንመልሳለን',
    },
    'carsAheadInQueue': {
      AppLanguage.en: 'Cars Ahead in Queue',
      AppLanguage.om: 'Konkolaattota Fuuldura Dabaree jiran',
      AppLanguage.am: 'በተራ ላይ ከፊትዎ ያሉ መኪኖች',
    },
    'estimatedBayArrival': {
      AppLanguage.en: 'Estimated Time to Service',
      AppLanguage.om: 'Yeroo Tilmaamaa Tajaajilaa',
      AppLanguage.am: 'የሚገመት የእጥበት መድረሻ ጊዜ',
    },
    'lookingForEarlierBooking': {
      AppLanguage.en: 'Looking for an earlier booking? Enter plate or phone',
      AppLanguage.om: 'Ajaja kanaan duraa barbaadaa jirtuu? Gabatee ykn bilbila galchaa',
      AppLanguage.am: 'ያለፈ ትዕዛዝ መፈለግ ይፈልጋሉ? ታርጋ ወይም ስልክ ያስገቡ',
    },
    'enterPlateOrPhone': {
      AppLanguage.en: 'Enter Plate or Phone Number',
      AppLanguage.om: 'Lakkoofsa Gabatee ykn Bilbilaa',
      AppLanguage.am: 'የታርጋ ወይም የስልክ ቁጥር ያስገቡ',
    },
    'onlyOwnVehicleNotice': {
      AppLanguage.en: 'You can only track active bookings associated with your vehicle or phone.',
      AppLanguage.om: 'Haala konkolaataa ykn bilbila keessanii qofa hordofuu dandeessu.',
      AppLanguage.am: 'የእርስዎን መኪና ወይም የስልክ ቁጥር ሁኔታ ብቻ መከታተል ይችላሉ።',
    },
    'phaseApprovedArrived': {
      AppLanguage.en: 'Approved & Arrived at Station',
      AppLanguage.om: 'Mirkanaa\'ee Buufata Gaheera',
      AppLanguage.am: 'ተረጋግጦ ማዕከል ደርሷል',
    },
    'phaseApprovedArrivedSub': {
      AppLanguage.en: 'Vehicle inspected & queued in reception bay',
      AppLanguage.om: 'Konkolaataan qoratamee dabaree dhiqaa galeera',
      AppLanguage.am: 'ተሽከርካሪው ተመርምሮ ወደ ማጠቢያ ተራ ገብቷል',
    },
    'phaseStartWash': {
      AppLanguage.en: 'Start Wash & Active Foam',
      AppLanguage.om: 'Dhiqannaa Jalqabuu & Saamunaa Hoomisaa',
      AppLanguage.am: 'እጥበት ጀምር እና የአረፋ ሳሙና',
    },
    'phaseStartWashSub': {
      AppLanguage.en: 'Touchless pre-soak & high-pressure jet rinse',
      AppLanguage.om: 'Saamunaa hoomisaafi bishaan dhiibbaa ol-aanaa',
      AppLanguage.am: 'የአረፋ ሳሙና እና ከፍተኛ ግፊት ውሃ',
    },
    'phaseMoveToDrying': {
      AppLanguage.en: 'Move to Drying & Detailing',
      AppLanguage.om: 'Goggogsuu & Qulqulleessuu',
      AppLanguage.am: 'ወደ ማድረቅ እና ማሳመር ሽግግር',
    },
    'phaseMoveToDryingSub': {
      AppLanguage.en: 'Microfiber hand towel dry, tire shine & interior vacuum',
      AppLanguage.om: 'Tawulaan goggogsuu, gommaa calaqqisiisuu fi vakiyuumii',
      AppLanguage.am: 'በማይክሮፋይበር ፎጣ ማድረቅ፣ ጎማ ማብረቅ እና ቫኪዩም',
    },
    'phaseCompletedReady': {
      AppLanguage.en: 'Completed & Showroom Ready',
      AppLanguage.om: 'Xumuramee Qophaa\'eera',
      AppLanguage.am: 'ተጠናቆ ዝግጁ ሆኗል',
    },
    'phaseCompletedReadySub': {
      AppLanguage.en: 'Final inspection passed & ready for handover',
      AppLanguage.om: 'Qulqullinni mirkanaa\'ee fudhachuuf qophiidha',
      AppLanguage.am: 'የመጨረሻ ምርመራ አልፎ ለርክክብ ዝግጁ ነው',
    },
    'liveVehicleStatusVisualizer': {
      AppLanguage.en: 'Live Vehicle Wash Visualizer',
      AppLanguage.om: 'Haala Dhiqannaa Konkolaataa Mul\'isaa',
      AppLanguage.am: 'የቀጥታ የተሽከርካሪ እጥበት ምስላዊ መከታተያ',
    },
    'horizontalPipelineTitle': {
      AppLanguage.en: 'Live Progress Pipeline',
      AppLanguage.om: 'Adeemsa Hordoffii Qophaa\'ina',
      AppLanguage.am: 'የቀጥታ ሂደት መከታተያ ቧንቧ',
    },
    'pipelineRealtimeNotice': {
      AppLanguage.en: 'Real-time automated status',
      AppLanguage.om: 'Haala kallattii yeroo qabatamaa',
      AppLanguage.am: 'የቅጽበት ራስ-ሰር ሁኔታ',
    },
    'waitingArrival': {
      AppLanguage.en: 'WAITING ARRIVAL',
      AppLanguage.om: 'GAA\'ITII EEGGACHAA',
      AppLanguage.am: 'መድረስን በመጠባበቅ ላይ',
    },
    'completedPhaseBadge': {
      AppLanguage.en: 'COMPLETED (4 OF 4)',
      AppLanguage.om: 'XUMURAMEERA (4 KEESSAA 4)',
      AppLanguage.am: 'ተጠናቋል (4 ከ 4)',
    },
    'pendingStepBadge': {
      AppLanguage.en: 'Pending Step',
      AppLanguage.om: 'Tarkaanfii Eeggachaa',
      AppLanguage.am: 'ደረጃ በመጠባበቅ ላይ',
    },
    'bookingApprovedStep': {
      AppLanguage.en: 'Booking Approved',
      AppLanguage.om: 'Galmeen Mirkanaa\'eera',
      AppLanguage.am: 'ትዕዛዝ ጸድቋል',
    },
    'queuedInBayStep': {
      AppLanguage.en: 'Queued in Bay',
      AppLanguage.om: 'Gola Dhiqannaa Galeera',
      AppLanguage.am: 'ወደ ማጠቢያ መስመር ገብቷል',
    },
    'washingInProgressStep': {
      AppLanguage.en: 'Washing in Progress',
      AppLanguage.om: 'Dhiqamuun Itti Jira',
      AppLanguage.am: 'እጥበት በመካሄድ ላይ',
    },
    'dryingDetailingStep': {
      AppLanguage.en: 'Drying & Detailing',
      AppLanguage.om: 'Goggogsuu & Miidhagsuu',
      AppLanguage.am: 'ማድረቅ እና ማሳመር',
    },
    'readyForPickupStep': {
      AppLanguage.en: 'Ready for Pick-Up',
      AppLanguage.om: 'Fudhachuuf Qophiidha',
      AppLanguage.am: 'ለመረከብ ዝግጁ',
    },
    'valetStepDispatched': {
      AppLanguage.en: 'Valet Driver Dispatched',
      AppLanguage.om: 'Konkolaachisaan Vaaleetii Ergameera',
      AppLanguage.am: 'ሹፌር ወደ እርስዎ ተልኳል',
    },
    'valetStepPickedUp': {
      AppLanguage.en: 'Picked Up & En Route to Station',
      AppLanguage.om: 'Fuudhamee Gara Buufataatti Deemaa Jira',
      AppLanguage.am: 'ተረክበን ወደ ማዕከሉ በመጓዝ ላይ ነው',
    },
    'valetStepWashing': {
      AppLanguage.en: 'Station Jet Wash & Detail',
      AppLanguage.om: 'Buufatatti Dhiqamuu & Qulqulleeffamuu',
      AppLanguage.am: 'በማዕከሉ ውስጥ እጥበት እና ማሳመር',
    },
    'valetStepReturning': {
      AppLanguage.en: 'Driver Returning Vehicle',
      AppLanguage.om: 'Konkolaachisaan Deebisaa Jira',
      AppLanguage.am: 'ሹፌሩ መኪናዎን ይዞ በመመለስ ላይ ነው',
    },
    'valetStepDelivered': {
      AppLanguage.en: 'Delivered to Doorstep',
      AppLanguage.om: 'Maniitti Fudhachiifameera',
      AppLanguage.am: 'በርዎ ላይ በሰላም ደርሶ ተረክበዋል',
    },
    'homeStepDispatched': {
      AppLanguage.en: 'Mobile Van Dispatched',
      AppLanguage.om: 'Garee Moobaayilaa Ergameera',
      AppLanguage.am: 'ተንቀሳቃሽ የቫን ቡድን ተልኳል',
    },
    'homeStepEnRoute': {
      AppLanguage.en: 'Van En Route to Address',
      AppLanguage.om: 'Vaanichi Karaarra Jira',
      AppLanguage.am: 'ቫኑ ወደ አድራሻዎ በመጓዝ ላይ ነው',
    },
    'homeStepSetup': {
      AppLanguage.en: 'Arrived & Driveway Setup',
      AppLanguage.om: 'Gahee Meeshaa Qopheessaa Jira',
      AppLanguage.am: 'ቦታው ደርሶ እቃዎችን በማዘጋጀት ላይ',
    },
    'homeStepWashing': {
      AppLanguage.en: 'Active Mobile Detailing',
      AppLanguage.om: 'Dhiqannaa Iddoo Sanatti',
      AppLanguage.am: 'በቦታው ላይ ንቁ እጥበት በመካሄድ ላይ',
    },
    'homeStepCompleted': {
      AppLanguage.en: 'Inspected & Completed',
      AppLanguage.om: 'Qoratamee Xumurameera',
      AppLanguage.am: 'ተመርምሮ ስራው ተጠናቋል',
    },
    'openGoogleMaps': {
      AppLanguage.en: 'Open in Google Maps',
      AppLanguage.om: 'Kaartaa Google irratti Bani',
      AppLanguage.am: 'በጉግል ካርታ ክፈት',
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
      AppLanguage.om: 'Eegaa Kuusaa',
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
    'managerPortal': {
      AppLanguage.en: 'Operational Manager',
      AppLanguage.om: 'Hojii Geggeessaa',
      AppLanguage.am: 'የኦፕሬሽን ስራ አስኪያጅ',
    },
    'managerPortalDesc': {
      AppLanguage.en: 'Night shift intake, cashier cash handover, washer dividends & closing',
      AppLanguage.om: 'Halkan hojjechuu, dabarsa qarshii saanduqaa, komishinii & cufiinsa',
      AppLanguage.am: 'የሌሊት ፈረቃ፣ ከካሺየር ገንዘብ ርክክብ፣ የአጣቢዎች ኮሚሽንና ሂሳብ መዝጊያ',
    },
    'managerPinBadge': {
      AppLanguage.en: 'Night Operations',
      AppLanguage.om: 'Hojii Halkan',
      AppLanguage.am: 'የሌሊት ኦፕሬሽን',
    },
    'operationalManagerTitle': {
      AppLanguage.en: 'Operations Manager Hub',
      AppLanguage.om: 'Wiirtuu Hojii Geggeessaa',
      AppLanguage.am: 'የኦፕሬሽን ስራ አስኪያጅ ማዕከል',
    },
    'cashierHandoverTitle': {
      AppLanguage.en: 'Cashier Cash Handover',
      AppLanguage.om: 'Dabarsa Qarshii Saanduqaa',
      AppLanguage.am: 'የካሺየር ጥሬ ገንዘብ ርክክብ',
    },
    'acceptCashierHandover': {
      AppLanguage.en: 'Verify Cashier Closing (OTP)',
      AppLanguage.om: 'Cufiinsa Kaasharii OTPn Mirkaneessi',
      AppLanguage.am: 'የገንዘብ ተቀባይ መዝጊያን በOTP ያረጋግጡ',
    },
    'handoverPending': {
      AppLanguage.en: 'Pending Manager Acceptance',
      AppLanguage.om: 'Fudhatama Eegaa Jira',
      AppLanguage.am: 'የስራ አስኪያጅ ማረጋገጫ በመጠባበቅ ላይ',
    },
    'handoverConfirmed': {
      AppLanguage.en: 'Confirmed',
      AppLanguage.om: 'Mirkanaa\'eera',
      AppLanguage.am: 'የተረጋገጠ',
    },
    'nightClosingTitle': {
      AppLanguage.en: 'Night Shift Closing & Payout to Admin',
      AppLanguage.om: 'Cufiinsa Halkan & Kaffaltii Bulchaaf',
      AppLanguage.am: 'የሌሊት ፈረቃ ሂሳብ መዝጊያ እና ለአስተዳዳሪ ማስረከቢያ',
    },
    'carriedCashierCash': {
      AppLanguage.en: 'Carried Cashier Cash',
      AppLanguage.om: 'Qarshii Saanduqarraa Fudhatame',
      AppLanguage.am: 'ከካሺየር የተረከቡት ጥሬ ገንዘብ',
    },
    'nightShiftGross': {
      AppLanguage.en: 'Night Shift Gross Revenue',
      AppLanguage.om: 'Galii Waliigalaa Halkan',
      AppLanguage.am: 'የሌሊት ፈረቃ ጠቅላላ ገቢ',
    },
    'totalCashHandedToAdmin': {
      AppLanguage.en: 'Total Physical Cash Handed to Admin',
      AppLanguage.om: 'Waliigala Qarshii Bulchaaf Kenname',
      AppLanguage.am: 'ለአስተዳዳሪው የሚሰጥ ጠቅላላ ጥሬ ገንዘብ',
    },
    'handoverMethod': {
      AppLanguage.en: 'Shift Closing & Verification Method',
      AppLanguage.om: 'Akkaataa Cufiinsa & Mirkaneessa',
      AppLanguage.am: 'የፈረቃ መዝጊያ እና ማረጋገጫ ዘዴ',
    },
    'handoverToManagerOption': {
      AppLanguage.en: 'Send OTP Request to Operational Manager',
      AppLanguage.om: 'Gaaffii OTP Hojii Geggeessaatti Ergi',
      AppLanguage.am: 'ለኦፕሬሽን ስራ አስኪያጅ የOTP ጥያቄ ላክ',
    },
    'handoverToAdminOption': {
      AppLanguage.en: 'Send OTP Request to Admin / Owner',
      AppLanguage.om: 'Gaaffii OTP Bulchaatti Ergi',
      AppLanguage.am: 'ለአስተዳዳሪ የOTP ጥያቄ ላክ',
    },
    'handoverToAdminSub': {
      AppLanguage.en: 'If Operational Manager is absent, off-duty, or on leave',
      AppLanguage.om: 'Hojii geggeessaan yoo hin jirre ykn boqonnaa irra jiraate',
      AppLanguage.am: 'ስራ አስኪያጁ ከሌለ፣ ስራ ላይ ካልሆነ ወይም እረፍት ላይ ከሆነ',
    },
    'bankDepositOption': {
      AppLanguage.en: 'Deposit to Owner Bank Account',
      AppLanguage.om: 'Herrega Baankii Abbaatti Galchuu',
      AppLanguage.am: 'ወደ ባለንብረቱ የባንክ ሂሳብ ማስገባት',
    },
    'bankDepositSub': {
      AppLanguage.en: 'If Manager is absent or deposited before 5 PM',
      AppLanguage.om: 'Hojii geggeessaan yoo hin jirre ykn sa\'a 11 dura',
      AppLanguage.am: 'ስራ አስኪያጁ ከሌለ ወይም ከቀኑ 11 ሰዓት በፊት',
    },
    'transferOtpCode': {
      AppLanguage.en: 'Shift Verification OTP Code',
      AppLanguage.om: 'Koodii Mirkaneessa OTP',
      AppLanguage.am: 'የፈረቃ ማረጋገጫ OTP ኮድ',
    },
    'enterHandoverOtp': {
      AppLanguage.en: 'Enter 4-Digit Handover Code',
      AppLanguage.om: 'Koodii Dabarsoo Dijitii 4 Galchaa',
      AppLanguage.am: 'ባለ 4 አሃዝ የርክክብ ኮድ ያስገቡ',
    },
    'giveOtpToReceiver': {
      AppLanguage.en: 'Give this 4-digit code to the receiver after counting physical cash',
      AppLanguage.om: 'Qarshii erga lakkooftanii kennitanii booda koodii kana fuudhataaf kennaa',
      AppLanguage.am: 'ጥሬ ገንዘቡን ቆጥረው ካስረከቡ በኋላ ይህንን ባለ 4 አሃዝ ኮድ ለተቀባዩ ይስጡ',
    },
    'verifyAndTakeCustody': {
      AppLanguage.en: 'Verify & Take Custody',
      AppLanguage.om: 'Mirkaneessi & Fudhadhu',
      AppLanguage.am: 'አረጋግጥ እና ተረከብ',
    },
    'invalidOtpCode': {
      AppLanguage.en: 'Invalid Code. Please confirm physical count with sender.',
      AppLanguage.om: 'Koodiin dogoggora. Maaloo lakkoofsa qarshii waliin mirkaneeffadhaa.',
      AppLanguage.am: 'የተሳሳተ ኮድ። እባክዎ ከላኪው ጋር የገንዘቡን መጠን ያረጋግጡ።',
    },
    'handoverSuccess': {
      AppLanguage.en: 'Cash handover verified and received successfully!',
      AppLanguage.om: 'Dabarsoon qarshii milkaa\'inaan mirkanaa\'eera!',
      AppLanguage.am: 'የጥሬ ገንዘብ ርክክቡ በተሳካ ሁኔታ ተረጋግጧል!',
    },
    'bankDepositRecorded': {
      AppLanguage.en: 'Cash deposit to Owner\'s Bank Account recorded',
      AppLanguage.om: 'Galiin herrega baankiitti galmaa\'eera',
      AppLanguage.am: 'ወደ ባለንብረቱ የባንክ ሂሳብ የተደረገው ተቀማጭ ተመዝግቧል',
    },
    'adminHandoverPending': {
      AppLanguage.en: 'Night Cash Pending Admin Acceptance',
      AppLanguage.om: 'Qarshii Halkan Bulchaan Fudhatamu',
      AppLanguage.am: 'የሌሊት ጥሬ ገንዘብ በአስተዳዳሪው እንዲረጋገጥ የሚጠብቅ',
    },
    'verifyAdminOtp': {
      AppLanguage.en: 'Verify & Accept Night Cash',
      AppLanguage.om: 'Mirkaneessi & Qarshii Halkan Fudhadhu',
      AppLanguage.am: 'አረጋግጥ እና የሌሊት ጥሬ ገንዘብ ተረከብ',
    },
    'enterCustomerPortal': {
      AppLanguage.en: 'Enter Customer Portal',
      AppLanguage.om: 'Gara Balbala Maamilaa Seenaa',
      AppLanguage.am: 'ወደ ደንበኛ መግቢያ ይግቡ',
    },
    'customerTrustPill': {
      AppLanguage.en: 'Instant Wash Booking • Live Queue Tracker',
      AppLanguage.om: 'Ajaja Dhiqannaa Battalaa • Hordoffii Dabaree Kallattii',
      AppLanguage.am: 'ፈጣን የእጥበት ትዕዛዝ • የቀጥታ የተራ መከታተያ',
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
      AppLanguage.en: 'Open in TikTok',
      AppLanguage.om: 'TikTok irratti Bani',
      AppLanguage.am: 'በቲክቶክ ክፈት',
    },
    'redirectingToTikTok': {
      AppLanguage.en: 'Redirecting to TikTok app...',
      AppLanguage.om: 'Gara App TikToktti dabarsaa jira...',
      AppLanguage.am: 'ወደ ቲክቶክ አፕ በመሄድ ላይ...',
    },
    'stationBishoftuLocation': {
      AppLanguage.en: 'Bishoftu (Debre Zeyit), Oromia, Ethiopia',
      AppLanguage.om: 'Bishoftuu (Dabrazayiti), Oromiyaa, Itoophiyaa',
      AppLanguage.am: 'ቢሾፍቱ (ደብረ ዘይት)፣ ኦሮሚያ፣ ኢትዮጵያ',
    },
    'curatedReelsPoolTitle': {
      AppLanguage.en: 'Curated Detailing & Ad Photo Pool (Tap to Apply):',
      AppLanguage.om: 'Filannoo Suuraalee Beeksisaafi Miidhaginaa (Tuqaa Fayyadamaa):',
      AppLanguage.am: 'የተመረጡ የማስታወቂያ እና ዲቴይሊንግ ፎቶዎች (ለመምረጥ ይንኩ):',
    },
    'curatedPoolArtworks': {
      AppLanguage.en: 'Official Branding Artworks & Murals',
      AppLanguage.om: 'Mallattoolee fi Fakkiiwwan Bishee Official',
      AppLanguage.am: 'ይፋዊ የቢሼ አርማዎች እና የግድግዳ ስዕሎች',
    },
    'curatedPoolAdBanners': {
      AppLanguage.en: 'Commercial Service Ad Banners (Trilingual Detailing & Carpet)',
      AppLanguage.om: 'Baanaroota Beeksisa Tajaajilaa (Miidhagina Makiinaa fi Kaarpeetii)',
      AppLanguage.am: 'የአገልግሎት ማስታወቂያ ባነሮች (የመኪና ዲቴይሊንግ እና ምንጣፍ እጥበት)',
    },
    'reelCounter': {
      AppLanguage.en: 'REEL',
      AppLanguage.om: 'Viidiyoo Gabaabaa (Reel)',
      AppLanguage.am: 'አጫጭር ቪዲዮዎች (Reel)',
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
      AppLanguage.en: 'Start Wash',
      AppLanguage.om: 'Dhiqannaa Jalqabi',
      AppLanguage.am: 'እጥበት ጀምር',
    },
    'moveToDryingAction': {
      AppLanguage.en: 'Move to Drying',
      AppLanguage.om: 'Gogsatti Dabarsi',
      AppLanguage.am: 'ወደ ማድረቅ አሳልፍ',
    },
    'markCompletedAction': {
      AppLanguage.en: 'Mark Completed',
      AppLanguage.om: 'Xumurameera Jedhi',
      AppLanguage.am: 'ተጠናቋል በል',
    },
    'collectPaymentAction': {
      AppLanguage.en: 'Collect Payment',
      AppLanguage.om: 'Kaffaltii Fudhadhu',
      AppLanguage.am: 'ክፍያ ተቀበል',
    },
    'paymentLockedUntilCompleted': {
      AppLanguage.en: 'Payment unlocks after vehicle is marked completed',
      AppLanguage.om: 'Kaffaltiin kan banamu erga dhiqamee xumuramee qofa',
      AppLanguage.am: 'ክፍያ የሚፈቀደው እጥበቱ ተጠናቋል ተብሎ ከተረጋገጠ በኋላ ብቻ ነው',
    },
    'registerPhoneBooking': {
      AppLanguage.en: 'Register Phone Booking',
      AppLanguage.om: 'Galmee Bilbilaa',
      AppLanguage.am: 'የስልክ ጥሪ ትዕዛዝ መዝግብ',
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

    // Dual Tab Bar - Service Selection
    'customDetailingTab': {
      AppLanguage.en: 'Custom Detailing (Tick Boxes)',
      AppLanguage.om: 'Filannoo Qubaa (Tajaajila Filatamaa)',
      AppLanguage.am: 'ልዩ ዲቴይሊንግ (የሚመረጡ አገልግሎቶች)',
    },
    'presetPackagesTab': {
      AppLanguage.en: 'Preset Service Packages',
      AppLanguage.om: 'Paakeejiiwwan Tajaajilaa Qophaa\'an',
      AppLanguage.am: 'የተዘጋጁ የአገልግሎት ፓኬጆች',
    },

    // Customer Feedback & Admin Moderation
    'feedbackTab': {
      AppLanguage.en: 'Feedback',
      AppLanguage.om: 'Yaada Maamilaa',
      AppLanguage.am: 'የደንበኞች አስተያየት',
    },
    'customerFeedbackHeader': {
      AppLanguage.en: 'Customer Feedback & Ratings',
      AppLanguage.om: 'Yaada fi Sadarkaa Qulqullinaa',
      AppLanguage.am: 'የደንበኞች አስተያየት እና ደረጃ',
    },
    'rateExperienceQuestion': {
      AppLanguage.en: 'How satisfied are you with our service?',
      AppLanguage.om: 'Tajaajila keenyaan hammam gammaddan?',
      AppLanguage.am: 'በአገልግሎታችን ምን ያህል ረክተዋል?',
    },
    'star1Good': {
      AppLanguage.en: '1 Star — Good',
      AppLanguage.om: 'Urjii 1 — Gaarii',
      AppLanguage.am: '1 ኮከብ — ጥሩ',
    },
    'star2Satisfactory': {
      AppLanguage.en: '2 Stars — Satisfactory',
      AppLanguage.om: 'Urjii 2 — Quubsaa',
      AppLanguage.am: '2 ኮከብ — አጥጋቢ',
    },
    'star3Excellent': {
      AppLanguage.en: '3 Stars — Excellent',
      AppLanguage.om: 'Urjii 3 — Baay\'ee Gaarii',
      AppLanguage.am: '3 ኮከብ — በጣም ጥሩ',
    },
    'star4SuperSatisfied': {
      AppLanguage.en: '4 Stars — Super Satisfied',
      AppLanguage.om: 'Urjii 4 — Hedduu Gammadeera',
      AppLanguage.am: '4 ኮከብ — እጅግ በጣም አርኪ',
    },
    'feedbackNameOptional': {
      AppLanguage.en: 'Your Name (Optional)',
      AppLanguage.om: 'Maqaa Keessan (Dirqama Miti)',
      AppLanguage.am: 'ስምዎ (አማራጭ)',
    },
    'feedbackOpinionHint': {
      AppLanguage.en: 'Write your personal opinion (Optional)',
      AppLanguage.om: 'Yaada dhuunfaa keessan barreessaa (Dirqama Miti)',
      AppLanguage.am: 'የግል አስተያየትዎን ይጻፉ (አማራጭ)',
    },
    'sendFeedback': {
      AppLanguage.en: 'Send Feedback',
      AppLanguage.om: 'Yaada Ergi',
      AppLanguage.am: 'አስተያየት ላክ',
    },
    'feedbackSentForApproval': {
      AppLanguage.en: 'Thank you! Your feedback has been sent to management for review.',
      AppLanguage.om: 'Galatoomaa! Yaadni keessan mirkaneessa bulchiinsaaf ergameera.',
      AppLanguage.am: 'እናመሰግናለን! አስተያየትዎ ለማጽደቅ ወደ አስተዳዳሪ ተልኳል።',
    },
    'selectStarRatingFirst': {
      AppLanguage.en: 'Please select a star rating (1–4) before sending.',
      AppLanguage.om: 'Erguun dura sadarkaa urjii (1–4) filadhaa.',
      AppLanguage.am: 'ከመላክዎ በፊት እባክዎ የኮከብ ደረጃ (1–4) ይምረጡ።',
    },
    'feedbackLinksBlocked': {
      AppLanguage.en: 'Links or web addresses are not allowed in feedback.',
      AppLanguage.om: 'Liinkiiwwan ykn teessoon weebsaayitii yaada keessatti hin hayyamamu.',
      AppLanguage.am: 'በአስተያየት ውስጥ ሊንኮች ወይም የድረ-ገጽ አድራሻዎች አይፈቀዱም።',
    },
    'feedbackCooldownError': {
      AppLanguage.en: 'Please wait a moment before sending another feedback.',
      AppLanguage.om: 'Yaada biroo erguuf yeroo xiqqoo eegaa.',
      AppLanguage.am: 'ሌላ አስተያየት ከመላክዎ በፊት እባክዎ ትንሽ ይጠብቁ።',
    },
    'showCustomersSuggestions': {
      AppLanguage.en: 'Show Customers Suggestions',
      AppLanguage.om: 'Yaada Maamiltootaa Agarsiisi',
      AppLanguage.am: 'የደንበኞችን አስተያየት አሳይ',
    },
    'noApprovedFeedbackYet': {
      AppLanguage.en: 'No approved customer feedback yet. Share your thoughts above!',
      AppLanguage.om: 'Hanga ammaatti yaadni mirkanaa\'e hin jiru. Yaada keessan qooddadhaa!',
      AppLanguage.am: 'እስካሁን የጸደቀ የደንበኛ አስተያየት የለም። አስተያየትዎን ከላይ ይላኩ!',
    },
    'anonymousCustomer': {
      AppLanguage.en: 'Anonymous Customer',
      AppLanguage.om: 'Maamila',
      AppLanguage.am: 'ደንበኛ',
    },
    'averageRatingLabel': {
      AppLanguage.en: 'Avg Rating',
      AppLanguage.om: 'Giddugaleessa',
      AppLanguage.am: 'አማካይ ደረጃ',
    },
    'adminFeedbackModeration': {
      AppLanguage.en: 'Customer Feedback Moderation',
      AppLanguage.om: 'To\'annoo Yaada Maamiltootaa',
      AppLanguage.am: 'የደንበኞች አስተያየት ማጽደቂያ',
    },
    'adminFeedbackModerationSub': {
      AppLanguage.en: 'Approve genuine ratings or ignore spam & inappropriate comments',
      AppLanguage.om: 'Yaada dhugaa mirkaneessaa ykn spam dhiisaa',
      AppLanguage.am: 'ትክክለኛ አስተያየቶችን ያጽድቁ ወይም አላስፈላጊዎችን ይተዉ',
    },
    'approveFeedback': {
      AppLanguage.en: 'Approve',
      AppLanguage.om: 'Mirkaneessi',
      AppLanguage.am: 'አጽድቅ',
    },
    'ignoreFeedback': {
      AppLanguage.en: 'Ignore',
      AppLanguage.om: 'Dhiisi',
      AppLanguage.am: 'ተወው',
    },
    'removeFeedback': {
      AppLanguage.en: 'Remove',
      AppLanguage.om: 'Haqi',
      AppLanguage.am: 'አስወግድ',
    },
    'pendingReviewLabel': {
      AppLanguage.en: 'Pending Review',
      AppLanguage.om: 'Mirkaneessa Eeggataa',
      AppLanguage.am: 'ማጽደቅ የሚጠባበቅ',
    },
    'approvedLabel': {
      AppLanguage.en: 'Approved',
      AppLanguage.om: 'Mirkanaa\'e',
      AppLanguage.am: 'የጸደቀ',
    },
    'ignoredLabel': {
      AppLanguage.en: 'Ignored',
      AppLanguage.om: 'Kan Dhiifame',
      AppLanguage.am: 'የተተወ',
    },
    'feedbackModerationEmpty': {
      AppLanguage.en: 'No customer feedback in this category.',
      AppLanguage.om: 'Kutaa kana keessa yaadni maamilaa hin jiru.',
      AppLanguage.am: 'በዚህ ክፍል ውስጥ ምንም የደንበኛ አስተያየት የለም።',
    },

    // Simplified Option 1 Customer Hub & 3-Step Booking Wizard
    'pricesAreNegotiable': {
      AppLanguage.en: 'Prices are negotiable',
      AppLanguage.om: 'Gatiin mariin ni sirraa\'a',
      AppLanguage.am: 'ዋጋዎች በድርድር የሚስተካከሉ ናቸው',
    },
    'whatToWashToday': {
      AppLanguage.en: 'What would you like to wash today?',
      AppLanguage.om: 'Har\'a maal dhiqachuu barbaaddu?',
      AppLanguage.am: 'ዛሬ ምን ማሳጠብ ይፈልጋሉ?',
    },
    'washMyCarTitle': {
      AppLanguage.en: 'Wash My Car',
      AppLanguage.om: 'Konkolaataa Dhiqachuu',
      AppLanguage.am: 'መኪና ማሳጠብ',
    },
    'washMyCarSub': {
      AppLanguage.en: 'Choose a ready package or pick exact items in 3 easy steps',
      AppLanguage.om: 'Paakeejii qophaa\'e ykn tajaajila barbaaddan tarkaanfii 3n filadhaa',
      AppLanguage.am: 'የተዘጋጀ ፓኬጅ ወይም የሚፈልጉትን አገልግሎት በ3 ቀላል ደረጃ ይዘዙ',
    },
    'startCarBooking': {
      AppLanguage.en: 'Start Car Booking',
      AppLanguage.om: 'Ajaja Konkolaataa Jalqabi',
      AppLanguage.am: 'የመኪና እጥበት ይዘዙ',
    },
    'washMyCarpetTitle': {
      AppLanguage.en: 'Wash My Carpet',
      AppLanguage.om: 'Karpeetii Dhiqachuu',
      AppLanguage.am: 'ምንጣፍ ማሳጠብ',
    },
    'washMyCarpetSub': {
      AppLanguage.en: 'At our station, driver pick-up, or cleaned right at your home',
      AppLanguage.om: 'Buufata keenyatti, mana keessanii fuunee ykn manatti isiniif dhiqna',
      AppLanguage.am: 'በማዕከላችን፣ ከቤትዎ ወስደን ወይም ቤትዎ ድረስ መጥተን እናጥባለን',
    },
    'startCarpetBooking': {
      AppLanguage.en: 'Start Carpet Booking',
      AppLanguage.om: 'Ajaja Karpeetii Jalqabi',
      AppLanguage.am: 'የምንጣፍ እጥበት ይዘዙ',
    },
    'needHelpCallBanner': {
      AppLanguage.en: 'New to the app? Call us and we will book for you in 30 seconds!',
      AppLanguage.om: 'Appii fayyadamuun yoo isinitti ulfaate bilbilaa — sekoondii 30 keessatti isiniif ajajna!',
      AppLanguage.am: 'መተግበሪያውን መጠቀም ካስቸገረዎት ይደውሉ — በ30 ሰከንድ እንመዘግብዎታለን!',
    },
    'step1ModeInstruction': {
      AppLanguage.en: 'Step 1 of 3: How should we serve you?',
      AppLanguage.om: 'Tarkaanfii 1/3: Akkamitti isin tajaajillu?',
      AppLanguage.am: 'ደረጃ 1 ከ 3፡ አገልግሎቱን እንዴት ማግኘት ይፈልጋሉ?',
    },
    'step2CarInstruction': {
      AppLanguage.en: 'Step 2 of 3: Pick vehicle size & wash service',
      AppLanguage.om: 'Tarkaanfii 2/3: Gosa konkolaataa fi tajaajila filadhaa',
      AppLanguage.am: 'ደረጃ 2 ከ 3፡ የመኪናውን አይነት እና አገልግሎት ይምረጡ',
    },
    'step2CarpetInstruction': {
      AppLanguage.en: 'Step 2 of 3: Pick carpet type & size',
      AppLanguage.om: 'Tarkaanfii 2/3: Gosa karpeetii fi bal\'ina filadhaa',
      AppLanguage.am: 'ደረጃ 2 ከ 3፡ የምንጣፍ አይነት እና መጠን ይምረጡ',
    },
    'step3DetailsInstruction': {
      AppLanguage.en: 'Step 3 of 3: Your name, phone and plate number',
      AppLanguage.om: 'Tarkaanfii 3/3: Maqaa, bilbila fi lakkoofsa taargaa keessan',
      AppLanguage.am: 'ደረጃ 3 ከ 3፡ ስም፣ ስልክ እና የሰሌዳ ቁጥርዎን ያስገቡ',
    },
    'step3CarpetDetailsInstruction': {
      AppLanguage.en: 'Step 3 of 3: Your name, phone & carpet tag',
      AppLanguage.om: 'Tarkaanfii 3/3: Maqaa, bilbila fi koodii karpeetii keessan',
      AppLanguage.am: 'ደረጃ 3 ከ 3፡ ስም፣ ስልክ እና የምንጣፍ መለያ ቁጥርዎን ያስገቡ',
    },
    'nextStep': {
      AppLanguage.en: 'Next Step',
      AppLanguage.om: 'Itti Fufi',
      AppLanguage.am: 'ቀጥል',
    },
    'backStep': {
      AppLanguage.en: 'Back',
      AppLanguage.om: 'Duubatti',
      AppLanguage.am: 'ተመለስ',
    },
    'estimatedTotalLabel': {
      AppLanguage.en: 'Estimated Total',
      AppLanguage.om: 'Tilmaama Waliigalaa',
      AppLanguage.am: 'ግምታዊ ጠቅላላ ዋጋ',
    },
    'finalNegotiatedPriceEtb': {
      AppLanguage.en: 'Final Negotiated Price (ETB)',
      AppLanguage.om: 'Gatii Xumuraa Mariin Murtaa\'e (ETB)',
      AppLanguage.am: 'በድርድር የጸደቀው የመጨረሻ ዋጋ (ብር)',
    },
    'bookedReferenceTariff': {
      AppLanguage.en: 'Booked Reference Tariff',
      AppLanguage.om: 'Gatii Jalqabaa Galmaa\'e',
      AppLanguage.am: 'በትዕዛዝ የተመዘገበ መነሻ ዋጋ',
    },
    'bookingFailedPrefix': {
      AppLanguage.en: 'Could not complete booking',
      AppLanguage.om: 'Ajaja xumuruun hin danda\'amne',
      AppLanguage.am: 'ትዕዛዙን ማጠናቀቅ አልተቻለም',
    },
    'callingStationPrefix': {
      AppLanguage.en: 'Calling BISHE Station',
      AppLanguage.om: 'Buufata BISHE\'tti bilbilamaa jira',
      AppLanguage.am: 'ወደ ቢሼ ማዕከል እየተደወለ ነው',
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
      AppLanguage.om: 'Pulaatiiniyemii Alaa - Sadarkaa A',
      AppLanguage.am: 'ፕላቲነም የውጭ - ደረጃ ኤ',
    },
    'pkg_plat_ext_a_desc': {
      AppLanguage.en: 'Body Polish + Water Spot removal and gloss treatment.',
      AppLanguage.om: 'Pooliishii qaamaa + bakkoota bishaanii balleessuu fi calaqqisiisuu.',
      AppLanguage.am: 'የቦዲ ፖሊሽ እና የውሃ ምልክት ማጥፊያ ህክምና።',
    },
    'pkg_plat_ext_b_name': {
      AppLanguage.en: 'Platinum Exterior - B',
      AppLanguage.om: 'Pulaatiiniyemii Alaa - Sadarkaa B',
      AppLanguage.am: 'ፕላቲነም የውጭ - ደረጃ ቢ',
    },
    'pkg_plat_ext_b_desc': {
      AppLanguage.en: 'Body + Water Spot + Tire Detailing & rim protection.',
      AppLanguage.om: 'Qaama + bakkoota bishaanii + dhiqannaa & eegumsa gommaa.',
      AppLanguage.am: 'የቦዲ + የውሃ ምልክት ማጥፊያ + የጎማ እና ሪም ዲቴይሊንግ።',
    },
    'pkg_plat_ext_c_name': {
      AppLanguage.en: 'Platinum Exterior - C',
      AppLanguage.om: 'Pulaatiiniyemii Alaa - Sadarkaa C',
      AppLanguage.am: 'ፕላቲነም የውጭ - ደረጃ ሲ',
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
      AppLanguage.om: 'Paakeejii Daayimandii Guutuu',
      AppLanguage.am: 'ዳይመንድ ሙሉ ፓኬጅ',
    },
    'pkg_diamond_full_desc': {
      AppLanguage.en: 'The ultimate showroom detail: Full Platinum Interior + Complete Platinum Exterior Level C.',
      AppLanguage.om: 'Sadarkaa olaanaa: Pulaatiiniyemii Keessoo Guutuu + Pulaatiiniyemii Alaa Sadarkaa C guutuu.',
      AppLanguage.am: 'የላቀ የሾውሩም ደረጃ ዲቴይሊንግ፡ ሙሉ የፕላቲነም የውስጥ + የተሟላ የፕላቲነም የውጭ ደረጃ ሲ።',
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
      AppLanguage.om: 'Dhiqannaa Saamunaa Saffisaa',
      AppLanguage.am: 'ፈጣን የአረፋ ሳሙና እጥበት',
    },
    'pkg_express_desc': {
      AppLanguage.en: 'High-pressure water rinse, active snow foam soak, tire shine & hand dry.',
      AppLanguage.om: 'Bishaan dhiibbaa ol-aanaa, saamunaa hoomisaa, cululuqsa gommaafi goggogsuu harkaa.',
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
      AppLanguage.om: 'Kaashiyara',
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
      AppLanguage.om: 'Hojii Kaashiyara',
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
      AppLanguage.om: 'Kaffaltii Dijitaalaa (Telebirr / CBE)',
      AppLanguage.am: 'ዲጂታል ክፍያ (ቴሌብር / ሲቢኢ ብር)',
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
      AppLanguage.om: 'Dabareefi Konkolaattota',
      AppLanguage.am: 'የመኪኖች ተራ ዝርዝር',
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
    'noReceiptImageAvailable': {
      AppLanguage.en: 'No Receipt Image Available',
      AppLanguage.om: 'Suurri Nagahee Hin Jiru',
      AppLanguage.am: 'የደረሰኝ ምስል አይገኝም',
    },
    'openWebReceipt': {
      AppLanguage.en: 'Open Web Receipt',
      AppLanguage.om: 'Nagahee Weebii Bani',
      AppLanguage.am: 'የድር ደረሰኝ ክፈት',
    },
    'verifiedDigitalReceipt': {
      AppLanguage.en: 'Verified Digital Receipt Proof',
      AppLanguage.om: 'Mirkaneessa Nagahee Dijitaalaa',
      AppLanguage.am: 'የተረጋገጠ የዲጂታል ደረሰኝ ማረጋገጫ',
    },
    'print': {
      AppLanguage.en: 'Print',
      AppLanguage.om: 'Maxxansi',
      AppLanguage.am: 'አትም',
    },
    'export': {
      AppLanguage.en: 'Export',
      AppLanguage.om: 'Gadhisiisi',
      AppLanguage.am: 'ላክ (Export)',
    },
    'exportCsv': {
      AppLanguage.en: 'Export CSV',
      AppLanguage.om: 'CSV Gadhisiisi',
      AppLanguage.am: 'CSV ላክ',
    },
    'printReceipt': {
      AppLanguage.en: 'Print Receipt',
      AppLanguage.om: 'Nagahee Maxxansi',
      AppLanguage.am: 'ደረሰኝ አትም',
    },
    'printReport': {
      AppLanguage.en: 'Print Report',
      AppLanguage.om: 'Gabaasa Maxxansi',
      AppLanguage.am: 'ሪፖርት አትም',
    },
    'printStatement': {
      AppLanguage.en: 'Print Statement',
      AppLanguage.om: 'Ibsa Maxxansi',
      AppLanguage.am: 'መግለጫ አትም',
    },
    'exportStatement': {
      AppLanguage.en: 'Export Statement',
      AppLanguage.om: 'Ibsa Gadhisiisi',
      AppLanguage.am: 'መግለጫ ላክ',
    },
    'printPayroll': {
      AppLanguage.en: 'Print Payroll',
      AppLanguage.om: 'Mindaa Maxxansi',
      AppLanguage.am: 'ደመወዝ አትም',
    },
    'exportPayroll': {
      AppLanguage.en: 'Export Payroll',
      AppLanguage.om: 'Mindaa Gadhisiisi',
      AppLanguage.am: 'ደመወዝ ላክ',
    },
    'deleteItem': {
      AppLanguage.en: 'Delete',
      AppLanguage.om: 'Haqi',
      AppLanguage.am: 'ሰርዝ',
    },
    'clearAll': {
      AppLanguage.en: 'Clear All',
      AppLanguage.om: 'Hunda Haqi',
      AppLanguage.am: 'ሁሉንም አጽዳ',
    },
    'confirmClearAll': {
      AppLanguage.en: 'Confirm Clear All',
      AppLanguage.om: 'Hunda Haqamuu Mirkaneessi',
      AppLanguage.am: 'ሁሉንም ማጽዳት አረጋግጥ',
    },
    'deleteSmsConfirm': {
      AppLanguage.en: 'Are you sure you want to delete this bank SMS?',
      AppLanguage.om: 'SMS baankii kana haquu barbaaddaa?',
      AppLanguage.am: 'ይህን የባንክ SMS መሰረዝ እርግጠኛ ኖት?',
    },
    'clearAllSmsConfirm': {
      AppLanguage.en: 'Are you sure you want to clear all incoming bank SMS records?',
      AppLanguage.om: 'Galmee SMS baankii hunda haquu mirkaneessaa?',
      AppLanguage.am: 'ሁሉንም የገቢ ባንክ SMS መዝገቦች ማጽዳት እርግጠኛ ኖት?',
    },
    'clearAllReceiptsConfirm': {
      AppLanguage.en: 'Are you sure you want to clear all station receipts?',
      AppLanguage.om: 'Nagahee buufataa hunda haquu mirkaneessaa?',
      AppLanguage.am: 'ሁሉንም የጣቢያ ደረሰኞች ማጽዳት እርግጠኛ ኖት?',
    },
    'receiptTitle': {
      AppLanguage.en: 'Customer Receipt',
      AppLanguage.om: 'Nagahee Maamilaa',
      AppLanguage.am: 'የደንበኛ ደረሰኝ',
    },
    'deleteReceiptConfirm': {
      AppLanguage.en: 'Are you sure you want to delete this station receipt?',
      AppLanguage.om: 'Nagahee buufataa kana haquu barbaaddaa?',
      AppLanguage.am: 'ይህን የጣቢያ ደረሰኝ መሰረዝ እርግጠኛ ኖት?',
    },
    'receiptDeletedSuccess': {
      AppLanguage.en: 'Station receipt deleted successfully',
      AppLanguage.om: 'Nagaheen buufataa milkaa\'inaan haqameera',
      AppLanguage.am: 'የጣቢያው ደረሰኝ በተሳካ ሁኔታ ተሰርዟል',
    },
    'allReceiptsClearedSuccess': {
      AppLanguage.en: 'All station receipts cleared successfully',
      AppLanguage.om: 'Nagaheen buufataa hundi milkaa\'inaan haqamaniiru',
      AppLanguage.am: 'ሁሉም የጣቢያ ደረሰኞች በተሳካ ሁኔታ ጸድተዋል',
    },
    'smsDeletedSuccess': {
      AppLanguage.en: 'Bank SMS record deleted successfully',
      AppLanguage.om: 'Galmeen SMS baankii milkaa\'inaan haqameera',
      AppLanguage.am: 'የባንክ SMS መዝገብ በተሳካ ሁኔታ ተሰርዟል',
    },
    'allSmsClearedSuccess': {
      AppLanguage.en: 'All incoming bank SMS records cleared successfully',
      AppLanguage.om: 'Galmeen SMS baankii hundi milkaa\'inaan haqamaniiru',
      AppLanguage.am: 'ሁሉም የባንክ SMS መዝገቦች በተሳካ ሁኔታ ጸድተዋል',
    },
    'pricingManagementTitle': {
      AppLanguage.en: 'Service Pricing & Master Inventory',
      AppLanguage.om: 'Gatii Tajaajilaa fi Qabeenyaa Waliigalaa',
      AppLanguage.am: 'የእጥበት ዋጋ እና አጠቃላይ የንብረት መቆጣጠሪያ',
    },
    'masterPricingAndInventory': {
      AppLanguage.en: 'Pricing & Master Inventory Editor',
      AppLanguage.om: 'Gulaalaa Gatii fi Qabeenyaa Waliigalaa',
      AppLanguage.am: 'የዋጋ ማስተካከያ እና አጠቃላይ የንብረት መቆጣጠሪያ',
    },
    'carWashTariffs': {
      AppLanguage.en: 'Car Wash Detailing',
      AppLanguage.om: 'Dhiqannaa Konkolaataa',
      AppLanguage.am: 'የመኪና ማጠቢያ ዋጋዎች',
    },
    'carpetTariffs': {
      AppLanguage.en: 'Carpet Services',
      AppLanguage.om: 'Tajaajila Karpeetii',
      AppLanguage.am: 'የምንጣፍ አገልግሎቶች',
    },
    'consumablesPricing': {
      AppLanguage.en: 'Storekeeper Consumables',
      AppLanguage.om: 'Meeshaalee Dhumatoo Bakka Kuusaa',
      AppLanguage.am: 'የመጋዘን አላቂ እቃዎች',
    },
    'fixedAssetsValuation': {
      AppLanguage.en: 'Storekeeper Fixed Assets',
      AppLanguage.om: 'Qabeenya Dhaabbataa Bakka Kuusaa',
      AppLanguage.am: 'የመጋዘን ቋሚ ንብረቶች',
    },
    'monthlyOverheadsTab': {
      AppLanguage.en: 'Monthly Overheads & Utilities',
      AppLanguage.om: 'Baasiiwwan Ji\'aa fi Tajaajiloota',
      AppLanguage.am: 'ወርሃዊ ወጪዎችና መገልገያዎች',
    },
    'dailyAccrualRate': {
      AppLanguage.en: 'Daily Accrual (÷ 30)',
      AppLanguage.om: 'Herrega Guyyaa (÷ 30)',
      AppLanguage.am: 'ዕለታዊ ወጪ (÷ 30)',
    },
    'monthlyBudget': {
      AppLanguage.en: 'Monthly Budget',
      AppLanguage.om: 'Bajata Ji\'aa',
      AppLanguage.am: 'ወርሃዊ በጀት',
    },
    'addCustomOverhead': {
      AppLanguage.en: 'Add Overhead Expense',
      AppLanguage.om: 'Baasii Haaraa Dabali',
      AppLanguage.am: 'አዲስ ወጪ ያክሉ',
    },
    'editOverhead': {
      AppLanguage.en: 'Edit Overhead Amount',
      AppLanguage.om: 'Hanga Baasii Gulaali',
      AppLanguage.am: 'የወጪውን መጠን ያስተካክሉ',
    },
    'deleteOverheadConfirm': {
      AppLanguage.en: 'Are you sure you want to delete this custom overhead expense?',
      AppLanguage.om: 'Baasii kana haquu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት ይህን ወጪ መሰረዝ ይፈልጋሉ?',
    },
    'pnlDailyView': {
      AppLanguage.en: 'Today Live P&L',
      AppLanguage.om: 'Bu\'aa/Kisaaraa Har\'aa',
      AppLanguage.am: 'የዛሬ የቀጥታ ትርፍና ኪሳራ',
    },
    'pnlMonthlyView': {
      AppLanguage.en: 'Monthly Statement',
      AppLanguage.om: 'Gabaasa Ji\'aa',
      AppLanguage.am: 'ወርሃዊ የሂሳብ መግለጫ',
    },
    'dailyRentAccrual': {
      AppLanguage.en: 'Station Land / House Rent (1/30th)',
      AppLanguage.om: 'Kiraa Lafaa/Bakka Buufataa (1/30)',
      AppLanguage.am: 'የጣቢያው መሬት / የቦታ ኪራይ (1/30)',
    },
    'dailyWaterAccrual': {
      AppLanguage.en: 'Municipal Water Supply (1/30th)',
      AppLanguage.om: 'Tajaajila Bishaanii (1/30)',
      AppLanguage.am: 'የውሃ አገልግሎት ፍጆታ (1/30)',
    },
    'dailyElectricityAccrual': {
      AppLanguage.en: 'Electricity Utility - EEU (1/30th)',
      AppLanguage.om: 'Humna Elektiriikii - EEU (1/30)',
      AppLanguage.am: 'የኤሌክትሪክ አገልግሎት - ኢኢዩ (1/30)',
    },
    'dailyInternetAccrual': {
      AppLanguage.en: 'Wi-Fi & Digital Connectivity (1/30th)',
      AppLanguage.om: 'Interneetii fi Wi-Fi (1/30)',
      AppLanguage.am: 'ኢንተርኔት እና ዋይፋይ (1/30)',
    },
    'dailySanitationAccrual': {
      AppLanguage.en: 'Municipal Sanitation & Environment (1/30th)',
      AppLanguage.om: 'Gibira Qulqullina Magaalaa (1/30)',
      AppLanguage.am: 'የከተማ ጽዳትና አካባቢ ጥበቃ ግብር (1/30)',
    },
    'dailyFuelAccrual': {
      AppLanguage.en: 'Generator Fuel & Maintenance Buffer (1/30th)',
      AppLanguage.om: 'Bobaa Jenereetaraa fi Suphaa (1/30)',
      AppLanguage.am: 'የጄኔሬተር ነዳጅ እና ጥገና (1/30)',
    },
    'dailyStaffSalaryAccrual': {
      AppLanguage.en: 'Management & Office Staff Salaries (1/30th)',
      AppLanguage.om: 'Miindaa Hojjettoota Waajjiraa (1/30)',
      AppLanguage.am: 'የአስተዳደርና የቢሮ ሰራተኞች ደመወዝ (1/30)',
    },
    'dailyWasherBaseAccrual': {
      AppLanguage.en: 'Washer Guaranteed Base Payroll Reserve (1/30th)',
      AppLanguage.om: 'Qophii Miindaa Bu\'uuraa Dhiqxootaa (1/30)',
      AppLanguage.am: 'የአጣቢዎች ዝቅተኛ ዋስትና ደመወዝ (1/30)',
    },
    'dailyMachineryDepreciation': {
      AppLanguage.en: 'Machinery & Equipment Depreciation (1/30th)',
      AppLanguage.om: 'Moofina Maashinootaa fi Qabeenyaa (1/30)',
      AppLanguage.am: 'የማሽኖችና ቋሚ ዕቃዎች እርጅና/ዲፕሪሴሽን (1/30)',
    },
    'addNewService': {
      AppLanguage.en: 'Add New Service',
      AppLanguage.om: 'Tajaajila Haaraa Dabali',
      AppLanguage.am: 'አዲስ አገልግሎት ያክሉ',
    },
    'edit': {
      AppLanguage.en: 'Edit',
      AppLanguage.om: 'Gulaali',
      AppLanguage.am: 'አስተካክል',
    },
    'editService': {
      AppLanguage.en: 'Edit Service',
      AppLanguage.om: 'Tajaajila Gulaali',
      AppLanguage.am: 'አገልግሎቱን ያርትዑ',
    },
    'deleteService': {
      AppLanguage.en: 'Delete Service',
      AppLanguage.om: 'Tajaajila Haqi',
      AppLanguage.am: 'አገልግሎቱን ይሰርዙ',
    },
    'confirmDeleteService': {
      AppLanguage.en: 'Are you sure you want to permanently delete this service?',
      AppLanguage.om: 'Tajaajila kana dhaabbataan haquu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት ይህን አገልግሎት እስከመጨረሻው መሰረዝ ይፈልጋሉ?',
    },
    'addNewConsumable': {
      AppLanguage.en: 'Add Consumable Item',
      AppLanguage.om: 'Meeshaa Dhumataa Haaraa Dabali',
      AppLanguage.am: 'አዲስ አላቂ እቃ ያክሉ',
    },
    'editConsumable': {
      AppLanguage.en: 'Edit Consumable Item',
      AppLanguage.om: 'Meeshaa Dhumataa Gulaali',
      AppLanguage.am: 'አላቂ እቃውን ያርትዑ',
    },
    'deleteConsumableConfirm': {
      AppLanguage.en: 'Are you sure you want to delete this consumable item from inventory?',
      AppLanguage.om: 'Meeshaa dhumataa kana kuusaa keessaa haquu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት ይህን አላቂ እቃ ከመጋዘን ዝርዝር መሰረዝ ይፈልጋሉ?',
    },
    'addNewFixedAsset': {
      AppLanguage.en: 'Add Fixed Asset',
      AppLanguage.om: 'Qabeenya Dhaabbataa Haaraa Dabali',
      AppLanguage.am: 'አዲስ ቋሚ ንብረት ያክሉ',
    },
    'editFixedAsset': {
      AppLanguage.en: 'Edit Fixed Asset',
      AppLanguage.om: 'Qabeenya Dhaabbataa Gulaali',
      AppLanguage.am: 'ቋሚ ንብረቱን ያርትዑ',
    },
    'deleteFixedAssetConfirm': {
      AppLanguage.en: 'Are you sure you want to permanently delete this fixed asset?',
      AppLanguage.om: 'Qabeenya dhaabbataa kana dhaabbataan haquu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት ይህን ቋሚ ንብረት እስከመጨረሻው መሰረዝ ይፈልጋሉ?',
    },
    'assetValueEtb': {
      AppLanguage.en: 'Asset Valuation (ETB)',
      AppLanguage.om: 'Gatii Qabeenyaa (ETB)',
      AppLanguage.am: 'የንብረቱ ዋጋ (ብር)',
    },
    'unitCostEtb': {
      AppLanguage.en: 'Unit Cost / Price (ETB)',
      AppLanguage.om: 'Gatii Tokkoo (ETB)',
      AppLanguage.am: 'የአንዱ ዋጋ (ብር)',
    },
    'addNewCarpetService': {
      AppLanguage.en: 'Add Carpet Service',
      AppLanguage.om: 'Tajaajila Karpeetii Dabali',
      AppLanguage.am: 'የምንጣፍ አገልግሎት ያክሉ',
    },
    'editCarpetService': {
      AppLanguage.en: 'Edit Carpet Service',
      AppLanguage.om: 'Tajaajila Karpeetii Gulaali',
      AppLanguage.am: 'የምንጣፍ አገልግሎት ያርትዑ',
    },
    'deleteCarpetServiceConfirm': {
      AppLanguage.en: 'Are you sure you want to delete this carpet service?',
      AppLanguage.om: 'Tajaajila karpeetii kana haquu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት ይህን የምንጣፍ አገልግሎት መሰረዝ ይፈልጋሉ?',
    },
    'superAdminOnlyNotice': {
      AppLanguage.en: 'Super Admin Access: Direct live changes to system tariffs & inventory',
      AppLanguage.om: 'Eeyyama Super Admin: Gatiiwwan sirnaa fi kuusaa kallattiin gulaaluuf',
      AppLanguage.am: 'የሱፐር አድሚን ፈቃድ፡ የሲስተም ዋጋዎችንና የመጋዘን እቃዎችን በቀጥታ የማስተካከል ስልጣን',
    },

    // ================= UPDATED FULL MASTER TABLE LOCALIZATION =================
    // Categories
    'cat_exterior': {
      AppLanguage.en: 'Exterior & Hand Wash',
      AppLanguage.om: 'Dhiqannaa Qaama Alaa fi Harka',
      AppLanguage.am: 'የውጭ አካል እና የእጅ እጥበት',
    },
    'cat_polish': {
      AppLanguage.en: 'Body Polish & Paint Correction',
      AppLanguage.om: 'Poolishii Qaama Konkolaataa fi Bakkoltee Halluu Sirreessuu',
      AppLanguage.am: 'የመኪና አካል ፖሊሽ እና የቀለም ጭረት ጥገና',
    },
    'cat_interior': {
      AppLanguage.en: 'Interior Restoration & Detailing',
      AppLanguage.om: 'Qulqullina Keessaa fi Miidhagina Guutuu',
      AppLanguage.am: 'የውስጥ ክፍል ፅዳት እና ዲቴይሊንግ',
    },
    'cat_engine': {
      AppLanguage.en: 'Engine & Specialty Detailing',
      AppLanguage.om: 'Qulqullina Gadi-fageenyaa Mootoraa fi Kutaa Addaa',
      AppLanguage.am: 'የሞተር እና የሞተር የተለያዩ ክፍሎች ጥልቅ ፅዳት',
    },
    'cat_specialty': {
      AppLanguage.en: 'Engine & Specialty Detailing',
      AppLanguage.om: 'Qulqullina Gadi-fageenyaa Mootoraa fi Kutaa Addaa',
      AppLanguage.am: 'የሞተር እና የሞተር የተለያዩ ክፍሎች ጥልቅ ፅዳት',
    },

    // 1. Exterior & Hand Wash Items
    'srv_body_wash': {
      AppLanguage.en: 'Body Hand Wash with Shampoo & Fiber Towel',
      AppLanguage.om: 'Dhiqannaa qaama konkolaataa shaamപ്പോ fi fooxaa faayiberiitiin',
      AppLanguage.am: 'የመኪና አካል በሻምፖ እና በፋይበር ፎጣ እጥበት',
    },
    'srv_tire_clean': {
      AppLanguage.en: 'Tire Cleaning & Tire Black Finish',
      AppLanguage.om: 'Qulqullina gommaa fi kuula guraachessituu gommaa',
      AppLanguage.am: 'የጎማ እጥበት እና ማጥቆሪያ ቅባት',
    },
    'srv_window_polish': {
      AppLanguage.en: 'Window Polish & Cleaning',
      AppLanguage.om: 'Daawwitii foddaa konkolaataa qulqulleessuu',
      AppLanguage.am: 'የመስኮት መስታወት ማጽዳት',
    },

    // 2. Body Polish & Paint Correction Items
    'srv_machine_polish': {
      AppLanguage.en: 'Machine Body Polish',
      AppLanguage.om: 'Poolishii qaamaa maashiniin hojjetamu',
      AppLanguage.am: 'በማሽን የሚደረግ የሰውነት ፖሊሽ',
    },
    'srv_scratch_removal': {
      AppLanguage.en: 'Scratch / Minor Scratch Removal',
      AppLanguage.om: 'Ciccitaa fi madaa xixiqqoo halluu balleessuu',
      AppLanguage.am: 'የጭረት እና ጥቃቅን ስንጥቆች ማስለቀቅ',
    },
    'srv_water_spot': {
      AppLanguage.en: 'Water Spot Chemical Removal',
      AppLanguage.om: 'Mallattoo bishaanii fi ashaboo goge qorichaan balleessuu',
      AppLanguage.am: 'የውሃ እና የጨው ድርቀት ምልክቶችን ማስለቀቅ',
    },

    // 3. Interior Restoration & Detailing Items
    'srv_int_vacuum': {
      AppLanguage.en: 'Interior Vacuum: Floor & Seat Cleaning',
      AppLanguage.om: 'Vaakiyuumii keessaa (dhukkee lafaa fi teessumaa qulqulleessuu)',
      AppLanguage.am: 'የውስጥ ክፍል ቫኪዩም (የወለል እና የወንበር አቧራ ማጽዳት)',
    },
    'srv_seats_out': {
      AppLanguage.en: 'Seat & Floor Carpet Removed & Washed',
      AppLanguage.om: 'Teessumootaa fi afata lafaa baasanii dhiquu',
      AppLanguage.am: 'ወንበሮችና የወለል ምንጣፎች ወጥተው የሚታጠቡበት',
    },
    'srv_roof_cleaning': {
      AppLanguage.en: 'Roof Headliner Deep Cleaning',
      AppLanguage.om: 'Huccuu korniisa/baaxii keessaa gadi-fageenyaan dhiquu',
      AppLanguage.am: 'የኮርኒስ/የጣራ ጨርቅ ጥልቅ እጥበት',
    },
    'srv_dashboard_detailing': {
      AppLanguage.en: 'Dashboard Detailing: Cream & Airfresh',
      AppLanguage.om: 'Daashboordii miidheksuu (kiriimii fi shittoo sirreessuu)',
      AppLanguage.am: 'የዳሽቦርድ ማስዋብ (ክሬም እና ሽቶ ማስተካከል)',
    },
    'srv_door_panel': {
      AppLanguage.en: 'Door Panel Deep Cleaning',
      AppLanguage.om: 'Qaama keessoo balbalaa gadi-fageenyaan qulqulleessuu fi miidheksuu',
      AppLanguage.am: 'የበር ውስጣዊ ገጽታዎች ጥልቅ ጽዳት እና ማስዋብ',
    },

    // 4. Engine & Specialty Detailing Items
    'srv_engine_shampoo': {
      AppLanguage.en: 'Engine Cleaning: Shampoo',
      AppLanguage.om: 'Mootora shaamപ്പോdhaan dhiquu',
      AppLanguage.am: 'የሞተር እጥበት (በሻምፖ)',
    },
    'srv_engine_chemical': {
      AppLanguage.en: 'Engine Bay Chemical Degreasing: Deep Clean, Rinse & Dry',
      AppLanguage.om: 'Moora mootoraa kemikaalaan cooma qulqulleessuu (dhiquu, dhiqachuu fi gogsuu)',
      AppLanguage.am: 'የሞተር ክፍል በኬሚካል ቅባት ማስለቀቅ (ጥልቅ ጽዳት፣ ማጠብ እና ማድረቅ)',
    },
    'srv_headlight_restoration': {
      AppLanguage.en: 'Headlight Restoration',
      AppLanguage.om: 'Daawwitii ifaa fuulduraa kan dhiitama/bifa gate gara oriijinaalaatti deebisuu',
      AppLanguage.am: 'የደበዘዘ (የወየበ) የግንባር መብራት መስታወት ወደ ኦሪጂናል መመለስ',
    },
    'srv_plastic_trim': {
      AppLanguage.en: 'Plastic Trim Restoration',
      AppLanguage.om: 'Pilaastikii fi Gommaa Haaromsuu',
      AppLanguage.am: 'የፕላስቲክ እና የጎማ ማደስ',
    },
    'srv_diamond_detailing': {
      AppLanguage.en: 'Diamond - Interior & Exterior Detailing (1 Day)',
      AppLanguage.om: 'Daayimandii - Miidhagina Keessaa fi Alaa Guutuu (Guyyaa 1)',
      AppLanguage.am: 'ዳይመንድ - የውስጥ እና የውጭ ሙሉ ዲቴይሊንግ (1 ቀን)',
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
    'scanningReceipt': {
      AppLanguage.en: 'Scanning receipt for transaction reference...',
      AppLanguage.om: 'Nagahee irraa koodii dabarsaa barbaadaa jira...',
      AppLanguage.am: 'ከደረሰኙ ላይ የክፍያ ማረጋገጫ ቁጥር በመቃኘት ላይ...',
    },
    'autoDetectedRef': {
      AppLanguage.en: 'Auto-scanned reference: ',
      AppLanguage.om: 'Koodii nagahee irraa argame: ',
      AppLanguage.am: 'ከደረሰኙ የተገኘ የክፍያ ቁጥር: ',
    },
    'detectedRecentBankSms': {
      AppLanguage.en: 'Recent Bank SMS Detected',
      AppLanguage.om: 'Ergaan Baankii Dhiyoo Argameera',
      AppLanguage.am: 'የቅርብ ጊዜ የባንክ ኤስኤምኤስ ተገኝቷል',
    },
    'tapToUseRef': {
      AppLanguage.en: 'Tap to Auto-Fill',
      AppLanguage.om: 'Guutuuf Tuqi',
      AppLanguage.am: 'ለመሙላት ይንኩ',
    },
    'confirmAndPay': {
      AppLanguage.en: 'Confirm & Complete Payment',
      AppLanguage.om: 'Mirkaneessiitii Kaffali',
      AppLanguage.am: 'አረጋግጥና ክፍያ ፈፅም',
    },
    'paymentAlreadyCollected': {
      AppLanguage.en: 'Payment Already Collected & Confirmed',
      AppLanguage.om: 'Kaffaltiin kanaan dura walitti qabamee mirkanaa\'eera',
      AppLanguage.am: 'ክፍያው አስቀድሞ ተሰብስቦ ተረጋግጧል',
    },
    'doubleCollectionDisabled': {
      AppLanguage.en: 'Double payment collection is strictly disabled.',
      AppLanguage.om: 'Kaffaltii dachaa walitti qabuun guutummaatti cufameera.',
      AppLanguage.am: 'ድርብ ክፍያ መሰብሰብ ሙሉ በሙሉ ታግዷል።',
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
      AppLanguage.om: 'Dabaree Kallattii',
      AppLanguage.am: 'የቀጥታ ተራ',
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
      AppLanguage.en: 'Full Name or Car Type',
      AppLanguage.om: 'Maqaa Guutuu ykn Gosa Konkolaataa',
      AppLanguage.am: 'ሙሉ ስም ወይም የመኪና ዓይነት',
    },
    'fullNameOrCarType': {
      AppLanguage.en: 'Full Name or Car Type',
      AppLanguage.om: 'Maqaa Guutuu ykn Gosa Konkolaataa',
      AppLanguage.am: 'ሙሉ ስም ወይም የመኪና ዓይነት',
    },
    'enterNameOrCarType': {
      AppLanguage.en: 'Please enter full name or car type',
      AppLanguage.om: 'Maaloo maqaa guutuu ykn gosa konkolaataa galchaa',
      AppLanguage.am: 'እባክዎ ሙሉ ስም ወይም የመኪና ዓይነት ያስገቡ',
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
      AppLanguage.om: 'Dabareen hin jiru • Tajaajila battalaa',
      AppLanguage.am: 'ተራ የለም • ፈጣን አገልግሎት ዝግጁ ነው',
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
      AppLanguage.en: 'Call hotline to book your wash instantly by phone',
      AppLanguage.om: 'Dhiqannaa battalatti qabachuuf sarara bilbilaa fayyadamaa',
      AppLanguage.am: 'በስልክ ፈጣን ቀጠሮ ለመያዝ ወደ ሆትላይን ቁጥር ይደውሉ',
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
      AppLanguage.en: 'Shift Locked',
      AppLanguage.om: 'Hojiin Cufameera',
      AppLanguage.am: 'ተዘግቷል',
    },
    'smsSentSuccess': {
      AppLanguage.en: 'Completion SMS dispatched to customer',
      AppLanguage.om: 'Ergaan xumuramu maamiilaaf ergameera',
      AppLanguage.am: 'የማጠናቀቂያ አጭር የጽሑፍ መልዕክት (SMS) ለደንበኛው ተልኳል',
    },
    'smsGatewayPhone': {
      AppLanguage.en: 'Cashier SMS Gateway Phone',
      AppLanguage.om: 'Lakk. Bilbilaa Ergaa SMS Kaashiyara',
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
      AppLanguage.om: 'Maqaa Kaashiyara Cufuu',
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
      AppLanguage.om: 'Gabaasa Komishiinii Torbanii Dhiqxootaa',
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
      AppLanguage.om: 'Kaashiyaraan Kan Gabaafame',
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
    'splitPayment': {
      AppLanguage.en: 'Split Payment (Cash + Digital)',
      AppLanguage.om: 'Kaffaltii Qoodamaa (Qarshii + Dijitaala)',
      AppLanguage.am: 'የተከፈለ ክፍያ (ጥሬ ገንዘብ + ዲጂታል)',
    },
    'cashPortion': {
      AppLanguage.en: 'Cash Portion (ETB)',
      AppLanguage.om: 'Qooda Qarshii (ETB)',
      AppLanguage.am: 'የጥሬ ገንዘብ መጠን (ETB)',
    },
    'digitalPortion': {
      AppLanguage.en: 'Digital Portion (ETB)',
      AppLanguage.om: 'Qooda Dijitaalaa (ETB)',
      AppLanguage.am: 'የዲጂታል ክፍያ መጠን (ETB)',
    },
    'splitTotalMismatch': {
      AppLanguage.en: 'Cash + Digital must equal the total amount due.',
      AppLanguage.om: 'Qarshiin fi Dijitaalli walitti qabamee gatii guutuu wajjin walqixa ta\'uu qaba.',
      AppLanguage.am: 'ጥሬ ገንዘብ እና ዲጂታል ድምር ከሚፈለገው ጠቅላላ ክፍያ ጋር እኩል መሆን አለበት።',
    },
    'bankVerifiedBadge': {
      AppLanguage.en: 'Bank Verified',
      AppLanguage.om: 'Baankin Mirkanaa\'e',
      AppLanguage.am: 'በባንክ የተረጋገጠ',
    },
    'bankPendingSmsBadge': {
      AppLanguage.en: 'Pending Bank SMS',
      AppLanguage.om: 'SMS Baankii Eegaa Jira',
      AppLanguage.am: 'የባንክ SMS በመጠበቅ ላይ',
    },
    'bankDiscrepancyBadge': {
      AppLanguage.en: 'Payment Discrepancy',
      AppLanguage.om: 'Garaagarummaa Kaffaltii',
      AppLanguage.am: 'የክፍያ ልዩነት',
    },
    'overpaymentDetected': {
      AppLanguage.en: 'Overpayment Detected',
      AppLanguage.om: 'Kaffaltii Dabalataa Argame',
      AppLanguage.am: 'ተጨማሪ ክፍያ ተገኝቷል',
    },
    'refundCashDrawer': {
      AppLanguage.en: 'Refund Difference in Cash',
      AppLanguage.om: 'Garaagarummaa Qarshiin Deebisi',
      AppLanguage.am: 'ልዩነቱን በጥሬ ገንዘብ መልስ',
    },
    'addAsWasherTip': {
      AppLanguage.en: 'Add Difference to Washer Tip',
      AppLanguage.om: 'Garaagarummaa Badhaasa Miiccootaatti Dabali',
      AppLanguage.am: 'ልዩነቱን ለአጣቢዎች ጉርሻ ጨምር',
    },
    'targetAccountNotice': {
      AppLanguage.en: 'Send payment to',
      AppLanguage.om: 'Kaffaltii asitti ergaa',
      AppLanguage.am: 'ክፍያውን ወደዚህ ይላኩ',
    },
    'sentinelStatusOnline': {
      AppLanguage.en: 'Sentinel Online',
      AppLanguage.om: 'Seentineelii Hojirra Jira',
      AppLanguage.am: 'ሴንቲኔል ዝግጁ ነው',
    },
    'sentinelStatusOffline': {
      AppLanguage.en: 'Sentinel Offline',
      AppLanguage.om: 'Seentineeliin Dhaabbateera',
      AppLanguage.am: 'ሴንቲኔል መስመር ላይ አይደለም',
    },
    'policyFlexibleMode': {
      AppLanguage.en: 'Flexible Mode (Photo + Delayed SMS)',
      AppLanguage.om: 'Haala Salphaa (Suuraa + SMS Booda)',
      AppLanguage.am: 'ተለዋዋጭ ሁነታ (ፎቶ + የዘገየ SMS)',
    },
    'policyStrictMode': {
      AppLanguage.en: 'Strict Lockdown (Bank SMS Required)',
      AppLanguage.om: 'Haala Cimaa (SMS Baankii Dirqama)',
      AppLanguage.am: 'ጥብቅ ሁነታ (የባንክ SMS ግዴታ)',
    },
    'sentinelTitle': {
      AppLanguage.en: 'Bishe PayGuard Sentinel',
      AppLanguage.om: 'Tiksaa Kaffaltii Seentineelii',
      AppLanguage.am: 'ቢሼ ፔይጋርድ ሴንቲነል',
    },
    'incomingBankSmsTab': {
      AppLanguage.en: 'Incoming Bank SMS',
      AppLanguage.om: 'Ergaa Baankii Galte',
      AppLanguage.am: 'ገቢ የባንክ SMS',
    },
    'stationReceiptsTab': {
      AppLanguage.en: 'Station Receipts',
      AppLanguage.om: 'Nagahee Buufataa',
      AppLanguage.am: 'የጣቢያ ደረሰኞች',
    },
    'unmatchedCredits': {
      AppLanguage.en: 'Unmatched Bank Credits',
      AppLanguage.om: 'Kaffaltii Baankii Hin Walsimne',
      AppLanguage.am: 'ያልተመሳሰሉ የባንክ ገቢዎች',
    },
    'matchedBooking': {
      AppLanguage.en: 'Matched Vehicle',
      AppLanguage.om: 'Konkolaataa Walsime',
      AppLanguage.am: 'የተመሳሰለ መኪና',
    },
    'payerInfo': {
      AppLanguage.en: 'Payer',
      AppLanguage.om: 'Kaffalaa',
      AppLanguage.am: 'ከፋይ',
    },
    'copyRef': {
      AppLanguage.en: 'Copy Reference',
      AppLanguage.om: 'Lakkoofsa Waraabi',
      AppLanguage.am: 'የማረጋገጫ ቁጥር ኮፒ',
    },
    'batteryLevel': {
      AppLanguage.en: 'Battery',
      AppLanguage.om: 'Baatrii',
      AppLanguage.am: 'ባትሪ',
    },
    'lastHeartbeat': {
      AppLanguage.en: 'Last Heartbeat',
      AppLanguage.om: 'Yeroo Dhumaa Argamuu',
      AppLanguage.am: 'የመጨረሻ ግንኙነት',
    },
    'switchSecurityMode': {
      AppLanguage.en: 'Security Mode',
      AppLanguage.om: 'Haala Nageenyaa',
      AppLanguage.am: 'የደህንነት ሁነታ',
    },
    'rawSms': {
      AppLanguage.en: 'Raw Bank SMS',
      AppLanguage.om: 'Ergaa Guutuu',
      AppLanguage.am: 'ሙሉ የSMS መልዕክት',
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
      AppLanguage.om: 'Kuusaa Komishiinii Dhiqxootaa Guyyaa',
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
    'expandRoster': {
      AppLanguage.en: 'Expand Washer Roster',
      AppLanguage.om: 'Tarree Dhiqxootaa Bal\'isi',
      AppLanguage.am: 'የአጣቢዎች ዝርዝር ዘርጋ',
    },
    'collapseRoster': {
      AppLanguage.en: 'Collapse Washer Roster',
      AppLanguage.om: 'Tarree Dhiqxootaa Dhiphisi',
      AppLanguage.am: 'የአጣቢዎች ዝርዝር አሳንስ',
    },
    'onDutyBadge': {
      AppLanguage.en: 'ON DUTY',
      AppLanguage.om: 'HOJIRRA',
      AppLanguage.am: 'በስራ ላይ',
    },
    'absentBadge': {
      AppLanguage.en: 'ABSENT',
      AppLanguage.om: 'HIN JIRRE',
      AppLanguage.am: 'ቀሪ',
    },
    'absentWashersProtection': {
      AppLanguage.en: '100% of the commission pool is distributed strictly among washers on duty today. Absent washers receive 0 ETB.',
      AppLanguage.om: '100% kuusaa komishiinii qulqullinaan hojjettoota guyyaa kana hojirra jiran qofaaf raabsama. Kanneen hin jirre 0 ETB argatu.',
      AppLanguage.am: '100% የኮሚሽን ገቢ ዛሬ በስራ ላይ ላሉ አጣቢዎች ብቻ ይከፋፈላል። የቀሩ አጣቢዎች 0 ብር ያገኛሉ።',
    },
    'disbursedToday': {
      AppLanguage.en: 'Disbursed Today',
      AppLanguage.om: 'Har\'a Kaffalameera',
      AppLanguage.am: 'ዛሬ ተከፍሏል',
    },
    'disburseAndReportDailyCommission': {
      AppLanguage.en: 'Disburse & Report Daily Commission',
      AppLanguage.om: 'Komishiinii Guyyaa Raabsii Gabaasi',
      AppLanguage.am: 'ዕለታዊ ኮሚሽን አከፋፍለህ ሪፖርት አድርግ',
    },
    'confirmWeeklyCommissionPaid': {
      AppLanguage.en: 'Confirm & Mark Weekly Commission Paid',
      AppLanguage.om: 'Komishiinii Torbanii Kaffalame Mirkaneessi',
      AppLanguage.am: 'ሳምንታዊ ኮሚሽን መከፈሉን አረጋግጥ',
    },
    'weeklyCommissionPaidAndConfirmed': {
      AppLanguage.en: 'Weekly Commission Paid & Confirmed',
      AppLanguage.om: 'Komishiiniin Torbanii Kaffalamee Mirkanaa\'eera',
      AppLanguage.am: 'ሳምንታዊ ኮሚሽን ተከፍሎ ተረጋግጧል',
    },
    'dailyCommissionDisbursedReported': {
      AppLanguage.en: 'Daily commission pool disbursed and reported to Accountant & Admin!',
      AppLanguage.om: 'Kuusaan komishiinii guyyaa raabsamee Herregaafi Bulchaaf gabaafameera!',
      AppLanguage.am: 'ዕለታዊ የኮሚሽን ገቢ ተከፋፍሎ ለሂሳብ ሹምና ለአስተዳዳሪ ሪፖርት ተደርጓል!',
    },
    'weeklyCommissionPaidSuccess': {
      AppLanguage.en: 'Weekly commission successfully marked as paid and confirmed!',
      AppLanguage.om: 'Komishiiniin torbanii milkaa\'inaan kaffalamee mirkanaa\'eera!',
      AppLanguage.am: 'ሳምንታዊ ኮሚሽን በተሳካ ሁኔታ ተከፍሎ ተረጋግጧል!',
    },
    'adminWasherHubTitle': {
      AppLanguage.en: 'Washer Team Operations & 7-Day Matrix',
      AppLanguage.om: 'Hojii Garee Dhiqxootaa fi Maatriksii Guyyaa 7',
      AppLanguage.am: 'የአጣቢዎች ቡድን ስራዎች እና የ7 ቀን ማትሪክስ',
    },
    'sevenDayMatrix': {
      AppLanguage.en: '7-Day Payroll Matrix',
      AppLanguage.om: 'Maatriksii Mindaa Guyyaa 7',
      AppLanguage.am: 'የ7 ቀን የደመወዝ ማትሪክስ',
    },
    'liveRosterAndSwitches': {
      AppLanguage.en: 'Live Shift Attendance Roster',
      AppLanguage.om: 'Galmee Hojii Dhiqxootaa Ammee',
      AppLanguage.am: 'የቀጥታ የአጣቢዎች የስራ ምዝገባ',
    },
    'emptyRefillExchangeTitle': {
      AppLanguage.en: 'Empty Return & Refill Desk (ዕቃ በዕቃ)',
      AppLanguage.om: 'Iddoo Meeshaa Qullaa Deebisanii Guutuu (ዕቃ በዕቃ)',
      AppLanguage.am: 'የባዶ እቃ መልሶ መሙያ ጠረጴዛ (ዕቃ በዕቃ)',
    },
    'emptyRefillExchangeSub': {
      AppLanguage.en: 'Issue chemicals & soaps strictly upon returning empty bottles',
      AppLanguage.om: 'Qorichaa fi saamunaa qullaa deebisuun qofa kenni',
      AppLanguage.am: 'ኬሚካሎችና ሳሙናዎችን ባዶ እቃ ሲመለስ ብቻ ይስጡ',
    },
    'dailyClosingTitle': {
      AppLanguage.en: 'Daily Closing & Financial Reconciliations',
      AppLanguage.om: 'Cufiinsa Guyyaa & Madaallii Faayinaansii',
      AppLanguage.am: 'የዕለት ሂሳብ መዝጊያ እና የፋይናንስ ማጠቃለያ',
    },
    'liveStationCapacity': {
      AppLanguage.en: 'Live Station & Van Capacity',
      AppLanguage.om: 'Dandeettii Buufataafi Vaan Dhiqannaa',
      AppLanguage.am: 'የቀጥታ ጣቢያ እና የሞባይል ቫን አቅም',
    },
    'statusPaid': {
      AppLanguage.en: 'Paid',
      AppLanguage.om: 'Kaffalameera',
      AppLanguage.am: 'ተከፍሏል',
    },
    'financialReports': {
      AppLanguage.en: 'Financial Reports',
      AppLanguage.om: 'Gabaasaalee Faayinaansii',
      AppLanguage.am: 'የፋይናንስ ሪፖርቶች',
    },
    'depositToOwnerAccounts': {
      AppLanguage.en: 'Deposit Cash to Owner Accounts',
      AppLanguage.om: 'Qarshii Herrega Abbaa Qabeenyaatti Galchi',
      AppLanguage.am: 'ጥሬ ገንዘብ ለባለቤቱ አካውንት ገቢ አድርግ',
    },
    'cashAwaitingDeposit': {
      AppLanguage.en: 'Cash Awaiting Deposit',
      AppLanguage.om: 'Qarshii Baankii Galuu Eegu',
      AppLanguage.am: 'ባንክ ሊገባ የሚጠብቅ ጥሬ ገንዘብ',
    },
    'selectTargetBankAccount': {
      AppLanguage.en: 'Select Target Bank Account',
      AppLanguage.om: 'Herrega Baankii Filadhu',
      AppLanguage.am: 'የባንክ አካውንት ይምረጡ',
    },
    'dailyClosing': {
      AppLanguage.en: 'Daily Closing',
      AppLanguage.om: 'Cufiinsa Guyyaa',
      AppLanguage.am: 'የዕለት መዝጊያ',
    },
    'bay': {
      AppLanguage.en: 'Bay',
      AppLanguage.om: 'Kutaa',
      AppLanguage.am: 'ክፍል',
    },
    'recentRefillLogs': {
      AppLanguage.en: 'Recent Refill Logs',
      AppLanguage.om: 'Galmee Guutinsa Dhiyoo',
      AppLanguage.am: 'የቅርብ ጊዜ የመሙያ መዝገቦች',
    },
    'shiftHandoverDesk': {
      AppLanguage.en: 'Shift Handover Desk',
      AppLanguage.om: 'Kutaa Wal-Harkaa Fuudhiinsa Shiftii',
      AppLanguage.am: 'የፈረቃ ርክክብ ማዕከል',
    },
    'shiftHandoverLogs': {
      AppLanguage.en: 'Shift Handover Logs',
      AppLanguage.om: 'Galmee Wal-Harkaa Fuudhiinsa Shiftii',
      AppLanguage.am: 'የፈረቃ ርክክብ መዝገብ',
    },
    'handoverOtpCode': {
      AppLanguage.en: 'ACTIVE SHIFT OTP CODE:',
      AppLanguage.om: 'KOODII OTP CUFINSAA:',
      AppLanguage.am: 'ንቁ የመዝጊያ OTP ኮድ:',
    },
    'waitingForManager': {
      AppLanguage.en: 'WAITING FOR MANAGER',
      AppLanguage.om: 'Maneejara Eeggachaa Jira',
      AppLanguage.am: 'ስራ አስኪያጁን በመጠባበቅ ላይ',
    },
    'enterOtp': {
      AppLanguage.en: 'Enter OTP',
      AppLanguage.om: 'OTP Galchaa',
      AppLanguage.am: 'OTP ያስገቡ',
    },
    'adminNightHandoverCode': {
      AppLanguage.en: 'NIGHT CLOSING ADMIN OTP CODE:',
      AppLanguage.om: 'KOODII OTP BULCHAA HALKAN:',
      AppLanguage.am: 'የምሽት መዝጊያ አስተዳዳሪ OTP ኮድ:',
    },
    'pendingAdminReceipt': {
      AppLanguage.en: 'PENDING ADMIN RECEIPT',
      AppLanguage.om: 'Wal-harkaa Fuudhiinsa Bulchaa Eeggachaa Jira',
      AppLanguage.am: 'የአስተዳዳሪ ርክክብ በመጠባበቅ ላይ',
    },
    'threePartyCustody': {
      AppLanguage.en: '3-PARTY CUSTODY',
      AppLanguage.om: 'Eegumsa Qabeenyaa Qaama Sadii (3)',
      AppLanguage.am: 'የ 3 ወገን ጥምር የገንዘብ ቁጥጥር',
    },
    'dayShiftCustody': {
      AppLanguage.en: 'Day Shift (Cashier → Op Manager)',
      AppLanguage.om: 'Shiftii Guyyaa (Kaashiyara → Maneejara Hojii)',
      AppLanguage.am: 'የቀን ፈረቃ (ገንዘብ ያዥ → ስራ አስኪያጅ)',
    },
    'nightShiftCustody': {
      AppLanguage.en: 'Night Shift (Op Manager → Admin Vault)',
      AppLanguage.om: 'Shiftii Halkan (Maneejara Hojii → Kaazinaa Bulchaa)',
      AppLanguage.am: 'የሌሊት ፈረቃ (ስራ አስኪያጅ → የአስተዳዳሪ ካዝና)',
    },
    'verifiedBadge': {
      AppLanguage.en: 'VERIFIED',
      AppLanguage.om: 'MIRKANAA\'EERA',
      AppLanguage.am: 'የተረጋገጠ',
    },
    'inVaultBadge': {
      AppLanguage.en: 'IN VAULT',
      AppLanguage.om: 'KAAZINAA KEESSA',
      AppLanguage.am: 'ካዝና ገብቷል',
    },
    'activeShiftBadge': {
      AppLanguage.en: 'ACTIVE',
      AppLanguage.om: 'HOJII IRRA',
      AppLanguage.am: 'በስራ ላይ',
    },
    'otpReconciliationPending': {
      AppLanguage.en: 'PENDING OTP RECONCILIATION',
      AppLanguage.om: 'WAL-SIMSIISA OTP EEGA',
      AppLanguage.am: 'የ OTP ማስታረቅ በመጠባበቅ ላይ',
    },
    'physicalCash': {
      AppLanguage.en: 'physical cash',
      AppLanguage.om: 'qarshii harkaa',
      AppLanguage.am: 'ጥሬ ገንዘብ',
    },
    'confirmDailyClosingOtp': {
      AppLanguage.en: 'Confirm Daily Closing (OTP)',
      AppLanguage.om: 'Cufiinsa Guyyaa Mirkaneessi (OTP)',
      AppLanguage.am: 'ዕለታዊ ሂሳብ መዝጊያን አረጋግጥ (OTP)',
    },
    'shiftHandoverMethodTitle': {
      AppLanguage.en: 'Shift Handover: Operational Manager (4-Digit OTP)',
      AppLanguage.om: 'Wal-Harkaa Fuudhiinsa Shiftii: Maneejara Hojii (OTP Dijitii 4)',
      AppLanguage.am: 'የፈረቃ ርክክብ፡ ስራ አስኪያጅ (ባለ 4 አሃዝ OTP)',
    },
    'shiftHandoverMethodDesc': {
      AppLanguage.en: 'Closing the register calculates washer dividends and generates a 4-digit OTP for the Operational Manager to count and accept physical cash.',
      AppLanguage.om: 'Kaazinaa cufuun komishiinii dhiqxootaa shallagee koodii OTP dijitii 4 maneejaraaf uuma.',
      AppLanguage.am: 'ካዝናውን መዝጋት የአጣቢዎችን ኮሚሽን በማስላት ስራ አስኪያጁ ጥሬ ገንዘቡን እንዲያረጋግጥ ባለ 4 አሃዝ OTP ያመነጫል።',
    },
    'viewClosingVoucher': {
      AppLanguage.en: 'View Closing Voucher',
      AppLanguage.om: 'Nagahee Cufiinsaa Ilaali',
      AppLanguage.am: 'የሂሳብ መዝጊያ ደረሰኝ እይ',
    },
    'waitingForManagerOtpDesc': {
      AppLanguage.en: 'Give this 4-digit code to the Operational Manager after counting physical cash.',
      AppLanguage.om: 'Qarshii harkaa erga lakkooftanii booda koodii OTP kana hojii geggeessaaf kennaa.',
      AppLanguage.am: 'ጥሬ ገንዘቡን ቆጥረው ካስረከቡ በኋላ ይህንን የ OTP ኮድ ለስራ አስኪያጁ ይስጡ።',
    },
    'handoverVerifiedTitle': {
      AppLanguage.en: 'Handover Verified & Accepted',
      AppLanguage.om: 'Dabarsoon Mirkanaa\'ee Fudhatameera',
      AppLanguage.am: 'ርክክቡ ተረጋግጦ ተጠናቋል',
    },
    'reconcileAndGenerateOtp': {
      AppLanguage.en: 'Reconcile register & generate OTP',
      AppLanguage.om: 'Herrega kaazinaafi koodii OTP uumi',
      AppLanguage.am: 'የካዝና ሂሳብ አስታርቅ እና OTP አመንጭ',
    },
    'washerCommissionReportNote': {
      AppLanguage.en: 'Reported for Weekly Admin Payroll • Not deducted from daily cash drawer',
      AppLanguage.om: 'Kaffaltii torbaniitiif gabaafame • Kaazinaa guyyaarraa hin hir\'ifamu',
      AppLanguage.am: 'ለሳምንታዊ ክፍያ ሪፖርት የተደረገ • ከዕለታዊ ካዝና የማይቀነስ',
    },
    'confirmCashierHandover': {
      AppLanguage.en: 'Verify Cashier Closing OTP',
      AppLanguage.om: 'OTP Kaasharii Mirkaneessi',
      AppLanguage.am: 'የገንዘብ ተቀባይ OTP አረጋግጥ',
    },
    'confirmManagerNightCash': {
      AppLanguage.en: 'Confirm & Seal in Vault',
      AppLanguage.om: 'Mirkaneessi & Kaazinatti Galchi',
      AppLanguage.am: 'አረጋግጥ እና ካዝና አስገባ',
    },
    'enterHandoverOtpInline': {
      AppLanguage.en: 'Enter 4-Digit Handover OTP',
      AppLanguage.om: 'Koodii OTP Dijitii 4 Galchaa',
      AppLanguage.am: 'ባለ 4 አሃዝ የርክክብ OTP ያስገቡ',
    },
    'unlockAndResumeShift': {
      AppLanguage.en: 'Unlock & Resume Day Shift',
      AppLanguage.om: 'Garee Guyyaa Bani & Itti Fufi',
      AppLanguage.am: 'የቀን ፈረቃን ክፈት እና ቀጥል',
    },
    'cancelHandoverAndAddCars': {
      AppLanguage.en: 'Cancel OTP Request & Add Cars',
      AppLanguage.om: 'Gaaffii OTP Haqii Konkolaataa Dabali',
      AppLanguage.am: 'የOTP ጥያቄን ሰርዝ እና መኪና ጨምር',
    },
    'unlockWithManagerPin': {
      AppLanguage.en: 'Unlock Shift (Manager / Admin PIN)',
      AppLanguage.om: 'Garee Bani (PIN Hoggansaa / Bulchaa)',
      AppLanguage.am: 'ፈረቃን ክፈት (የስራ አስኪያጅ / አስተዳዳሪ ፒን)',
    },
    'confirmUnlockShiftTitle': {
      AppLanguage.en: 'Unlock Day Shift Closing?',
      AppLanguage.om: 'Cuffaa Guyyaa Banuu Barbaaddaa?',
      AppLanguage.am: 'የቀን ፈረቃ መዝጊያን መክፈት ይፈልጋሉ?',
    },
    'confirmUnlockShiftDesc': {
      AppLanguage.en: 'This will cancel the pending closing and allow you to record and wash new vehicles. You can close again when done.',
      AppLanguage.om: 'Kun cufiinsa eeggataa haqa, konkolaattota haaraa galmeessuuf carraa kenna. Erga xumurte booda deebitee cufuu dandeessa.',
      AppLanguage.am: 'ይህ በመጠባበቅ ላይ ያለውን መዝጊያ ይሰርዛል፤ አዳዲስ መኪኖችን መዝግበው እንዲያጥቡ ያስችላል። ሲጨርሱ እንደገና መዝጋት ይችላሉ።',
    },
    'shiftUnlockedSuccess': {
      AppLanguage.en: 'Day shift unlocked! You can now record new cars and close again.',
      AppLanguage.om: 'Gareen guyyaa banameera! Konkolaattota haaraa galmeessitee deebitee cufuu dandeessa.',
      AppLanguage.am: 'የቀን ፈረቃ ተከፍቷል! አሁን አዳዲስ መኪኖችን መዝግበው እንደገና መዝጋት ይችላሉ።',
    },
    'managerOrAdminPinRequired': {
      AppLanguage.en: 'Manager or Admin PIN required to unlock verified closing',
      AppLanguage.om: 'Cufiinsa mirkanaa\'e banuuf PIN Hoggansaa ykn Bulchaa barbaachisa',
      AppLanguage.am: 'የተረጋገጠ መዝጊያን ለመክፈት የስራ አስኪያጅ ወይም አስተዳዳሪ ፒን ያስፈልጋል',
    },
    'enterManagerOrAdminPin': {
      AppLanguage.en: 'Enter Operational Manager or Admin PIN',
      AppLanguage.om: 'PIN Hoggansa Hojii ykn Bulchaa galchaa',
      AppLanguage.am: 'የስራ አስኪያጅ ወይም የአስተዳዳሪ ፒን ያስገቡ',
    },
    'invalidManagerOrAdminPin': {
      AppLanguage.en: 'Invalid Manager or Admin PIN. Access denied.',
      AppLanguage.om: 'PIN Hoggansaa ykn Bulchaa dogoggora. Hayyamni dhowwameera.',
      AppLanguage.am: 'ልክ ያልሆነ የስራ አስኪያጅ ወይም አስተዳዳሪ ፒን። አልተፈቀደም።',
    },
    'confirmUnlockAction': {
      AppLanguage.en: 'Yes, Unlock Shift',
      AppLanguage.om: 'Eeyyee, Garee Bani',
      AppLanguage.am: 'አዎ፣ ፈረቃውን ክፈት',
    },
    'cashierHandoverVerification': {
      AppLanguage.en: '1. Cashier Day Closing Verification (OTP)',
      AppLanguage.om: '1. Mirkaneessa Cufiinsa Kaasharii (OTP)',
      AppLanguage.am: '1. የገንዘብ ተቀባይ የቀን መዝጊያ ማረጋገጫ (OTP)',
    },
    'managerHandoverVerification': {
      AppLanguage.en: '2. Night Shift Closing Verification (OTP)',
      AppLanguage.om: '2. Mirkaneessa Cufiinsa Shiftii Halkanii (OTP)',
      AppLanguage.am: '2. የምሽት ፈረቃ መዝጊያ ማረጋገጫ (OTP)',
    },
    'noPendingClosingToVerify': {
      AppLanguage.en: 'No pending closing found. The staff must submit daily closing first.',
      AppLanguage.om: 'Gabaasni cufiinsa eeggatu hin jiru. Jalqaba gabaasa cufaa dhiyeessuu qabu.',
      AppLanguage.am: 'በመጠባበቅ ላይ ያለ መዝጊያ አልተገኘም። መጀመሪያ የዕለት መዝጊያውን ማስገባት አለባቸው።',
    },
    'alreadyVerifiedClosing': {
      AppLanguage.en: 'This shift closing is already verified and reconciled.',
      AppLanguage.om: 'Cufiinsi garee kanaa duraan mirkanaa\'ee qulqullaa\'eera.',
      AppLanguage.am: 'ይህ የፈረቃ መዝጊያ ቀደም ሲል ተረጋግጦ ተጠናቋል።',
    },

    // Carpet Cleaning Service
    'carpetCleaning': {
      AppLanguage.en: 'Carpet Cleaning',
      AppLanguage.om: 'Qulqulleessaa Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት',
    },
    'carpetCleaningSubtitle': {
      AppLanguage.en: 'Professional residential & commercial carpet deep wash & sanitize',
      AppLanguage.om: 'Tajaajila qulqulleessa karpeetii qulqullina olaanaa fi ammayyaa',
      AppLanguage.am: 'ሙያዊ የመኖሪያ እና የንግድ ምንጣፍ ጥልቅ እጥበት እና ማጽዳት',
    },
    'carpetTypeA': {
      AppLanguage.en: 'Type A (Normal Clean)',
      AppLanguage.om: 'Akaakuu A (Idilee)',
      AppLanguage.am: 'አይነት ሀ (መደበኛ እጥበት)',
    },
    'carpetTypeB': {
      AppLanguage.en: 'Type B (Heavy Duty / Deep Clean)',
      AppLanguage.om: 'Akaakuu B (Xurii Cimaa)',
      AppLanguage.am: 'አይነት ለ (ከባድ ቆሻሻ/ጥልቅ እጥበት)',
    },
    'carpetTypeADesc': {
      AppLanguage.en: 'Standard clean: snow foam, dirt lift & air dry.',
      AppLanguage.om: 'Dhiqannaa idilee: soofii dhoqqee kaasuu fi gogsuu.',
      AppLanguage.am: 'መደበኛ እጥበት፡ አረፋ፣ ቆሻሻ ማንሳት እና ማድረቅ።',
    },
    'carpetTypeBDesc': {
      AppLanguage.en: 'Deep extraction: stain treatment, brush agitation & sanitization.',
      AppLanguage.om: 'Qulqulleessa gadi fageenyaa: bブラシ fi keemikaala xurii balleessu.',
      AppLanguage.am: 'ጥልቅ እጥበት፡ የቆሻሻ ማስለቀቂያ፣ ፍቅፋቂ እና ማጽዳት።',
    },
    'carpetDimensions': {
      AppLanguage.en: 'Dimensions (Length × Width)',
      AppLanguage.om: 'Safartuu (Dheerina × Bal\'ina)',
      AppLanguage.am: 'ልኬት (ርዝመት × ወርድ)',
    },
    'carpetAreaSqM': {
      AppLanguage.en: 'Area (m²)',
      AppLanguage.om: 'Bal\'ina (m²)',
      AppLanguage.am: 'ስፋት (በካሬ ሜትር)',
    },
    'pricePerSqM': {
      AppLanguage.en: 'Rate per m²',
      AppLanguage.om: 'Gatii m² Tokkoo',
      AppLanguage.am: 'ዋጋ በካሬ ሜትር',
    },
    'carpetDropOff': {
      AppLanguage.en: 'Station Drop-off',
      AppLanguage.om: 'Buufataatti Fiduu',
      AppLanguage.am: 'ጣቢያው ድረስ አምጥቶ ማስረከብ',
    },
    'carpetPickUpValet': {
      AppLanguage.en: 'Staff Pickup & Return',
      AppLanguage.om: 'Hojjattootaan Fudhatamee Deebifamu',
      AppLanguage.am: 'በሰራተኞች ተወስዶ የሚመለስ',
    },
    'carpetTag': {
      AppLanguage.en: 'Carpet Tag / ID',
      AppLanguage.om: 'Koodii Karpeetii',
      AppLanguage.am: 'የምንጣፍ መለያ ቁጥር',
    },
    'bookCarpet': {
      AppLanguage.en: 'Book Carpet Cleaning',
      AppLanguage.om: 'Qulqulleessaa Karpeetii Qabadhaa',
      AppLanguage.am: 'የምንጣፍ እጥበት ያስይዙ',
    },
    'carpetServicesTab': {
      AppLanguage.en: 'Carpet Cleaning',
      AppLanguage.om: 'Qulqullina Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት',
    },
    'vehicleServicesTab': {
      AppLanguage.en: 'Car Wash Packages',
      AppLanguage.om: 'Paakeejii Makiinaa',
      AppLanguage.am: 'የመኪና እጥበት ጥቅሎች',
    },
    // Shower Service
    'showerServiceTitle': {
      AppLanguage.en: 'Station Public Shower',
      AppLanguage.om: 'Shawaaraa Buufataa',
      AppLanguage.am: 'የጣቢያው የህዝብ ሻወር',
    },
    'showerServiceSubtitle': {
      AppLanguage.en: 'Fast counter logger for shower users & payments',
      AppLanguage.om: 'Galmeessaa kaffaltii fi fayyadamtoota shawaaraa',
      AppLanguage.am: 'የሻወር ተጠቃሚዎች እና ክፍያ ፈጣን መዝገብ',
    },
    'showerUsers': {
      AppLanguage.en: 'Shower Users',
      AppLanguage.om: 'Fayyadamtoota Shawaaraa',
      AppLanguage.am: 'የሻወር ተጠቃሚዎች',
    },
    'showerTariff': {
      AppLanguage.en: 'Shower Tariff (per person)',
      AppLanguage.om: 'Gatii Shawaaraa (Nama 1)',
      AppLanguage.am: 'የአንድ ሰው የሻወር ዋጋ',
    },
    'recordShower': {
      AppLanguage.en: 'Record Shower Entry',
      AppLanguage.om: 'Seensa Shawaaraa Galmeessi',
      AppLanguage.am: 'የሻወር ተጠቃሚ መዝግብ',
    },
    'todayShowerRevenue': {
      AppLanguage.en: 'Shower Revenue',
      AppLanguage.om: 'Galii Shawaaraa',
      AppLanguage.am: 'የሻወር ገቢ',
    },
    'stationShowerService': {
      AppLanguage.en: 'Station Public Shower',
      AppLanguage.om: 'Shawaaraa Buufataa',
      AppLanguage.am: 'የጣቢያው የህዝብ ሻወር',
    },
    'perPerson': {
      AppLanguage.en: 'per person',
      AppLanguage.om: 'nama tokkoof',
      AppLanguage.am: 'በአንድ ሰው',
    },
    'showerCommissionNotice': {
      AppLanguage.en: '100% Station Net Revenue • 0% Washer Commission',
      AppLanguage.om: 'Galii Buufataa %100 • Dhiqxootaaf %0',
      AppLanguage.am: '100% የጣቢያው ገቢ • ለአጣቢዎች 0% ኮሚሽን',
    },
    'numberOfPersons': {
      AppLanguage.en: 'Number of Persons',
      AppLanguage.om: 'Baay\'ina Namootaa',
      AppLanguage.am: 'የሰዎች ብዛት',
    },
    'recordShowerEntry': {
      AppLanguage.en: 'Record Shower Entry',
      AppLanguage.om: 'Seensa Shawaaraa Galmeessi',
      AppLanguage.am: 'የሻወር ተጠቃሚ መዝግብ',
    },
    'showerTotalRevenue': {
      AppLanguage.en: 'Total Shower Revenue',
      AppLanguage.om: 'Ida\'ama Galii Shawaaraa',
      AppLanguage.am: 'አጠቃላይ የሻወር ገቢ',
    },
    'additionalServicesTariffs': {
      AppLanguage.en: 'Additional Services Tariffs',
      AppLanguage.om: 'Madaallii Gatii Tajaajiloota Biroo',
      AppLanguage.am: 'ተጨማሪ የአገልግሎት ዋጋዎች',
    },
    'carpetPricingTitle': {
      AppLanguage.en: 'Carpet Cleaning Pricing (ETB/m²)',
      AppLanguage.om: 'Gatii Qulqullina Karpeetii (ETB/m²)',
      AppLanguage.am: 'የምንጣፍ እጥበት ዋጋ (ብር/ካሬ)',
    },
    'carpetPricingSubtitle': {
      AppLanguage.en: 'Estimated dynamically by area square meters',
      AppLanguage.om: 'Bal\'ina kaaree meetiraatiin kan shallagamu',
      AppLanguage.am: 'በካሬ ሜትር ስፋት የሚሰላ ዋጋ',
    },
    'showerTariffTitle': {
      AppLanguage.en: 'Station Public Shower Fee',
      AppLanguage.om: 'Gatii Shawaaraa Buufataa',
      AppLanguage.am: 'የጣቢያው የህዝብ ሻወር ክፍያ',
    },
    'showerFeePerPerson': {
      AppLanguage.en: 'Shower Fee per Person',
      AppLanguage.om: 'Kaffaltii Shawaaraa Nama Tokkoo',
      AppLanguage.am: 'የአንድ ሰው የሻወር ክፍያ',
    },
    'publicShowerAtStation': {
      AppLanguage.en: 'On-site hot & cold shower facility',
      AppLanguage.om: 'Tajaajila shawaaraa buufata keessatti argamu',
      AppLanguage.am: 'በጣቢያው የሚገኝ የሻወር አገልግሎት',
    },
    'carpetDimensionsTitle': {
      AppLanguage.en: 'Carpet Dimensions (Length × Width)',
      AppLanguage.om: 'Safartuu Karpeetii (Dheerina × Bal\'ina)',
      AppLanguage.am: 'የምንጣፍ ልኬት (ርዝመት × ወርድ)',
    },
    'carpetLength': {
      AppLanguage.en: 'Length',
      AppLanguage.om: 'Dheerina',
      AppLanguage.am: 'ርዝመት',
    },
    'carpetWidth': {
      AppLanguage.en: 'Width',
      AppLanguage.om: 'Bal\'ina',
      AppLanguage.am: 'ወርድ',
    },
    'carpetTotalArea': {
      AppLanguage.en: 'Total Area',
      AppLanguage.om: 'Bal\'ina Waliigalaa',
      AppLanguage.am: 'አጠቃላይ ስፋት',
    },
    'bookCarpetCleaning': {
      AppLanguage.en: 'Book Carpet Cleaning',
      AppLanguage.om: 'Qulqullina Karpeetii Qabadhaa',
      AppLanguage.am: 'የምንጣፍ እጥበት ያስይዙ',
    },
    'carpetService': {
      AppLanguage.en: 'Carpet Cleaning',
      AppLanguage.om: 'Qulqullina Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት',
    },
    'carpetCleaningOptions': {
      AppLanguage.en: 'Carpet Cleaning Options',
      AppLanguage.om: 'Filannoowwan Qulqullina Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት አማራጮች',
    },
    'serviceProvisionMode': {
      AppLanguage.en: 'Service Delivery Provision',
      AppLanguage.om: 'Haala Tajaajilli Itti Kennamu',
      AppLanguage.am: 'የአገልግሎት አሰጣጥ ዘዴ',
    },
    'carpetTrackingTag': {
      AppLanguage.en: 'Carpet Tracking Tag / ID',
      AppLanguage.om: 'Koodii Karpeetii',
      AppLanguage.am: 'የምንጣፍ መለያ ቁጥር',
    },
    'vehicleRegistration': {
      AppLanguage.en: 'Vehicle Registration',
      AppLanguage.om: 'Galmee Makiinaa',
      AppLanguage.am: 'የመኪና ምዝገባ',
    },
    'atStationService': {
      AppLanguage.en: 'At Station',
      AppLanguage.om: 'Buufata Keessatti',
      AppLanguage.am: 'ጣቢያው ድረስ',
    },
    'carpetStationService': {
      AppLanguage.en: 'At-Station Carpet Cleaning',
      AppLanguage.om: 'Dhiqa Karpeetii Buufatatti',
      AppLanguage.am: 'የጣቢያ ውስጥ የምንጣፍ እጥበት',
    },
    'carpetStationSub': {
      AppLanguage.en: 'Bring your carpet directly to our station wash floor & drying racks.',
      AppLanguage.om: 'Karpeetii keessan kallattiin gara buufata keenyaafi iddoo gogsiisaatti fidaa.',
      AppLanguage.am: 'ምንጣፍዎን በቀጥታ ወደ ማጠቢያ ጣቢያችንና ማድረቂያ ቦታ ያምጡ።',
    },
    'carpetValetTitle': {
      AppLanguage.en: 'Carpet Pick-up & Return',
      AppLanguage.om: 'Karpeetii Fudhatanii Deebisuu',
      AppLanguage.am: 'ምንጣፍን መውሰድና ማድረስ',
    },
    'carpetValetSub': {
      AppLanguage.en: 'Staff picks up your carpet from your door, deep-cleans at station, and returns it safely.',
      AppLanguage.om: 'Hojjettoonni keenya balbala keessanirraa fuudhanii, dhiqanii, deebisanii isiniif fidu.',
      AppLanguage.am: 'ሰራተኞቻችን ደጃፍዎ ድረስ መጥተው ምንጣፍዎን ወስደው፣ አጥበውና አድርቀው ይመልሱልዎታል።',
    },
    'carpetValetAvailable': {
      AppLanguage.en: 'Carpet Pick-up Available',
      AppLanguage.om: 'Karpeetii Fuudhuun Qophiidha',
      AppLanguage.am: 'የምንጣፍ ማድረስና መውሰድ ዝግጁ ነው',
    },
    'carpetHomeTitle': {
      AppLanguage.en: 'At-Home Carpet Cleaning',
      AppLanguage.om: 'Dhiqa Karpeetii Mana Keessanitti',
      AppLanguage.am: 'የቤት ውስጥ የምንጣፍ እጥበት',
    },
    'carpetHomeSub': {
      AppLanguage.en: 'Mobile crew comes to your home equipped with carpet extraction machines & shampoo.',
      AppLanguage.om: 'Gareen keenya maashina cuunfaafi saamuunaan mana keessan dhufee dhiqa.',
      AppLanguage.am: 'ተንቀሳቃሽ ቡድናችን ከነማሽኑና ሳሙናው ቤትዎ ድረስ መጥቶ ያጥባልዎታል።',
    },
    'atHomeService': {
      AppLanguage.en: 'At Customer Home',
      AppLanguage.om: 'Mana Maamilaatti',
      AppLanguage.am: 'ደንበኛ መኖሪያ ቤት',
    },
    'valetPickupReturn': {
      AppLanguage.en: 'Valet Pickup & Return',
      AppLanguage.om: 'Fuudhanii Deebisuu',
      AppLanguage.am: 'ተወስዶ የሚመለስ',
    },
    'carpetPickUpLocation': {
      AppLanguage.en: 'Carpet Pick-up & Return Address',
      AppLanguage.om: 'Teessoo Karpeetii Fudhatanii Deebisan',
      AppLanguage.am: 'ምንጣፍ የሚወሰድበትና የሚመለስበት አድራሻ',
    },
    'carpetPaymentAtGateNote': {
      AppLanguage.en: 'No advance payment needed. Payment is settled at delivery or pickup once your carpet is cleaned & dried.',
      AppLanguage.om: 'Kaffaltii duroo hin barbaachisu. Kaffaltiin kan kaffalamu erga karpeetiin dhiqamee gogee booda.',
      AppLanguage.am: 'ቅድመ ክፍያ አያስፈልግም። ክፍያ የሚፈጸመው ምንጣፍዎ ታጥቦና ደርቆ ሲረከቡ ነው።',
    },
    'trackMyCarpet': {
      AppLanguage.en: 'Track My Carpet Cleaning',
      AppLanguage.om: 'Qulqullina Karpeetii Koo Hordofaa',
      AppLanguage.am: 'የምንጣፍ እጥበትን ይከታተሉ',
    },
    'trackCarpetPrompt': {
      AppLanguage.en: 'Enter your carpet tracking tag (e.g. CPT-8941) or phone number to see real-time progress',
      AppLanguage.om: 'Koodii karpeetii keessanii yookiin lakkoofsa bilbilaa galchuun haala dhiqannaa hordofaa',
      AppLanguage.am: 'የምንጣፍ መለያ ቁጥር ወይም ስልክ ቁጥር በማስገባት የእጥበቱን ሂደት በቀጥታ ይከታተሉ',
    },
    'carpetTagOrPhoneHint': {
      AppLanguage.en: 'Carpet Tag (CPT-...) or Phone Number',
      AppLanguage.om: 'Koodii Karpeetii ykn Bilbila',
      AppLanguage.am: 'የምንጣፍ መለያ ወይም ስልክ ቁጥር',
    },
    'carpetTrackingTitle': {
      AppLanguage.en: 'Carpet Live Tracking',
      AppLanguage.om: 'Hordoffii Dhiqa Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት የቀጥታ ክትትል',
    },
    'enterCarpetTag': {
      AppLanguage.en: 'Please enter carpet tracking tag',
      AppLanguage.om: 'Koodii karpeetii galchaa',
      AppLanguage.am: 'እባክዎ የምንጣፍ መለያ ቁጥር ያስገቡ',
    },
    'customTip': {
      AppLanguage.en: 'Custom Tip',
      AppLanguage.om: 'Tipii Kan Biroo',
      AppLanguage.am: 'ሌላ የቲፕ መጠን',
    },
    // Tips
    'washersTip': {
      AppLanguage.en: 'Washer Team Tip (ETB)',
      AppLanguage.om: 'Gumaata Dhiqxootaa (ETB)',
      AppLanguage.am: 'የአጣቢዎች ቲፕ (ብር)',
    },
    'addTipPrompt': {
      AppLanguage.en: 'Add Tip for Washers (Optional)',
      AppLanguage.om: 'Dhiqxootaaf tipii dabali (filannoo)',
      AppLanguage.am: 'ለአጣቢዎች ቲፕ ጨምር (አማራጭ)',
    },
    'tipPassThroughNotice': {
      AppLanguage.en: '100% of customer tips are passed directly to the washing crew.',
      AppLanguage.om: 'Tipiin maamilaa %100 kallattiin garee dhiqdootaatiif kennama.',
      AppLanguage.am: '100% የደንበኛ ቲፕ በቀጥታ ለአጣቢዎች ይተላለፋል።',
    },
    'customerTipsPool': {
      AppLanguage.en: 'Customer Tips Pool',
      AppLanguage.om: 'Kuusaa Tipii Maamiltootaa',
      AppLanguage.am: 'የደንበኞች ቲፕ ድምር',
    },
    'carWashingService': {
      AppLanguage.en: 'Car Washing Service',
      AppLanguage.om: 'Tajaajila Dhiqa Konkolaataa',
      AppLanguage.am: 'የመኪና እጥበት አገልግሎት',
    },
    'carpetWashingService': {
      AppLanguage.en: 'Carpet Washing Service',
      AppLanguage.om: 'Tajaajila Dhiqa Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት አገልግሎት',
    },
    'carpetMatrixTitle': {
      AppLanguage.en: 'Carpet Service Package Pricing Matrix',
      AppLanguage.om: 'Madaallii Gatii Paakeejii Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት ፓኬጆች ዋጋ ዝርዝር',
    },
    'carpetMatrixSubtitle': {
      AppLanguage.en: 'Set ETB per m² for Type A & Type B across all 3 delivery modes',
      AppLanguage.om: 'Gatii m² akaakuu A fi B tajaajiloota 3f murteessaa',
      AppLanguage.am: 'ለአይነት ሀ እና አይነት ለ በሦስቱም የአገልግሎት መንገዶች የካሬ ሜትር ዋጋ ይወስኑ',
    },
    'carpetTypeAStation': {
      AppLanguage.en: 'Type A - At Station',
      AppLanguage.om: 'Akaakuu A - Buufatatti',
      AppLanguage.am: 'አይነት ሀ - ጣቢያ ውስጥ',
    },
    'carpetTypeAHome': {
      AppLanguage.en: 'Type A - At Owner\'s Home',
      AppLanguage.om: 'Akaakuu A - Mana Abbaatti',
      AppLanguage.am: 'አይነት ሀ - ባለቤቱ ቤት',
    },
    'carpetTypeAValet': {
      AppLanguage.en: 'Type A - Pick-up & Return',
      AppLanguage.om: 'Akaakuu A - Fudhatamee Deebifamu',
      AppLanguage.am: 'አይነት ሀ - ተወስዶ የሚመለስ',
    },
    'carpetTypeBStation': {
      AppLanguage.en: 'Type B - At Station',
      AppLanguage.om: 'Akaakuu B - Buufatatti',
      AppLanguage.am: 'አይነት ለ - ጣቢያ ውስጥ',
    },
    'carpetTypeBHome': {
      AppLanguage.en: 'Type B - At Owner\'s Home',
      AppLanguage.om: 'Akaakuu B - Mana Abbaatti',
      AppLanguage.am: 'አይነት ለ - ባለቤቱ ቤት',
    },
    'carpetTypeBValet': {
      AppLanguage.en: 'Type B - Pick-up & Return',
      AppLanguage.om: 'Akaakuu B - Fudhatamee Deebifamu',
      AppLanguage.am: 'አይነት ለ - ተወስዶ የሚመለስ',
    },
    'carpetStations': {
      AppLanguage.en: 'Carpet Cleaning Stations',
      AppLanguage.om: 'Buufataalee Dhiqa Karpeetii',
      AppLanguage.am: 'የምንጣፍ ማጠቢያ ክፍሎች',
    },
    'carpetWashFloor': {
      AppLanguage.en: 'Wash & Extraction Floor',
      AppLanguage.om: 'Lafa Dhiqaafi Cuunfaa',
      AppLanguage.am: 'ማጠቢያና ማድረቂያ ወለል',
    },
    'carpetDryingRacks': {
      AppLanguage.en: 'Ventilated Drying Racks',
      AppLanguage.om: 'Bakka Karpeetii Gogsuu',
      AppLanguage.am: 'አየር የሚዘዋወርበት ማድረቂያ ራክ',
    },
    'carpetHomeMobileCrew': {
      AppLanguage.en: 'Home Cleaning Mobile Crew',
      AppLanguage.om: 'Garee Moobaayilaa Manaa',
      AppLanguage.am: 'የቤት ውስጥ ተንቀሳቃሽ አጣቢ ቡድን',
    },
    'carpetValetDriver': {
      AppLanguage.en: 'Valet Pick-up & Delivery',
      AppLanguage.om: 'Geejjiba Karpeetii',
      AppLanguage.am: 'የምንጣፍ ትራንስፖርትና ርክክብ',
    },
    'carpetQueueTitle': {
      AppLanguage.en: 'Carpet Cleaning Queue',
      AppLanguage.om: 'Tarree Dhiqa Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት ተራ',
    },
    'carpetIntakeRegister': {
      AppLanguage.en: 'Register Carpet Intake',
      AppLanguage.om: 'Karpeetii Haaraa Galmeessi',
      AppLanguage.am: 'አዲስ ምንጣፍ መዝግብ',
    },
    'carpetTagNumber': {
      AppLanguage.en: 'Tag Number',
      AppLanguage.om: 'Lakkoofsa Karpeetii',
      AppLanguage.am: 'የምንጣፍ መለያ ቁጥር',
    },
    'editCarpetTariff': {
      AppLanguage.en: 'Edit Carpet Tariff (ETB/m²)',
      AppLanguage.om: 'Gatii Karpeetii Jijjiiri (ETB/m²)',
      AppLanguage.am: 'የምንጣፍ ካሬ ሜትር ዋጋ ቀይር (ብር/ካሬ)',
    },
    'servicePricingSettings': {
      AppLanguage.en: 'Service Pricing & Tariffs',
      AppLanguage.om: 'Madaallii Gatii Tajaajilootaa',
      AppLanguage.am: 'የአገልግሎት ዋጋዎች ማስተካከያ',
    },
    'carWashHistoryTitle': {
      AppLanguage.en: 'Car Wash History',
      AppLanguage.om: 'Seenaa Dhiqa Konkolaataa',
      AppLanguage.am: 'የመኪና እጥበት ታሪክ',
    },
    'carpetWashHistoryTitle': {
      AppLanguage.en: 'Carpet Cleaning History',
      AppLanguage.om: 'Seenaa Dhiqa Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት ታሪክ',
    },
    'myCarWashes': {
      AppLanguage.en: 'My Car Washes',
      AppLanguage.om: 'Dhiqa Konkolaataa Koo',
      AppLanguage.am: 'የመኪና እጥበቶቼ',
    },
    'myCarpetCleanings': {
      AppLanguage.en: 'My Carpet Cleanings',
      AppLanguage.om: 'Dhiqa Karpeetii Koo',
      AppLanguage.am: 'የምንጣፍ እጥበቶቼ',
    },
    'consolidatedStationClosing': {
      AppLanguage.en: 'Consolidated Daily Financial Report',
      AppLanguage.om: 'Gabaasa Maallaqaa Guyyaa Waliigalaa',
      AppLanguage.am: 'የጣቢያው ጠቅላላ ዕለታዊ የፋይናንስ ሪፖርት',
    },
    'carWashSubtotal': {
      AppLanguage.en: 'Car Wash Division',
      AppLanguage.om: 'Kutaa Dhiqa Konkolaataa',
      AppLanguage.am: 'የመኪና እጥበት ዘርፍ',
    },
    'carpetWashSubtotal': {
      AppLanguage.en: 'Carpet Cleaning Division',
      AppLanguage.om: 'Kutaa Dhiqa Karpeetii',
      AppLanguage.am: 'የምንጣፍ እጥበት ዘርፍ',
    },
    'showerSubtotal': {
      AppLanguage.en: 'Station Public Shower',
      AppLanguage.om: 'Dhaaba Dhiqannaa Buufataa',
      AppLanguage.am: 'የጣቢያው የህዝብ ሻወር',
    },
    'washerTipsSubtotal': {
      AppLanguage.en: 'Customer Digital Tips',
      AppLanguage.om: 'Gumaata Maamiltootaa (Tip)',
      AppLanguage.am: 'የደንበኞች ዲጂታል ጉርሻ (ቲፕ)',
    },
    'carpetsCleanedSqM': {
      AppLanguage.en: 'Area Cleaned (m²)',
      AppLanguage.om: 'Bal\'ina Dhiqame (m²)',
      AppLanguage.am: 'የታጠበው ስፋት (ካሬ ሜትር)',
    },
    'noCarpetsFound': {
      AppLanguage.en: 'No carpet cleaning records found',
      AppLanguage.om: 'Galmeen dhiqa karpeetii hin jiru',
      AppLanguage.am: 'ምንም የምንጣፍ እጥበት መረጃ አልተገኘም',
    },
    'noVehiclesInQueue': {
      AppLanguage.en: 'No vehicles currently in queue',
      AppLanguage.om: 'Konkolaataan tarree keessa jiru hin jiru',
      AppLanguage.am: 'በተራው ላይ ያለ መኪና የለም',
    },
    'noCarpetsInQueue': {
      AppLanguage.en: 'No carpets currently in queue',
      AppLanguage.om: 'Karpeetiin tarree keessa jiru hin jiru',
      AppLanguage.am: 'በተራው ላይ ያለ ምንጣፍ የለም',
    },
    'washFloorAndDryingRacks': {
      AppLanguage.en: 'Wash Floor & Drying Racks',
      AppLanguage.om: 'Lafa Dhiqaafi Bakka Gogsuu',
      AppLanguage.am: 'ማጠቢያ ወለልና ማድረቂያዎች',
    },
    'storekeeperCombinedHeader': {
      AppLanguage.en: 'Car Wash & Carpet Consumables & Assets Desk',
      AppLanguage.om: 'Kutaa Qabeenyaa Dhiqa Konkolaataafi Karpeetii',
      AppLanguage.am: 'የመኪና እና የምንጣፍ እጥበት እቃዎችና ንብረት ማዕከል',
    },
    'storekeeperCombinedSub': {
      AppLanguage.en: 'Central warehouse inventory for vehicle chemicals and carpet detergents',
      AppLanguage.om: 'Kuusaa qorichootaafi meeshaalee dhiqa konkolaataafi karpeetii',
      AppLanguage.am: 'የመኪና ኬሚካሎች እና የምንጣፍ ሳሙናዎች ማዕከላዊ መጋዘን',
    },
    'carpetIntakeSmsSent': {
      AppLanguage.en: 'Carpet registration tag SMS sent to customer!',
      AppLanguage.om: 'Ergaan koodii galmee karpeetii maamilaaf ergameera!',
      AppLanguage.am: 'የምንጣፍ ምዝገባ መለያ ቁጥር ኤስኤምኤስ ለደንበኛው ተልኳል!',
    },
    'carpetCompletionSmsSent': {
      AppLanguage.en: 'Carpet completion SMS sent to customer!',
      AppLanguage.om: 'Ergaan xumura dhiqa karpeetii maamilaaf ergameera!',
      AppLanguage.am: 'የምንጣፍ እጥበት መጠናቀቅ ኤስኤምኤስ ለደንበኛው ተልኳል!',
    },
    'sendCarpetCompletionSms': {
      AppLanguage.en: 'Send Completion SMS',
      AppLanguage.om: 'Ergaa Xumuraa Ergi',
      AppLanguage.am: 'የመጠናቀቂያ ኤስኤምኤስ ላክ',
    },
    'startWashFloorAction': {
      AppLanguage.en: 'Start Wash Floor',
      AppLanguage.om: 'Dhiqa Lafa Jalqabi',
      AppLanguage.am: 'ወለል ላይ ማጠብ ጀምር',
    },
    'moveToDryingRacksAction': {
      AppLanguage.en: 'Move to Drying Racks',
      AppLanguage.om: 'Bakka Gogsuutti Dabarri',
      AppLanguage.am: 'ወደ ማድረቂያ ራክ አዛውር',
    },
    'markCarpetReadyAction': {
      AppLanguage.en: 'Mark Cleaned & Dried',
      AppLanguage.om: 'Dhiqamee Goge Jedhi',
      AppLanguage.am: 'ታጥቦ ደርቋል በል',
    },
    'accountantCombinedHeader': {
      AppLanguage.en: 'Car Wash & Carpet Consolidated Financial Hub',
      AppLanguage.om: 'Wiirtuu Maallaqa Dhiqa Konkolaataafi Karpeetii',
      AppLanguage.am: 'የመኪና እና የምንጣፍ እጥበት የጋራ ፋይናንስ ማዕከል',
    },
    'accountantCombinedSub': {
      AppLanguage.en: 'Audits, daily closings, bank accounts A & B, and consolidated P&L',
      AppLanguage.om: 'Oodiitii, cufiinsa guyyaa, herrega baankii A fi B, gabaasa bu\'aafi kisaaraa',
      AppLanguage.am: 'ኦዲት፣ ዕለታዊ ሂሳብ መዝጊያ፣ የባንክ ሂሳብ ሀ እና ለ፣ እና ጠቅላላ ትርፍና ኪሳራ',
    },
    'adminCombinedHeader': {
      AppLanguage.en: 'Car Wash & Carpet Administration Desk',
      AppLanguage.om: 'Wiirtuu Bulchiinsa Dhiqa Konkolaataafi Karpeetii',
      AppLanguage.am: 'የመኪና እና የምንጣፍ እጥበት ዋና አስተዳደር ማዕከል',
    },
    'adminCombinedSub': {
      AppLanguage.en: 'System configuration, pricing tariffs, bays & staff credentials',
      AppLanguage.om: 'Qindaa\'ina sirnaa, madaallii gatii, iddoowwan dhiqaafi eeyyama hojjettootaa',
      AppLanguage.am: 'የስርዓት ቅንብር፣ የዋጋ ተመኖች፣ ማጠቢያ ክፍሎች እና የሰራተኞች መለያዎች',
    },
    'unifiedDesk': {
      AppLanguage.en: 'Unified Desk',
      AppLanguage.om: 'Kutaa Qindaa\'e',
      AppLanguage.am: 'የተቀናጀ ማዕከል',
    },
    'carWashAndCarpetFacilities': {
      AppLanguage.en: 'Car Bays & Carpet Facilities',
      AppLanguage.om: 'Bakka Dhiqa Konkolaataafi Karpeetii',
      AppLanguage.am: 'የመኪና ማጠቢያና የምንጣፍ ክፍሎች',
    },
    'carWashAndCarpetFacilitiesSub': {
      AppLanguage.en: 'Bay 1, Bay 2, Mobile Van & Carpet Drying Racks',
      AppLanguage.om: 'Kutaa 1, Kutaa 2, Vaan Moobaayilaafi Raakii Karpeetii',
      AppLanguage.am: 'ክፍል 1፣ ክፍል 2፣ ተንቀሳቃሽ ቫን እና የምንጣፍ ማድረቂያ ራኮች',
    },
    'serviceSelectionMode': {
      AppLanguage.en: 'Service Mode',
      AppLanguage.om: 'Haala Tajaajilaa',
      AppLanguage.am: 'የአገልግሎት ምርጫ',
    },
    'customServicesChecklist': {
      AppLanguage.en: 'Detailing Services Checklist',
      AppLanguage.om: 'Tarree Tajaajiloota Filataman',
      AppLanguage.am: 'የዝርዝር አገልግሎቶች አመራረጥ',
    },
    'presetPackages': {
      AppLanguage.en: 'Preset Packages',
      AppLanguage.om: 'Paakeejiiwwan Qophaa\'an',
      AppLanguage.am: 'ዝግጁ ፓኬጆች',
    },
    'negotiatedTotalPrice': {
      AppLanguage.en: 'Negotiated Total Price (ETB)',
      AppLanguage.om: 'Gatii Waliigaltee Waliigalaa (ETB)',
      AppLanguage.am: 'የተደራደሩበት ጠቅላላ ዋጋ (ብር)',
    },
    'suggestedTariffTotal': {
      AppLanguage.en: 'Suggested Tariff Total',
      AppLanguage.om: 'Ida\'ama Gatii Dhaabbataa',
      AppLanguage.am: 'መደበኛ የተሰላ ድምር ዋጋ',
    },
    'staffTariff': {
      AppLanguage.en: 'Staff Tariff Total',
      AppLanguage.om: 'Ida\'ama Gatii Hojjattootaa',
      AppLanguage.am: 'የሰራተኞች መደበኛ ታሪፍ',
    },
    'agreedTariff': {
      AppLanguage.en: 'Agreed Tariff (ETB)',
      AppLanguage.om: 'Gatii Waliigaltee (ETB)',
      AppLanguage.am: 'የተስማሙበት ዋጋ (ብር)',
    },
    'useSuggestedPrice': {
      AppLanguage.en: 'Use Tariff',
      AppLanguage.om: 'Gatii Dhaabbataa Fudhadhu',
      AppLanguage.am: 'መደበኛ ዋጋ ተጠቀም',
    },
    'manageDetailServices': {
      AppLanguage.en: 'Manage Detailing Services',
      AppLanguage.om: 'Tajaajiloota Bal\'aa Bulchi',
      AppLanguage.am: 'ዝርዝር አገልግሎቶችን አስተዳድር',
    },
    'addNewDetailService': {
      AppLanguage.en: 'Add Detailing Service',
      AppLanguage.om: 'Tajaajila Haaraa Dabaladhu',
      AppLanguage.am: 'አዲስ ዝርዝር አገልግሎት አክል',
    },
    'serviceCategory': {
      AppLanguage.en: 'Service Category',
      AppLanguage.om: 'Ramaddii Tajaajilaa',
      AppLanguage.am: 'የአገልግሎት ምድብ',
    },
    'categoryExterior': {
      AppLanguage.en: 'Exterior & Wash',
      AppLanguage.om: 'Dhiqannaa Alaa',
      AppLanguage.am: 'የውጭ እጥበት',
    },
    'categoryPolish': {
      AppLanguage.en: 'Body Polish & Restoration',
      AppLanguage.om: 'Pooliishii fi Bareechuu',
      AppLanguage.am: 'የመኪና ፖሊሽ እና ማብራት',
    },
    'categoryInterior': {
      AppLanguage.en: 'Interior Detailing',
      AppLanguage.om: 'Qulqullina Keessoo',
      AppLanguage.am: 'የውስጥ ዲቴይሊንግ',
    },
    'categoryEngine': {
      AppLanguage.en: 'Engine Detailing',
      AppLanguage.om: 'Qulqullina Motooraa',
      AppLanguage.am: 'የሞተር ጽዳት',
    },
    'categorySpecialty': {
      AppLanguage.en: 'Specialty Add-ons',
      AppLanguage.om: 'Tajaajiloota Dabalataa',
      AppLanguage.am: 'ልዩ ተጨማሪ አገልግሎቶች',
    },
    'selectAtLeastOneService': {
      AppLanguage.en: 'Please select at least one detailing service',
      AppLanguage.om: 'Maaloo yoo xiqqaate tajaajila tokko filadhaa',
      AppLanguage.am: 'እባክዎ ቢያንስ አንድ ዝርዝር አገልግሎት ይምረጡ',
    },
    'enterAgreedPrice': {
      AppLanguage.en: 'Enter agreed price',
      AppLanguage.om: 'Gatii waliigaltee galchaa',
      AppLanguage.am: 'የተስማሙበትን ዋጋ ያስገቡ',
    },
    'customNegotiatedWash': {
      AppLanguage.en: 'Custom Detailing Wash',
      AppLanguage.om: 'Dhiqannaa Addaa Filatame',
      AppLanguage.am: 'ልዩ የተመረጠ ዲቴይሊንግ እጥበት',
    },
    'customWashServices': {
      AppLanguage.en: 'Custom Wash Services',
      AppLanguage.om: 'Tajaajiloota Dhiqannaa Filataman',
      AppLanguage.am: 'የተመረጡ የእጥበት አገልግሎቶች',
    },
    'cashierTabQueue': {
      AppLanguage.en: 'Queue',
      AppLanguage.om: 'Tartiiba',
      AppLanguage.am: 'ወረፋ',
    },
    'cashierTabMoney': {
      AppLanguage.en: 'Money',
      AppLanguage.om: 'Maallaqa',
      AppLanguage.am: 'ገንዘብ',
    },
    'cashierTabTeamShower': {
      AppLanguage.en: 'Team & Shower',
      AppLanguage.om: 'Garee & Shaaworii',
      AppLanguage.am: 'ቡድን እና ሻወር',
    },
    'cashierTabHistory': {
      AppLanguage.en: 'Wash History',
      AppLanguage.om: 'Seenaa Dhiqannaa',
      AppLanguage.am: 'የእጥበት ታሪክ',
    },
    'cashierFilterAll': {
      AppLanguage.en: 'All',
      AppLanguage.om: 'Hunda',
      AppLanguage.am: 'ሁሉም',
    },
    'cashierFilterWaiting': {
      AppLanguage.en: 'Waiting',
      AppLanguage.om: 'Eegamaa',
      AppLanguage.am: 'በመጠባበቅ ላይ',
    },
    'cashierFilterInProgress': {
      AppLanguage.en: 'In Progress',
      AppLanguage.om: 'Hojii Irra',
      AppLanguage.am: 'በሂደት ላይ',
    },
    'cashierFilterPayReady': {
      AppLanguage.en: 'Ready to Pay',
      AppLanguage.om: 'Kaffaltiif Qophii',
      AppLanguage.am: 'ለክፍያ ዝግጁ',
    },
    'searchQueueHint': {
      AppLanguage.en: 'Search plate, tag, customer or phone...',
      AppLanguage.om: 'Lakkoofsa gabatee, taagii, maqaa ykn bilbila barbaadi...',
      AppLanguage.am: 'ሰሌዳ፣ ታግ፣ ስም ወይም ስልክ ይፈልጉ...',
    },
    'waitingForAdminOtp': {
      AppLanguage.en: 'WAITING FOR ADMIN',
      AppLanguage.om: 'ADMIN EEGAMAA JIRA',
      AppLanguage.am: 'አስተዳዳሪን በመጠባበቅ ላይ',
    },
    'physicalCashInDrawer': {
      AppLanguage.en: 'Physical Cash in Drawer (Awaiting Deposit)',
      AppLanguage.om: 'Maallaqa Kaashii Harkaa (Baankiitti Hin Galin)',
      AppLanguage.am: 'በመሳቢያ ያለ ጥሬ ገንዘብ (ወደ ባንክ ያልገባ)',
    },
    'managerPhysicalCashInCustody': {
      AppLanguage.en: 'Manager Physical Cash in Custody',
      AppLanguage.om: 'Maallaqa Kaashii Harkaa Hojii Geggeessaa',
      AppLanguage.am: 'በስራ አስኪያጁ እጅ ያለ ጥሬ ገንዘብ',
    },
    'pendingCashierHandoverOtp': {
      AppLanguage.en: 'Pending Cashier Handover (OTP Required)',
      AppLanguage.om: 'Wal-harkaa Fuudhinsa Kaasharii Eegamaa (OTP)',
      AppLanguage.am: 'የገንዘብ ተቀባይ ርክክብ በመጠባበቅ ላይ (OTP ያስፈልጋል)',
    },
    'cashWithDayCashier': {
      AppLanguage.en: 'Cash with Day Cashier (Shift Active)',
      AppLanguage.om: 'Maallaqni Kaasharii Guyyaa Harka Jira',
      AppLanguage.am: 'ገንዘብ በቀን ገንዘብ ተቀባይ እጅ ነው (ፈረቃው ክፍት ነው)',
    },
    'noCustodyCashToDeposit': {
      AppLanguage.en: 'No Custody Cash (0.00 ETB)',
      AppLanguage.om: 'Maallaqa Harkaa Hin Jiru (0.00 ETB)',
      AppLanguage.am: 'በእጅ ያለ ጥሬ ገንዘብ የለም (0.00 ብር)',
    },
    'noStaffPinConfigured': {
      AppLanguage.en: 'No active PIN configured for this role. Only the Super Admin can create staff PINs.',
      AppLanguage.om: 'Koodiin PIN kanaaf hin qophoofne. Bulchaa Olaanaa qofatu PIN uumuu danda\'a.',
      AppLanguage.am: 'ለዚህ የስራ ድርሻ ገና PIN አልተፈጠረም። ሱፐር አስተዳዳሪ ብቻ የሰራተኛ PIN መፍጠር ይችላል።',
    },
    'superAdminOnlyPinsNotice': {
      AppLanguage.en: 'Restricted Access: Only the Super Admin has permission to create, edit, or delete staff PINs.',
      AppLanguage.om: 'Daangaa Eegumsaa: Bulchaa Olaanaa qofatu koodii PIN qindeessuu ykn jijjiiruu danda\'a.',
      AppLanguage.am: 'የተገደበ መብት፡ ሱፐር አስተዳዳሪ ብቻ የሰራተኛ PIN የመፍጠር፣ የመቀየር ወይም የመሰረዝ ፈቃድ አለው።',
    },
    'superAdminOnlyStaffNotice': {
      AppLanguage.en: 'Roster Notice: Only the Super Admin has permission to add, edit salaries, or delete staff personnel.',
      AppLanguage.om: 'Beeksisa Garee: Bulchaa Olaanaa qofatu hojjettoota galmeessuu, mindaa jijjiiruu ykn haquu danda\'a.',
      AppLanguage.am: 'የሰራተኞች ማስታወቂያ፡ ሱፐር አስተዳዳሪ ብቻ ሰራተኞችን የመጨመር፣ ደመወዝ የማስተካከል ወይም የመሰረዝ ፈቃድ አለው።',
    },
    'superAdminManagedBadge': {
      AppLanguage.en: 'Super Admin Protected',
      AppLanguage.om: 'Bulchaa Olaanaan Kan Eegame',
      AppLanguage.am: 'በሱፐር አስተዳዳሪ የተጠበቀ',
    },
    'logout': {
      AppLanguage.en: 'Log Out',
      AppLanguage.om: 'Ba\'i',
      AppLanguage.am: 'ውጣ',
    },
    'confirmLogout': {
      AppLanguage.en: 'Confirm Log Out',
      AppLanguage.om: 'Bahuu Mirkaneessi',
      AppLanguage.am: 'መውጣትዎን ያረጋግጡ',
    },
    'confirmLogoutMessage': {
      AppLanguage.en: 'Are you sure you want to log out and return to the Welcome screen?',
      AppLanguage.om: 'Dhuguma ba\'uudhaan gara fuula simannaatti deebi\'uu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት መውጣት እና ወደ መግቢያ ገጽ መመለስ ይፈልጋሉ?',
    },
    'vatOutput': {
      AppLanguage.en: 'VAT (15%)',
      AppLanguage.om: 'VAT (15%)',
      AppLanguage.am: 'ቫት (15%)',
    },
    'vatRateNotice': {
      AppLanguage.en: '15% VAT (Car Wash)',
      AppLanguage.om: 'VAT 15% (Dhiqannaa Konkolaataa)',
      AppLanguage.am: '15% ቫት (የመኪና እጥበት)',
    },
    'vatExempt': {
      AppLanguage.en: 'VAT Exempt (0%)',
      AppLanguage.om: 'VAT Irraa Bilisoomte (0%)',
      AppLanguage.am: 'ከቫት ነፃ (0%)',
    },
    'netRevenue': {
      AppLanguage.en: 'Net Operating Revenue',
      AppLanguage.om: 'Galii Hojii Qulqulluu',
      AppLanguage.am: 'የተጣራ የሥራ ገቢ',
    },
    'carWashVat': {
      AppLanguage.en: 'Car Wash VAT (15%)',
      AppLanguage.om: 'VAT Dhiqannaa Konkolaataa (15%)',
      AppLanguage.am: 'የመኪና እጥበት ቫት (15%)',
    },
    'facilityRent': {
      AppLanguage.en: 'Facility & House Rent',
      AppLanguage.om: 'Kiraa Buufataafi Manaa',
      AppLanguage.am: 'የጣቢያው እና የቤት ኪራይ',
    },
    'facilityRentDesc': {
      AppLanguage.en: 'Station yard, wash bays & office lease',
      AppLanguage.om: 'Kiraa lafa buufataa fi waajjiraa',
      AppLanguage.am: 'የጣቢያው ቦታ፣ የመታጠቢያ ክፍል እና የቢሮ ኪራይ',
    },
    'vatAuditCard': {
      AppLanguage.en: 'Ministry of Revenues • VAT Audit',
      AppLanguage.om: 'Ministeera Galiiwwanii • Oodiitii VAT',
      AppLanguage.am: 'የገቢዎች ሚኒስቴር • የቫት ኦዲት',
    },
    'vatSummaryNotice': {
      AppLanguage.en: 'Car wash services are vatable (15%). Carpet and shower services are VAT exempted (0%).',
      AppLanguage.om: 'Tajaajilli dhiqannaa konkolaataa VAT (15%) qaba. Tajaajilli afataafi dhiqannaa qaamaa VAT irraa bilisa (0%).',
      AppLanguage.am: 'የመኪና እጥበት አገልግሎቶች 15% ቫት የሚከፈልባቸው ሲሆን፣ ምንጣፍና ሻወር ከቫት ነፃ (0%) ናቸው።',
    },
    'exportVatReport': {
      AppLanguage.en: 'Export VAT Declaration',
      AppLanguage.om: 'Waraqaa VAT Baasi',
      AppLanguage.am: 'የቫት ማስታወቂያ አውርድ',
    },
    'taxLiability': {
      AppLanguage.en: 'Tax Liability (Fiduciary)',
      AppLanguage.om: 'Itti Gaafatamummaa Gibiraa',
      AppLanguage.am: 'የታክስ ዕዳ (ለመንግስት የሚከፈል)',
    },
    'departmentalPnl': {
      AppLanguage.en: 'Departmental P&L Breakdown',
      AppLanguage.om: 'Tarree Bu\'aafi Kisaaraa Dameedhaan',
      AppLanguage.am: 'የትርፍና ኪሳራ ዝርዝር በዘርፍ',
    },
    'drawerEmptyHandedOver': {
      AppLanguage.en: 'Drawer 0 ETB • Handed Over',
      AppLanguage.om: 'Saanduqa 0 ETB • Dabarfameera',
      AppLanguage.am: 'ሳጥን 0 ብር • ተላልፏል',
    },
    'cashHandedOverDisabledNotice': {
      AppLanguage.en: 'Cash already handed over. Drawer is empty.',
      AppLanguage.om: 'Qarshiin duraan dabarfameera. Saanduqni duwwaadha.',
      AppLanguage.am: 'ጥሬ ገንዘብ አስቀድሞ ተላልፏል። ሳጥኑ ባዶ ነው።',
    },
    'handedOverViaOtpPrefix': {
      AppLanguage.en: 'Handed Over',
      AppLanguage.om: 'Dabarfameera',
      AppLanguage.am: 'ተላልፏል',
    },
    'expenseAmount': {
      AppLanguage.en: 'Expense Amount (ETB)',
      AppLanguage.om: 'Hamma Baasii (ETB)',
      AppLanguage.am: 'የወጪ መጠን (ብር)',
    },
    'copySms': {
      AppLanguage.en: 'Copy SMS',
      AppLanguage.om: 'SMS Garagalchi',
      AppLanguage.am: 'SMS ቅዳ',
    },
    'smsCopiedClipboard': {
      AppLanguage.en: 'Customer SMS copied to clipboard!',
      AppLanguage.om: 'Ergaan maamilaa gara clipboard garagalfameera!',
      AppLanguage.am: 'የደንበኛ SMS ወደ ክሊፕቦርድ ተቀድቷል!',
    },
    'settledPaidBadge': {
      AppLanguage.en: 'PAID',
      AppLanguage.om: 'KAFFALAMEERA',
      AppLanguage.am: 'ተከፍሏል',
    },
    'phoneOrderBadge': {
      AppLanguage.en: 'Phone',
      AppLanguage.om: 'Bilbila',
      AppLanguage.am: 'ስልክ',
    },
    'carpetTypeBadgeA': {
      AppLanguage.en: 'CARPET A',
      AppLanguage.om: 'KARPEETII A',
      AppLanguage.am: 'ምንጣፍ A',
    },
    'carpetTypeBadgeB': {
      AppLanguage.en: 'CARPET B',
      AppLanguage.om: 'KARPEETII B',
      AppLanguage.am: 'ምንጣፍ B',
    },
    'tipBadgePrefix': {
      AppLanguage.en: 'Tip',
      AppLanguage.om: 'Gumaata',
      AppLanguage.am: 'ቲፕ',
    },
    'bayAndWasherLabel': {
      AppLanguage.en: 'Bay / Washer',
      AppLanguage.om: 'Bakka / Dhiqaa',
      AppLanguage.am: 'ቦታ / አጣቢ',
    },
    'unassignedBay': {
      AppLanguage.en: 'Assign Bay',
      AppLanguage.om: 'Bakka Ramadi',
      AppLanguage.am: 'ቦታ መድብ',
    },
    'busyLabel': {
      AppLanguage.en: 'Busy',
      AppLanguage.om: 'Qabameera',
      AppLanguage.am: 'ተይዟል',
    },
    'activeLabel': {
      AppLanguage.en: 'Active',
      AppLanguage.om: 'Hojii Irra',
      AppLanguage.am: 'በስራ ላይ',
    },
    'commissionShort': {
      AppLanguage.en: 'Commission',
      AppLanguage.om: 'Komishiinii',
      AppLanguage.am: 'ኮሚሽን',
    },
    'dutyWorkers': {
      AppLanguage.en: 'Duty',
      AppLanguage.om: 'Hojii Irra',
      AppLanguage.am: 'በስራ ላይ',
    },
    'dailyFinancialReportsTab': {
      AppLanguage.en: 'Shift Logs & Deposits',
      AppLanguage.om: 'Galmee Cufiinsaafi Baankii',
      AppLanguage.am: 'የፈረቃ መዝገብ እና ተቀማጭ',
    },
    'safeCashierModeNotice': {
      AppLanguage.en: 'Safe Mode: Bulk delete disabled for Cashier',
      AppLanguage.om: 'Eegumsa: Haqumsii waliigalaa dhorkameera',
      AppLanguage.am: 'ደህንነት፡ የጅምላ ማጥፊያ ተሰናክሏል',
    },
    'showerRecordedToast': {
      AppLanguage.en: 'Recorded shower entry',
      AppLanguage.om: 'Tajaajilli shaaworii galmaa\'eera',
      AppLanguage.am: 'የሻወር አገልግሎት ተመዝግቧል',
    },
    'viewVoucher': {
      AppLanguage.en: 'View Voucher',
      AppLanguage.om: 'Ragaalee Ilaali',
      AppLanguage.am: 'ደረሰኝ እይ',
    },
    'shiftLockedLabel': {
      AppLanguage.en: 'Shift Locked',
      AppLanguage.om: 'Shiffitiin Cufameera',
      AppLanguage.am: 'ፈረቃ ተቆልፏል',
    },
    'managerTabHandoverClose': {
      AppLanguage.en: 'Money & Closing',
      AppLanguage.om: 'Maallaqa & Cufiinsa',
      AppLanguage.am: 'ገንዘብ እና መዝጊያ',
    },
    'managerTabTeam': {
      AppLanguage.en: 'Team',
      AppLanguage.om: 'Garee',
      AppLanguage.am: 'ቡድን',
    },
    'cashierOtpSubmitPrompt': {
      AppLanguage.en: 'submitted physical cash. Count drawer cash and enter the 4-digit Cashier OTP below:',
      AppLanguage.om: 'maallaqa kaashii dhiheesseera. Maallaqa lakkaa\'iitii koodii OTP lakkoofsa 4 gadi galchi:',
      AppLanguage.am: 'ጥሬ ገንዘብ አስገብቷል። ገንዘቡን ቆጥረው ባለ 4 አሃዝ የOTP ኮድ ከታች ያስገቡ:',
    },
    'enterFourDigitOtpError': {
      AppLanguage.en: 'Please enter the 4-digit Cashier OTP code.',
      AppLanguage.om: 'Maaloo koodii OTP kaasharii lakkoofsa 4 galchaa.',
      AppLanguage.am: 'እባክዎ ባለ 4 አሃዝ የገንዘብ ተቀባይ OTP ኮድ ያስገቡ።',
    },
    'dayShiftHandoverCashLabel': {
      AppLanguage.en: 'Day Shift Carried Cash:',
      AppLanguage.om: 'Maallaqa Shiftii Guyyaa Wal-harkaa:',
      AppLanguage.am: 'ከቀን ፈረቃ የተረከቡት ገንዘብ:',
    },
    'nightShiftNetCashLabel': {
      AppLanguage.en: 'Night Shift Cash Collected:',
      AppLanguage.om: 'Maallaqa Shiftii Halkanii Sassaabame:',
      AppLanguage.am: 'በምሽት ፈረቃ የተሰበሰበ ገንዘብ:',
    },
    'totalCashToAdminLabel': {
      AppLanguage.en: 'Total Physical Cash to Admin:',
      AppLanguage.om: 'Maallaqa Kaashii Waliigalaa Adminiif:',
      AppLanguage.am: 'ለአስተዳዳሪ የሚረከብ ጠቅላላ ጥሬ ገንዘብ:',
    },
    'initiateNightShiftClosing': {
      AppLanguage.en: 'Initiate Night Shift Closing',
      AppLanguage.om: 'Cufiinsa Shiftii Halkanii Jalqabi',
      AppLanguage.am: 'የምሽት ፈረቃ መዝጊያ ጀምር',
    },
    'nightClosingConfirmed': {
      AppLanguage.en: 'Night Closing Confirmed',
      AppLanguage.om: 'Cufiinsi Halkanii Mirkanaa\'eera',
      AppLanguage.am: 'የምሽት ፈረቃ መዝጊያ ተረጋግጧል',
    },
    'nightClosingSubDesc': {
      AppLanguage.en: 'Reconciles night shift cash & washer pool before closing.',
      AppLanguage.om: 'Cufiinsa dura maallaqaafi komishinii shiftii halkanii walitti qaba.',
      AppLanguage.am: 'ከመዝጋቱ በፊት የምሽት ፈረቃ ገንዘብን እና የአጣቢዎችን ኮሚሽን ያስላል።',
    },
    'cashToAdminSuffix': {
      AppLanguage.en: 'cash to Admin',
      AppLanguage.om: 'Adminiif',
      AppLanguage.am: 'ለአስተዳዳሪ',
    },
    'awaitingHandoverLabel': {
      AppLanguage.en: 'No Day Handover Yet',
      AppLanguage.om: 'Wal-Harkaan Guyyaa Hin Jiru',
      AppLanguage.am: 'እስካሁን የቀን ርክክብ አልተደረገም',
    },
    'awaitingHandoverDesc': {
      AppLanguage.en: 'When Cashier submits Day closing via Manager OTP, verification appears above.',
      AppLanguage.om: 'Yeroo kaashariin cufiinsa guyyaa OTP Maanaajaraatiin ergu asirratti mul\'ata.',
      AppLanguage.am: 'ገንዘብ ተቀባዩ የቀን ፈረቃን በስራ አስኪያጅ OTP ሲዘጋ ማረጋገጫው ከላይ ይታያል።',
    },
    'commissionDisburseRequiredTitle': {
      AppLanguage.en: 'Disburse Daily Commissions First',
      AppLanguage.om: 'Koomishinii Guyyaa Dura Kaffali',
      AppLanguage.am: 'በመጀመሪያ የቀን ኮሚሽን ይክፈሉ',
    },
    'commissionDisburseRequiredDesc': {
      AppLanguage.en: 'You must disburse today\'s daily washer commission pool before closing or handing over this shift.',
      AppLanguage.om: 'Shiftii kana cufuun ykn maallaqa wal-harkaa fuuchuun dura koomishinii dhiqxootaa har\'aa kaffaluun dirqama.',
      AppLanguage.am: 'ይህንን ፈረቃ ከመዝጋትዎ ወይም ከማስረከብዎ በፊት የዛሬውን የአጣቢዎች የቀን ኮሚሽን መክፈል የግድ ነው።',
    },
    'goToTeamAndDisburse': {
      AppLanguage.en: 'Go to Team & Disburse',
      AppLanguage.om: 'Gara Garee Deemiitii Kaffali',
      AppLanguage.am: 'ወደ ቡድን ሄደው ይክፈሉ',
    },
    'disburseNowAndUnlockClosing': {
      AppLanguage.en: 'Disburse Pool Now & Unlock Closing',
      AppLanguage.om: 'Amma Kaffaliitii Cufiinsa Bani',
      AppLanguage.am: 'አሁን ከፍለው መዝጊያውን ይክፈቱ',
    },
    'remainingCommissionPool': {
      AppLanguage.en: 'Undisbursed Pool',
      AppLanguage.om: 'Koomishinii Hin Kaffalamin',
      AppLanguage.am: 'ያልተከፈለ ኮሚሽን',
    },
    'enterFourDigitManagerOtpError': {
      AppLanguage.en: 'Please enter the 4-digit Operational Manager OTP code.',
      AppLanguage.om: 'Maaloo koodii OTP Hojii Geggeessaa lakkoofsa 4 galchaa.',
      AppLanguage.am: 'እባክዎ ባለ 4 አሃዝ የኦፕሬሽን ስራ አስኪያጅ OTP ኮድ ያስገቡ።',
    },
    'otpMissingOrCorruptError': {
      AppLanguage.en: 'Handover OTP could not be verified. Ask the sender to regenerate a fresh OTP.',
      AppLanguage.om: 'Koodiin OTP mirkanaa\'uu hin dandeenye. Ergaan koodii haaraa akka uumu gaafadhu.',
      AppLanguage.am: 'የOTP ኮዱን ማረጋገጥ አልተቻለም። ላኪው አዲስ ኮድ እንዲያወጣ ይጠይቁ።',
    },
    'adminTabOverviewCash': {
      AppLanguage.en: 'Overview & Cash',
      AppLanguage.om: 'Cuunfaa & Maallaqa',
      AppLanguage.am: 'አጠቃላይ እና ገንዘብ',
    },
    'adminTabPricingTeam': {
      AppLanguage.en: 'Pricing & Team',
      AppLanguage.om: 'Gatii & Garee',
      AppLanguage.am: 'ዋጋ እና ቡድን',
    },
    'adminTabCustomersAds': {
      AppLanguage.en: 'Customers & Ads',
      AppLanguage.om: 'Maamila & Beeksisa',
      AppLanguage.am: 'ደንበኞች እና ማስታወቂያ',
    },
    'superAdminRoleBadge': {
      AppLanguage.en: 'SUPER ADMIN',
      AppLanguage.om: 'SUPPER ADMINII',
      AppLanguage.am: 'ዋና አስተዳዳሪ',
    },
    'secondaryAdminRoleBadge': {
      AppLanguage.en: 'SECONDARY ADMIN',
      AppLanguage.om: 'ADMINII LAMAFFAA',
      AppLanguage.am: 'ሁለተኛ አስተዳዳሪ',
    },
    'filterByDate': {
      AppLanguage.en: 'Filter by Date',
      AppLanguage.om: 'Guyyaadhaan Filadhu',
      AppLanguage.am: 'በቀን ይምረጡ',
    },
    'executiveMetricsTitle': {
      AppLanguage.en: 'Executive Real-Time Metrics',
      AppLanguage.om: 'Raawwii Hojii Kallattii',
      AppLanguage.am: 'ቀጥታ የስራ አፈጻጸም',
    },
    'netMarginLabel': {
      AppLanguage.en: 'Net Margin',
      AppLanguage.om: 'Bu\'aa Qulqulluu',
      AppLanguage.am: 'የተጣራ ትርፍ %',
    },
    'digitalVsCashLabel': {
      AppLanguage.en: 'Digital Transfers vs Cash',
      AppLanguage.om: 'Dijitaala vs Kaashii',
      AppLanguage.am: 'ዲጂታል እና ጥሬ ገንዘብ',
    },
    'washerCrewAttendanceLabel': {
      AppLanguage.en: 'Washer Crew Attendance',
      AppLanguage.om: 'Hirmaannaa Dhiqxootaa',
      AppLanguage.am: 'የአጣቢዎች መገኘት',
    },
    'onDutyCountLabel': {
      AppLanguage.en: 'On Duty',
      AppLanguage.om: 'Hojii Irra',
      AppLanguage.am: 'በስራ ላይ',
    },
    'totalWashersLabel': {
      AppLanguage.en: 'total washers',
      AppLanguage.om: 'dhiqxoota waliigalaa',
      AppLanguage.am: 'ጠቅላላ አጣቢዎች',
    },
    'teamPoolLabel': {
      AppLanguage.en: 'team pool',
      AppLanguage.om: 'kuufama garee',
      AppLanguage.am: 'የቡድን ኮሚሽን',
    },
    'pnlStatementTitle': {
      AppLanguage.en: 'Financial Statement (P&L)',
      AppLanguage.om: 'Gabaasa Bu\'aa fi Kasaaraa (P&L)',
      AppLanguage.am: 'የትርፍ እና ኪሳራ መግለጫ (P&L)',
    },
    'pnlStatementSub': {
      AppLanguage.en: 'Gross revenue, commission COGS, supplies & petty cash OpEx',
      AppLanguage.om: 'Galii waliigalaa, koomishinii, meeshaalee fi baasii xixiqqaa',
      AppLanguage.am: 'ጠቅላላ ገቢ፣ ኮሚሽን፣ የፍጆታ እቃዎች እና ጥቃቅን ወጪ',
    },
    'profitableBadge': {
      AppLanguage.en: 'PROFITABLE',
      AppLanguage.om: 'BU\'AA QABA',
      AppLanguage.am: 'ትርፋማ',
    },
    'deficitBadge': {
      AppLanguage.en: 'DEFICIT',
      AppLanguage.om: 'HIR\'INA',
      AppLanguage.am: 'ጉድለት',
    },
    'grossRevenueRow': {
      AppLanguage.en: 'I. Gross Station Revenue',
      AppLanguage.om: 'I. Galii Buufataa Waliigalaa',
      AppLanguage.am: 'I. ጠቅላላ የጣቢያው ገቢ',
    },
    'cogsRow': {
      AppLanguage.en: 'II. Cost of Goods Sold (COGS)',
      AppLanguage.om: 'II. Baasii Tajaajilaa (COGS)',
      AppLanguage.am: 'II. የአገልግሎት ወጪ (COGS)',
    },
    'washerCommissionSub': {
      AppLanguage.en: 'Washer Team Commission Pool',
      AppLanguage.om: 'Koomishinii Garee Dhiqxootaa',
      AppLanguage.am: 'የአጣቢ ቡድን ኮሚሽን',
    },
    'consumablesSub': {
      AppLanguage.en: 'Consumables Used & Soap Restocks',
      AppLanguage.om: 'Saamunaa fi Meeshaalee Fayyadaman',
      AppLanguage.am: 'የተጠቀሙ ፍጆታ ዕቃዎች እና ሳሙና',
    },
    'grossOperatingProfitRow': {
      AppLanguage.en: 'Gross Operating Profit',
      AppLanguage.om: 'Bu\'aa Hojii Waliigalaa',
      AppLanguage.am: 'ጠቅላላ የስራ ትርፍ',
    },
    'opexRow': {
      AppLanguage.en: 'III. Operating Expenses (OpEx)',
      AppLanguage.om: 'III. Baasii Hojii Guyyaa (OpEx)',
      AppLanguage.am: 'III. የስራ ማስኬጃ ወጪ (OpEx)',
    },
    'pettyCashOpexSub': {
      AppLanguage.en: 'Petty Cash Emergency Spends',
      AppLanguage.om: 'Baasii Kaashii Hatattamaa',
      AppLanguage.am: 'ጥቃቅን የአስቸኳይ ወጪዎች',
    },
    'netOperatingProfitRow': {
      AppLanguage.en: 'Net Operating Profit (EBITDA)',
      AppLanguage.om: 'Bu\'aa Qulqulluu (EBITDA)',
      AppLanguage.am: 'የተጣራ የስራ ትርፍ (EBITDA)',
    },
    'salaryReserveRow': {
      AppLanguage.en: 'IV. Guaranteed Base Salaries Reserve',
      AppLanguage.om: 'IV. Mindaa Bu\'uuraa Ji\'aa',
      AppLanguage.am: 'IV. የወር መሰረታዊ ደሞዝ መጠባበቂያ',
    },
    'netRetainedProfitRow': {
      AppLanguage.en: 'Net Retained Cash Profit',
      AppLanguage.om: 'Bu\'aa Kaashii Qulqulluu Hafe',
      AppLanguage.am: 'የተጣራ የተረፈ ትርፍ',
    },
    'statementPnlTab': {
      AppLanguage.en: 'P&L Statement',
      AppLanguage.om: 'Bu\'aa fi Kasaaraa',
      AppLanguage.am: 'የትርፍ እና ኪሳራ',
    },
    'statementBalanceSheetTab': {
      AppLanguage.en: 'Balance Sheet',
      AppLanguage.om: 'Qabeenya fi Idhaa',
      AppLanguage.am: 'የሃብት እና እዳ',
    },
    'statementCashFlowTab': {
      AppLanguage.en: 'Cash Flow',
      AppLanguage.om: 'Yaatuu Maallaqaa',
      AppLanguage.am: 'የጥሬ ገንዘብ ፍሰት',
    },
    'statementReconciliationTab': {
      AppLanguage.en: 'Chemical Audit',
      AppLanguage.om: 'Walsimsiisa Saamunaa',
      AppLanguage.am: 'የሳሙና ኦዲት',
    },
    'balanceSheetTitle': {
      AppLanguage.en: 'Balance Sheet (Statement of Financial Position)',
      AppLanguage.om: 'Gabaasa Qabeenyaa fi Idhaa (Balance Sheet)',
      AppLanguage.am: 'የሃብት እና ዕዳ መግለጫ (ሚዛን ሉህ)',
    },
    'balanceSheetSub': {
      AppLanguage.en: 'Current & Fixed Assets, Liabilities and Retained Equity',
      AppLanguage.om: 'Qabeenya, Idhaa fi Kaappitaala',
      AppLanguage.am: 'ወቅታዊ እና ቋሚ ሃብቶች፣ እዳዎች እና የተጣራ ካፒታል',
    },
    'assetsHeader': {
      AppLanguage.en: '1. TOTAL ASSETS',
      AppLanguage.om: '1. QABEENYA WALIIGALAA',
      AppLanguage.am: '1. ጠቅላላ ሃብት',
    },
    'currentAssets': {
      AppLanguage.en: 'Current Assets (Liquid)',
      AppLanguage.om: 'Qabeenya Socho\'aa',
      AppLanguage.am: 'ወቅታዊ (ፈሳሽ) ሃብቶች',
    },
    'cashInRegister': {
      AppLanguage.en: 'Cash on Hand (Drawer & Safe)',
      AppLanguage.om: 'Kaashii Harka Irraa',
      AppLanguage.am: 'በእጅ ያለ ጥሬ ገንዘብ',
    },
    'bankAndDigital': {
      AppLanguage.en: 'Bank & Mobile Money (Telebirr/CBE)',
      AppLanguage.om: 'Baankii fi Moobaayilii',
      AppLanguage.am: 'የባንክ እና የቴሌብር ሂሳብ',
    },
    'inventoryAsset': {
      AppLanguage.en: 'Consumables & Soap Inventory',
      AppLanguage.om: 'Kuusa Saamunaa fi Meeshaalee',
      AppLanguage.am: 'የሳሙና እና ኬሚካል ክምችት',
    },
    'nonCurrentAssets': {
      AppLanguage.en: 'Fixed Assets (Machinery & Gear)',
      AppLanguage.om: 'Qabeenya Dhaabbataa (Maashinoota)',
      AppLanguage.am: 'ቋሚ ሃብቶች (ማሽኖች እና መሳሪያዎች)',
    },
    'grossFixedAssets': {
      AppLanguage.en: 'Gross Machinery & Station Equipment',
      AppLanguage.om: 'Gatii Maashinootaa Waliigalaa',
      AppLanguage.am: 'ጠቅላላ የማሽነሪ እና የጣቢያ ዋጋ',
    },
    'accumulatedDepr': {
      AppLanguage.en: 'Less: Accumulated Depreciation',
      AppLanguage.om: 'Hir\'ifama: Dulloma Maashinaa',
      AppLanguage.am: 'ሲቀነስ፡ የተጠራቀመ እርጅና (ዴፕሪሴሽን)',
    },
    'netFixedAssets': {
      AppLanguage.en: 'Net Plant & Equipment',
      AppLanguage.om: 'Qabeenya Dhaabbataa Qulqulluu',
      AppLanguage.am: 'የተጣራ ቋሚ ሃብት',
    },
    'liabilitiesHeader': {
      AppLanguage.en: '2. LIABILITIES (OBLIGATIONS)',
      AppLanguage.om: '2. IDHAA WALIIGALAA',
      AppLanguage.am: '2. እዳዎች እና ግዴታዎች',
    },
    'currentLiabilities': {
      AppLanguage.en: 'Current Operating Liabilities',
      AppLanguage.om: 'Idhaa Yeroo Gabaabaa',
      AppLanguage.am: 'የአጭር ጊዜ እዳዎች',
    },
    'commissionsPayable': {
      AppLanguage.en: 'Washer Commissions Payable',
      AppLanguage.om: 'Koomishinii Dhiqxootaa Kan Kaffalamu',
      AppLanguage.am: 'የሚከፈል የአጣቢዎች ኮሚሽን',
    },
    'facilityRentPayable': {
      AppLanguage.en: 'Accrued Facility Rent Payable',
      AppLanguage.om: 'Kiraa Gamoo Kan Kaffalamu',
      AppLanguage.am: 'የጣቢያው የቤት ኪራይ እዳ',
    },
    'vatPayable': {
      AppLanguage.en: 'VAT Payable (15% Car Wash Tax)',
      AppLanguage.om: 'Taaksii VAT (15% Kan Mootummaa)',
      AppLanguage.am: 'የሚከፈል የተጨማሪ እሴት ታክስ (15% ቫት)',
    },
    'salariesPayable': {
      AppLanguage.en: 'Accrued Staff Wages Payable',
      AppLanguage.om: 'Mindaa Hojjattootaa Kan Kaffalamu',
      AppLanguage.am: 'የሚከፈል የሰራተኞች ደሞዝ',
    },
    'equityHeader': {
      AppLanguage.en: '3. OWNER\'S EQUITY',
      AppLanguage.om: '3. KAAPPITAALA ABBAA QABEENYAA',
      AppLanguage.am: '3. የባለቤቱ የተጣራ ካፒታል',
    },
    'initialCapital': {
      AppLanguage.en: 'Station Startup Capital',
      AppLanguage.om: 'Kaappitaala Jalqabaa',
      AppLanguage.am: 'የመጀመሪያ መነሻ ካፒታል',
    },
    'retainedEarnings': {
      AppLanguage.en: 'Retained Earnings (Cumulative Net Profit)',
      AppLanguage.om: 'Bu\'aa Kuufame (Retained Earnings)',
      AppLanguage.am: 'የተጠራቀመ የተጣራ ትርፍ',
    },
    'totalEquity': {
      AppLanguage.en: 'Total Owner Equity',
      AppLanguage.om: 'Kaappitaala Waliigalaa',
      AppLanguage.am: 'ጠቅላላ የባለቤቱ ካፒታል',
    },
    'balancedAccountingEquation': {
      AppLanguage.en: 'BALANCED: Assets = Liabilities + Equity',
      AppLanguage.om: 'MIZANAWA: Qabeenya = Idhaa + Kaappitaala',
      AppLanguage.am: 'የተመጣጠነ፡ ሃብት = እዳ + ካፒታል',
    },
    'cashFlowTitle': {
      AppLanguage.en: 'Cash Flow Statement',
      AppLanguage.om: 'Gabaasa Yaatuu Maallaqaa (Cash Flow)',
      AppLanguage.am: 'የጥሬ ገንዘብ ፍሰት መግለጫ (ካሽ ፍሎው)',
    },
    'cashFlowSub': {
      AppLanguage.en: 'Inflows & outflows: Operations, Investing & Financing',
      AppLanguage.om: 'Seensa fi Baasii Maallaqaa',
      AppLanguage.am: 'የገቢ እና ወጪ ጥሬ ገንዘብ እንቅስቃሴ',
    },
    'cfoHeader': {
      AppLanguage.en: 'Operating Activities (CFO)',
      AppLanguage.om: 'Hojiiwwan Bu\'uuraa (CFO)',
      AppLanguage.am: 'የስራ ማስኬጃ እንቅስቃሴዎች (CFO)',
    },
    'cashFromCarWash': {
      AppLanguage.en: 'Cash Receipts from Car Washes',
      AppLanguage.om: 'Galii Kaashii Dhiqa Konkolaataa',
      AppLanguage.am: 'ከመኪና እጥበት የተሰበሰበ ጥሬ ገንዘብ',
    },
    'cashFromCarpet': {
      AppLanguage.en: 'Cash Receipts from Carpet Cleanings',
      AppLanguage.om: 'Galii Kaashii Dhiqa Afataa',
      AppLanguage.am: 'ከምንጣፍ እጥበት የተሰበሰበ ጥሬ ገንዘብ',
    },
    'cashFromShower': {
      AppLanguage.en: 'Cash Receipts from Shower Services',
      AppLanguage.om: 'Galii Kaashii Shaworii',
      AppLanguage.am: 'ከሻወር አገልግሎት የተሰበሰበ ጥሬ ገንዘብ',
    },
    'digitalCollections': {
      AppLanguage.en: 'Digital Inflows (Telebirr & CBE)',
      AppLanguage.om: 'Galii Moobaayilii (Telebirr/CBE)',
      AppLanguage.am: 'የዲጂታል ገቢዎች (ቴሌብር እና ንግድ ባንክ)',
    },
    'outflowSupplies': {
      AppLanguage.en: 'Cash Paid for Soaps & Restocks',
      AppLanguage.om: 'Kaffaltii Saamunaa fi Bittaa',
      AppLanguage.am: 'ለሳሙና እና ኬሚካል ግዢ የተከፈለ',
    },
    'outflowCommissions': {
      AppLanguage.en: 'Cash Paid for Washer Commissions',
      AppLanguage.om: 'Kaffaltii Koomishinii Dhiqxootaa',
      AppLanguage.am: 'ለአጣቢዎች ኮሚሽን የተከፈለ',
    },
    'outflowPettyCash': {
      AppLanguage.en: 'Cash Paid for Station Petty Expenses',
      AppLanguage.om: 'Kaffaltii Baasii Xixiqqaa Buufataa',
      AppLanguage.am: 'ለጣቢያው ጥቃቅን ወጪዎች የተከፈለ',
    },
    'outflowRent': {
      AppLanguage.en: 'Cash Paid for Facility Rent',
      AppLanguage.om: 'Kaffaltii Kiraa Gamoo',
      AppLanguage.am: 'ለጣቢያው የቤት ኪራይ የተከፈለ',
    },
    'netCfo': {
      AppLanguage.en: 'Net Cash from Operating Activities',
      AppLanguage.om: 'Yaatuu Maallaqa Hojii Qulqulluu',
      AppLanguage.am: 'የተጣራ የስራ እንቅስቃሴ የገንዘብ ፍሰት',
    },
    'cfiHeader': {
      AppLanguage.en: 'Investing Activities (CFI)',
      AppLanguage.om: 'Sochii Invastimantii (CFI)',
      AppLanguage.am: 'የኢንቨስትመንት እንቅስቃሴዎች (CFI)',
    },
    'capexEquipment': {
      AppLanguage.en: 'Machinery & Equipment Capital Outlay',
      AppLanguage.om: 'Bittaa fi Haaromsa Maashinaa',
      AppLanguage.am: 'ለማሽኖች እና መሳሪያዎች ግዢ የወጣ',
    },
    'netCfi': {
      AppLanguage.en: 'Net Cash Used in Investing Activities',
      AppLanguage.om: 'Maallaqa Invastimantiif Oole',
      AppLanguage.am: 'ለኢንቨስትመንት የዋለ የተጣራ ገንዘብ',
    },
    'cffHeader': {
      AppLanguage.en: 'Financing Activities (CFF)',
      AppLanguage.om: 'Sochii Faayinaansii (CFF)',
      AppLanguage.am: 'የፋይናንስ እንቅስቃሴዎች (CFF)',
    },
    'ownerDrawings': {
      AppLanguage.en: 'Owner Capital Drawings / Distributions',
      AppLanguage.om: 'Baasii Abbaa Qabeenyaa',
      AppLanguage.am: 'የባለቤቱ የትርፍ ድርሻ ወጪ',
    },
    'netCff': {
      AppLanguage.en: 'Net Cash from Financing Activities',
      AppLanguage.om: 'Maallaqa Faayinaansii Qulqulluu',
      AppLanguage.am: 'የተጣራ የፋይናንስ እንቅስቃሴ ገንዘብ',
    },
    'netChangeInCash': {
      AppLanguage.en: 'Net Change in Cash',
      AppLanguage.om: 'Jijjiirama Maallaqaa Qulqulluu',
      AppLanguage.am: 'የተጣራ የገንዘብ ለውጥ',
    },
    'openingCash': {
      AppLanguage.en: 'Cash at Beginning of Period',
      AppLanguage.om: 'Maallaqa Jalqaba Yeroo',
      AppLanguage.am: 'የመጀመሪያ የጥሬ ገንዘብ መነሻ',
    },
    'closingCash': {
      AppLanguage.en: 'Cash & Cash Equivalents at End of Period',
      AppLanguage.om: 'Maallaqa Dhuma Yeroo',
      AppLanguage.am: 'የመጨረሻ የጥሬ ገንዘብ መጠን',
    },
    'reconciliationTitle': {
      AppLanguage.en: 'Storekeeper vs Cashier Reconciliation',
      AppLanguage.om: 'Walsimsiisa Kuusaa fi Dhiqxootaa',
      AppLanguage.am: 'የእቃ ግምጃ ቤት እና የካሸር እጥበት ማስታረቂያ',
    },
    'reconciliationSub': {
      AppLanguage.en: 'Chemical issue logs compared to cars washed',
      AppLanguage.om: 'Saamunaa bahe fi konkolaataa dhiqame',
      AppLanguage.am: 'የወጣው ሳሙና እና የታጠበው መኪና ብዛት ንጽጽር',
    },
    'carsWashedCount': {
      AppLanguage.en: 'Cars Washed Count',
      AppLanguage.om: 'Baay\'ina Konkolaataa Dhiqame',
      AppLanguage.am: 'የታጠቡ መኪኖች ብዛት',
    },
    'carpetsWashedCount': {
      AppLanguage.en: 'Carpets Cleaned Count',
      AppLanguage.om: 'Baay\'ina Afata Dhiqame',
      AppLanguage.am: 'የታጠቡ ምንጣፎች ብዛት',
    },
    'expectedChemical': {
      AppLanguage.en: 'Theoretical Expected Usage',
      AppLanguage.om: 'Hamma Fayyadama Tilmaamame',
      AppLanguage.am: 'የሚጠበቅ የኬሚካል ፍጆታ',
    },
    'actualIssued': {
      AppLanguage.en: 'Actual Storekeeper Issues',
      AppLanguage.om: 'Hamma Kuusaa Irraa Bahe',
      AppLanguage.am: 'በእርግጥ ከግምጃ ቤት የወጣ',
    },
    'varianceLabel': {
      AppLanguage.en: 'Variance (Discrepancy)',
      AppLanguage.om: 'Garaagarummaa (Hir\'ina/Dabalata)',
      AppLanguage.am: 'ልዩነት (ብክነት/ጉድለት)',
    },
    'optimalUsage': {
      AppLanguage.en: 'Optimal Usage (Efficient)',
      AppLanguage.om: 'Fayyadama Qusatamaa',
      AppLanguage.am: 'ተገቢ እና ቆጣቢ አጠቃቀም',
    },
    'moderateWaste': {
      AppLanguage.en: 'Moderate Waste / Overfoaming',
      AppLanguage.om: 'Qisaasama Giddu-galeessaa',
      AppLanguage.am: 'መጠነኛ ብክነት / ከመጠን ያለፈ ሳሙና',
    },
    'highLeakage': {
      AppLanguage.en: 'High Discrepancy / Audit Required',
      AppLanguage.om: 'Garaagarummaa Guddaa / Qorannoo',
      AppLanguage.am: 'ከፍተኛ ልዩነት / ኦዲት ያስፈልገዋል',
    },
    'dilutedUsage': {
      AppLanguage.en: 'Diluted Usage / Under-foaming',
      AppLanguage.om: 'Fayyadama Bishaaniin Xiqqaate',
      AppLanguage.am: 'የቀጠነ ውህድ / ዝቅተኛ ሳሙና',
    },
    'washHistoryAuditDesc': {
      AppLanguage.en: 'Audit paid washes & receipts by date',
      AppLanguage.om: 'Seenaa dhiqannaa kaffalamee sakatta\'i',
      AppLanguage.am: 'የተከፈሉ እጥበቶችን እና ደረሰኞችን ይመልከቱ',
    },
    'financialReportsAuditDesc': {
      AppLanguage.en: 'Shift closings, bank deposits & cash drawer',
      AppLanguage.om: 'Cufiinsa shiftii, baankii fi kaashii',
      AppLanguage.am: 'የፈረቃ መዝጊያ፣ የባንክ ገቢ እና የገንዘብ ሪፖርት',
    },
    'editTariffsInventorySub': {
      AppLanguage.en: 'Car & carpet tariffs, consumables & equipment',
      AppLanguage.om: 'Gatii konkolaataa fi kaarpeetii, meeshaalee',
      AppLanguage.am: 'የመኪና እና ምንጣፍ ዋጋ፣ ዕቃዎች እና መሳሪያ',
    },
    'dailyTodayFilter': {
      AppLanguage.en: 'Daily Today',
      AppLanguage.om: 'Har\'a',
      AppLanguage.am: 'የዛሬ ቀን',
    },
    'weeklyReportFilter': {
      AppLanguage.en: 'Weekly Report',
      AppLanguage.om: 'Torbanii',
      AppLanguage.am: 'ሳምንታዊ ሪፖርት',
    },
    'periodReportFilter': {
      AppLanguage.en: 'Selected Period',
      AppLanguage.om: 'Yeroo Filatame',
      AppLanguage.am: 'የተመረጠ ጊዜ',
    },
    'pendingDayOtpBadge': {
      AppLanguage.en: 'PENDING CASHIER OTP',
      AppLanguage.om: 'OTP KAASHARII EEGAA JIRA',
      AppLanguage.am: 'የገንዘብ ተቀባይ OTP በመጠባበቅ ላይ',
    },
    'reconciledBadge': {
      AppLanguage.en: 'RECONCILED',
      AppLanguage.om: 'MIRKANAA\'EERA',
      AppLanguage.am: 'ተረጋግጧል',
    },
    'dayShiftActiveBadge': {
      AppLanguage.en: 'DAY SHIFT ACTIVE',
      AppLanguage.om: 'SHIFTIIN GUYYAA HOJII IRRA',
      AppLanguage.am: 'የቀን ፈረቃ ንቁ ነው',
    },
    'pendingVaultSealBadge': {
      AppLanguage.en: 'PENDING VAULT SEAL',
      AppLanguage.om: 'KAAZINAAN EEGAMA',
      AppLanguage.am: 'ካዝና ማረጋገጫ በመጠባበቅ ላይ',
    },
    'sealedInVaultBadge': {
      AppLanguage.en: 'SEALED IN VAULT',
      AppLanguage.om: 'KAAZINATTI MIRKANAA\'E',
      AppLanguage.am: 'በካዝና ተዘግቷል',
    },
    'nightShiftActiveBadge': {
      AppLanguage.en: 'NIGHT SHIFT ACTIVE',
      AppLanguage.om: 'SHIFTIIN HALKANII HOJII IRRA',
      AppLanguage.am: 'የምሽት ፈረቃ ንቁ ነው',
    },
    'secondaryApprovalsAwaiting': {
      AppLanguage.en: 'Secondary Admin Action(s) Awaiting Approval',
      AppLanguage.om: 'Gochaa Adminii Lammaffaa Mirkaneessa Eegu',
      AppLanguage.am: 'ማረጋገጫ የሚጠብቁ የሁለተኛ አስተዳዳሪ ተግባራት',
    },
    'submittedForSuperApproval': {
      AppLanguage.en: 'Action(s) Submitted for Super Admin Approval',
      AppLanguage.om: 'Gochaa Mirkaneessa Supper Adminiif Ergame',
      AppLanguage.am: 'ለዋና አስተዳዳሪ ማረጋገጫ የቀረቡ ተግባራት',
    },
    'approveAction': {
      AppLanguage.en: 'Approve',
      AppLanguage.om: 'Mirkaneessi',
      AppLanguage.am: 'አጽድቅ',
    },
    'rejectAction': {
      AppLanguage.en: 'Reject',
      AppLanguage.om: 'Kuffisi',
      AppLanguage.am: 'ውድቅ አድርግ',
    },
    'pendingReviewBadge': {
      AppLanguage.en: 'Pending Review',
      AppLanguage.om: 'Sakatta\'ama Eegaa Jira',
      AppLanguage.am: 'ግምገማ በመጠባበቅ ላይ',
    },
    'smsAndHotlineTitle': {
      AppLanguage.en: 'Customer Hotline & Cashier SMS',
      AppLanguage.om: 'Bilbila Maamilaafi SMS Kaasharii',
      AppLanguage.am: 'የደንበኞች ስልክ እና የገንዘብ ተቀባይ SMS',
    },
    'hotlineBookingLabel': {
      AppLanguage.en: 'Customer Hotline Booking Number',
      AppLanguage.om: 'Lakkoofsa Bilbila Ajaja Maamilaa',
      AppLanguage.am: 'የደንበኞች የስልክ ማዘዣ ቁጥር',
    },
    'cashierSmsPhoneLabel': {
      AppLanguage.en: 'Cashier SMS Phone Number',
      AppLanguage.om: 'Lakkoofsa Bilbila SMS Kaasharii',
      AppLanguage.am: 'የገንዘብ ተቀባይ SMS ስልክ ቁጥር',
    },
    'updateAction': {
      AppLanguage.en: 'Update',
      AppLanguage.om: 'Haaromsi',
      AppLanguage.am: 'አዘምን',
    },
    'tiktokReelsCardTitle': {
      AppLanguage.en: 'Welcome Screen TikTok Reels',
      AppLanguage.om: 'Viidiyoo TikTok Fuula Jalqabaa',
      AppLanguage.am: 'የመግቢያ ገጽ የTikTok ማስታወቂያዎች',
    },
    'manageReelsBtn': {
      AppLanguage.en: 'Manage Reels',
      AppLanguage.om: 'Viidiyoowwan Bulchi',
      AppLanguage.am: 'ቪዲዮዎችን ያስተዳድሩ',
    },
    'reelsActiveSuffix': {
      AppLanguage.en: 'reels active',
      AppLanguage.om: 'viidiyoowwan hojii irra',
      AppLanguage.am: 'ንቁ ቪዲዮዎች',
    },
    'cashierFilterOnlineBookers': {
      AppLanguage.en: 'Online Bookers',
      AppLanguage.om: 'Ajaja Intarneetaa',
      AppLanguage.am: 'በኦንላይን ያዘዙ',
    },
    'onlineBookingBadge': {
      AppLanguage.en: 'ONLINE BOOKER',
      AppLanguage.om: 'AJAJA INTARNEETAA',
      AppLanguage.am: 'የኦንላይን ትዕዛዝ',
    },
    'approveAndArrivedAction': {
      AppLanguage.en: 'Approve & Arrived at Station',
      AppLanguage.om: 'Mirkaneessiitii Buufata Gahe',
      AppLanguage.am: 'አጽድቅ እና ጣቢያ ደርሷል',
    },
    'postponeNextDayAction': {
      AppLanguage.en: 'Postpone to Next Day',
      AppLanguage.om: 'Guyyaa Itti Aanutti Dabarsi',
      AppLanguage.am: 'ለሚቀጥለው ቀን አዛውር',
    },
    'postponedCarryOverBadge': {
      AppLanguage.en: 'POSTPONED CARRY-OVER',
      AppLanguage.om: 'BORUUTTI DARBE',
      AppLanguage.am: 'ለነገ የተዛወረ',
    },
    'prepaidFinishWashBadge': {
      AppLanguage.en: 'PAID — FINISH & DELIVER',
      AppLanguage.om: 'KAFFALAMEERA — XUMURIITII KENNI',
      AppLanguage.am: 'ተከፍሏል — አጥበህ አስረክብ',
    },
    'postponeDialogTitle': {
      AppLanguage.en: 'Postpone Wash to Next Day',
      AppLanguage.om: 'Dhiqannaa Boruutti Dabarsi',
      AppLanguage.am: 'እጥበቱን ለሚቀጥለው ቀን አዛውር',
    },
    'postponeDialogDesc': {
      AppLanguage.en: 'Keep this arrived vehicle active for tomorrow\'s queue and log the reason for Accountant & Admin audit.',
      AppLanguage.om: 'Konkolaataan dhufe kun dabaree dhiqaa boruutiif akka turuu fi sababni isaa oodiitiif akka galmaa\'u godhi.',
      AppLanguage.am: 'የደረሰው ተሽከርካሪ ለነገው ተራ እንዲቆይ እና ምክንያቱ ለሂሳብና ለአስተዳዳሪ ኦዲት እንዲመዘገብ ያድርጉ።',
    },
    'postponeReasonHint': {
      AppLanguage.en: 'e.g. Customer pickup tomorrow morning',
      AppLanguage.om: 'fkn. Maamilli ganama boruu fudhata',
      AppLanguage.am: 'ለምሳሌ፡ ደንበኛው ነገ ጠዋት ይረከባል',
    },
    'postponedSuccessMsg': {
      AppLanguage.en: 'Vehicle carried over to next day queue & logged for audit.',
      AppLanguage.om: 'Konkolaataan gara boruutti dabarfamee oodiitidhaaf galmaa\'eera.',
      AppLanguage.am: 'ተሽከርካሪው ወደ ቀጣዩ ቀን ተዛውሮ ለኦዲት ተመዝግቧል።',
    },
    'openVehiclesHandoverTitle': {
      AppLanguage.en: 'Active Vehicles Continuing to Next Shift',
      AppLanguage.om: 'Konkolaattota Shiftii Itti Aanutti Darban',
      AppLanguage.am: 'ወደ ቀጣዩ ፈረቃ የሚቀጥሉ ተሽከርካሪዎች',
    },
    'openVehiclesHandoverDesc': {
      AppLanguage.en: 'Arrived vehicles still in bays or queue continue automatically to the next shift.',
      AppLanguage.om: 'Konkolaattonni buufata gahanii hin xumuramin gara shiftii itti aanuutti ofumaan itti fufu.',
      AppLanguage.am: 'ጣቢያ የደረሱና ያልተጠናቀቁ ተሽከርካሪዎች በራስ-ሰር ወደ ቀጣዩ ፈረቃ ይቀጥላሉ።',
    },
    'autoClearNoShowsNotice': {
      AppLanguage.en: 'Unarrived online booking(s) will be automatically removed from the queue upon closing.',
      AppLanguage.om: 'Ajajni intarneetaa hin dhufne yeroo cufiinsaa ofumaan hiriira keessaa ni haqamu.',
      AppLanguage.am: 'ያልመጡ የኦንላይን ትዕዛዞች ሲዘጋ በራስ-ሰር ከሰልፉ ይሰረዛሉ።',
    },
    'unarrivedNoShowsClearedLabel': {
      AppLanguage.en: 'Online no-shows cleared',
      AppLanguage.om: 'Ajaja hin dhufne haqaman',
      AppLanguage.am: 'ያልመጡ የተሰረዙ ትዕዛዞች',
    },
    'carryOverAuditTitle': {
      AppLanguage.en: 'Carry-Over & Postponed Vehicles Audit',
      AppLanguage.om: 'Oodiitii Konkolaattota Boruutti Darban',
      AppLanguage.am: 'ወደ ቀጣይ ቀን የተዛወሩ ተሽከርካሪዎች ኦዲት',
    },
    'carryOverAuditSub': {
      AppLanguage.en: 'Open, postponed & prepaid pending washes across shifts',
      AppLanguage.om: 'Dhiqannaa hin xumuramin ykn boruutti darban',
      AppLanguage.am: 'ያልተጠናቀቁ እና ለነገ የተዛወሩ እጥበቶች',
    },
    'noCarryOverVehicles': {
      AppLanguage.en: 'No postponed or overdue carry-over vehicles pending.',
      AppLanguage.om: 'Konkolaataan hin xumuramin ykn boruutti darbe hin jiru.',
      AppLanguage.am: 'ምንም ያልተጠናቀቀ ወይም የተዛወረ ተሽከርካሪ የለም።',
    },
    'stepApprovedDesc': {
      AppLanguage.en: 'Booking approved — drive in to the station when ready to start.',
      AppLanguage.om: 'Ajajni mirkanaa\'eera — yeroo dhuftan buufatatti mirkaneessaa.',
      AppLanguage.am: 'ቦታዎ ጸድቋል — ወደ ጣቢያው ሲመጡ መድረስዎን ያረጋግጡ።',
    },
    'stepArrivedDesc': {
      AppLanguage.en: 'Cashier confirmed your arrival at station.',
      AppLanguage.om: 'Qabaan qarshii buufata gahuu keessan mirkaneesseera.',
      AppLanguage.am: 'ገንዘብ ተቀባዩ ጣቢያ መድረስዎን አረጋግጧል።',
    },
    'handoverToOpManagerAction': {
      AppLanguage.en: 'Handover to Operational Manager',
      AppLanguage.om: 'Hogganaa Hojiitti Kenni',
      AppLanguage.am: 'ለኦፕሬሽን ማናጀር አስረክብ',
    },
    'handedOverToManagerBadge': {
      AppLanguage.en: 'HANDED TO OP. MANAGER',
      AppLanguage.om: 'HOGGANAA HOJIITTI KENNAME',
      AppLanguage.am: 'ለኦፕሬሽን ማናጀር የተረከበ',
    },
    'fromDayCashierBadge': {
      AppLanguage.en: 'FROM DAY CASHIER',
      AppLanguage.om: 'KAASHIYARA GUYAA IRRAA',
      AppLanguage.am: 'ከቀን ካሸር የመጣ',
    },
    'postponedByManagerBadge': {
      AppLanguage.en: 'POSTPONED BY OP. MANAGER',
      AppLanguage.om: 'HOGGANAA HOJIIN BORUUTTI DARBE',
      AppLanguage.am: 'በኦፕሬሽን ማናጀር ለነገ የተዛወረ',
    },
    'handoverDialogTitle': {
      AppLanguage.en: 'Handover to Operational Manager',
      AppLanguage.om: 'Hogganaa Hojiitti Dabarsi',
      AppLanguage.am: 'ለኦፕሬሽን ማናጀር ማስረከብ',
    },
    'handoverDialogDesc': {
      AppLanguage.en: 'Keep this vehicle active for Night Shift continuation under the Operational Manager. Current wash stage, bay & payment status stay preserved.',
      AppLanguage.om: 'Konkolaataan kun shiftii halkaniitti hogganaa hojiitiin akka itti fufu godhi. Sadarkaan dhiqannaa, booxinii fi haalli kaffaltii ni eegama.',
      AppLanguage.am: 'ይህ ተሽከርካሪ በምሽት ፈረቃ በኦፕሬሽን ማናጀር ስር እንዲቀጥል ያስረክቡ። የእጥበት ደረጃው፣ ቦታው እና የክፍያ ሁኔታው እንደተጠበቀ ይቆያል።',
    },
    'handoverNoteHint': {
      AppLanguage.en: 'Optional note (e.g. half-washed, prepaid)...',
      AppLanguage.om: 'Yaada dabalataa (fkn. walakkaan dhiqame, kaffalameera)...',
      AppLanguage.am: 'ተጨማሪ ማስታወሻ (ለምሳሌ፡ ግማሽ የታጠበ፣ የተከፈለ)...',
    },
    'handoverSuccessMsg': {
      AppLanguage.en: 'Vehicle handed over to Operational Manager for Night Shift.',
      AppLanguage.om: 'Konkolaataan shiftii halkaniif Hogganaa Hojiitti dabarfameera.',
      AppLanguage.am: 'ተሽከርካሪው ለምሽት ፈረቃ ለኦፕሬሽን ማናጀር ተሰጥቷል።',
    },
    'postponeReasonRequiredError': {
      AppLanguage.en: 'Operational Manager must enter a reason before postponing to next day.',
      AppLanguage.om: 'Hogganaan Hojii gara boruutti dabarsuun dura sababa barreessuu qaba.',
      AppLanguage.am: 'ኦፕሬሽን ማናጀር ለነገ ከማዘዋወሩ በፊት ምክንያት መጻፍ አለበት።',
    },
    'postponeReasonRequiredLabel': {
      AppLanguage.en: 'Reason required for Accountant & Admin audit *',
      AppLanguage.om: 'Sababa dirqama oodiitiif barreeffamu *',
      AppLanguage.am: 'ለሂሳብ እና ለአስተዳዳሪ ኦዲት የሚያስፈልግ የግድ ምክንያት *',
    },
    'handedOverVehiclesTitle': {
      AppLanguage.en: 'Active Vehicles from Day Shift',
      AppLanguage.om: 'Konkolaattota Shiftii Guyyaa',
      AppLanguage.am: 'ከቀን ፈረቃ የቀጠሉ ተሽከርካሪዎች',
    },
    'postponedByLabel': {
      AppLanguage.en: 'Postponed by',
      AppLanguage.om: 'Kan dabarse',
      AppLanguage.am: 'ያዘዋወረው',
    },
    'custodyChainLabel': {
      AppLanguage.en: 'Custody',
      AppLanguage.om: 'Wal-Harkaa Fuudhiinsa',
      AppLanguage.am: 'የርክክብ ሰንሰለት',
    },
    'handoffCustodyArrow': {
      AppLanguage.en: 'Day Cashier → Op. Manager',
      AppLanguage.om: 'Kaashiyara Guyyaa → Hogganaa Hojii',
      AppLanguage.am: 'ቀን ካሸር → ኦፕሬሽን ማናጀር',
    },
    'closingCloudSyncRlsWarning': {
      AppLanguage.en: 'Saved locally, but Supabase daily_closings UPDATE was blocked by RLS (42501). Run migration 20261111_fix_rls_closings_and_bookings.sql in Supabase SQL Editor.',
      AppLanguage.om: 'Naannotti olkaa\'ameera, garuu haaromsi daily_closings Supabase keessaa seera RLS (42501) tiin uggurame. Migration 20261111_fix_rls_closings_and_bookings.sql Supabase SQL Editor keessatti hojisiisaa.',
      AppLanguage.am: 'በመሣሪያው ላይ ተቀምጧል፣ ነገር ግን የSupabase daily_closings ማሻሻያ በRLS ፖሊሲ (42501) ታግዷል። እባክዎ 20261111_fix_rls_closings_and_bookings.sql በSupabase SQL Editor ያስኪዱ።',
    },
    'closingCloudSyncNetworkWarning': {
      AppLanguage.en: 'Saved locally, but cloud sync to Supabase daily_closings failed. Check connection or verify Supabase policies and refresh.',
      AppLanguage.om: 'Naannotti olkaa\'ameera, garuu erguun gara Supabase daily_closings hin milkoofne. Interneetii yookaan seera Supabase mirkaneeffadhaatii haaromsaa.',
      AppLanguage.am: 'በመሣሪያው ላይ ተቀምጧል፣ ነገር ግን ወደ Supabase daily_closings መላክ አልተቻለም። ኢንተርኔት ወይም የSupabase ፖሊሲዎችን አረጋግጠው ያድሱ።',
    },
    'exactHomePlaceLabel': {
      AppLanguage.en: 'Exact Customer Home / Place Address',
      AppLanguage.om: 'Teessoo Sirrii Manaa / Bakka Maamilaa',
      AppLanguage.am: 'የደንበኛው ቤት / ቦታ ትክክለኛ አድራሻ',
    },
    'exactHomePlaceHint': {
      AppLanguage.en: 'e.g. Kebele 04, Near Kuriftu Gate, Villa #12',
      AppLanguage.om: 'fkn. Ganda 04, Karra Kuriftu bira, Mana #12',
      AppLanguage.am: 'ለምሳሌ፡ ቀበሌ 04፣ ኩሪፍቱ በር አጠገብ፣ ቤት ቁጥር 12',
    },
    'liveGpsLocatorBtn': {
      AppLanguage.en: 'Live GPS',
      AppLanguage.om: 'GPS Ammaa',
      AppLanguage.am: 'ቀጥታ ጂፒኤስ',
    },
    'liveGpsFetching': {
      AppLanguage.en: 'Locating...',
      AppLanguage.om: 'Barbaadaa...',
      AppLanguage.am: 'በመፈለግ...',
    },
    'gpsCoordinatesLabel': {
      AppLanguage.en: 'Live GPS Coordinates (Lat, Lng)',
      AppLanguage.om: 'Koordinaatii GPS (Lat, Lng)',
      AppLanguage.am: 'የጂፒኤስ መጋጠሚያ (Lat, Lng)',
    },
    'gpsUnavailableMsg': {
      AppLanguage.en: 'Allow location access in browser or enter address / coordinates manually.',
      AppLanguage.om: 'Hayyama bakkaa banaa ykn teessoo/GPS harkaan galchaa.',
      AppLanguage.am: 'የአካባቢ ፈቃድ ይስጡ ወይም አድራሻውን በእጅ ያስገቡ።',
    },
    'phoneIntakeDeliverySub': {
      AppLanguage.en: 'Phone intake: At Station, At Home Van, or VIP Driver Pick-up & Return',
      AppLanguage.om: 'Ajaja bilbilaa: Buufata, Mana Maamilaa (Van), ykn Konkolaachisaa VIP',
      AppLanguage.am: 'የስልክ ትዕዛዝ፡ በጣቢያ፣ በቤት ቫን ወይም በቪአይፒ ሹፌር መውሰድና መመለስ',
    },
    'deliveryModeRequiredAddress': {
      AppLanguage.en: 'Please enter the exact home/place address or live GPS coordinates.',
      AppLanguage.om: 'Mee teessoo sirrii manaa ykn GPS galchaa.',
      AppLanguage.am: 'እባክዎ ትክክለኛ የቤት አድራሻ ወይም ጂፒኤስ ያስገቡ።',
    },
    'chooseDeliveryQuick': {
      AppLanguage.en: 'Car Wash Delivery Options',
      AppLanguage.om: 'Filannoo Tajaajila Dhiqannaa',
      AppLanguage.am: 'የመኪና እጥበት አገልግሎት አማራጮች',
    },
    'consolidatedDailyTitle': {
      AppLanguage.en: 'Consolidated Daily Financial Report',
      AppLanguage.om: 'Gabaasa Faayinaansii Guyyaa Walitti Qabame',
      AppLanguage.am: 'የተጠቃለለ ዕለታዊ የፋይናንስ ሪፖርት',
    },
    'consolidatedWeeklyTitle': {
      AppLanguage.en: 'Consolidated Weekly Financial Report',
      AppLanguage.om: 'Gabaasa Faayinaansii Torbanii Walitti Qabame',
      AppLanguage.am: 'የተጠቃለለ ሳምንታዊ የፋይናንስ ሪፖርት',
    },
    'consolidatedMonthlyTitle': {
      AppLanguage.en: 'Consolidated Monthly Financial Report',
      AppLanguage.om: 'Gabaasa Faayinaansii Ji\'aa Walitti Qabame',
      AppLanguage.am: 'የተጠቃለለ ወርሃዊ የፋይናንስ ሪፖርት',
    },
    'consolidatedCustomPrefix': {
      AppLanguage.en: 'Consolidated',
      AppLanguage.om: 'Walitti Qabama',
      AppLanguage.am: 'የተጠቃለለ',
    },
    'consolidatedCustomSuffix': {
      AppLanguage.en: 'Financial Report',
      AppLanguage.om: 'Gabaasa Faayinaansii',
      AppLanguage.am: 'የፋይናንስ ሪፖርት',
    },
    'divisionSummaryTableTitle': {
      AppLanguage.en: 'Service Division Revenue Summary',
      AppLanguage.om: 'Cuunfaa Galii Kutaa Tajaajilaa',
      AppLanguage.am: 'የአገልግሎት ክፍሎች የገቢ ማጠቃለያ',
    },
    'paymentSummaryTableTitle': {
      AppLanguage.en: 'Collections & Profit Ledger Table',
      AppLanguage.om: 'Gabatee Kaffaltii fi Bu\'aa',
      AppLanguage.am: 'የክፍያ እና ትርፍ መዝገብ ሰንጠረዥ',
    },
    'categoryColLabel': {
      AppLanguage.en: 'Category',
      AppLanguage.om: 'Gosa',
      AppLanguage.am: 'ምድብ',
    },
    'countColLabel': {
      AppLanguage.en: 'Count / Detail',
      AppLanguage.om: 'Lakkoofsa',
      AppLanguage.am: 'ብዛት / ዝርዝር',
    },
    'amountColLabel': {
      AppLanguage.en: 'Amount (ETB)',
      AppLanguage.om: 'Hanga (ETB)',
      AppLanguage.am: 'መጠን (ETB)',
    },
    'weeklyTotalLabel': {
      AppLanguage.en: 'Weekly Total',
      AppLanguage.om: 'Ida\'ama Torbanii',
      AppLanguage.am: 'ሳምንታዊ ድምር',
    },
    'reconcileAndCloseShift': {
      AppLanguage.en: 'Reconcile cash drawer & close shift',
      AppLanguage.om: 'Qarshii kaazinaa wal-simsiisii shiftii cufi',
      AppLanguage.am: 'የካዝናውን ሂሳብ አስታርቀህ ፈረቃውን ዝጋ',
    },
    'carpetDeliveryOptionsTitle': {
      AppLanguage.en: 'Carpet Cleaning Service Options',
      AppLanguage.om: 'Filannoo Tajaajila Dhiqannaa Firaashii',
      AppLanguage.am: 'የምንጣፍ እጥበት አገልግሎት አማራጮች',
    },
    'carpetTrustFooter': {
      AppLanguage.en: 'Professional Carpet Cleaning • Fast Drying & Delivery',
      AppLanguage.om: 'Dhiqannaa Firaashii Qulqullina Qabu • Gogsuu fi Geessuu Saffisaa',
      AppLanguage.am: 'ፕሮፌሽናል የምንጣፍ እጥበት • ፈጣን ማድረቅና ማድረስ',
    },
    'dayShiftClosingSubtitle': {
      AppLanguage.en: 'Reconcile day shift sales, commissions & cash drawer',
      AppLanguage.om: 'Gurgurtaa shiftii guyyaa, komishinii fi qarshii kaazinaa wal-simsiisi',
      AppLanguage.am: 'የቀን ፈረቃ ሽያጭን፣ ኮሚሽንን እና የካዝናውን ጥሬ ገንዘብ ያስታርቁ',
    },
    'remainingCashInDrawerLabel': {
      AppLanguage.en: 'Remaining Cash Balance in Drawer:',
      AppLanguage.om: 'Qarshii Kaazinaa Keessaa Hafe:',
      AppLanguage.am: 'በካዝና ውስጥ የቀረ ጥሬ ገንዘብ:',
    },
    'sendManagerOtpSub': {
      AppLanguage.en: 'Generates a 4-digit OTP request for Operational Manager to verify drawer cash.',
      AppLanguage.om: 'Koodii OTP dijitii 4 Hojii Geggeessaan qarshii akka mirkaneessuuf uuma.',
      AppLanguage.am: 'ስራ አስኪያጁ ጥሬ ገንዘቡን እንዲያረጋግጥ ባለ 4 አሃዝ OTP ጥያቄ ያመነጫል።',
    },
    'basePrice': {
      AppLanguage.en: 'Base Price',
      AppLanguage.om: 'Gatii Bu\'uuraa',
      AppLanguage.am: 'መሰረታዊ ዋጋ',
    },
    'deliveryAddonFeeLabel': {
      AppLanguage.en: 'Delivery / Service Add-on',
      AppLanguage.om: 'Kaffaltii Dabalataa Geessuu',
      AppLanguage.am: 'የማድረስ ተጨማሪ ክፍያ',
    },
    'deliveryAddonIncluded': {
      AppLanguage.en: 'Includes delivery add-on',
      AppLanguage.om: 'Kaffaltiin geessuu itti dabalameera',
      AppLanguage.am: 'የማድረስ ተጨማሪ ክፍያ ተካትቷል',
    },
    'carWashDeliveryFeesTitle': {
      AppLanguage.en: 'Car Wash Delivery Add-on Fees',
      AppLanguage.om: 'Kaffaltii Dabalataa Geessuu Konkolaataa',
      AppLanguage.am: 'የመኪና ማጠብ የማድረስ ተጨማሪ ክፍያዎች',
    },
    'carpetDeliveryFeesTitle': {
      AppLanguage.en: 'Carpet Delivery Add-on Fees (Once Per Order)',
      AppLanguage.om: 'Kaffaltii Dabalataa Geessuu Firaashii (Ajaja Tokkotti)',
      AppLanguage.am: 'የምንጣፍ ማድረስ ተጨማሪ ክፍያዎች (በአንድ ትዕዛዝ)',
    },
    'oncePerOrderTag': {
      AppLanguage.en: 'Once per order',
      AppLanguage.om: 'Ajaja tokkotti al tokko',
      AppLanguage.am: 'በአንድ ትዕዛዝ አንድ ጊዜ',
    },
    'baseStationRatePerSqm': {
      AppLanguage.en: 'Base At-Station Rate / m²',
      AppLanguage.om: 'Gatii Bu\'uuraa Buufataa / m²',
      AppLanguage.am: 'መሰረታዊ የጣቢያ ዋጋ / ካሬ ሜትር',
    },
    'negotiatedTotalPriceTitle': {
      AppLanguage.en: 'Negotiated Final Price (ETB)',
      AppLanguage.om: 'Gatii Xumuraa Waliigaltee (ETB)',
      AppLanguage.am: 'የተስማሙበት የመጨረሻ ዋጋ (ብር)',
    },
    'assignWasherDuringBooking': {
      AppLanguage.en: 'Assign Washer (Tips go 100% to assigned washer)',
      AppLanguage.om: 'Dhiqaa Ramadi (Tippiin 100% isaaf kenna)',
      AppLanguage.am: 'አጣቢ ይመድቡ (ቲፕ 100% ለተመደበው አጣቢ ይሆናል)',
    },
    'noWasherAssignedOption': {
      AppLanguage.en: 'Assign Later / No Washer Selected',
      AppLanguage.om: 'Booda Ramadi / Hin Filatamne',
      AppLanguage.am: 'በኋላ ይመደብ / አጣቢ አልተመረጠም',
    },
    'vatDeduction15Label': {
      AppLanguage.en: 'Less: 15% VAT (Wash & Delivery)',
      AppLanguage.om: 'Hir\'isa: VAT 15% (Dhiqaa fi Geessuu)',
      AppLanguage.am: 'ተቀናሽ: 15% ተ.እ.ታ (እጥበት እና ማድረስ)',
    },
    'netTaxableWashRevenue': {
      AppLanguage.en: 'Net Revenue (Excl. 15% VAT)',
      AppLanguage.om: 'Galii Qulqulluu (VAT 15% Booda)',
      AppLanguage.am: 'የተጣራ ገቢ (15% ተ.እ.ታ ከተቀነሰ በኋላ)',
    },
    'directAssignedTip': {
      AppLanguage.en: 'Direct Tip',
      AppLanguage.om: 'Tippii Kallattii',
      AppLanguage.am: 'ቀጥተኛ ቲፕ',
    },
    'newOnlineBookingAlertTitle': {
      AppLanguage.en: 'New Online Booking Received!',
      AppLanguage.om: 'Ajajni Toora Interneetii Haaraan Dhufeera!',
      AppLanguage.am: 'አዲስ የኦንላይን ትዕዛዝ ደርሷል!',
    },
    'acknowledgeAlert': {
      AppLanguage.en: 'Dismiss',
      AppLanguage.om: 'Cufi',
      AppLanguage.am: 'አጥፋ',
    },
    'deliveryModeLabel': {
      AppLanguage.en: 'Service Delivery Mode',
      AppLanguage.om: 'Haala Kenniinsa Tajaajilaa',
      AppLanguage.am: 'የአገልግሎት አሰጣጥ ሁኔታ',
    },
    'loadOlderBookings': {
      AppLanguage.en: 'Load Older Bookings',
      AppLanguage.om: 'Galmee Dursa Dhufe Fe\'i',
      AppLanguage.am: 'የቀደሙ መዝገቦችን ጫን',
    },
    'loadedOlderBookingsPrefix': {
      AppLanguage.en: 'Loaded',
      AppLanguage.om: 'Fe\'ameera',
      AppLanguage.am: 'ተጭነዋል',
    },
    'loadedOlderBookingsSuffix': {
      AppLanguage.en: 'older bookings',
      AppLanguage.om: 'galmeewwan dursa',
      AppLanguage.am: 'የቀደሙ መዝገቦች',
    },
    'noMoreOlderBookings': {
      AppLanguage.en: 'All historical bookings loaded',
      AppLanguage.om: 'Galmeen seenaa hundi fe\'ameera',
      AppLanguage.am: 'ሁሉም ታሪካዊ መዝገቦች ተጭነዋል',
    },
    'aiExecutiveTitle': {
      AppLanguage.en: 'BISHE AI Executive',
      AppLanguage.om: 'Hogganaa AI BISHE',
      AppLanguage.am: 'የቢሼ AI ስራ አስፈፃሚ',
    },
    'aiExecutiveSub': {
      AppLanguage.en: 'Real-time operational Q&A, chemical yields, and P&L analytics',
      AppLanguage.om: 'Gaaffilee hojii battalaa, ittifayyadama saamunaa fi gabaasa bu\'aa/kisaaraa',
      AppLanguage.am: 'የእውነተኛ ጊዜ ስራዎች፣ የኬሚካል ፍጆታ እና የትርፍ/ኪሳራ ትንተና',
    },
    'askAiHint': {
      AppLanguage.en: 'Ask anything (e.g. "Today\'s P&L", "Cars washed", "Shampoo yield")...',
      AppLanguage.om: 'Waan fedhe gaafadhaa (fkn "Bu\'aa har\'aa", "Konkolaattota dhiqaman")...',
      AppLanguage.am: 'ማንኛውንም ይጠይቁ (ምሳሌ "የዛሬው ትርፍና ኪሳራ"፣ "የታጠቡ መኪኖች")...',
    },
    'aiPromptPnL': {
      AppLanguage.en: '📊 Today\'s P&L & Profit',
      AppLanguage.om: '📊 Bu\'aa & Kisaaraa Har\'aa',
      AppLanguage.am: '📊 የዛሬው ትርፍና ኪሳራ',
    },
    'aiPromptCars': {
      AppLanguage.en: '🚗 Cars Washed Today',
      AppLanguage.om: '🚗 Konkolaattota Har\'a Dhiqaman',
      AppLanguage.am: '🚗 ዛሬ የታጠቡ መኪኖች',
    },
    'aiPromptWashers': {
      AppLanguage.en: '👥 Active Washers & Commissions',
      AppLanguage.om: '👥 Hojjettoota Hojjataaniifi Komishinii',
      AppLanguage.am: '👥 ስራ ላይ ያሉ አጣቢዎችና ኮሚሽን',
    },
    'aiPromptYield': {
      AppLanguage.en: '🧼 Chemical Yield & Averages',
      AppLanguage.om: '🧼 Ittifayyadama Saamunaafi Qorichaa',
      AppLanguage.am: '🧼 የኬሚካልና ሳሙና ፍጆታ አማካይ',
    },
    'aiPromptAlerts': {
      AppLanguage.en: '⚠️ Stock & Anomaly Alerts',
      AppLanguage.om: '⚠️ Akeekkachiisa Meeshaafi Hir\'inaa',
      AppLanguage.am: '⚠️ የአላቂ ዕቃዎችና የስጋት ማሳወቂያ',
    },
    'configureApiKey': {
      AppLanguage.en: 'Configure Gemini API Key',
      AppLanguage.om: 'Furtuu Gemini API Qindeessi',
      AppLanguage.am: 'የGemini API ቁልፍ ያዘጋጁ',
    },
    'apiKeyNotice': {
      AppLanguage.en: 'Free Gemini API Key from Google AI Studio (optional for deep chat)',
      AppLanguage.om: 'Furtuu Gemini API tolaa Google AI Studio irraa',
      AppLanguage.am: 'ነጻ የGemini API ቁልፍ ከ Google AI Studio',
    },
    'getFreeKeyBtn': {
      AppLanguage.en: 'Get Free Key',
      AppLanguage.om: 'Furtuu Tolaa Fudhadhu',
      AppLanguage.am: 'ነጻ ቁልፍ ይውሰዱ',
    },
    'aiLocalEngineBadge': {
      AppLanguage.en: 'Local Station Analytics',
      AppLanguage.om: 'Xiinxala Iddoo Dhiqa',
      AppLanguage.am: 'የማዕከሉ የቀጥታ ትንተና',
    },
    'aiCloudEngineBadge': {
      AppLanguage.en: 'Gemini AI Cloud',
      AppLanguage.om: 'Gemini AI Duumessa',
      AppLanguage.am: 'የGemini AI ደመና',
    },
    'aiThinking': {
      AppLanguage.en: 'Analyzing station data...',
      AppLanguage.om: 'Ragaa iddoo dhiqa xiinxalaa jira...',
      AppLanguage.am: 'የማዕከሉን መረጃ በመተንተን ላይ...',
    },
    'clearChat': {
      AppLanguage.en: 'Clear Chat',
      AppLanguage.om: 'Haquu',
      AppLanguage.am: 'ውይይት አጽዳ',
    },
    'aiWelcomeMessage': {
      AppLanguage.en: '👋 Hello! I am your BISHE AI Operations Executive. Ask me anything about today\'s cars, washer commissions, chemical yields (shampoo & perfume averages), or station P&L.',
      AppLanguage.om: '👋 Akkam! Ani Gargaaraa Hojii AI BISHE ti. Waa\'ee konkolaattota har\'aa, komishinii dhiqxootaa, ittifayyadama saamunaafi qorichaa ykn bu\'aafi kisaaraa na gaafachuu dandeessu.',
      AppLanguage.am: '👋 ጤና ይስጥልኝ! እኔ የቢሼ AI ስራ አስፈፃሚ ነኝ። ስለ ዛሬ የታጠቡ መኪኖች፣ የአጣቢዎች ኮሚሽን፣ የኬሚካል ፍጆታ (የሻምፑና የሽቶ አማካይ) ወይም ስለ ትርፍና ኪሳራ ማንኛውንም ይጠይቁኝ።',
    },
    'aiListen': {
      AppLanguage.en: 'Listen',
      AppLanguage.om: 'Dhaggeeffadhu',
      AppLanguage.am: 'አዳምጥ',
    },
    'aiStopAudio': {
      AppLanguage.en: 'Stop Audio',
      AppLanguage.om: 'Sagalee Dhaabi',
      AppLanguage.am: 'ድምፅ አቁም',
    },
    'aiVoiceMode': {
      AppLanguage.en: 'Voice Narration',
      AppLanguage.om: 'Ibsa Sagalee',
      AppLanguage.am: 'የድምፅ ንባብ',
    },
    'aiMicListening': {
      AppLanguage.en: 'Listening...',
      AppLanguage.om: 'Dhaggeeffachaa jira...',
      AppLanguage.am: 'እያዳመጠ ነው...',
    },
    'aiMicTooltip': {
      AppLanguage.en: 'Speak with microphone',
      AppLanguage.om: 'Maayikiroofooniin dubbadhu',
      AppLanguage.am: 'በማይክሮፎን ተናገር',
    },
    'aiExportCsv': {
      AppLanguage.en: 'Export CSV',
      AppLanguage.om: 'CSV Baasi',
      AppLanguage.am: 'CSV ላክ',
    },
    'aiCopyTable': {
      AppLanguage.en: 'Copy Table',
      AppLanguage.om: 'Gabatee Waraabi',
      AppLanguage.am: 'ሰንጠረዥ ቅዳ',
    },
    'aiCopyAll': {
      AppLanguage.en: 'Copy Text',
      AppLanguage.om: 'Barreeffama Waraabi',
      AppLanguage.am: 'ጽሁፍ ቅዳ',
    },
    'aiCopiedToast': {
      AppLanguage.en: 'Copied to clipboard!',
      AppLanguage.om: 'Gara gabatee waraabbiitti kophameera!',
      AppLanguage.am: 'ወደ ቅንጥብ ሰሌዳ ተቀድቷል!',
    },
    'aiExportSuccess': {
      AppLanguage.en: 'CSV exported & copied to clipboard!',
      AppLanguage.om: 'Galmeen CSV kophamee baafameera!',
      AppLanguage.am: 'CSV በተሳካ ሁኔታ ተዘጋጅቷል ወደ ቅንጥብ ሰሌዳ ተቀድቷል!',
    },
    'aiTableHint': {
      AppLanguage.en: 'Swipe ↔ to view table',
      AppLanguage.om: 'Gabatee arguuf gara cinaatti dhiibi ↔',
      AppLanguage.am: 'ሰንጠረዥ ለማየት ወደ ጎን ያንሸራትቱ ↔',
    },
    'aiConciergeTitle': {
      AppLanguage.en: 'BISHE AI Concierge',
      AppLanguage.om: 'Tajaajila AI BISHE',
      AppLanguage.am: 'የቢሼ AI እንግዳ ተቀባይ',
    },
    'aiConciergeSub': {
      AppLanguage.en: 'Instant price estimates, package guidance, EV care, and live queue status',
      AppLanguage.om: 'Tilmaama gatii battalaa, qajeelfama paakeejii fi dabaree dhiqa',
      AppLanguage.am: 'የዋጋ ግምት፣ የፓኬጅ ማብራሪያ፣ የኤሌክትሪክ መኪና እንክብካቤ እና የተራ ሁኔታ',
    },
    'aiCustomerWelcomeMessage': {
      AppLanguage.en: '👋 Welcome to BISHE Car Wash! I am your AI Concierge. Ask me about our wash packages, prices, EV safety, carpet cleaning, or current bay wait times.',
      AppLanguage.om: '👋 Baga nagaan dhuftan gara Dhiqa Konkolaataa BISHE! Ani gargaaraa AI keessani. Waa\'ee paakeejii dhiqa, gatii, eegumsa konkolaataa elektiriikii ykn dabaree na gaafadhaa.',
      AppLanguage.am: '👋 ወደ ቢሼ መኪና ማጠቢያ እንኳን ደህና መጡ! እኔ የ AI እንግዳ ተቀባይ ነኝ። ስለ ማጠቢያ ፓኬጆቻችን፣ ዋጋዎች፣ የኤሌክትሪክ መኪናዎች ደህንነት፣ ምንጣፍ እጥበት ወይም የተራ ጊዜ ማንኛውንም ይጠይቁኝ።',
    },
    'askAiCustomerHint': {
      AppLanguage.en: 'Ask anything (e.g. "SUV wash price?", "Silver vs Gold?", "Wait time right now?")...',
      AppLanguage.om: 'Waan fedhe gaafadhaa (fkn "Gatiin SUV meeqa?", "Silver moo Gold?", "Yeroon eegumsaa meeqa?")...',
      AppLanguage.am: 'ማንኛውንም ይጠይቁ (ምሳሌ "የSUV እጥበት ስንት ነው?"፣ "ሲልቨር ወይስ ጎልድ?"፣ "አሁን ያለው ተራ ስንት ነው?")...',
    },
    'askBisheAiConcierge': {
      AppLanguage.en: 'Ask BISHE AI Concierge',
      AppLanguage.om: 'AI BISHE Gaafadhaa',
      AppLanguage.am: 'የቢሼ AI እንግዳ ተቀባይን ይጠይቁ',
    },
    'aiConciergeBannerSub': {
      AppLanguage.en: 'Need price estimates, wait times, or service advice? Chat now',
      AppLanguage.om: 'Tilmaama gatii, yeroo eegumsaa ykn gorsa barbaaddu? Amma haasa\'aa',
      AppLanguage.am: 'የዋጋ ግምት፣ የተራ ጊዜ ወይም የማጠቢያ ምክር ይፈልጋሉ? አሁን ይጠይቁ',
    },
    'aiPromptCustomerPackages': {
      AppLanguage.en: '✨ Packages & Pricing',
      AppLanguage.om: '✨ Paakeejii & Gatii',
      AppLanguage.am: '✨ የፓኬጅ ዓይነቶችና ዋጋ',
    },
    'aiPromptCustomerWaitTime': {
      AppLanguage.en: '⏱️ Live Queue & Wait Time',
      AppLanguage.om: '⏱️ Dabaree & Yeroo Eegumsaa',
      AppLanguage.am: '⏱️ የቀጥታ ተራና የጥበቃ ጊዜ',
    },
    'aiPromptCustomerEvSafety': {
      AppLanguage.en: '⚡ EV & High-Pressure Safety',
      AppLanguage.om: '⚡ Eegumsa Konkolaataa Elektiriikii',
      AppLanguage.am: '⚡ የኤሌክትሪክ መኪና ደህንነት',
    },
    'aiPromptCustomerCarpet': {
      AppLanguage.en: '🏠 Carpet Wash & Delivery',
      AppLanguage.om: '🏠 Dhiqa Afataafi Geessuu',
      AppLanguage.am: '🏠 የምንጣፍ እጥበትና ትራንስፖርት',
    },
    'aiPromptCustomerShower': {
      AppLanguage.en: '🚿 Clean Hot Showers',
      AppLanguage.om: '🚿 Dhiqannaa Qaamaa Qulqulluu',
      AppLanguage.am: '🚿 ዘመናዊ የሙቅ ውሃ ሻወር',
    },
    'aiPromptBaySpeed': {
      AppLanguage.en: '⚡ Bay Turnaround & Queue',
      AppLanguage.om: '⚡ Saffisa Dabaree & Iddoo Dhiqa',
      AppLanguage.am: '⚡ የማጠቢያ ቦታዎች ፍጥነትና ተራ',
    },
    'aiPromptOtpStatus': {
      AppLanguage.en: '🔐 OTP Shift Handover Status',
      AppLanguage.om: '🔐 Haala OTP Wal-Harkaa Fuudhiinsa Shiftii',
      AppLanguage.am: '🔐 የፈረቃ ርክክብ OTP ሁኔታ',
    },
    'aiPromptWasherPairs': {
      AppLanguage.en: '👥 Washer Pairs & Bay Roster',
      AppLanguage.om: '👥 Ramaddii Cimdii Hojjettootaa',
      AppLanguage.am: '👥 የአጣቢ ጥንዶችና የስራ ድልድል',
    },
    'aiPromptUnsettled': {
      AppLanguage.en: '⏳ Unsettled & Pending Tickets',
      AppLanguage.om: '⏳ Tikkeettii Hin Kaffalamne',
      AppLanguage.am: '⏳ ያልተከፈሉና በመጠባበቅ ያሉ ቲኬቶች',
    },
    'aiPromptShowersCount': {
      AppLanguage.en: '🚿 Today\'s Shower Revenue',
      AppLanguage.om: '🚿 Galii Dhiqannaa Har\'aa',
      AppLanguage.am: '🚿 የዛሬው የሻወር ገቢ',
    },
    'aiPromptCashDrawer': {
      AppLanguage.en: '💵 Drawer Cash & Handover',
      AppLanguage.om: '💵 Qarshii Kaazinaafi Wal-Harkaa Fuudhiinsa',
      AppLanguage.am: '💵 የካዝና ጥሬ ገንዘብና ርክክብ',
    },
    'aiPromptEmptyExchange': {
      AppLanguage.en: '🔄 Empty Return (ዕቃ በዕቃ)',
      AppLanguage.om: '🔄 Qodaa Duudaa Deebisuu',
      AppLanguage.am: '🔄 ዕቃ በዕቃ ቅያሪ',
    },
    'aiPromptAssetHealth': {
      AppLanguage.en: '🛠️ Machinery & Asset Health',
      AppLanguage.om: '🛠️ Fayyummaa Maashinootaa',
      AppLanguage.am: '🛠️ የማሽኖችና ቋሚ ዕቃዎች ጤንነት',
    },
    'aiPromptConsumableReorder': {
      AppLanguage.en: '📦 Low Stock & Re-Order',
      AppLanguage.om: '📦 Hir\'ina Meeshaafi Ajajuu',
      AppLanguage.am: '📦 የአላቂ ዕቃዎች እጥረትና ማዘዣ',
    },
    'aiPromptBankReconciliation': {
      AppLanguage.en: '🏦 Bank Deposit Slips Audit',
      AppLanguage.om: '🏦 Qorannoo Nagahee Baankii',
      AppLanguage.am: '🏦 የባንክ ተቀማጭ ደረሰኞች ማረጋገጫ',
    },
    'aiPromptVatSummary': {
      AppLanguage.en: '📑 15% VAT vs 0% Exempt Shower',
      AppLanguage.om: '📑 VAT 15% fi Dhiqannaa 0%',
      AppLanguage.am: '📑 15% ቫት እና ከቫት ነጻ ሻወር',
    },
    'aiQueryCustomerPackages': {
      AppLanguage.en: 'What wash packages do you offer and what are the prices?',
      AppLanguage.om: 'Paakeejiiwwan dhiqaafi gatii isaanii natti himaa',
      AppLanguage.am: 'የማጠቢያ ፓኬጆችንና ዋጋቸውን ንገሩኝ',
    },
    'aiQueryCustomerWaitTime': {
      AppLanguage.en: 'How busy are the bays right now and what is the wait time?',
      AppLanguage.om: 'Amma dabareefi yeroon eegumsaa akkam jira?',
      AppLanguage.am: 'አሁን ያለው ተራ እና የጥበቃ ጊዜ ስንት ነው?',
    },
    'aiQueryCustomerEvSafety': {
      AppLanguage.en: 'Is high-pressure and steam wash safe for electric vehicles (EV)?',
      AppLanguage.om: 'Konkolaataa elektiriikii dhiquun amansiisaadhaa?',
      AppLanguage.am: 'የኤሌክትሪክ መኪና ማጠብ ደህንነቱ የተጠበቀ ነው?',
    },
    'aiQueryCustomerCarpet': {
      AppLanguage.en: 'How much is carpet washing per square meter and delivery turnaround?',
      AppLanguage.om: 'Dhiqi afataa meetira isquweeriin meeqa?',
      AppLanguage.am: 'የምንጣፍ እጥበት በካሬ ሜትር ዋጋው ስንት ነው?',
    },
    'aiQueryCustomerShower': {
      AppLanguage.en: 'Where are your clean hot showers located and what is the fee?',
      AppLanguage.om: 'Tajaajilli dhiqannaa eessatti argama kaffaltiin meeqa?',
      AppLanguage.am: 'የሻወር አገልግሎት የት ይገኛል ክፍያው ስንት ነው?',
    },
    'aiQueryPnL': {
      AppLanguage.en: 'Today\'s P&L and net profit summary',
      AppLanguage.om: 'Gabaasa bu\'aa fi kisaaraa har\'aa',
      AppLanguage.am: 'የዛሬው ትርፍና ኪሳራ ማጠቃለያ',
    },
    'aiQueryCars': {
      AppLanguage.en: 'List cars washed today and vehicle types',
      AppLanguage.om: 'Tarree konkolaattota har\'a dhiqamanii fi akaakuu isaanii',
      AppLanguage.am: 'ዛሬ የታጠቡ መኪኖች ዝርዝርና ዓይነታቸው',
    },
    'aiQueryWashers': {
      AppLanguage.en: 'Active washers on duty and their commissions',
      AppLanguage.om: 'Hojjettoota hojii irra jiranii fi komishinii isaanii',
      AppLanguage.am: 'ስራ ላይ ያሉ አጣቢዎችና ኮሚሽናቸው',
    },
    'aiQueryYield': {
      AppLanguage.en: 'Chemical yield and average shampoo and perfume used per car',
      AppLanguage.om: 'Ittifayyadama qorichaa fi giddu galeessa shaampuu fayyadamaa',
      AppLanguage.am: 'የኬሚካል ፍጆታና የሻምፑ እንዲሁም የሽቶ አማካይ',
    },
    'aiQueryAlerts': {
      AppLanguage.en: 'Check for low inventory stock and station discrepancies',
      AppLanguage.om: 'Akeekkachiisa meeshaalee fi hir\'ina iddoo dhiqa',
      AppLanguage.am: 'የአላቂ ዕቃዎች እጥረትና የስጋት ማሳወቂያዎች',
    },
    'aiQueryBaySpeed': {
      AppLanguage.en: 'Bay turnaround speed, active queue, and washer dispatch',
      AppLanguage.om: 'Saffisa dabaree, iddoowwan dhiqaafi ramaddii hojjettootaa',
      AppLanguage.am: 'የማጠቢያ ቦታዎች ፍጥነት፣ ተራና የስራ ድልድል',
    },
    'aiQueryOtpStatus': {
      AppLanguage.en: 'Status of Cashier 15:30 OTP handover and night closing',
      AppLanguage.om: 'Haala OTP dabarsa shiftii fi cufiinsa halkan',
      AppLanguage.am: 'የ15:30 ፈረቃ ርክክብ OTP እና የማታ መዝጊያ ሁኔታ',
    },
    'aiQueryWasherPairs': {
      AppLanguage.en: 'Active washer pairs distribution and commission balance',
      AppLanguage.om: 'Ramaddii cimdii hojjettootaa fi madaallii komishinii',
      AppLanguage.am: 'የአጣቢ ጥንዶች ድልድልና የኮሚሽን ሚዛን',
    },
    'aiQueryUnsettled': {
      AppLanguage.en: 'List cars in queue and unsettled vehicle tickets',
      AppLanguage.om: 'Tarree tikkeettiiwwan hin kaffalamneefi dabaree keessa jiranii',
      AppLanguage.am: 'ያልተከፈሉ ቲኬቶችና በተራ ላይ ያሉ መኪኖች',
    },
    'aiQueryShowersCount': {
      AppLanguage.en: 'Today\'s shower ticket count, cash and digital totals',
      AppLanguage.om: 'Baay\'ina tikkeettii dhiqannaa fi galii har\'aa',
      AppLanguage.am: 'የዛሬው የሻወር ቲኬት ብዛትና ጠቅላላ ገቢ',
    },
    'aiQueryCashDrawer': {
      AppLanguage.en: 'Cash drawer balance and 15:30 OTP handover preparation',
      AppLanguage.om: 'Hambaa qarshii sanduuqaa fi qophii OTP',
      AppLanguage.am: 'የካዝና ጥሬ ገንዘብና የ15:30 OTP ዝግጅት',
    },
    'aiQueryEmptyExchange': {
      AppLanguage.en: 'Empty-for-full container exchange balance and missing cans',
      AppLanguage.om: 'Qodaa duudaa deebisuu fi qorannoo qodaa',
      AppLanguage.am: 'ዕቃ በዕቃ ቅያሪ ሚዛንና የጎደሉ ዕቃዎች',
    },
    'aiQueryAssetHealth': {
      AppLanguage.en: 'Fixed asset equipment health, service due, and repairs',
      AppLanguage.om: 'Fayyummaa maashinootaa fi suphaa',
      AppLanguage.am: 'የማሽኖችና ቋሚ ዕቃዎች ጤንነት እንዲሁም ጥገና',
    },
    'aiQueryConsumableReorder': {
      AppLanguage.en: 'Consumables stock levels and low-stock re-order alerts',
      AppLanguage.om: 'Sadarkaa meeshaalee dhumoo fi ajaja haaromsaa',
      AppLanguage.am: 'የአላቂ ዕቃዎች ክምችትና የዳግም ማዘዣ ማሳወቂያ',
    },
    'aiQueryBankReconciliation': {
      AppLanguage.en: 'Bank deposit slips vs cashier drawer settlements audit',
      AppLanguage.om: 'Qorannoo nagahee baankii fi herrega kaashiyaraa',
      AppLanguage.am: 'የባንክ ተቀማጭ ደረሰኞችና የካሺየር ሂሳብ ማረጋገጫ',
    },
    'aiPromptCustomerLoyalty': {
      AppLanguage.en: '🎁 Loyalty Pass & Rewards',
      AppLanguage.om: '🎁 Paasii Maamilummaa & Badhaasa',
      AppLanguage.am: '🎁 የታማኝ ደንበኛ ፓስና ሽልማት',
    },
    'aiQueryCustomerLoyalty': {
      AppLanguage.en: 'Check my loyalty pass status and free wash eligibility',
      AppLanguage.om: 'Sadarkaa paasii maamilummaafi dhiqa tolaa naaf ilaali',
      AppLanguage.am: 'የታማኝ ደንበኛ ደረጃዬንና የነጻ እጥበት እድሌን አሳየኝ',
    },
    'aiPromptCustomerScratch': {
      AppLanguage.en: '📷 Pre-Wash Inspection',
      AppLanguage.om: '📷 Qorannoo Suuraa',
      AppLanguage.am: '📷 ከእጥበት በፊት ፍተሻ',
    },
    'aiQueryCustomerScratch': {
      AppLanguage.en: 'How does pre-wash scratch and dent photo inspection work?',
      AppLanguage.om: 'Qorannoon suuraa miidhaa duraa akkamitti hojjeta?',
      AppLanguage.am: 'ከእጥበት በፊት የጭረትና ጉዳት ፎቶ ፍተሻ እንዴት ይሰራል?',
    },
    'aiWatchdogAlertsActive': {
      AppLanguage.en: '⚠️ Station Watchdog: {count} Operational Alerts',
      AppLanguage.om: '⚠️ Hordoffii Buufataa: Akeekkachiisa Hojii {count}',
      AppLanguage.am: '⚠️ የማዕከሉ ንቁ ጠባቂ፡ {count} የስራ ማስጠንቀቂያዎች አሉ',
    },
    'aiWatchdogBannerAction': {
      AppLanguage.en: 'Explain & Fix',
      AppLanguage.om: 'Ibsi & Furi',
      AppLanguage.am: 'አብራራና መፍትሔ ስጥ',
    },
    'aiPromptWatchdog': {
      AppLanguage.en: '⚠️ Watchdog Health Audit',
      AppLanguage.om: '⚠️ Qorannoo Eegumsa Buufataa',
      AppLanguage.am: '⚠️ የማዕከሉ ንቁ የደህንነት ፍተሻ',
    },
    'aiQueryWatchdog': {
      AppLanguage.en: 'Run Station Watchdog audit for bottlenecks, low stock, and shift handovers',
      AppLanguage.om: 'Akeekkachiisa dhiphina iddoo dhiqa, hir\'ina meeshaalee fi dabarsa shiftii qoradhu',
      AppLanguage.am: 'የቦታዎች መዘግየት፣ የአላቂ ዕቃዎች እጥረትና የፈረቃ ርክክብ የስጋት ፍተሻ አድርግ',
    },

    'editBooking': {
      AppLanguage.en: 'Edit Booking',
      AppLanguage.om: 'Qabiyyee Fooyyessi',
      AppLanguage.am: 'ቦታ ማስያዣውን አስተካክል',
    },
    'cancelBooking': {
      AppLanguage.en: 'Cancel Booking',
      AppLanguage.om: 'Qabiyyee Haqii',
      AppLanguage.am: 'ቦታ ማስያዣውን ሰርዝ',
    },
    'confirmCancelBookingMsg': {
      AppLanguage.en: 'Are you sure you want to cancel and remove this booking from the queue? Any assigned bay will be released immediately.',
      AppLanguage.om: 'Qabiyyee kana sarara irraa haquu fi bakka dhiqannaa bilisa gochuu barbaadduu?',
      AppLanguage.am: 'እርግጠኛ ነዎት ይህንን ቦታ ማስያዣ ከሰልፉ መሰረዝ እና የተመደበውን የውሃ ማጠቢያ ክፍል መልቀቅ ይፈልጋሉ?',
    },
    'bookingCancelledToast': {
      AppLanguage.en: 'Booking cancelled and bay released.',
      AppLanguage.om: 'Qabiyyeen haqameera, bakki dhiqannaa bilisa ta\'eera.',
      AppLanguage.am: 'ቦታ ማስያዣው ተሰርዟል፣ የውሃ ማጠቢያ ክፍሉም ነፃ ሆኗል።',
    },
    'bookingUpdatedToast': {
      AppLanguage.en: 'Booking details updated successfully.',
      AppLanguage.om: 'Odeeffannoon qabiyyee milkaa\'inaan haaromfameera.',
      AppLanguage.am: 'የቦታ ማስያዣ መረጃ በተሳካ ሁኔታ ተስተካክሏል።',
    },
    'recordDeletedToast': {
      AppLanguage.en: 'Record deleted successfully.',
      AppLanguage.om: 'Galmeen milkaa\'inaan haqameera.',
      AppLanguage.am: 'መዝገቡ በተሳካ ሁኔታ ተሰርዟል።',
    },
    'takePhoto': {
      AppLanguage.en: 'Take a Photo',
      AppLanguage.om: 'Suuraa Kaasi',
      AppLanguage.am: 'ፎቶ አንሳ',
    },
    'uploadPhoto': {
      AppLanguage.en: 'Upload Photo',
      AppLanguage.om: 'Suuraa Olfe\'i',
      AppLanguage.am: 'ፎቶ ስቀል',
    },
    'optional': {
      AppLanguage.en: 'Optional',
      AppLanguage.om: 'Dirqama Miti',
      AppLanguage.am: 'አማራጭ',
    },
    'recentShowerEntries': {
      AppLanguage.en: 'Recent Shower Entries',
      AppLanguage.om: 'Galmee Dhiqannaa Qaamaa Dhihoo',
      AppLanguage.am: 'የቅርብ ጊዜ የሻወር መዝገቦች',
    },
    'editRecord': {
      AppLanguage.en: 'Edit Record',
      AppLanguage.om: 'Galmee Fooyyessi',
      AppLanguage.am: 'መዝገብ አስተካክል',
    },
    'deleteRecord': {
      AppLanguage.en: 'Delete Record',
      AppLanguage.om: 'Galmee Haqii',
      AppLanguage.am: 'መዝገብ ሰርዝ',
    },
    'saveChanges': {
      AppLanguage.en: 'Save Changes',
      AppLanguage.om: 'Jijjiirama Galmeessi',
      AppLanguage.am: 'ለውጦችን መዝግብ',
    },
    'rapidRefillTab': {
      AppLanguage.en: 'Rapid Refill (ዕቃ በዕቃ)',
      AppLanguage.om: 'Bakka Buusa Saffisaa (ዕቃ በዕቃ)',
      AppLanguage.am: 'ፈጣን ዕቃ በዕቃ መመዝገቢያ',
    },
    'storeroomStockTab': {
      AppLanguage.en: 'Storeroom Stock (ክምችት)',
      AppLanguage.om: 'Kuusaa Meeshaalee',
      AppLanguage.am: 'አጠቃላይ የመጋዘን ክምችት',
    },
    'fixedAssetsTab': {
      AppLanguage.en: 'Fixed Assets (ቋሚ እቃዎች)',
      AppLanguage.om: 'Qabeenya Dhaabbataa',
      AppLanguage.am: 'ቋሚ ንብረቶችና ማሽኖች',
    },
    'fastTurnoverItems': {
      AppLanguage.en: 'Fast-Turnover Items (Rapid Exchanges)',
      AppLanguage.om: 'Meeshaalee Saffisaan Dhumatan',
      AppLanguage.am: 'ፈጣን አላቂ እቃዎች (ዕለታዊ ቅያሬ)',
    },
    'slowTurnoverItems': {
      AppLanguage.en: 'Slow-Moving / Detailing Items',
      AppLanguage.om: 'Meeshaalee Suuta Dhumatan',
      AppLanguage.am: 'ዝግተኛ አላቂ / የዲቴይሊንግ እቃዎች',
    },
    'confirmExchangeBtn': {
      AppLanguage.en: 'Confirm Exchange (Received Empty & Issued Full)',
      AppLanguage.om: 'Jijjiirraa Mirkaneessi (Qullaa Fudhadhee Guutuu Kennuu)',
      AppLanguage.am: 'ቅያሬ አረጋግጥ (ዕቃ ተረክቤ ሰጥቻለሁ)',
    },
    'receiverLabel': {
      AppLanguage.en: 'Receiver / Head Washer',
      AppLanguage.om: 'Fudhataa / Hojjetaa Dhiqa',
      AppLanguage.am: 'ተረካቢ / የዋሸሮች ኃላፊ',
    },
    'todayExchangesTitle': {
      AppLanguage.en: "Today's Returned Empties & Exchanges",
      AppLanguage.om: 'Jijjiirraa fi Qullaa Har\'aa Deebi\'an',
      AppLanguage.am: 'የዛሬ የተመለሱ ባዶዎችና የዕቃ ቅያሬ መዝገብ',
    },
    'receiveDeliveryBtn': {
      AppLanguage.en: 'Receive Delivery',
      AppLanguage.om: 'Meeshaa Haaraa Fudhadhu',
      AppLanguage.am: 'ዕቃ መረከቢያ',
    },
    'undoExchange': {
      AppLanguage.en: 'Undo Exchange',
      AppLanguage.om: 'Jijjiirraa Basi',
      AppLanguage.am: 'ቅያሬ ሰርዝ (Undo)',
    },
    'undoExchangeConfirm': {
      AppLanguage.en: 'Undo this exchange and restore stock to warehouse?',
      AppLanguage.om: 'Jijjiirraa kana haquun kuusaatti deebisuu barbaaddaa?',
      AppLanguage.am: 'ይህን የዕቃ ቅያሬ ሰርዘው ክምችቱን ወደ መጋዘን መመለስ ይፈልጋሉ?',
    },
    'itemOperational': {
      AppLanguage.en: 'Operational',
      AppLanguage.om: 'Hojii irra jira',
      AppLanguage.am: 'ሰላም ነው (በስራ ላይ)',
    },
    'itemNeedsRepair': {
      AppLanguage.en: 'Needs Repair',
      AppLanguage.om: 'Suphaa barbaada',
      AppLanguage.am: 'ጥገና ያስፈልገዋል',
    },
    'markNeedsRepair': {
      AppLanguage.en: 'Flag Needs Repair',
      AppLanguage.om: 'Suphaa Barbaada Jedhi',
      AppLanguage.am: 'ብልሽት መዝግብ',
    },
    'markOperational': {
      AppLanguage.en: 'Mark Operational',
      AppLanguage.om: 'Hojii Irra Jira Jedhi',
      AppLanguage.am: 'ተጠግኗል / ሰላም ነው በል',
    },
    'quantityExchanged': {
      AppLanguage.en: 'Quantity',
      AppLanguage.om: 'Baay\'ina',
      AppLanguage.am: 'ብዛት',
    },
    'searchInventoryHint': {
      AppLanguage.en: 'Search items by name or code...',
      AppLanguage.om: 'Maqaa ykn koodiin barbaadi...',
      AppLanguage.am: 'በስም ወይም በኮድ ፈልግ...',
    },
    'healthyStock': {
      AppLanguage.en: 'Healthy Stock',
      AppLanguage.om: 'Sadarkaa Gaarii',
      AppLanguage.am: 'በቂ ክምችት',
    },
    'reorderAlert': {
      AppLanguage.en: 'Reorder Alert',
      AppLanguage.om: 'Akeekkachiisa Dhumachuu',
      AppLanguage.am: 'የማዘዣ ማስጠንቀቂያ',
    },
    'exchangeSuccessMsg': {
      AppLanguage.en: 'Successfully recorded exchange! Stock updated.',
      AppLanguage.om: 'Jijjiirraan milkaa\'inaan galmaa\'eera!',
      AppLanguage.am: 'የዕቃ በዕቃ ቅያሬው በተሳካ ሁኔታ ተመዝግቧል!',
    },
    'undoSuccessMsg': {
      AppLanguage.en: 'Exchange successfully undone. Stock restored.',
      AppLanguage.om: 'Jijjiirraan haqamee kuusaan deebi\'eera.',
      AppLanguage.am: 'ቅያሬው ተሰርዞ ክምችቱ ወደ መጋዘን ተመልሷል።',
    },
    'issueInitialFloat': {
      AppLanguage.en: 'Issue Initial Working Float / Supplies',
      AppLanguage.om: 'Meeshaalee Jalqabaa Hojii Kenni',
      AppLanguage.am: 'የመጀመሪያ የሥራ ዕቃ ማውጫ',
    },
    'allFixedAssetsCount': {
      AppLanguage.en: 'All Machinery & Equipment',
      AppLanguage.om: 'Maashinoota fi Meeshaalee Hunda',
      AppLanguage.am: 'ሁሉም ማሽኖችና መሳሪያዎች',
    },
    'fastRefillSubtitle': {
      AppLanguage.en: 'Quick empty-for-full container exchange with Head Washer',
      AppLanguage.om: 'Jijjiirraa saffisaa qullaa-guutuutti hojjetaa dhiqa wajjin',
      AppLanguage.am: 'ከዋሸሮች ኃላፊ ጋር የሚደረግ ፈጣን የባዶና ሙሉ ዕቃ ቅያሬ',
    },
    'inStoreStock': {
      AppLanguage.en: 'in store',
      AppLanguage.om: 'kuusaa keessa',
      AppLanguage.am: 'በመጋዘን',
    },
    'outOfStock': {
      AppLanguage.en: 'Out of Stock',
      AppLanguage.om: 'Kuusaan dhumatee',
      AppLanguage.am: 'ክምችት አልቋል',
    },
    'editAssetDetails': {
      AppLanguage.en: 'Edit Details / Location',
      AppLanguage.om: 'Ibsa / Bakka Fooyyessi',
      AppLanguage.am: 'ዝርዝር መረጃ / ቦታ አስተካክል',
    },
    'stepperDone': {
      AppLanguage.en: 'DONE',
      AppLanguage.om: 'XUMURAMEERA',
      AppLanguage.am: 'ተጠናቋል',
    },
    'stepperCurrent': {
      AppLanguage.en: 'CURRENT',
      AppLanguage.om: 'HOJJETAMAA JIRA',
      AppLanguage.am: 'በሂደት ላይ',
    },
    'stepperStep': {
      AppLanguage.en: 'STEP',
      AppLanguage.om: 'SADARKAA',
      AppLanguage.am: 'ደረጃ',
    },
    'phaseCounter': {
      AppLanguage.en: 'Phase',
      AppLanguage.om: 'Marsaa',
      AppLanguage.am: 'ምዕራፍ',
    },
    'ofTotal': {
      AppLanguage.en: 'of',
      AppLanguage.om: 'keessaa',
      AppLanguage.am: 'ከ',
    },
    'liveBadge': {
      AppLanguage.en: 'LIVE',
      AppLanguage.om: 'KALLATTII',
      AppLanguage.am: 'ቀጥታ',
    },
    'pendingStep': {
      AppLanguage.en: 'Pending Step',
      AppLanguage.om: 'Sadarkaa Eeggatu',
      AppLanguage.am: 'ተራ የሚጠብቅ ደረጃ',
    },
    'stationHoursDaily': {
      AppLanguage.en: 'Open daily 7:00 AM - 8:00 PM',
      AppLanguage.om: "Guyyaa hundumaa sa'aatii 1:00 - 2:00 banaadha",
      AppLanguage.am: 'በየቀኑ ከጠዋቱ 1:00 - ማታ 2:00 ክፍት ነው',
    },
    'viewDigitalReceipt': {
      AppLanguage.en: 'View Digital Receipt',
      AppLanguage.om: 'Nagahee Dijitaalaa Ilaali',
      AppLanguage.am: 'ዲጂታል ደረሰኝ ይመልከቱ',
    },
    'digitalReceiptTitle': {
      AppLanguage.en: 'Digital Receipt & Payment Voucher',
      AppLanguage.om: 'Nagahee Dijitaalaa fi Ragaa Kaffaltii',
      AppLanguage.am: 'ዲጂታል ደረሰኝ እና የክፍያ ማረጋገጫ',
    },
    'paymentVerifiedBadge': {
      AppLanguage.en: 'Verified Paid',
      AppLanguage.om: "Kaffaltiin Mirkanaa'e",
      AppLanguage.am: 'ክፍያው ተረጋግጧል',
    },
    'offlineNotice': {
      AppLanguage.en: 'Connection Unavailable',
      AppLanguage.om: 'Koonneekshiniin Hin Jiru',
      AppLanguage.am: 'የኔትወርክ ግንኙነት የለም',
    },
    'callStationDirect': {
      AppLanguage.en: 'Call Bishoftu Station directly at 0910046553 to book your wash',
      AppLanguage.om: 'Dhiqannaa keessan qabachuuf kallattiin Buufata Bishooftuu 0910046553 irratti bilbilaa',
      AppLanguage.am: 'እጥበትዎን ለማስያዝ በቀጥታ ወደ ቢሾፍቱ ጣቢያ በ 0910046553 ይደውሉ',
    },
    'offlineCachedStatus': {
      AppLanguage.en: 'Offline (showing latest cached status)',
      AppLanguage.om: "Koonneekshinii malee (haala qabame mul'isa)",
      AppLanguage.am: 'ከመስመር ውጭ (የመጨረሻውን መረጃ እያሳየ ነው)',
    },
    'offlineOrderHelp': {
      AppLanguage.en: 'Network offline. Would you like to call the Bishoftu Station desk directly?',
      AppLanguage.om: 'Koonneekshiniin addaan citeera. Kallattiin minjaala Buufata Bishooftuu bilbiluu barbaadduu?',
      AppLanguage.am: 'የኔትወርክ መስመር ተቋርጧል። በቀጥታ ወደ ቢሾፍቱ ጣቢያ ቢሮ መደወል ይፈልጋሉ?',
    },
    'callStationNow': {
      AppLanguage.en: 'Call Station Desk',
      AppLanguage.om: 'Minjaala Buufataa Bilbili',
      AppLanguage.am: 'ወደ ጣቢያው ቢሮ ይደውሉ',
    },
    // ==========================================
    // Prototype Sandbox & Dual-Gateway Strings
    // ==========================================
    'bookingConfirmedTitle': {
      AppLanguage.en: 'Booking Confirmed!',
      AppLanguage.om: 'Dhiqannaan Mirkanaa\'eera!',
      AppLanguage.am: 'ትዕዛዝዎ ተረጋግጧል!',
    },
    'backBtn': {
      AppLanguage.en: 'Back',
      AppLanguage.om: 'Deebi\'i',
      AppLanguage.am: 'ተመለስ',
    },
    'selectVehicle': {
      AppLanguage.en: '1. Select Vehicle',
      AppLanguage.om: '1. Gosa Konkolaataa Filadhaa',
      AppLanguage.am: '1. የመኪና አይነት ይምረጡ',
    },
    'selectPackage': {
      AppLanguage.en: '2. Select Service Package',
      AppLanguage.om: '2. Paakeejii Dhiqannaa Filadhaa',
      AppLanguage.am: '2. የእጥበት ፓኬጅ ይምረጡ',
    },
    'ticketRef': {
      AppLanguage.en: 'Ticket Ref',
      AppLanguage.om: 'Koodii Tikkeettii',
      AppLanguage.am: 'የቲኬት ቁጥር',
    },
    'washProgressStepperTitle': {
      AppLanguage.en: 'Live Wash Progress',
      AppLanguage.om: 'Adeemsa Dhiqannaa Kallattii',
      AppLanguage.am: 'የቀጥታ እጥበት ሂደት',
    },
    'exploreStationLoungeBtn': {
      AppLanguage.en: 'Waiting for your wash? Explore Station Lounge & Reels',
      AppLanguage.om: 'Eegaa jirtuu? Boqonnaa Laawunjii & Viidiyoo Daawwadhaa',
      AppLanguage.am: 'እየጠበቁ ነው? ላውንጅ እና አጫጭር ቪዲዮዎችን ይመልከቱ',
    },
    'bookAnotherVehicleBtn': {
      AppLanguage.en: 'Book Another Vehicle',
      AppLanguage.om: 'Konkolaataa Biraa Galmeessi',
      AppLanguage.am: 'ሌላ መኪና ያስመዝግቡ',
    },
    'step1ChooseVehicle': {
      AppLanguage.en: 'Step 1: Choose Vehicle',
      AppLanguage.om: 'Tarkaanfii 1: Konkolaataa Filadhaa',
      AppLanguage.am: 'ደረጃ 1፡ የመኪና አይነት ይምረጡ',
    },
    'step1ChooseVehicleSub': {
      AppLanguage.en: 'Select your vehicle category to preview pricing.',
      AppLanguage.om: 'Gosa konkolaataa keessanii filachuun gatii ilaalaa.',
      AppLanguage.am: 'ዋጋውን ለማየት የተሽከርካሪዎን አይነት ይምረጡ።',
    },
    'nextChoosePackageBtn': {
      AppLanguage.en: 'Next: Choose Package',
      AppLanguage.om: 'Itti Fufi: Paakeejii Filadhaa',
      AppLanguage.am: 'ቀጣይ፡ ፓኬጅ ይምረጡ',
    },
    'step2ChoosePackage': {
      AppLanguage.en: 'Step 2: Wash Package',
      AppLanguage.om: 'Tarkaanfii 2: Paakeejii Dhiqannaa',
      AppLanguage.am: 'ደረጃ 2፡ የእጥበት ፓኬጅ',
    },
    'step2ChoosePackageSub': {
      AppLanguage.en: 'Select the optimal cleaning tier for your car.',
      AppLanguage.om: 'Paakeejii qulqullinaa mijataa ta\'e filadhaa.',
      AppLanguage.am: 'ለመኪናዎ ተስማሚ የሆነውን የእጥበት ደረጃ ይምረጡ።',
    },
    'nextContactDetailsBtn': {
      AppLanguage.en: 'Next: Contact Details',
      AppLanguage.om: 'Itti Fufi: Odeeffannoo Quunnamtii',
      AppLanguage.am: 'ቀጣይ፡ የእውቂያ መረጃ',
    },
    'step3ContactDetails': {
      AppLanguage.en: 'Step 3: Contact Details',
      AppLanguage.om: 'Tarkaanfii 3: Odeeffannoo Quunnamtii',
      AppLanguage.am: 'ደረጃ 3፡ የእውቂያ መረጃ',
    },
    'step3ContactDetailsSub': {
      AppLanguage.en: 'Enter your license plate and phone number.',
      AppLanguage.om: 'Lakk. Gabatee fi bilbila keessan galchaa.',
      AppLanguage.am: 'የሰሌዳ ቁጥርዎን እና ስልክዎን ያስገቡ።',
    },
    'confirmAndDriveInBtn': {
      AppLanguage.en: 'Confirm & Drive In',
      AppLanguage.om: 'Mirkaneessi & Ol Seenaa',
      AppLanguage.am: 'ያረጋግጡ እና ወደ ውስጥ ይግቡ',
    },
    'liveStationTelemetry': {
      AppLanguage.en: 'Live Station Pulse',
      AppLanguage.om: 'Haala Buufataa Kallattii',
      AppLanguage.am: 'የጣቢያው የቀጥታ ሁኔታ',
    },
    'bayAvailability': {
      AppLanguage.en: 'Bay Status',
      AppLanguage.om: 'Haala Kilaasii',
      AppLanguage.am: 'የክፍል ሁኔታ',
    },
    'estWaitTime': {
      AppLanguage.en: 'Est. Wait Time',
      AppLanguage.om: 'Turtii Tilmaamaa',
      AppLanguage.am: 'የሚገመት የጥበቃ ጊዜ',
    },
    'activeQueue': {
      AppLanguage.en: 'Active Queue',
      AppLanguage.om: 'Dabareerra Kan Jiran',
      AppLanguage.am: 'በተራ ላይ ያሉ',
    },
    'staffOnDuty': {
      AppLanguage.en: 'Washers on Duty',
      AppLanguage.om: 'Dhiqxoota Hojiirra Jiran',
      AppLanguage.am: 'በስራ ላይ ያሉ አጣቢዎች',
    },
    'expressBookingPortal': {
      AppLanguage.en: 'Express Booking Portal',
      AppLanguage.om: 'Fuula Galmee Ariifachiisaa',
      AppLanguage.am: 'ፈጣን የማስመዝገቢያ ገጽ',
    },
    'vehicleCategory': {
      AppLanguage.en: 'Vehicle Category',
      AppLanguage.om: 'Gosa Konkolaataa',
      AppLanguage.am: 'የተሽከርካሪ ምድብ',
    },
    'servicePackage': {
      AppLanguage.en: 'Service Package',
      AppLanguage.om: 'Paakeejii Tajaajilaa',
      AppLanguage.am: 'የአገልግሎት ፓኬጅ',
    },
    'calculatedTotal': {
      AppLanguage.en: 'Total Price',
      AppLanguage.om: 'Gatii Waliigalaa',
      AppLanguage.am: 'ጠቅላላ ዋጋ',
    },
    'confirmBookingBtn': {
      AppLanguage.en: 'Confirm Wash Booking',
      AppLanguage.om: 'Galmee Dhiqannaa Mirkaneessi',
      AppLanguage.am: 'የእጥበት ምዝገባውን ያረጋግጡ',
    },
    'expressWashIntakeTitle': {
      AppLanguage.en: 'Express Wash Intake',
      AppLanguage.om: 'Simannaa Dhiqannaa Saffisaa',
      AppLanguage.am: 'ፈጣን የመኪና እጥበት መግቢያ',
    },
    'instantBookAndDriveInBtn': {
      AppLanguage.en: 'Instant Book & Drive In',
      AppLanguage.om: 'Saffisaan Galmeessi & Seenaa',
      AppLanguage.am: 'አሁኑኑ ያስመዝግቡና ይግቡ',
    },
    'stationLoungeTitle': {
      AppLanguage.en: 'Station Lounge & Media',
      AppLanguage.om: 'Laawunjii Buufataa & Miidiyaa',
      AppLanguage.am: 'የጣቢያው ላውንጅ እና ሚዲያ',
    },
    'stationLoungeHeader': {
      AppLanguage.en: 'Bishe Station Lounge & Ad Hub',
      AppLanguage.om: 'Laawunjii Buufata Biishee & Beeksisa',
      AppLanguage.am: 'የቢሼ ጣቢያ ላውንጅ እና የማስታወቂያ ማዕከል',
    },
    'stationLoungeHeaderSub': {
      AppLanguage.en: 'Relax while your vehicle undergoes premier auto care',
      AppLanguage.om: 'Konkolaataan keessan qulqullaa\'aa jiruutti boqodhaa',
      AppLanguage.am: 'መኪናዎ እየታጠበ ባለበት ወቅት ዘና ይበሉ',
    },
    'carCareReelsTitle': {
      AppLanguage.en: 'Car Care & Detailing Reels',
      AppLanguage.om: 'Viidiyoowwan Eegumsa Konkolaataa',
      AppLanguage.am: 'የመኪና እንክብካቤ እና ዲቴይሊንግ ቪዲዮዎች',
    },
    'carCareReelsSub': {
      AppLanguage.en: 'Watch our active foam cannons and ceramic treatment highlights',
      AppLanguage.om: 'Hojii saamuunaa foamii fi poolishii keenya daawwadhaa',
      AppLanguage.am: 'የፎም እና የፖሊሽ ስራዎቻችንን በቪዲዮ ይመልከቱ',
    },
    'stationAmenitiesTitle': {
      AppLanguage.en: 'Station Amenities',
      AppLanguage.om: 'Tajaajiloota Dabalataa Buufataa',
      AppLanguage.am: 'የጣቢያው ተጨማሪ አገልግሎቶች',
    },
    'stationAmenitiesSub': {
      AppLanguage.en: 'Comfortable waiting area, fast Wi-Fi, and fresh drinks',
      AppLanguage.om: 'Bakka boqonnaa qabbanaawaa, Wi-Fi saffisaa fi dhugaatii',
      AppLanguage.am: 'ምቹ የማረፊያ ቦታ፣ ፈጣን ዋይፋይ እና ቀዝቃዛ መጠጦች',
    },
    'amenitiesWifiCoffee': {
      AppLanguage.en: 'Complimentary High-Speed Wi-Fi & Lounge Area',
      AppLanguage.om: 'Wi-Fi Saffisaa Bilaashaa & Iddoo Boqonnaa',
      AppLanguage.am: 'ነጻ ፈጣን ዋይፋይ እና ምቹ ማረፊያ',
    },
    'amenitiesWifiCoffeeSub': {
      AppLanguage.en: 'Ask our reception desk for the guest Wi-Fi code',
      AppLanguage.om: 'Koodii Wi-Fi keessummaa kashiyara gaafadhaa',
      AppLanguage.am: 'የእንግዳ ዋይፋይ ኮድ ከካሺየሩ ይጠይቁ',
    },
    'linkNotConfigured': {
      AppLanguage.en: 'Video link is not configured yet',
      AppLanguage.om: 'Liankiin viidiyoo ammayyuu hin qophoofne',
      AppLanguage.am: 'የቪዲዮ ማያያዣ ገና አልተዘጋጀም',
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

  /// Maps any car wash service name (or ID) into the exact Master Table translation for AM/OM.
  static String translateServiceName(String name, dynamic lang) {
    AppLanguage targetLang = AppLanguage.en;
    if (lang is AppLanguage) {
      targetLang = lang;
    } else if (lang != null) {
      targetLang = AppLanguage.fromCode(lang.toString());
    }
    if (targetLang == AppLanguage.en) return name;

    // Check if key is already an exact service ID
    if (_strings.containsKey(name)) {
      return get(name, targetLang);
    }

    final lower = name.toLowerCase().trim();

    // 1.1 Body Hand Wash
    if (lower.contains('body hand wash') || lower.contains('body wash')) {
      return get('srv_body_wash', targetLang);
    }
    // 1.2 Tire Cleaning
    if (lower.contains('tire clean') || lower.contains('tire black')) {
      return get('srv_tire_clean', targetLang);
    }
    // 1.3 Window Polish & Cleaning
    if (lower.contains('window polish') || lower.contains('exterior glass') || lower.contains('window')) {
      return get('srv_window_polish', targetLang);
    }
    // 2.1 Machine Body Polish
    if (lower.contains('machine body polish') || lower.contains('machine polish')) {
      return get('srv_machine_polish', targetLang);
    }
    // 2.2 Scratch Removal
    if (lower.contains('scratch') || lower.contains('scuff')) {
      return get('srv_scratch_removal', targetLang);
    }
    // 2.3 Water Spot
    if (lower.contains('water spot')) {
      return get('srv_water_spot', targetLang);
    }
    // 3.1 Interior Vacuum
    if (lower.contains('interior vacuum') || lower.contains('vacuum floor') || (lower.contains('vacuum') && lower.contains('seat'))) {
      return get('srv_int_vacuum', targetLang);
    }
    // 3.2 Seat & Floor Carpet
    if ((lower.contains('seat') && lower.contains('carpet')) || lower.contains('seats out') || lower.contains('unbolted seat')) {
      return get('srv_seats_out', targetLang);
    }
    // 3.3 Roof Headliner
    if (lower.contains('roof') || lower.contains('headliner')) {
      return get('srv_roof_cleaning', targetLang);
    }
    // 3.4 Dashboard Detailing
    if (lower.contains('dashboard')) {
      return get('srv_dashboard_detailing', targetLang);
    }
    // 3.5 Door Panel
    if (lower.contains('door panel')) {
      return get('srv_door_panel', targetLang);
    }
    // 4.1 Engine Shampoo
    if (lower.contains('engine') && lower.contains('shampoo')) {
      return get('srv_engine_shampoo', targetLang);
    }
    // 4.2 Engine Degreasing / Chemical
    if (lower.contains('engine') && (lower.contains('chemical') || lower.contains('degreas') || lower.contains('rinse'))) {
      return get('srv_engine_chemical', targetLang);
    }
    // 4.3 Headlight Restoration
    if (lower.contains('headlight')) {
      return get('srv_headlight_restoration', targetLang);
    }
    // Plastic trim
    if (lower.contains('plastic trim')) {
      return get('srv_plastic_trim', targetLang);
    }
    // Diamond Detailing
    if (lower.contains('diamond')) {
      return get('srv_diamond_detailing', targetLang);
    }

    return name;
  }

  /// Maps category keywords into the exact Master Table translation for AM/OM.
  static String translateCategoryName(String category, dynamic lang) {
    AppLanguage targetLang = AppLanguage.en;
    if (lang is AppLanguage) {
      targetLang = lang;
    } else if (lang != null) {
      targetLang = AppLanguage.fromCode(lang.toString());
    }
    final lower = category.toLowerCase().trim();
    if (lower == 'exterior' || lower.contains('exterior')) {
      return get('cat_exterior', targetLang);
    }
    if (lower == 'polish' || lower.contains('polish') || lower.contains('paint')) {
      return get('cat_polish', targetLang);
    }
    if (lower == 'interior' || lower.contains('interior')) {
      return get('cat_interior', targetLang);
    }
    if (lower == 'engine' || lower.contains('engine') || lower == 'specialty' || lower.contains('specialty')) {
      return get('cat_engine', targetLang);
    }
    return category;
  }
}
