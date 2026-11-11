import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_dispatcher.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../screens/bay_assignment_modal.dart';
import '../screens/payment_process_dialog.dart';
import '../screens/phone_booking_dialog.dart';
import '../screens/walk_in_registration_screen.dart';

enum QueueStageFilter { all, onlineBookers, waiting, inProgress, payReady }

/// Shared two-button Walk-In & Phone intake bar used by Cashier & Operational Manager.
class PrimaryIntakeActionRow extends StatelessWidget {
  final bool isMobile;

  const PrimaryIntakeActionRow({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isCarpet = state.isCarpetDivisionActive;
    final walkInColor = isCarpet ? const Color(0xFF7C3AED) : AppColors.primary;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalkInRegistrationScreen(initialCarpetMode: isCarpet),
                ),
              );
            },
            icon: Icon(isCarpet ? Icons.texture_rounded : Icons.add_road_rounded, size: isMobile ? 18 : 20),
            label: Text(
              isCarpet ? state.tr('carpetIntakeRegister') : state.tr('newWalkIn'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12.5 : 13.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: walkInColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 13 : 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => PhoneBookingDialog.show(context, initialCarpetMode: isCarpet),
            icon: Icon(Icons.phone_in_talk_rounded, size: isMobile ? 18 : 20),
            label: Text(
              state.tr('registerPhoneBooking'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12.5 : 13.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 13 : 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Filters active queue orders for the currently active Car vs Carpet division.
List<WashBooking> getActiveDivisionQueue(List<WashBooking> bookings, bool isCarpetDivision) {
  return bookings.where((b) {
    if (b.status == WashStatus.cancelled) return false;
    if (b.isCarpet != isCarpetDivision) return false;
    final done = b.status == WashStatus.completed || b.status == WashStatus.readyForPickup;
    return !(done && b.payment.isPaid);
  }).toList();
}

/// Shared Option 1 Queue Tab used by Cashier and Operational Manager:
/// live bay strip, stage filter chips, search, bay/washer assignment, SMS, maps & stage advancement.
class StationQueueTab extends StatefulWidget {
  final List<WashBooking> divisionQueue;
  final StationBay bay1;
  final StationBay bay2;
  final StationBay van;
  final bool isMobile;
  final bool isManager;

  const StationQueueTab({
    super.key,
    required this.divisionQueue,
    required this.bay1,
    required this.bay2,
    required this.van,
    required this.isMobile,
    this.isManager = false,
  });

  @override
  State<StationQueueTab> createState() => _StationQueueTabState();
}

class _StationQueueTabState extends State<StationQueueTab> {
  QueueStageFilter _stageFilter = QueueStageFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isOnlineWaiting(WashBooking b) =>
      b.isOnlineBooking && b.status == WashStatus.pending;

  bool _isWaiting(WashBooking b) =>
      !_isOnlineWaiting(b) &&
      (b.status == WashStatus.pending || b.status == WashStatus.confirmed || b.status == WashStatus.assignedToBay);

  bool _isInProgress(WashBooking b) =>
      b.status == WashStatus.washing || b.status == WashStatus.drying;

  bool _isPayReady(WashBooking b) =>
      (b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && !b.payment.isPaid;

  List<WashBooking> _applyFilters() {
    final byStage = widget.divisionQueue.where((b) {
      switch (_stageFilter) {
        case QueueStageFilter.all:
          return true;
        case QueueStageFilter.onlineBookers:
          return _isOnlineWaiting(b);
        case QueueStageFilter.waiting:
          return _isWaiting(b);
        case QueueStageFilter.inProgress:
          return _isInProgress(b);
        case QueueStageFilter.payReady:
          return _isPayReady(b);
      }
    }).toList();

    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return byStage;
    return byStage.where((b) {
      return b.licensePlate.toLowerCase().contains(q) ||
          b.customerName.toLowerCase().contains(q) ||
          b.customerPhone.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isCarpet = state.isCarpetDivisionActive;
    final onlineCount = widget.divisionQueue.where(_isOnlineWaiting).length;
    final waitingCount = widget.divisionQueue.where(_isWaiting).length;
    final inProgressCount = widget.divisionQueue.where(_isInProgress).length;
    final payReadyCount = widget.divisionQueue.where(_isPayReady).length;
    final filtered = _applyFilters();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStationCapacityBar(state),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildFilterChip(QueueStageFilter.all, '${state.tr("cashierFilterAll")} (${widget.divisionQueue.length})', isCarpet),
            _buildFilterChip(QueueStageFilter.onlineBookers, '${state.tr("cashierFilterOnlineBookers")} ($onlineCount)', isCarpet),
            _buildFilterChip(QueueStageFilter.waiting, '${state.tr("cashierFilterWaiting")} ($waitingCount)', isCarpet),
            _buildFilterChip(QueueStageFilter.inProgress, '${state.tr("cashierFilterInProgress")} ($inProgressCount)', isCarpet),
            _buildFilterChip(QueueStageFilter.payReady, '${state.tr("cashierFilterPayReady")} ($payReadyCount)', isCarpet),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: state.tr('searchQueueHint'),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  isCarpet ? Icons.texture_rounded : Icons.local_car_wash_rounded,
                  size: 36,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  isCarpet ? state.tr('noCarpetsInQueue') : state.tr('noVehiclesInQueue'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )
        else
          ...filtered.map((b) => _buildQueueOrderCard(context, state, b)),
      ],
    );
  }

  Widget _buildFilterChip(QueueStageFilter filter, String label, bool isCarpet) {
    final isSelected = _stageFilter == filter;
    final activeColor = filter == QueueStageFilter.payReady
        ? AppColors.cashGreen
        : (filter == QueueStageFilter.onlineBookers
            ? const Color(0xFF4F46E5)
            : (isCarpet ? const Color(0xFF7C3AED) : AppColors.primary));

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? activeColor : AppColors.cardBorder),
      ),
      onSelected: (_) => setState(() => _stageFilter = filter),
    );
  }

  Widget _buildQueueOrderCard(BuildContext context, dynamic state, WashBooking b) {
    final langCode = state.currentLang as String;
    final bayLabel = b.assignedBay != null ? b.assignedBay!.localizedName(langCode) : state.tr('unassignedBay');
    final washerLabel = b.assignedWasherName != null && b.assignedWasherName!.isNotEmpty ? ' • ${b.assignedWasherName}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(widget.isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPayReady(b) ? AppColors.cashGreen.withOpacity(0.45) : AppColors.cardBorder,
          width: _isPayReady(b) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: b.isCarpet
                    ? (b.carpetType == 'type_b' ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carpetTypeAUrl)
                    : AutoCareAssets.getPackageImage(b.package),
                width: widget.isMobile ? 40 : 46,
                height: widget.isMobile ? 40 : 46,
                borderRadius: 10,
                fallbackIcon: b.isCarpet ? Icons.texture_rounded : Icons.local_car_wash_rounded,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          b.licensePlate,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: AppColors.textPrimary),
                        ),
                        if (b.isCarpet)
                          _buildMiniPill(
                            b.carpetType == 'type_b' ? state.tr('carpetTypeBadgeB') : state.tr('carpetTypeBadgeA'),
                            const Color(0xFF6366F1),
                            icon: Icons.texture_rounded,
                          )
                        else
                          _buildMiniPill(b.carType.localizedName(langCode), AppColors.textSecondary, neutral: true),
                        if (b.isOnlineBooking)
                          _buildMiniPill(state.tr('onlineBookingBadge'), const Color(0xFF4F46E5), icon: Icons.phone_android_rounded),
                        if (b.isHandedOverToManager && !b.isPostponed)
                          _buildMiniPill(
                            widget.isManager ? state.tr('fromDayCashierBadge') : state.tr('handedOverToManagerBadge'),
                            const Color(0xFF4338CA),
                            icon: Icons.swap_horiz_rounded,
                          ),
                        if (b.isPostponed)
                          _buildMiniPill(
                            b.postponedByRole == 'Operational Manager'
                                ? state.tr('postponedByManagerBadge')
                                : state.tr('postponedCarryOverBadge'),
                            const Color(0xFFD97706),
                            icon: Icons.schedule_send_rounded,
                          ),
                        if (b.payment.isPaid && b.status != WashStatus.completed && b.status != WashStatus.readyForPickup)
                          _buildMiniPill(state.tr('prepaidFinishWashBadge'), const Color(0xFF059669), icon: Icons.verified_rounded),
                        if (b.isPhoneBooking)
                          _buildMiniPill(state.tr('phoneOrderBadge'), AppColors.primary, icon: Icons.phone_in_talk_rounded),
                        if (b.serviceType == ServiceType.valetPickUp)
                          _buildMiniPill(state.tr('valetBadge'), const Color(0xFF7C3AED), icon: Icons.car_rental_rounded),
                        if (b.payment.tipAmount > 0)
                          _buildMiniPill(
                            '+${CurrencyFormatter.formatShort(b.payment.tipAmount)} ${state.tr("tipBadgePrefix")}',
                            Colors.amber.shade900,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.isCarpet
                          ? '${b.carpetDimensions ?? "${b.carpetAreaSqMeters ?? 0.0} m²"}${b.customerName.isNotEmpty ? " • ${b.customerName}" : ""} • ${b.customerPhone}'
                          : '${b.localizedServiceDisplayName(langCode)}${b.customerName.isNotEmpty ? " • ${b.customerName}" : ""} • ${b.customerPhone}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    if (b.isHandedOverToManager &&
                        !b.isPostponed &&
                        b.handoverNote != null &&
                        b.handoverNote!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${b.handedOverBy != null ? "${b.handedOverBy}: " : ""}${b.handoverNote!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                      ),
                    ],
                    if (b.isPostponed && b.postponedReason != null && b.postponedReason!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${b.postponedByRole != null ? "${b.postponedByRole}: " : ""}${b.postponedReason!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.isMobile ? 116 : 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: b.status.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.status.localizedName(langCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: b.status.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(b.totalPrice),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (b.serviceType.requiresLocation) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    b.deliveryLocation ?? b.gpsCoordinates ?? (b.serviceType == ServiceType.valetPickUp ? state.tr('valetPickupInBishoftu') : state.tr('bishoftuMobileVan')),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _openMapLocation(b),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          state.tr('openInMaps'),
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!b.payment.isPaid)
                OutlinedButton.icon(
                  onPressed: () => BayAssignmentModal.show(context, b),
                  icon: Icon(
                    b.assignedBay?.icon ?? Icons.edit_location_alt_rounded,
                    size: 14,
                    color: b.assignedBay?.color ?? AppColors.textSecondary,
                  ),
                  label: Text(
                    '$bayLabel$washerLabel',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              if (b.isCarpet && _isWaiting(b))
                OutlinedButton.icon(
                  onPressed: () => _sendCarpetIntakeSms(context, state, b),
                  icon: const Icon(Icons.sms_rounded, size: 14, color: Color(0xFF7C3AED)),
                  label: Text(
                    state.tr('sendCarpetIntakeSms'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF7C3AED)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              if (widget.isManager &&
                  !_isOnlineWaiting(b) &&
                  b.status != WashStatus.completed &&
                  b.status != WashStatus.readyForPickup)
                OutlinedButton.icon(
                  onPressed: () => _showPostponeDialog(context, state, b),
                  icon: const Icon(Icons.schedule_send_rounded, size: 14, color: Color(0xFFD97706)),
                  label: Text(
                    state.tr('postponeNextDayAction'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFFB45309)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD97706)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              _buildNextStepButton(context, state, b, langCode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepButton(BuildContext context, dynamic state, WashBooking b, String langCode) {
    if (_isOnlineWaiting(b)) {
      return _actionButton(
        color: const Color(0xFF4F46E5),
        icon: Icons.how_to_reg_rounded,
        label: state.tr('approveAndArrivedAction'),
        onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.confirmed),
      );
    }
    if (_isWaiting(b)) {
      return _actionButton(
        color: b.isCarpet ? const Color(0xFF7C3AED) : AppColors.primary,
        icon: Icons.play_arrow_rounded,
        label: b.isCarpet ? state.tr('startWashFloorAction') : state.tr('startWashAction'),
        onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.washing),
      );
    }
    if (b.status == WashStatus.washing) {
      return _actionButton(
        color: b.isCarpet ? const Color(0xFF6366F1) : AppColors.bay1Color,
        icon: Icons.air_rounded,
        label: b.isCarpet ? state.tr('moveToDryingRacksAction') : state.tr('moveToDryingAction'),
        onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.drying),
      );
    }
    if (b.status == WashStatus.drying) {
      return _actionButton(
        color: b.isCarpet ? const Color(0xFF059669) : AppColors.bay2Color,
        icon: Icons.check_circle_outline_rounded,
        label: b.isCarpet ? state.tr('markCarpetReadyAction') : state.tr('markCompletedAction'),
        onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.completed),
      );
    }
    if (_isPayReady(b)) {
      return _actionButton(
        color: AppColors.cashGreen,
        icon: Icons.payments_rounded,
        label: '${state.tr("collectPaymentAction")} (${CurrencyFormatter.formatShort(b.totalPrice)})',
        onPressed: () => PaymentProcessDialog.show(context, b),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusCompleted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${state.tr("settledPaidBadge")} (${b.payment.method.localizedName(langCode)})',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
      ),
    );
  }

  Widget _actionButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildMiniPill(String text, Color color, {IconData? icon, bool neutral = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: neutral ? AppColors.surfaceVariant : color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCapacityBar(dynamic state) {
    final bookings = state.bookings as List<WashBooking>;
    final langCode = state.currentLang as String;

    if (state.isCarpetDivisionActive as bool) {
      final carpetActive = bookings.where((b) => b.isCarpet && b.status != WashStatus.cancelled && !((b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && b.payment.isPaid)).toList();
      final washing = carpetActive.where((b) => b.status == WashStatus.washing || b.status == WashStatus.assignedToBay || b.status == WashStatus.pending).toList();
      final drying = carpetActive.where((b) => b.status == WashStatus.drying).toList();
      final valet = carpetActive.where((b) => b.serviceType.requiresLocation && b.status != WashStatus.completed).toList();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 10 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildMiniBayCard(
                title: state.tr('carpetWashFloor'),
                isFree: washing.isEmpty,
                statusText: washing.isEmpty ? state.tr('availableNow') : '${washing.length} ${state.tr("activeLabel")}',
                icon: Icons.waves_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniBayCard(
                title: state.tr('carpetDryingRacks'),
                isFree: drying.isEmpty,
                statusText: drying.isEmpty ? state.tr('availableNow') : '${drying.length} ${state.tr("activeLabel")}',
                icon: Icons.dry_cleaning_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniBayCard(
                title: state.tr('carpetValetDriver'),
                isFree: valet.isEmpty,
                statusText: valet.isEmpty ? state.tr('availableNow') : '${valet.length} ${state.tr("activeLabel")}',
                icon: Icons.local_shipping_rounded,
              ),
            ),
          ],
        ),
      );
    }

    WashBooking? active1;
    WashBooking? active2;
    WashBooking? activeVan;
    for (final b in bookings) {
      if (!b.isCarpet && (b.status == WashStatus.washing || b.status == WashStatus.drying || b.status == WashStatus.assignedToBay)) {
        if (b.assignedBay == BayType.bay1 && active1 == null) {
          active1 = b;
        } else if (b.assignedBay == BayType.bay2 && active2 == null) {
          active2 = b;
        } else if ((b.assignedBay == BayType.mobileVan || b.serviceType == ServiceType.atHomeMobile) && activeVan == null) {
          activeVan = b;
        }
      }
    }

    final busyPrefix = state.tr('busyLabel');
    String bayStatusText(bool isFree, String? plate) =>
        isFree ? state.tr('availableNow') : (plate != null && plate.isNotEmpty ? '$busyPrefix ($plate)' : state.tr('busyWashing'));

    final isBay1Free = active1 == null && widget.bay1.isVacant;
    final isBay2Free = active2 == null && widget.bay2.isVacant;
    final isVanFree = activeVan == null && widget.van.isVacant;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 10 : 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniBayCard(
              title: BayType.bay1.localizedName(langCode),
              isFree: isBay1Free,
              statusText: bayStatusText(isBay1Free, active1?.licensePlate ?? widget.bay1.activeLicensePlate),
              icon: BayType.bay1.icon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniBayCard(
              title: BayType.bay2.localizedName(langCode),
              isFree: isBay2Free,
              statusText: bayStatusText(isBay2Free, active2?.licensePlate ?? widget.bay2.activeLicensePlate),
              icon: BayType.bay2.icon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniBayCard(
              title: BayType.mobileVan.localizedName(langCode),
              isFree: isVanFree,
              statusText: bayStatusText(isVanFree, activeVan?.licensePlate ?? widget.van.activeLicensePlate),
              icon: BayType.mobileVan.icon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBayCard({
    required String title,
    required bool isFree,
    required String statusText,
    required IconData icon,
  }) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;
    return Container(
      padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 7 : 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: widget.isMobile ? 10.5 : 11.5, color: AppColors.textPrimary),
                ),
              ),
              Icon(icon, size: 13, color: color),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: widget.isMobile ? 9.5 : 10.5, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _sendCarpetIntakeSms(BuildContext context, dynamic state, WashBooking b) async {
    await state.sendCarpetRegistrationSms(b);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('carpetIntakeSmsSent')),
          backgroundColor: const Color(0xFF7C3AED),
          action: SnackBarAction(
            label: state.tr('copySms'),
            textColor: Colors.amberAccent,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: state.getCarpetRegistrationSmsText(b)));
            },
          ),
        ),
      );
    }
  }

  Future<void> _advanceBookingStatus(
    BuildContext context,
    WashBooking booking, {
    WashStatus? targetStatus,
  }) async {
    final state = AppStateProvider.read(context);
    final next = targetStatus ??
        ((booking.status == WashStatus.drying || booking.status == WashStatus.readyForPickup)
            ? WashStatus.completed
            : WashDispatcher.nextStatus(booking.status));
    if (next == null) return;

    await state.updateWashStatus(booking.id, next);
    if (next == WashStatus.completed) {
      await state.sendCustomerCompletionSms(booking);
    }

    if (context.mounted) {
      final nextLabel = next.localizedName(state.currentLang);
      final msg = next == WashStatus.completed && booking.isCarpet
          ? '${booking.licensePlate}: ${state.tr("carpetCompletionSmsSent")}'
          : '${booking.licensePlate}: $nextLabel';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: next == WashStatus.completed ? AppColors.cashGreen : next.color,
          action: next == WashStatus.completed
              ? SnackBarAction(
                  label: state.tr('copySms'),
                  textColor: Colors.amberAccent,
                  onPressed: () {
                    final sms = state.getCustomerCompletionSmsText(booking);
                    Clipboard.setData(ClipboardData(text: sms));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.tr('smsCopiedClipboard')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                )
              : null,
          content: Row(
            children: [
              Icon(
                next == WashStatus.completed ? Icons.sms_rounded : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700))),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _showPostponeDialog(BuildContext context, dynamic state, WashBooking b) async {
    String reason = '';
    final requireReason = widget.isManager;
    String? errorMsg;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.schedule_send_rounded, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('postponeDialogTitle'),
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${b.licensePlate} • ${state.tr("postponeDialogDesc")}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
              ),
              if (requireReason) ...[
                const SizedBox(height: 8),
                Text(
                  state.tr('postponeReasonRequiredLabel'),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                initialValue: reason,
                onChanged: (v) {
                  reason = v;
                  if (errorMsg != null) {
                    setDialogState(() => errorMsg = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: state.tr('postponeReasonHint'),
                  errorText: errorMsg,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(state.tr('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
              onPressed: () {
                if (requireReason && reason.trim().isEmpty) {
                  setDialogState(() => errorMsg = state.tr('postponeReasonRequiredError'));
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: Text(state.tr('confirm')),
            ),
          ],
        ),
      ),
    );
    final trimmedReason = reason.trim();
    if (confirmed == true) {
      await state.postponeBookingToNextDay(
        bookingId: b.id,
        reason: trimmedReason.isNotEmpty ? trimmedReason : null,
        postponedByRole: widget.isManager ? 'Operational Manager' : 'Cashier',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${b.licensePlate}: ${state.tr("postponedSuccessMsg")}'), backgroundColor: const Color(0xFFD97706)),
        );
      }
    }
  }

  void _openMapLocation(WashBooking b) {
    final query = b.gpsCoordinates ?? b.deliveryLocation ?? 'Bishoftu, Ethiopia';
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
    UrlLauncherHelper.openUrl(mapUrl);
  }
}
