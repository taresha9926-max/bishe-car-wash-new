import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'car_type.dart';

class CarWashServiceItem {
  final String id;
  final String name;
  final String? nameAmharic;
  final String? nameOromo;
  final String category; // 'exterior', 'polish', 'interior', 'engine', 'specialty'
  final String? description;
  final Map<CarType, double> pricingByCarType;
  final bool isActive;

  const CarWashServiceItem({
    required this.id,
    required this.name,
    this.nameAmharic,
    this.nameOromo,
    required this.category,
    this.description,
    required this.pricingByCarType,
    this.isActive = true,
  });

  double getPriceFor(CarType carType) =>
      pricingByCarType[carType] ?? pricingByCarType[CarType.automobile] ?? 0.0;

  String localizedName(dynamic lang) {
    AppLanguage appLang = AppLanguage.en;
    if (lang is AppLanguage) {
      appLang = lang;
    } else if (lang != null) {
      appLang = AppLanguage.fromCode(lang.toString());
    }
    if (appLang == AppLanguage.am) {
      if (nameAmharic != null && nameAmharic!.isNotEmpty) return nameAmharic!;
      return AppStrings.translateServiceName(name, AppLanguage.am);
    }
    if (appLang == AppLanguage.om) {
      if (nameOromo != null && nameOromo!.isNotEmpty) return nameOromo!;
      return AppStrings.translateServiceName(name, AppLanguage.om);
    }
    return name;
  }

  String localizedCategory(dynamic lang) {
    return AppStrings.translateCategoryName(category, lang);
  }

  CarWashServiceItem copyWith({
    String? id,
    String? name,
    String? nameAmharic,
    String? nameOromo,
    String? category,
    String? description,
    Map<CarType, double>? pricingByCarType,
    bool? isActive,
  }) {
    return CarWashServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAmharic: nameAmharic ?? this.nameAmharic,
      nameOromo: nameOromo ?? this.nameOromo,
      category: category ?? this.category,
      description: description ?? this.description,
      pricingByCarType: pricingByCarType ?? this.pricingByCarType,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_amharic': nameAmharic,
      'name_oromo': nameOromo,
      'category': category,
      'description': description,
      'pricing_automobile': pricingByCarType[CarType.automobile],
      'pricing_minibus': pricingByCarType[CarType.minibus],
      'pricing_truck': pricingByCarType[CarType.truck],
      'is_active': isActive,
    };
  }

  factory CarWashServiceItem.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? '';
    final name = map['name']?.toString() ?? '';
    final nameAm = map['name_amharic']?.toString() ?? AppStrings.translateServiceName(name, AppLanguage.am);
    final nameOm = map['name_oromo']?.toString() ?? AppStrings.translateServiceName(name, AppLanguage.om);
    return CarWashServiceItem(
      id: id,
      name: name,
      nameAmharic: nameAm,
      nameOromo: nameOm,
      category: map['category']?.toString() ?? 'exterior',
      description: map['description']?.toString(),
      pricingByCarType: {
        CarType.automobile: (map['pricing_automobile'] as num?)?.toDouble() ?? 500.0,
        CarType.minibus: (map['pricing_minibus'] as num?)?.toDouble() ?? 700.0,
        CarType.truck: (map['pricing_truck'] as num?)?.toDouble() ?? 1200.0,
      },
      isActive: map['is_active'] == null ? true : (map['is_active'] as bool),
    );
  }

  /// Official Master Table detailing services with complete trilingual translations (EN, AM, OM)
  static List<CarWashServiceItem> getInitialServiceItems() {
    return const [
      // 1. Exterior & Hand Wash (የውጭ አካል እና የእጅ እጥበት / Dhiqannaa Qaama Alaa fi Harka)
      CarWashServiceItem(
        id: 'srv_body_wash',
        name: 'Body Hand Wash with Shampoo & Fiber Towel',
        nameAmharic: 'የመኪና አካል በሻምፖ እና በፋይበር ፎጣ እጥበት',
        nameOromo: 'Dhiqannaa qaama konkolaataa shaamപ്പോ fi fooxaa faayiberiitiin',
        category: 'exterior',
        description: 'High-pressure pre-rinse, touchless snow foam & microfiber hand wash',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
          CarType.truck: 1200.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_tire_clean',
        name: 'Tire Cleaning & Tire Black Finish',
        nameAmharic: 'የጎማ እጥበት እና ማጥቆሪያ ቅባት',
        nameOromo: 'Qulqullina gommaa fi kuula guraachessituu gommaa',
        category: 'exterior',
        description: 'Deep rim scrub, silicone tire black gloss dressing',
        pricingByCarType: {
          CarType.automobile: 200.0,
          CarType.minibus: 300.0,
          CarType.truck: 400.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_window_polish',
        name: 'Window Polish & Cleaning',
        nameAmharic: 'የመስኮት መስታወት ማጽዳት',
        nameOromo: 'Daawwitii foddaa konkolaataa qulqulleessuu',
        category: 'exterior',
        description: 'Streak-free exterior windshield & side window polish',
        pricingByCarType: {
          CarType.automobile: 150.0,
          CarType.minibus: 250.0,
          CarType.truck: 400.0,
        },
      ),

      // 2. Body Polish & Paint Correction (የመኪና አካል ፖሊሽ እና የቀለም ጭረት ጥገና / Poolishii Qaama Konkolaataa fi Bakkoltee Halluu Sirreessuu)
      CarWashServiceItem(
        id: 'srv_machine_polish',
        name: 'Machine Body Polish',
        nameAmharic: 'በማሽን የሚደረግ የሰውነት ፖሊሽ',
        nameOromo: 'Poolishii qaamaa maashiniin hojjetamu',
        category: 'polish',
        description: 'Machine rotary buffer gloss restoration & paint enhancement',
        pricingByCarType: {
          CarType.automobile: 1000.0,
          CarType.minibus: 1500.0,
          CarType.truck: 2000.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_scratch_removal',
        name: 'Scratch / Minor Scratch Removal',
        nameAmharic: 'የጭረት እና ጥቃቅን ስንጥቆች ማስለቀቅ',
        nameOromo: 'Ciccitaa fi madaa xixiqqoo halluu balleessuu',
        category: 'polish',
        description: 'Targeted abrasive compound for clear-coat scratches and scuffs',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 800.0,
          CarType.truck: 1100.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_water_spot',
        name: 'Water Spot Chemical Removal',
        nameAmharic: 'የውሃ እና የጨው ድርቀት ምልክቶችን ማስለቀቅ',
        nameOromo: 'Mallattoo bishaanii fi ashaboo goge qorichaan balleessuu',
        category: 'polish',
        description: 'Chemical mineral dissolution for Bishoftu lake water mineral stains',
        pricingByCarType: {
          CarType.automobile: 800.0,
          CarType.minibus: 1200.0,
          CarType.truck: 1600.0,
        },
      ),

      // 3. Interior Restoration & Detailing (የውስጥ ክፍል ፅዳት እና ዲቴይሊንግ / Qulqullina Keessaa fi Miidhagina Guutuu)
      CarWashServiceItem(
        id: 'srv_int_vacuum',
        name: 'Interior Vacuum: Floor & Seat Cleaning',
        nameAmharic: 'የውስጥ ክፍል ቫኪዩም (የወለል እና የወንበር አቧራ ማጽዳት)',
        nameOromo: 'Vaakiyuumii keessaa (dhukkee lafaa fi teessumaa qulqulleessuu)',
        category: 'interior',
        description: 'Deep cabin vacuuming of seats, floor mats and trunk',
        pricingByCarType: {
          CarType.automobile: 400.0,
          CarType.minibus: 600.0,
          CarType.truck: 800.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_seats_out',
        name: 'Seat & Floor Carpet Removed & Washed',
        nameAmharic: 'ወንበሮችና የወለል ምንጣፎች ወጥተው የሚታጠቡበት',
        nameOromo: 'Teessumootaa fi afata lafaa baasanii dhiquu',
        category: 'interior',
        description: 'Unbolting passenger seats for extraction shampoo & pressure wash',
        pricingByCarType: {
          CarType.automobile: 2500.0,
          CarType.minibus: 4000.0,
          CarType.truck: 5000.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_roof_cleaning',
        name: 'Roof Headliner Deep Cleaning',
        nameAmharic: 'የኮርኒስ/የጣራ ጨርቅ ጥልቅ እጥበት',
        nameOromo: 'Huccuu korniisa/baaxii keessaa gadi-fageenyaan dhiquu',
        category: 'interior',
        description: 'High-heat steam sanitization for roof fabric without sagging',
        pricingByCarType: {
          CarType.automobile: 600.0,
          CarType.minibus: 900.0,
          CarType.truck: 1200.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_dashboard_detailing',
        name: 'Dashboard Detailing: Cream & Airfresh',
        nameAmharic: 'የዳሽቦርድ ማስዋብ (ክሬም እና ሽቶ ማስተካከል)',
        nameOromo: 'Daashboordii miidheksuu (kiriimii fi shittoo sirreessuu)',
        category: 'interior',
        description: 'Air vent brush detailing, UV dashboard cream & fragrance',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 800.0,
          CarType.truck: 1100.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_door_panel',
        name: 'Door Panel Deep Cleaning',
        nameAmharic: 'የበር ውስጣዊ ገጽታዎች ጥልቅ ጽዳት እና ማስዋብ',
        nameOromo: 'Qaama keessoo balbalaa gadi-fageenyaan qulqulleessuu fi miidheksuu',
        category: 'interior',
        description: 'Deep scrubbing of all interior door skins, handles and pockets',
        pricingByCarType: {
          CarType.automobile: 400.0,
          CarType.minibus: 600.0,
          CarType.truck: 800.0,
        },
      ),

      // 4. Engine & Specialty Detailing (የሞተር እና የሞተር የተለያዩ ክፍሎች ጥልቅ ፅዳት / Qulqullina Gadi-fageenyaa Mootoraa fi Kutaa Addaa)
      CarWashServiceItem(
        id: 'srv_engine_shampoo',
        name: 'Engine Cleaning: Shampoo',
        nameAmharic: 'የሞተር እጥበት (በሻምፖ)',
        nameOromo: 'Mootora shaamപ്പോdhaan dhiquu',
        category: 'engine',
        description: 'Basic engine compartment wash with automotive shampoo',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
          CarType.truck: 1000.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_engine_chemical',
        name: 'Engine Bay Chemical Degreasing: Deep Clean, Rinse & Dry',
        nameAmharic: 'የሞተር ክፍል በኬሚካል ቅባት ማስለቀቅ (ጥልቅ ጽዳት፣ ማጠብ እና ማድረቅ)',
        nameOromo: 'Moora mootoraa kemikaalaan cooma qulqulleessuu (dhiquu, dhiqachuu fi gogsuu)',
        category: 'engine',
        description: 'Specialty chemical degreasing, deep bay grime rinse & hose conditioning',
        pricingByCarType: {
          CarType.automobile: 1200.0,
          CarType.minibus: 1700.0,
          CarType.truck: 2300.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_headlight_restoration',
        name: 'Headlight Restoration',
        nameAmharic: 'የደበዘዘ (የወየበ) የግንባር መብራት መስታወት ወደ ኦሪጂናል መመለስ',
        nameOromo: 'Daawwitii ifaa fuulduraa kan dhiitama/bifa gate gara oriijinaalaatti deebisuu',
        category: 'specialty',
        description: 'Dual-stage wet-sanding to clear yellow oxidation + UV sealant',
        pricingByCarType: {
          CarType.automobile: 1000.0,
          CarType.minibus: 1400.0,
          CarType.truck: 1800.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_plastic_trim',
        name: 'Plastic Trim Restoration',
        nameAmharic: 'የፕላስቲክ እና የጎማ ማደስ',
        nameOromo: 'Pilaastikii fi Gommaa Haaromsuu',
        category: 'specialty',
        description: 'UV deep black plastic and exterior rubber restoration & protection',
        pricingByCarType: {
          CarType.automobile: 400.0,
          CarType.minibus: 600.0,
          CarType.truck: 800.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_diamond_detailing',
        name: 'Diamond - Interior & Exterior Detailing (1 Day)',
        nameAmharic: 'ዳይመንድ - የውስጥ እና የውጭ ሙሉ ዲቴይሊንግ (1 ቀን)',
        nameOromo: 'Daayimandii - Miidhagina Keessaa fi Alaa Guutuu (Guyyaa 1)',
        category: 'specialty',
        description: 'Comprehensive 13-point full day detailing: unbolted seats, machine polish, engine degreasing & ceramic coat',
        pricingByCarType: {
          CarType.automobile: 5000.0,
          CarType.minibus: 7500.0,
          CarType.truck: 10000.0,
        },
      ),
    ];
  }
}
