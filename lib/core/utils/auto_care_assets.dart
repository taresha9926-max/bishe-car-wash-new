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
