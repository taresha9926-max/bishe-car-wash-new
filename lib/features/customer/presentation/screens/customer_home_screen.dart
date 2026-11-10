import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
import 'package:bishe_car_wash/core/widgets/app_role_header.dart';
import 'package:bishe_car_wash/core/widgets/responsive_layout.dart';
import 'package:bishe_car_wash/core/widgets/status_badge.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_dispatcher.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/negotiable_price_badge.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/customer_feedback_sheet.dart';

/// Simplified Option 1 Customer Hub: 2 big service choices + live status + 1-tap help.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _trackController = TextEditingController();

  @override
  void dispose() {
    _trackController.dispose();
    super.dispose();
  }

  void _startGuidedBooking(BuildContext context, {required bool isCarpet}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewBookingScreen(isCarpet: isCarpet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final activeWash = state.activeTrackingBooking;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final queueAhead = state.bookings
        .where((b) => b.status != WashStatus.completed && b.status != WashStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(title: state.tr('appName')),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Station Availability Bar (1 simple glance)
                  _buildCompactLiveStatusCard(state, queueAhead),
                  const SizedBox(height: 14),

                  // 2. Main Hub Title + 2 Big Action Cards ("Wash My Car" vs "Wash My Carpet")
                  Text(
                    state.tr('whatToWashToday'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final carCard = _buildDivisionHubCard(
                        context: context,
                        title: state.tr('washMyCarTitle'),
                        subtitle: state.tr('washMyCarSub'),
                        ctaLabel: state.tr('startCarBooking'),
                        imageUrl: AutoCareAssets.carSedanUrl,
                        fallbackIcon: Icons.directions_car_filled_rounded,
                        accentColor: AppColors.primary,
                        onTap: () => _startGuidedBooking(context, isCarpet: false),
                      );
                      final carpetCard = _buildDivisionHubCard(
                        context: context,
                        title: state.tr('washMyCarpetTitle'),
                        subtitle: state.tr('washMyCarpetSub'),
                        ctaLabel: state.tr('startCarpetBooking'),
                        imageUrl: AutoCareAssets.carpetTypeAUrl,
                        fallbackIcon: Icons.texture_rounded,
                        accentColor: const Color(0xFF4F46E5),
                        onTap: () => _startGuidedBooking(context, isCarpet: true),
                      );

                      if (constraints.maxWidth >= 680) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: carCard),
                            const SizedBox(width: 14),
                            Expanded(child: carpetCard),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          carCard,
                          const SizedBox(height: 12),
                          carpetCard,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Active Wash Tracker OR Unified Plate/Carpet Lookup
                  if (activeWash != null &&
                      (activeWash.status.isOngoing ||
                          activeWash.status == WashStatus.pending ||
                          activeWash.status == WashStatus.confirmed))
                    _buildActiveWashCard(context, state, activeWash)
                  else
                    _buildVehicleLookupCard(context, state),
                  const SizedBox(height: 14),

                  // 4. Community Help: Call to Book Card
                  _buildPhoneBookingCard(context, state),
                  const SizedBox(height: 12),

                  // 5. Google Maps + Feedback Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
                          icon: const Icon(Icons.location_on_rounded, size: 17, color: AppColors.statusPending),
                          label: Text(
                            state.tr('openGoogleMaps'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => CustomerFeedbackSheet.show(context),
                          icon: const Icon(Icons.star_rounded, size: 17, color: Color(0xFFD97706)),
                          label: Text(
                            state.tr('feedbackTab'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF3C7).withOpacity(0.55),
                            side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 6. Simple Bishoftu Station Footer
                  _buildBishoftuLocationFooter(state),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLiveStatusCard(dynamic state, List<WashBooking> queueAhead) {
    final stationQueue = queueAhead.where((b) => b.serviceType == ServiceType.walkInStation).toList();
    final mobileQueue = queueAhead.where((b) => b.serviceType == ServiceType.atHomeMobile).toList();

    final stationWaitMins = WashDispatcher.estimateStationWaitMinutes(
      availableBaysCount: state.availableBaysCount,
      queue: stationQueue,
    );
    final mobileWaitMins = WashDispatcher.estimateMobileVanWaitMinutes(
      isVanAvailable: state.isMobileVanAvailable,
      queue: mobileQueue,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEtaPill(
              icon: Icons.local_car_wash_rounded,
              title: state.tr('stationBaysTitle'),
              value: stationWaitMins == 0 ? state.tr('readyNow') : '~$stationWaitMins ${state.tr('minWait')}',
              isReady: stationWaitMins == 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEtaPill(
              icon: Icons.rv_hookup_rounded,
              title: state.tr('mobileVanTitle'),
              value: mobileWaitMins == 0 ? state.tr('vanReady') : '~$mobileWaitMins ${state.tr('minWait')}',
              isReady: mobileWaitMins == 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaPill({
    required IconData icon,
    required String title,
    required String value,
    required bool isReady,
  }) {
    final color = isReady ? AppColors.statusReady : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isReady ? AppColors.statusReady.withOpacity(0.08) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isReady ? AppColors.statusReady.withOpacity(0.4) : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionHubCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required String imageUrl,
    required IconData fallbackIcon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withOpacity(0.35), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AutoCareAssets.buildPhotoThumbnail(
                    imageUrl: imageUrl,
                    width: 62,
                    height: 62,
                    borderRadius: 14,
                    fallbackIcon: fallbackIcon,
                    fallbackColor: accentColor,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const NegotiablePriceBadge(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    ctaLabel,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleLookupCard(BuildContext context, dynamic state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr('trackMyCar'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('trackVehiclePrompt'),
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _trackController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: state.tr('plateOrPhoneHint'),
                      hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.directions_car_outlined, size: 18, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      fillColor: AppColors.surfaceVariant,
                      filled: true,
                    ),
                    onSubmitted: (_) => _handleTrackVehicle(context, state),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => _handleTrackVehicle(context, state),
                  icon: const Icon(Icons.radar_rounded, size: 16),
                  label: Text(state.tr('trackNow'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTrackVehicle(BuildContext context, dynamic state) {
    final query = _trackController.text.trim();
    if (query.isEmpty) return;
    final found = state.findBookingByPhoneOrPlate(query);
    if (found != null) {
      state.setActiveTrackingBooking(found.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: found.id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryDark,
          content: Text(state.tr('noActiveWashFound')),
        ),
      );
    }
  }

  Widget _buildActiveWashCard(BuildContext context, dynamic state, WashBooking wash) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: wash.status.color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.radar_rounded, size: 16, color: wash.status.color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${state.tr("activeWashTitle")}: ${wash.licensePlate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: wash.status.localizedName(state.currentLang),
                color: wash.status.color,
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${wash.localizedServiceDisplayName(state.currentLang)} • ${wash.assignedWasherName ?? state.tr("pending")}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _trackController.clear();
                  state.clearActiveTrackingBooking();
                },
                child: Text(state.tr('trackAnother'), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: wash.id)),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      state.tr('openFullTracker'),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: wash.status.color),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: wash.status.color),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneBookingCard(BuildContext context, dynamic state) {
    final phone = state.customerPhoneBookingNumber as String;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cashGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cashGreen.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.cashGreen, shape: BoxShape.circle),
            child: const Icon(Icons.phone_forwarded_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('phoneCallBooking'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.cashGreen),
                ),
                Text(
                  state.tr('needHelpCallBanner'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cashGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.call, size: 15),
            label: Text(phone, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${state.tr("callingStationPrefix")}: $phone...')),
              );
              UrlLauncherHelper.openUrl('tel:$phone');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBishoftuLocationFooter(dynamic state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        '${state.tr("appName")} • ${state.tr("bishoftu")}\n${state.tr("customerTrustPill")} • ${state.customerPhoneBookingNumber}',
        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}
