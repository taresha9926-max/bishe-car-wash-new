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

  // Inventory & Consumable Supplies
  static const String assetShampooUrl =
      'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&auto=format&fit=crop&q=80';
  static const String assetEquipmentUrl =
      'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=400&auto=format&fit=crop&q=80';
  static const String assetTowelsUrl =
      'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=400&auto=format&fit=crop&q=80';
  static const String cashMoneyUrl =
      'https://images.unsplash.com/photo-1580519542036-c47de6196ba5?w=400&auto=format&fit=crop&q=80';
  static const String cbeLogoUrl =
      'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=400&auto=format&fit=crop&q=80';
  static const String spongeBucketUrl =
      'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=400&auto=format&fit=crop&q=80';

  // Curated 8-Reel Commercial Detailing Photography Pool
  static const List<Map<String, String>> curatedReelsPool = [
    {
      'id': 'reel-1',
      'label': 'Reel 1: Active Snow Foam',
      'title': 'Active Snow Foam Cannon & Pre-Wash',
      'subtitle': 'Triple-action foaming & streak-free dirt lift • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-2',
      'label': 'Reel 2: Chassis Steam',
      'title': 'High-Pressure Chassis Steam Bay',
      'subtitle': 'Deep wheel-well & engine chassis steam care • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-3',
      'label': 'Reel 3: Ceramic Shield',
      'title': 'Ceramic Shield & Paint Polish',
      'subtitle': 'Hydrophobic ceramic shield & ultimate gloss • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-4',
      'label': 'Reel 4: Interior Care',
      'title': 'Deep Interior & Leather Care',
      'subtitle': 'Anti-bacterial steam & luxury cabin detailing • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-5',
      'label': 'Reel 5: Tire Gloss',
      'title': 'Wheel-Well & Tire Gloss Treatment',
      'subtitle': 'Brake-dust dissolve & deep satin tire dressing • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-6',
      'label': 'Reel 6: Engine Bay',
      'title': 'Engine Bay Detailing & Degrease',
      'subtitle': 'Precision dry-steam grease wipe & harness coat • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-7',
      'label': 'Reel 7: Water Beading',
      'title': 'Water-Beading Hydrophobic Rinse',
      'subtitle': 'Extreme water repelling & fast crystal dry coat • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?w=800&auto=format&fit=crop&q=80',
    },
    {
      'id': 'reel-8',
      'label': 'Reel 8: Mobile Van',
      'title': 'Mobile Van At-Home Service',
      'subtitle': 'Equipped generator & tank van right to your door • Watch Reel',
      'url': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&auto=format&fit=crop&q=80',
    },
  ];

  static String getInventoryImage(String itemName) {
    final lower = itemName.toLowerCase();
    if (lower.contains('shampoo') || lower.contains('foam') || lower.contains('wax') || lower.contains('chemical') || lower.contains('liquid')) {
      return assetShampooUrl;
    } else if (lower.contains('towel') || lower.contains('cloth') || lower.contains('sponge') || lower.contains('brush')) {
      return assetTowelsUrl;
    }
    return assetEquipmentUrl;
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

  /// Reusable rounded automotive photo thumbnail with glass gradient and offline fallback.
  static Widget buildPhotoThumbnail({
    required String imageUrl,
    required double width,
    required double height,
    double borderRadius = 10.0,
    IconData fallbackIcon = Icons.local_car_wash_rounded,
    Color fallbackColor = AppColors.primary,
    String? durationBadge,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.52)],
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
