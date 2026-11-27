import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
import 'package:bishe_car_wash/core/widgets/app_role_header.dart';
import 'package:bishe_car_wash/core/widgets/responsive_layout.dart';
import 'package:bishe_car_wash/core/widgets/status_badge.dart';
import 'package:bishe_car_wash/core/widgets/tactile_bounce.dart';
import 'package:bishe_car_wash/features/admin/presentation/widgets/bishe_ai_executive_sheet.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_dispatcher.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/ad_video_showcase_card.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/customer_feedback_sheet.dart';

/// Direct customer dashboard after Splash:
/// - Tab 0 (Wash): "What would you like to wash today?" + Car & Carpet tabs opening booking directly
/// - Tab 1 (Track): Restored "Track My Vehicle / Carpet" lookup + Active Wash + TikTok Ad Reels
/// - Tab 2 (Station): Live Bay Queue + Phone Call Booking + Google Maps + Bishoftu Info
/// - Tab 3 (Feedback): Customer ratings & suggestions
class CustomerHomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const CustomerHomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late int _selectedTabIndex;
  bool _trackIsCarpet = false;
  final TextEditingController _trackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, 3);
  }

  @override
  void dispose() {
    _trackController.dispose();
    super.dispose();
  }

  void _openDirectBooking(BuildContext context, {required bool isCarpet}) {
    final state = AppStateProvider.read(context);
    state.setActiveServiceDivision(
      isCarpet ? ActiveServiceDivision.carpetWash : ActiveServiceDivision.carWash,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewBookingScreen(isCarpet: isCarpet),
      ),
    );
  }

  void _handleTrackLookup(BuildContext context, dynamic state, {required bool isCarpet}) {
    final query = _trackController.text.trim();
    if (query.isEmpty) return;
    final found = state.findBookingByPhoneOrPlate(query, isCarpet: isCarpet);
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

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final activeWash = state.activeTrackingBooking;
    final displayActiveWash = (activeWash != null &&
            activeWash.status != WashStatus.pending &&
            activeWash.status != WashStatus.cancelled)
        ? activeWash
        : null;

    final queueAhead = state.bookings
        .where((b) =>
            !b.isCarpet &&
            b.status != WashStatus.completed &&
            b.status != WashStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('appName'),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.liquidCyanNeon, size: 21),
            tooltip: state.tr('askBisheAiConcierge'),
            onPressed: () => BisheAiExecutiveSheet.show(context),
          ),
        ],
      ),
      body: switch (_selectedTabIndex) {
        1 => _buildTrackTab(context, state, isDesktop: isDesktop, activeWash: displayActiveWash),
        2 => _buildStationTab(context, state, isDesktop: isDesktop, isMobile: isMobile, queueAhead: queueAhead),
        3 => const CustomerFeedbackSheet(embedded: true),
        _ => _buildWashTab(context, state, isDesktop: isDesktop, queueAhead: queueAhead, activeWash: displayActiveWash),
      },
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A192F), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _selectedTabIndex == 1
              ? const Color(0xFFFE2C55)
              : (_selectedTabIndex == 3 ? AppColors.oromiaGold : AppColors.liquidCyanNeon),
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.local_car_wash_rounded),
              label: state.tr('bottomTabWash'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.radar_rounded),
              label: state.tr('bottomTabTrack'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.storefront_rounded),
              label: state.tr('bottomTabStation'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star_rounded),
              label: state.tr('bottomTabFeedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWashTab(
    BuildContext context,
    dynamic state, {
    required bool isDesktop,
    required List<WashBooking> queueAhead,
    required WashBooking? activeWash,
  }) {
    return RefreshIndicator(
      onRefresh: () => state.loadData(),
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.tr('whatToWashToday'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildServiceChoiceTab(
                          label: state.tr('carWashingService'),
                          imageUrl: AutoCareAssets.carSedanUrl,
                          fallbackIcon: Icons.local_car_wash_rounded,
                          colors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                          onTap: () => _openDirectBooking(context, isCarpet: false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildServiceChoiceTab(
                          label: state.tr('carpetWashingService'),
                          imageUrl: AutoCareAssets.carpetTypeAUrl,
                          fallbackIcon: Icons.texture_rounded,
                          colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                          onTap: () => _openDirectBooking(context, isCarpet: true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCompactLiveStatusCard(state, queueAhead),
                if (activeWash != null) ...[
                  const SizedBox(height: 14),
                  _buildActiveWashCard(context, state, activeWash),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackTab(
    BuildContext context,
    dynamic state, {
    required bool isDesktop,
    required WashBooking? activeWash,
  }) {
    final matchingActiveWash = (activeWash != null && activeWash.isCarpet == _trackIsCarpet)
        ? activeWash
        : null;

    return RefreshIndicator(
      onRefresh: () => state.loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Switch between tracking Car vs Carpet cleanly
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _trackIsCarpet = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_trackIsCarpet ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              state.tr('trackMyCar'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: !_trackIsCarpet ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _trackIsCarpet = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _trackIsCarpet ? const Color(0xFF4F46E5) : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              state.tr('trackMyCarpet'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _trackIsCarpet ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (matchingActiveWash != null) ...[
                  _buildActiveWashCard(context, state, matchingActiveWash),
                  const SizedBox(height: 14),
                ],
                _buildVehicleLookupCard(context, state, isCarpet: _trackIsCarpet),
                const SizedBox(height: 16),
                const AdVideoShowcaseCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationTab(
    BuildContext context,
    dynamic state, {
    required bool isDesktop,
    required bool isMobile,
    required List<WashBooking> queueAhead,
  }) {
    return RefreshIndicator(
      onRefresh: () => state.loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCompactLiveStatusCard(state, queueAhead),
                const SizedBox(height: 14),
                _buildPhoneBookingCard(context, state),
                const SizedBox(height: 12),
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
                            icon: const Icon(Icons.location_on_rounded, size: 17, color: AppColors.statusPending),
                            label: Text(
                              state.tr('openGoogleMaps'),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              side: const BorderSide(color: AppColors.cardBorder),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => state.goToWelcome(),
                            icon: const Icon(Icons.home_rounded, size: 17, color: AppColors.liquidCyanNeon),
                            label: Text(
                              state.tr('welcomeHub'),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.liquidCyanNeon),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF111827),
                              side: const BorderSide(color: AppColors.cardBorder),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      )
                    : Row(
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
                                backgroundColor: const Color(0xFF1E293B),
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => state.goToWelcome(),
                              icon: const Icon(Icons.home_rounded, size: 17, color: AppColors.liquidCyanNeon),
                              label: Text(
                                state.tr('welcomeHub'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.liquidCyanNeon),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFF111827),
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                _buildBishoftuLocationFooter(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChoiceTab({
    required String label,
    required String imageUrl,
    required IconData fallbackIcon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return BounceTappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoCareAssets.buildPhotoThumbnail(
              imageUrl: imageUrl,
              width: 48,
              height: 48,
              borderRadius: 12,
              fallbackIcon: fallbackIcon,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLiveStatusCard(dynamic state, List<WashBooking> queueAhead) {
    final stationQueue = queueAhead.where((b) => b.serviceType == ServiceType.walkInStation).toList();
    final carsAhead = stationQueue.length;
    final stationWaitMins = WashDispatcher.estimateStationWaitMinutes(
      availableBaysCount: state.availableBaysCount,
      queue: stationQueue,
    );
    final waitText = stationWaitMins == 0
        ? state.tr('readyNow')
        : '~$stationWaitMins ${state.tr('minWait')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liquidCyanNeon.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.liquidCyanNeon.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.liquidCyanNeon.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.liquidCyanNeon.withValues(alpha: 0.45)),
            ),
            child: const Icon(Icons.radar_rounded, color: AppColors.liquidCyanNeon, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.statusReady,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$carsAhead ${state.tr("carsAheadInQueue")}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${state.tr("estimatedBayArrival")}: $waitText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.liquidCyanNeon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleLookupCard(BuildContext context, dynamic state, {bool isCarpet = false}) {
    final accent = isCarpet ? const Color(0xFF4F46E5) : AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: accent.withOpacity(0.1),
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
                      isCarpet ? state.tr('trackMyCarpet') : state.tr('trackMyCar'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                    Text(
                      isCarpet ? state.tr('trackCarpetPrompt') : state.tr('trackVehiclePrompt'),
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
                  height: 48,
                  child: TextField(
                    controller: _trackController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: isCarpet ? state.tr('carpetTagOrPhoneHint') : state.tr('plateOrPhoneHint'),
                      hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      prefixIcon: Icon(
                        isCarpet ? Icons.texture_rounded : Icons.directions_car_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      fillColor: AppColors.surfaceVariant,
                      filled: true,
                    ),
                    onSubmitted: (_) => _handleTrackLookup(context, state, isCarpet: isCarpet),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _handleTrackLookup(context, state, isCarpet: isCarpet),
                  icon: const Icon(Icons.radar_rounded, size: 16),
                  label: Text(state.tr('trackNow'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
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

  Widget _buildActiveWashCard(BuildContext context, dynamic state, WashBooking wash) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: wash.status.color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: wash.status.color.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '${state.tr("appName")} • ${state.tr("bishoftu")}\n${state.tr("customerTrustPill")} • ${state.customerPhoneBookingNumber}',
        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}
