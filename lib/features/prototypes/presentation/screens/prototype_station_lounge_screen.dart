import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/widgets/responsive_layout.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/ad_video_showcase_card.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/welcome_service_carousel_banner.dart';

/// Prototype preview of the dedicated Station Lounge & Ad Hub.
/// Apple Design Standards: Canvas Parchment (#F5F5F7), Ceramic Dark Titanium card (#1D1D1F),
/// Action Blue highlights (#0071E3), clean hairline borders (#E5E5EA), and zero visual slop.
class PrototypeStationLoungeScreen extends StatelessWidget {
  const PrototypeStationLoungeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    // Apple Style Tokens
    const appleCanvas = Color(0xFFF5F5F7);
    const appleInk = Color(0xFF1D1D1F);
    const appleMuted = Color(0xFF86868B);
    const appleHairline = Color(0xFFE5E5EA);
    const appleActionBlue = Color(0xFF0071E3);

    return Scaffold(
      backgroundColor: appleCanvas,
      appBar: AppBar(
        title: Text(
          state.tr('stationLoungeTitle'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: appleInk,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: appleInk,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: appleHairline, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: appleInk),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner: Apple Ceramic Dark Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: appleInk,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('stationLoungeHeader'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.tr('stationLoungeHeaderSub'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Video Reels & Detailing Ad Showcase
                Text(
                  state.tr('carCareReelsTitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: appleInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.tr('carCareReelsSub'),
                  style: const TextStyle(color: appleMuted, fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: appleHairline),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const AdVideoShowcaseCard(),
                  ),
                ),
                const SizedBox(height: 28),

                // Station Amenities Carousel
                Text(
                  state.tr('stationAmenitiesTitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: appleInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.tr('stationAmenitiesSub'),
                  style: const TextStyle(color: appleMuted, fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: WelcomeServiceCarouselBanner(isMobile: isMobile),
                ),
                const SizedBox(height: 28),

                // Relax & Refresh Card (Apple White Card)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: appleHairline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.wifi_rounded, size: 28, color: appleActionBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('amenitiesWifiCoffee'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: appleInk,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.tr('amenitiesWifiCoffeeSub'),
                              style: const TextStyle(color: appleMuted, fontSize: 13, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
