import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';

/// Centralized repository of high-definition AI automotive photography assets
/// for primary, secondary, and tertiary screens across Bishe Car Wash.
class AutoCareAssets {
  // Service Station Facilities
  static const String stationBayUrl =
      'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=80';
  static const String mobileVanUrl =
      'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80';
  static const String valetDriverUrl =
      'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=600&auto=format&fit=crop&q=80';
  static const String welcomeHeroUrl =
      'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=600&auto=format&fit=crop&q=80';

  // Vehicle Categories
  static const String carSedanUrl =
      'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400&auto=format&fit=crop&q=80';
  static const String carMinibusUrl =
      'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400&auto=format&fit=crop&q=80';
  static const String carTruckUrl =
      'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=400&auto=format&fit=crop&q=80';

  // Detailing Service Tiers
  static const String packageFoamUrl =
      'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=600&auto=format&fit=crop&q=80';
  static const String packageVacuumUrl =
      'https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=600&auto=format&fit=crop&q=80';
  static const String packageDeluxeSpaUrl =
      'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=600&auto=format&fit=crop&q=80';
  static const String packageMobileVanUrl =
      'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&auto=format&fit=crop&q=80';
  static const String packageSteamEngineUrl =
      'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=600&auto=format&fit=crop&q=80';
  static const String packageTireRimUrl =
      'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=80';

  // Inventory & Consumable Supplies (Legacy & Base)
  static const String assetShampooUrl =
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&auto=format&fit=crop&q=80';
  static const String assetEquipmentUrl =
      'https://images.unsplash.com/photo-1581092162384-8987c1d64718?w=400&auto=format&fit=crop&q=80';
  static const String assetTowelsUrl =
      'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=400&auto=format&fit=crop&q=80';
  static const String cashMoneyUrl =
      'https://images.unsplash.com/photo-1580519542036-c47de6196ba5?w=400&auto=format&fit=crop&q=80';
  static const String cbeLogoUrl =
      'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=400&auto=format&fit=crop&q=80';
  static const String spongeBucketUrl =
      'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&auto=format&fit=crop&q=80';

  // Dedicated Physical Fixed Asset Machinery & Tool Photographs
  static const String assetPolisherMachineUrl =
      'https://images.unsplash.com/photo-1708805282695-ef186db20192?w=400&auto=format&fit=crop&q=80';
  static const String assetVacuumCleanerUrl =
      'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400&auto=format&fit=crop&q=80';
  static const String assetSteamMachineUrl =
      'https://images.unsplash.com/photo-1776585617123-84cb50100bd0?w=400&auto=format&fit=crop&q=80';
  static const String assetPressurePumpUrl =
      'https://images.unsplash.com/photo-1581092162384-8987c1d64718?w=400&auto=format&fit=crop&q=80';
  static const String assetAngleGrinderUrl =
      'https://images.unsplash.com/photo-1564182999211-0992ff88172a?w=400&auto=format&fit=crop&q=80';
  static const String assetHeatGunUrl =
      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400&auto=format&fit=crop&q=80';
  static const String assetElectricDrillUrl =
      'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=400&auto=format&fit=crop&q=80';
  static const String assetAirBlowerUrl =
      'https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=400&auto=format&fit=crop&q=80';
  static const String assetAirStaplerUrl =
      'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?w=400&auto=format&fit=crop&q=80';
  static const String assetWeldingMachineUrl =
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&auto=format&fit=crop&q=80';
  static const String assetToolKitUrl =
      'https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?w=400&auto=format&fit=crop&q=80';
  static const String assetHackSawUrl =
      'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=400&auto=format&fit=crop&q=80';
  static const String assetHammerUrl =
      'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?w=400&auto=format&fit=crop&q=80';
  static const String assetTrimmingMachineUrl =
      'https://images.unsplash.com/photo-1581092334651-ddf26d9a09d0?w=400&auto=format&fit=crop&q=80';
  static const String assetSewingMachineUrl =
      'https://images.unsplash.com/photo-1587819390518-12c38c703ba2?w=400&auto=format&fit=crop&q=80';
  static const String assetWifiRouterUrl =
      'https://images.unsplash.com/photo-1606904825846-647eb07f5be2?w=400&auto=format&fit=crop&q=80';
  static const String assetWeldingGlassesUrl =
      'https://images.unsplash.com/photo-1584467735871-8e85353a8413?w=400&auto=format&fit=crop&q=80';
  static const String assetWaterLevelUrl =
      'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=400&auto=format&fit=crop&q=80';
  static const String assetPaperStaplerUrl =
      'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=400&auto=format&fit=crop&q=80';
  static const String assetPaperPuncherUrl =
      'https://images.unsplash.com/photo-1456735190827-d1262f71b8a3?w=400&auto=format&fit=crop&q=80';
  static const String assetCashRegisterUrl =
      'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=400&auto=format&fit=crop&q=80';
  static const String assetBenchViceUrl =
      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400&auto=format&fit=crop&q=80';
  static const String assetTrySquareUrl =
      'https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?w=400&auto=format&fit=crop&q=80';
  static const String assetFirstAidKitUrl =
      'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&auto=format&fit=crop&q=80';

  // Dedicated Physical Consumable Products & Chemicals Photographs
  static const String assetSprayBottleBlueUrl =
      'https://images.unsplash.com/photo-1550963295-019d8a8a61c5?w=400&auto=format&fit=crop&q=80';
  static const String assetSprayCanYellowUrl =
      'https://images.unsplash.com/photo-1563453392212-326f5e854473?w=400&auto=format&fit=crop&q=80';
  static const String assetSprayCanWhiteUrl =
      'https://images.unsplash.com/photo-1556579573-1629c871d914?w=400&auto=format&fit=crop&q=80';
  static const String assetLiquidBottleUrl =
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&auto=format&fit=crop&q=80';
  static const String assetFoldedTowelsUrl =
      'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=400&auto=format&fit=crop&q=80';
  static const String assetFragranceSprayUrl =
      'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400&auto=format&fit=crop&q=80';
  static const String assetDetailingBrushesUrl =
      'https://images.unsplash.com/photo-1590736969955-71cc94801759?w=400&auto=format&fit=crop&q=80';
  static const String assetDusterMopUrl =
      'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=400&auto=format&fit=crop&q=80';
  static const String assetHygieneSoapUrl =
      'https://images.unsplash.com/photo-1607006314352-a567634f59fc?w=400&auto=format&fit=crop&q=80';

  // Official @bishecarwash Published TikTok Video URLs (Latest 7 Videos)
  static const List<String> officialTikTokVideos = [
    'https://www.tiktok.com/@bishecarwash/video/7703232736168791303',
    'https://www.tiktok.com/@bishecarwash/video/7703201662713728274',
    'https://www.tiktok.com/@bishecarwash/video/7701736769619905799',
    'https://www.tiktok.com/@bishecarwash/video/7700597195816357127',
    'https://www.tiktok.com/@bishecarwash/video/7699125432259464455',
    'https://www.tiktok.com/@bishecarwash/video/7698005404336573703',
    'https://www.tiktok.com/@bishecarwash/video/7696533703924682002',
  ];

  // Curated 8-Reel Commercial Detailing Photography Pool
  static const List<Map<String, String>> curatedReelsPool = [
    {
      'id': 'reel-1',
      'label': 'Reel 1: Active Snow Foam',
      'title': 'Active Snow Foam Cannon & Pre-Wash',
      'subtitle': 'Triple-action foaming & streak-free dirt lift • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7703232736168791303',
    },
    {
      'id': 'reel-2',
      'label': 'Reel 2: Chassis Steam',
      'title': 'High-Pressure Chassis Steam Bay',
      'subtitle': 'Deep wheel-well & engine chassis steam care • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7703201662713728274',
    },
    {
      'id': 'reel-3',
      'label': 'Reel 3: Ceramic Shield',
      'title': 'Ceramic Shield & Paint Polish',
      'subtitle': 'Hydrophobic ceramic shield & ultimate gloss • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7701736769619905799',
    },
    {
      'id': 'reel-4',
      'label': 'Reel 4: Interior Care',
      'title': 'Deep Interior & Leather Care',
      'subtitle': 'Anti-bacterial steam & luxury cabin detailing • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7700597195816357127',
    },
    {
      'id': 'reel-5',
      'label': 'Reel 5: Tire Gloss',
      'title': 'Wheel-Well & Tire Gloss Treatment',
      'subtitle': 'Brake-dust dissolve & deep satin tire dressing • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7699125432259464455',
    },
    {
      'id': 'reel-6',
      'label': 'Reel 6: Engine Bay',
      'title': 'Engine Bay Detailing & Degrease',
      'subtitle': 'Precision dry-steam grease wipe & harness coat • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7698005404336573703',
    },
    {
      'id': 'reel-7',
      'label': 'Reel 7: Water Beading',
      'title': 'Water-Beading Hydrophobic Rinse',
      'subtitle': 'Extreme water repelling & fast crystal dry coat • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash/video/7696533703924682002',
    },
    {
      'id': 'reel-8',
      'label': 'Reel 8: Mobile Van',
      'title': 'Mobile Van At-Home Service',
      'subtitle': 'Equipped generator & tank van right to your door • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&auto=format&fit=crop&q=80',
      'videoUrl': 'https://www.tiktok.com/@bishecarwash',
    },
  ];

  /// Specific physical machinery & workshop tool photo thumbnail resolver
  static String getFixedAssetImage(String assetName, {String? id}) {
    final lowerId = (id ?? '').toLowerCase();
    final lowerName = assetName.toLowerCase();

    if (lowerId == 'fa-001' || lowerName.contains('polish grinder') || lowerName.contains('ፖሊሽ መፍጫ')) {
      return assetPolisherMachineUrl;
    } else if (lowerId == 'fa-002' || lowerName.contains('vacuum') || lowerName.contains('ቫኪዩም')) {
      return assetVacuumCleanerUrl;
    } else if (lowerId == 'fa-003' || lowerName.contains('steam') || lowerName.contains('እንፋሎት')) {
      return assetSteamMachineUrl;
    } else if (lowerId == 'fa-004' || lowerName.contains('pressure pump') || lowerName.contains('ከፍተኛ ግፊት')) {
      return assetPressurePumpUrl;
    } else if (lowerId == 'fa-005' || lowerName.contains('small grinder') || lowerName.contains('አነስተኛ መፍጫ')) {
      return assetAngleGrinderUrl;
    } else if (lowerId == 'fa-006' || lowerName.contains('hot gun') || lowerName.contains('heat gun') || lowerName.contains('ሙቀት')) {
      return assetHeatGunUrl;
    } else if (lowerId == 'fa-007' || lowerName.contains('drill') || lowerName.contains('መሰርሰሪያ')) {
      return assetElectricDrillUrl;
    } else if (lowerId == 'fa-008' || lowerName.contains('blower') || lowerName.contains('ብሎወር')) {
      return assetAirBlowerUrl;
    } else if (lowerId == 'fa-009' || (lowerName.contains('stapler') && (lowerName.contains('air') || lowerName.contains('wood') || lowerName.contains('እንጨት')))) {
      return assetAirStaplerUrl;
    } else if (lowerId == 'fa-010' || lowerName.contains('weld') || lowerName.contains('ብየዳ')) {
      return assetWeldingMachineUrl;
    } else if (lowerId == 'fa-011' || lowerName.contains('motor') || lowerName.contains('ሞተር')) {
      return assetPressurePumpUrl;
    } else if (lowerId == 'fa-012' || lowerName.contains('tool kit') || lowerName.contains('መሳሪያዎች')) {
      return assetToolKitUrl;
    } else if (lowerId == 'fa-013' || lowerName.contains('saw') || lowerName.contains('መጋዝ')) {
      return assetHackSawUrl;
    } else if (lowerId == 'fa-014' || lowerName.contains('hammer') || lowerName.contains('መዶሻ')) {
      return assetHammerUrl;
    } else if (lowerId == 'fa-015' || lowerName.contains('trimming') || lowerName.contains('ትሪሚንግ')) {
      return assetTrimmingMachineUrl;
    } else if (lowerId == 'fa-016' || lowerName.contains('sewing') || lowerName.contains('ስፌት')) {
      return assetSewingMachineUrl;
    } else if (lowerId == 'fa-017' || lowerName.contains('wifi') || lowerName.contains('router') || lowerName.contains('ራውተር')) {
      return assetWifiRouterUrl;
    } else if (lowerId == 'fa-018' || lowerName.contains('glasses') || lowerName.contains('መነጽር')) {
      return assetWeldingGlassesUrl;
    } else if (lowerId == 'fa-019' || lowerName.contains('level') || lowerName.contains('ልክ')) {
      return assetWaterLevelUrl;
    } else if (lowerId == 'fa-020' || lowerName.contains('paper stapler') || lowerName.contains('የወረቀት እስቴፕለር')) {
      return assetPaperStaplerUrl;
    } else if (lowerId == 'fa-021' || lowerName.contains('puncher') || lowerName.contains('ቀዳዳ')) {
      return assetPaperPuncherUrl;
    } else if (lowerId == 'fa-022' || lowerName.contains('cash register') || lowerName.contains('መመዝገቢያ')) {
      return assetCashRegisterUrl;
    } else if (lowerId == 'fa-023' || lowerName.contains('vice') || lowerName.contains('መንከሻ')) {
      return assetBenchViceUrl;
    } else if (lowerId == 'fa-024' || lowerName.contains('square') || lowerName.contains('ማእዘን')) {
      return assetTrySquareUrl;
    } else if (lowerId == 'fa-025' || lowerName.contains('first aid') || lowerName.contains('እርዳታ')) {
      return assetFirstAidKitUrl;
    }
    return assetToolKitUrl;
  }

  /// Specific physical chemical bottle, spray, or consumable supply photo thumbnail resolver
  static String getConsumableImage(String itemName, {String? id}) {
    final lowerId = (id ?? '').toLowerCase();
    final lowerName = itemName.toLowerCase();

    if (lowerId == 'cs-001' || lowerName.contains('abro') || lowerName.contains('አብሮ')) {
      return assetLiquidBottleUrl;
    } else if (lowerId == 'cs-002' || lowerName.contains('buffing pad') || lowerName.contains('polish pad') || lowerName.contains('መፍጫ ስፖንጅ')) {
      return assetToolKitUrl;
    } else if (lowerId == 'cs-003' || lowerName.contains('dashboard protectant') || lowerName.contains('ዳሽቦርድ ቅባት')) {
      return assetSprayBottleBlueUrl;
    } else if (lowerId == 'cs-004' || lowerName.contains('tire') || lowerName.contains('ጎማ')) {
      return assetSprayCanYellowUrl;
    } else if (lowerId == 'cs-005' || lowerName.contains('water spot')) {
      return assetSprayBottleBlueUrl;
    } else if (lowerId == 'cs-006' || lowerName.contains('freshener') || lowerName.contains('ሽቶ')) {
      return assetFragranceSprayUrl;
    } else if (lowerId == 'cs-007' || lowerName.contains('2c') || lowerName.contains('polishing cloth') || lowerName.contains('ማሻ ጨርቅ')) {
      return assetFoldedTowelsUrl;
    } else if (lowerId == 'cs-008' || lowerName.contains('headlight')) {
      return assetLiquidBottleUrl;
    } else if (lowerId == 'cs-009' || lowerName.contains('shampoo') || lowerName.contains('ሻምፑ')) {
      return assetLiquidBottleUrl;
    } else if (lowerId == 'cs-010a' || lowerName.contains('dashboard spray') || lowerName.contains('ዳሽቦርድ ስፕሬይ')) {
      return assetSprayCanWhiteUrl;
    } else if (lowerId == 'cs-010b' || lowerName.contains('carpet') || lowerName.contains('ምንጣፍ')) {
      return assetSprayBottleBlueUrl;
    } else if (lowerId == 'cs-010c' || lowerName.contains('degreaser') || lowerName.contains('ሞተር ኬሚካል')) {
      return assetSprayCanYellowUrl;
    } else if (lowerId == 'cs-011' || lowerName.contains('cutting compound')) {
      return assetLiquidBottleUrl;
    } else if (lowerId == 'cs-012' || lowerName.contains('brush') || lowerName.contains('ብሩሽ')) {
      return assetDetailingBrushesUrl;
    } else if (lowerId == 'cs-013' || lowerName.contains('microfiber') || lowerName.contains('towel') || lowerName.contains('ፎጣ')) {
      return assetFoldedTowelsUrl;
    } else if (lowerId == 'cs-014' || lowerName.contains('grinder disc') || lowerName.contains('መፍጫ ድንጋይ')) {
      return assetAngleGrinderUrl;
    } else if (lowerId == 'cs-015' || lowerName.contains('electrode') || lowerName.contains('ኤሌክትሮድ')) {
      return assetWeldingMachineUrl;
    } else if (lowerId == 'cs-016' || lowerName.contains('wax drag') || lowerName.contains('መወልወያ')) {
      return assetDusterMopUrl;
    } else if (lowerId == 'cs-017' || lowerName.contains('oil') || lowerName.contains('ዘይት')) {
      return assetLiquidBottleUrl;
    } else if (lowerId == 'cs-018' || lowerName.contains('soap') || lowerName.contains('ሳሙና')) {
      return assetHygieneSoapUrl;
    } else if (lowerId == 'cs-019' || lowerName.contains('screw') || lowerName.contains('ብሎን')) {
      return assetToolKitUrl;
    } else if (lowerId == 'cs-020' || lowerName.contains('fisher') || lowerName.contains('ፊሸር')) {
      return assetHeatGunUrl;
    }
    return assetLiquidBottleUrl;
  }

  /// Unified item-specific inventory thumbnail resolver
  static String getInventoryImage(String itemName, {String? id}) {
    final lowerId = (id ?? '').toLowerCase();
    if (lowerId.startsWith('fa-')) {
      return getFixedAssetImage(itemName, id: id);
    } else if (lowerId.startsWith('cs-')) {
      return getConsumableImage(itemName, id: id);
    }

    final lower = itemName.toLowerCase();
    if (lower.contains('polish grinder') ||
        lower.contains('vacuum') ||
        lower.contains('drill') ||
        lower.contains('welding') ||
        lower.contains('sewing') ||
        lower.contains('router') ||
        lower.contains('pump') ||
        lower.contains('saw') ||
        lower.contains('hammer') ||
        lower.contains('vice') ||
        lower.contains('puncher') ||
        lower.contains('first aid') ||
        lower.contains('register')) {
      return getFixedAssetImage(itemName, id: id);
    }
    return getConsumableImage(itemName, id: id);
  }

  /// High-accuracy fallback icon based on inventory item type
  static IconData getInventoryFallbackIcon(String itemName, {String? id}) {
    final lower = itemName.toLowerCase();
    if (lower.contains('vacuum')) return Icons.cleaning_services_rounded;
    if (lower.contains('drill') || lower.contains('grinder')) return Icons.build_rounded;
    if (lower.contains('weld')) return Icons.handyman_rounded;
    if (lower.contains('sewing')) return Icons.content_cut_rounded;
    if (lower.contains('towel') || lower.contains('cloth')) return Icons.dry_cleaning_rounded;
    if (lower.contains('shampoo') || lower.contains('foam')) return Icons.local_car_wash_rounded;
    if (lower.contains('router') || lower.contains('wifi')) return Icons.router_rounded;
    if (lower.contains('first aid')) return Icons.medical_services_rounded;
    if (lower.contains('cash') || lower.contains('register')) return Icons.point_of_sale_rounded;
    return Icons.inventory_2_rounded;
  }

  static String getCarTypeImage(CarType type) {
    switch (type) {
      case CarType.automobile:
        return carSedanUrl;
      case CarType.minibus:
        return carMinibusUrl;
      case CarType.truck:
        return carTruckUrl;
    }
  }

  static String getPackageImage(WashPackage pkg) {
    return getPackageImageByName(pkg.name);
  }

  static String getPackageImageByName(String name) {
    final pName = name.toLowerCase();
    if (pName.contains('foam') || pName.contains('express')) {
      return packageFoamUrl;
    } else if (pName.contains('vacuum') || pName.contains('standard') || pName.contains('interior')) {
      return packageVacuumUrl;
    } else if (pName.contains('spa') || pName.contains('deluxe') || pName.contains('ceramic') || pName.contains('polish')) {
      return packageDeluxeSpaUrl;
    } else if (pName.contains('mobile') || pName.contains('van')) {
      return packageMobileVanUrl;
    } else if (pName.contains('engine') || pName.contains('steam')) {
      return packageSteamEngineUrl;
    } else if (pName.contains('wheel') || pName.contains('tire') || pName.contains('rim')) {
      return packageTireRimUrl;
    }
    return packageFoamUrl;
  }

  /// Reusable rounded automotive photo thumbnail with obsidian glass border,
  /// dark gradient scrim overlay, and smooth offline fallback icon.
  static Widget buildPhotoThumbnail({
    required String imageUrl,
    required double width,
    required double height,
    double borderRadius = 12.0,
    IconData fallbackIcon = Icons.directions_car_rounded,
    Color fallbackColor = AppColors.primary,
    String? durationBadge,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.cardGlassBorder, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius > 1 ? borderRadius - 1 : borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: fallbackColor.withOpacity(0.12),
                child: Center(
                  child: Icon(fallbackIcon, color: fallbackColor, size: width * 0.45),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (durationBadge != null)
              Positioned(
                bottom: 2,
                left: 2,
                right: 2,
                child: Text(
                  durationBadge,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
