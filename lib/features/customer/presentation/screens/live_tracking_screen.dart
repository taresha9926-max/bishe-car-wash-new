import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/receipt_image_helper.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/language_switcher_action.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/automotive_3d_car_view.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/live_wash_stepper.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? bookingId;

  const LiveTrackingScreen({
    super.key,
    this.bookingId,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _queriedBookingId;
  bool _showSearchHeader = false;
  bool _isOffline = false;
  Timer? _liveSyncTimer;

  @override
  void initState() {
    super.initState();
    _queriedBookingId = widget.bookingId;
    _startLiveSync();
  }

  void _startLiveSync() {
    _liveSyncTimer?.cancel();
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTesting) return;

    // Real-time automatic polling every 3.5 seconds to sync cashier/manager status updates instantly
    _liveSyncTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) async {
      if (!mounted) return;
      final state = AppStateProvider.of(context);
      final activeId = _queriedBookingId ?? state.activeTrackingBookingId;
      if (activeId != null && activeId.isNotEmpty) {
        final ok = await state.refreshActiveBooking(activeId);
        if (mounted) {
          if (!ok && !_isOffline) {
            setState(() => _isOffline = true);
          } else if (ok && _isOffline) {
            setState(() => _isOffline = false);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _liveSyncTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(dynamic state, {bool? isCarpet}) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final found = state.findBookingByPhoneOrPlate(query, isCarpet: isCarpet);
    if (found != null) {
      setState(() {
        _queriedBookingId = found.id;
        _showSearchHeader = false;
      });
      state.setActiveTrackingBooking(found.id);
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
    final activeId = _queriedBookingId ?? state.activeTrackingBookingId;
    WashBooking? booking;
    if (activeId != null) {
      try {
        booking = state.bookings.firstWhere((b) => b.id == activeId);
      } catch (_) {}
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(state.tr('liveTrackingTitle')),
          actions: const [
            LanguageSwitcherAction(isDark: false),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.radar_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    !state.isCarWashDivisionActive ? state.tr('trackMyCarpet') : state.tr('trackMyCar'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    !state.isCarWashDivisionActive ? state.tr('trackCarpetPrompt') : state.tr('trackVehiclePrompt'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: !state.isCarWashDivisionActive ? state.tr('carpetTagOrPhoneHint') : state.tr('plateOrPhoneHint'),
                      prefixIcon: Icon(!state.isCarWashDivisionActive ? Icons.texture_rounded : Icons.directions_car_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                    ),
                    onSubmitted: (_) => _performSearch(state, isCarpet: !state.isCarWashDivisionActive),
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: state.tr('trackNow'),
                    icon: Icons.search,
                    onPressed: () => _performSearch(state, isCarpet: !state.isCarWashDivisionActive),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(state.tr('back')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final isCarpetBooking = booking.isCarpet;

    return Scaffold(
      appBar: AppBar(
        title: Text('${isCarpetBooking ? state.tr("carpetTrackingTitle") : state.tr("liveTrackingTitle")} • ${booking.licensePlate}'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF10B981),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  state.tr('liveBadge'),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const LanguageSwitcherAction(isDark: false),
          IconButton(
            icon: Icon(_showSearchHeader ? Icons.close : Icons.search_rounded),
            tooltip: state.tr('trackAnother'),
            onPressed: () {
              setState(() => _showSearchHeader = !_showSearchHeader);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => state.loadData(),
            tooltip: state.tr('refresh'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOffline) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade700, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.tr('offlineCachedStatus'),
                        style: const TextStyle(fontSize: 11.5, color: Colors.amber, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_showSearchHeader) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: isCarpetBooking ? state.tr('carpetTagOrPhoneHint') : state.tr('plateOrPhoneHint'),
                          hintStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (_) => _performSearch(state, isCarpet: isCarpetBooking),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _performSearch(state, isCarpet: isCarpetBooking),
                      child: Text(state.tr('trackNow'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
            // Unified Vehicle & 4-Phase Activity Hero Card (Side-by-Side)
            _buildVehicleDetailsCard(context, state, booking),
            const SizedBox(height: 20),

            // Horizontal Visual Live Progress Stepper
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                boxShadow: [
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
                    children: [
                      const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.tr('horizontalPipelineTitle'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          state.tr('liveTrackingTitle'),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.isCarpet
                        ? '${booking.licensePlate} • ${booking.carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
                        : '${booking.licensePlate} • ${booking.localizedServiceDisplayName(state.currentLang)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  LiveWashStepper(
                    currentStatus: booking.status,
                    isCarpet: booking.isCarpet,
                    serviceType: booking.serviceType,
                  ),
                ],
              ),
            ),
            if (booking.payment.isPaid) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('digitalReceiptTitle'),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          Text(
                            '${booking.payment.method.displayName} • ${state.tr('paymentVerifiedBadge')}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ReceiptImageHelper.showDigitalReceiptDialog(context, booking!, state: state),
                      icon: const Icon(Icons.visibility_rounded, size: 14, color: AppColors.liquidCyanNeon),
                      label: Text(
                        state.tr('viewDigitalReceipt'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.liquidCyanNeon),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.liquidCyanNeon),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Facility Contact Assistance
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 28, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bishoftu Station Desk: ${state.customerPhoneBookingNumber}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          state.tr('stationHoursDaily'),
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    onPressed: () {
                      final phone = state.customerPhoneBookingNumber as String;
                      UrlLauncherHelper.openUrl('tel:$phone');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsCard(BuildContext context, dynamic state, WashBooking booking) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 740;

    final vehicleInfoWidget = _buildVehicleInfoColumn(context, state, booking);
    final phaseGridWidget = _buildPhaseGrid(context, state, booking);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                vehicleInfoWidget,
                const Divider(height: 28, color: Color(0xFF1F2937)),
                phaseGridWidget,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: vehicleInfoWidget),
                const SizedBox(width: 18),
                Container(width: 1, height: 230, color: const Color(0xFF1F2937)),
                const SizedBox(width: 18),
                Expanded(flex: 6, child: phaseGridWidget),
              ],
            ),
    );
  }

  Widget _buildVehicleInfoColumn(BuildContext context, dynamic state, WashBooking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.liquidCyanNeon, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.liquidCyanNeon.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                booking.licensePlate,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: booking.status.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: booking.status.color.withValues(alpha: 0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(booking.status.icon, size: 11, color: booking.status.color),
                  const SizedBox(width: 4),
                  Text(
                    booking.status.localizedName(state.currentLang),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: booking.status.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusCompleted.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.4)),
              ),
              child: Text(
                booking.isCarpet
                    ? (booking.carpetType == 'type_b' ? state.tr('carpetTypeB') : state.tr('carpetTypeA'))
                    : booking.carType.localizedName(state.currentLang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.statusCompleted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          booking.isCarpet
              ? '${state.tr("carpetService")}${booking.carpetDimensions != null && booking.carpetDimensions!.isNotEmpty ? " • ${booking.carpetDimensions}" : ""}'
              : booking.localizedServiceDisplayName(state.currentLang),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          booking.isCarpet
              ? (booking.carpetAreaSqMeters != null ? '${booking.carpetAreaSqMeters!.toStringAsFixed(1)} m²' : '')
              : '${booking.carType.localizedName(state.currentLang)} • BISHE Auto Care',
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailSubItem(
                  icon: booking.isCarpet ? Icons.layers_rounded : Icons.garage_rounded,
                  label: booking.isCarpet ? state.tr('carpetWashFloor') : state.tr('bay'),
                  value: booking.isCarpet
                      ? (booking.status == WashStatus.drying || booking.status == WashStatus.readyForPickup
                          ? state.tr('carpetDryingRacks')
                          : state.tr('carpetWashFloor'))
                      : (booking.assignedBay != null
                          ? booking.assignedBay!.localizedName(state.currentLang)
                          : state.tr('pending')),
                  color: booking.isCarpet ? const Color(0xFF4F46E5) : (booking.assignedBay?.color ?? AppColors.textMuted),
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.cardBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildDetailSubItem(
                    icon: Icons.badge_outlined,
                    label: state.tr('washer'),
                    value: booking.assignedWasherName ?? state.tr('assignedTeam'),
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (booking.deliveryLocation != null) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 15,
                color: booking.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${booking.isCarpet ? state.tr("carpetPickUpLocation") : (booking.serviceType == ServiceType.valetPickUp ? state.tr("driverPickUpLocation") : state.tr("locationArea"))}: ${booking.deliveryLocation}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPhaseGrid(BuildContext context, dynamic state, WashBooking booking) {
    final status = booking.status;
    final isCarpet = booking.isCarpet;

    int activePhase = 0;
    if (status == WashStatus.completed || status == WashStatus.readyForPickup) {
      activePhase = 4;
    } else if (status == WashStatus.drying) {
      activePhase = 3;
    } else if (status == WashStatus.washing) {
      activePhase = 2;
    } else if (status != WashStatus.pending && status != WashStatus.cancelled) {
      activePhase = 1;
    }

    final phases = [
      (
        stageNumber: 1,
        title: state.tr('phaseApprovedArrived'),
        imagePath: isCarpet ? AutoCareAssets.carpetTypeAUrl : AutoCareAssets.phase1ArrivedDirtyAsset,
        icon: Icons.domain_verification_rounded,
      ),
      (
        stageNumber: 2,
        title: state.tr('phaseStartWash'),
        imagePath: isCarpet ? AutoCareAssets.carpetStationWashUrl : AutoCareAssets.phase2StartWashAsset,
        icon: Icons.wash_rounded,
      ),
      (
        stageNumber: 3,
        title: state.tr('phaseMoveToDrying'),
        imagePath: isCarpet ? AutoCareAssets.carpetDryingRackUrl : AutoCareAssets.phase3MoveDryingAsset,
        icon: Icons.dry_cleaning_rounded,
      ),
      (
        stageNumber: 4,
        title: state.tr('phaseCompletedReady'),
        imagePath: isCarpet ? AutoCareAssets.carpetValetPickupUrl : AutoCareAssets.phase4CompletedShowroomAsset,
        icon: Icons.check_circle_rounded,
      ),
    ];

    final counterText = activePhase == 0
        ? state.tr('waitingArrival')
        : (activePhase == 4
            ? state.tr('completedPhaseBadge')
            : '${state.tr('phaseCounter').toUpperCase()} $activePhase ${state.tr('ofTotal').toUpperCase()} 4');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.camera_alt_rounded, color: AppColors.liquidCyanNeon, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      state.tr('liveVehicleStatusVisualizer'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.liquidCyanNeon.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                counterText,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.liquidCyanNeon,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildPhaseCardItem(phases[0], activePhase, booking)),
            const SizedBox(width: 8),
            Expanded(child: _buildPhaseCardItem(phases[1], activePhase, booking)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildPhaseCardItem(phases[2], activePhase, booking)),
            const SizedBox(width: 8),
            Expanded(child: _buildPhaseCardItem(phases[3], activePhase, booking)),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseCardItem(
    ({int stageNumber, dynamic title, String imagePath, IconData icon}) phase,
    int activePhase,
    WashBooking booking,
  ) {
    final state = AppStateProvider.of(context);
    final isReached = activePhase >= phase.stageNumber;
    final isCurrent = activePhase == phase.stageNumber && booking.status != WashStatus.completed;
    final isDone = activePhase > phase.stageNumber || booking.status == WashStatus.completed;

    if (!isReached) {
      // Empty Slate Card (NO picture, text & pending indicator only)
      return Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 1.1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty_rounded, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(height: 5),
            Text(
              phase.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${state.tr('pendingStep')} ${phase.stageNumber}',
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    // Filled Action Photo Card (Loaded when stage is triggered)
    return Container(
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? AppColors.liquidCyanNeon
              : (isDone ? AppColors.statusCompleted : AppColors.cardBorder),
          width: isCurrent ? 2.0 : 1.2,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.liquidCyanNeon.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPhaseImage(phase.imagePath),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.60),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.88),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.liquidCyanNeon : AppColors.statusCompleted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCurrent ? state.tr('stepperCurrent').toUpperCase() : state.tr('stepperDone').toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.w900,
                      color: isCurrent ? const Color(0xFF031428) : const Color(0xFF022013),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Text(
                  phase.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF1E293B),
          child: const Center(
            child: Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 22),
          ),
        ),
      );
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 22),
        ),
      ),
    );
  }

  Widget _buildDetailSubItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
