import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../../auth_roles/domain/models/user_role.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_dispatcher.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'bank_deposit_dialog.dart';
import 'bay_assignment_modal.dart';
import 'daily_closing_dialog.dart';
import 'payment_process_dialog.dart';
import 'petty_cash_dialog.dart';
import 'phone_booking_dialog.dart';
import 'walk_in_registration_screen.dart';

enum _QueueStageFilter { all, waiting, inProgress, payReady }

/// Option 1 Cashier Action Desk: immediate live queue, unified money/closing desk,
/// and expanded team & shower workbench without hidden nested accordions.
class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _QueueStageFilter _stageFilter = _QueueStageFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDigitalBreakdownExpanded = false;
  bool _showShiftReports = false;
  int _showerCount = 1;
  PaymentMethod _showerPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final bays = state.bays;
    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    final activeDivisionQueue = _getActiveDivisionQueue(state.bookings, state.isCarpetDivisionActive);
    final pendingHandover = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
    final latestDayClosing = state.latestDayClosing;
    final isClosed = state.isTodayDayShiftClosed as bool;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("cashierTitle")} • ${state.activeStaffFullName}'
            : state.tr('cashierTitle'),
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 28 : (isMobile ? 12 : 20),
            vertical: isMobile ? 10 : 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DualServiceEntranceTabBar(padding: EdgeInsets.only(bottom: 12)),
                  if (pendingHandover != null)
                    _buildPendingOtpBanner(context, state, pendingHandover, isMobile)
                  else if (isClosed && latestDayClosing != null && latestDayClosing.isHandoverAccepted)
                    _buildVerifiedHandoverBanner(context, state, latestDayClosing),
                  _buildPrimaryIntakeRow(context, state, isMobile),
                  const SizedBox(height: 12),
                  _buildActionTabBar(state, activeDivisionQueue.length, isMobile),
                  const SizedBox(height: 14),
                  if (_tabController.index == 0)
                    _buildQueueTab(context, state, activeDivisionQueue, bay1, bay2, van, isMobile)
                  else if (_tabController.index == 1)
                    _buildMoneyTab(context, state, pendingHandover, latestDayClosing, isClosed, isMobile)
                  else
                    _buildTeamAndShowerTab(context, state, isMobile),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryIntakeRow(BuildContext context, dynamic state, bool isMobile) {
    final isCarpet = state.isCarpetDivisionActive as bool;
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

  Widget _buildActionTabBar(dynamic state, int activeCount, bool isMobile) {
    final isCarpet = state.isCarpetDivisionActive as bool;
    final activeColor = isCarpet ? const Color(0xFF7C3AED) : AppColors.primary;
    final undeposited = state.undepositedCashTodayETB as double;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: [
          _buildCompactTab(
            icon: Icons.directions_car_filled_rounded,
            label: '${state.tr("cashierTabQueue")} ($activeCount)',
            isMobile: isMobile,
          ),
          _buildCompactTab(
            icon: Icons.account_balance_wallet_rounded,
            label: '${state.tr("cashierTabMoney")} (${CurrencyFormatter.formatShort(undeposited)})',
            isMobile: isMobile,
          ),
          _buildCompactTab(
            icon: Icons.groups_rounded,
            label: state.tr('cashierTabTeamShower'),
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Tab _buildCompactTab({required IconData icon, required String label, required bool isMobile}) {
    return Tab(
      height: 40,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 15 : 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 11.5 : 12.5),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: LIVE QUEUE & BAYS
  // ===========================================================================

  Widget _buildQueueTab(
    BuildContext context,
    dynamic state,
    List<WashBooking> divisionQueue,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
    bool isMobile,
  ) {
    final isCarpet = state.isCarpetDivisionActive as bool;
    final waitingCount = divisionQueue.where(_isWaitingStatus).length;
    final inProgressCount = divisionQueue.where(_isInProgressStatus).length;
    final payReadyCount = divisionQueue.where(_isPayReadyStatus).length;

    final filtered = _applyQueueFilters(divisionQueue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStationCapacityBar(state, bay1, bay2, van, isMobile),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(_QueueStageFilter.all, '${state.tr("cashierFilterAll")} (${divisionQueue.length})', isCarpet),
              _buildFilterChip(_QueueStageFilter.waiting, '${state.tr("cashierFilterWaiting")} ($waitingCount)', isCarpet),
              _buildFilterChip(_QueueStageFilter.inProgress, '${state.tr("cashierFilterInProgress")} ($inProgressCount)', isCarpet),
              _buildFilterChip(_QueueStageFilter.payReady, '${state.tr("cashierFilterPayReady")} ($payReadyCount)', isCarpet),
            ],
          ),
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
          ...filtered.map((b) => _buildQueueOrderCard(context, state, b, isMobile)),
      ],
    );
  }

  Widget _buildFilterChip(_QueueStageFilter filter, String label, bool isCarpet) {
    final isSelected = _stageFilter == filter;
    final activeColor = filter == _QueueStageFilter.payReady
        ? AppColors.cashGreen
        : (isCarpet ? const Color(0xFF7C3AED) : AppColors.primary);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
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
      ),
    );
  }

  Widget _buildQueueOrderCard(BuildContext context, dynamic state, WashBooking b, bool isMobile) {
    final langCode = state.currentLang as String;
    final bayLabel = b.assignedBay != null ? b.assignedBay!.localizedName(langCode) : state.tr('unassignedBay');
    final washerLabel = b.assignedWasherName != null && b.assignedWasherName!.isNotEmpty ? ' • ${b.assignedWasherName}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPayReadyStatus(b) ? AppColors.cashGreen.withOpacity(0.45) : AppColors.cardBorder,
          width: _isPayReadyStatus(b) ? 1.5 : 1,
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
                width: isMobile ? 40 : 46,
                height: isMobile ? 40 : 46,
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
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
                  onTap: () => _openMapLocation(context, b),
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
              if (b.isCarpet && _isWaitingStatus(b))
                OutlinedButton.icon(
                  onPressed: () => _sendCarpetIntakeSmsWithFeedback(context, state, b),
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
              _buildNextStepActionButton(context, state, b, langCode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepActionButton(BuildContext context, dynamic state, WashBooking b, String langCode) {
    if (_isWaitingStatus(b)) {
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
    if (_isPayReadyStatus(b)) {
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

  // ===========================================================================
  // TAB 1: MONEY, CLOSING & SAFE PAID HISTORY
  // ===========================================================================

  Widget _buildMoneyTab(
    BuildContext context,
    dynamic state,
    dynamic pendingHandover,
    DailyFinancialClosing? latestDayClosing,
    bool isClosed,
    bool isMobile,
  ) {
    final undepositedCash = state.undepositedCashTodayETB as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Ambiguity-free Physical Cash in Drawer Focus Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.tr('physicalCashInDrawer'),
                      style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.tr('filterToday'),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.format(undepositedCash),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Station Today KPI Strip
        _buildShiftSummaryBanner(state, isMobile),
        const SizedBox(height: 12),

        // 3. Handover Policy & Action Buttons + Digital Channels Breakdown
        _buildFinancialActionDesk(context, state, isMobile, pendingHandover, latestDayClosing, isClosed),
        const SizedBox(height: 16),

        // 4. Safe Today/Filtered Paid Receipts History (No bulk-delete danger for Cashier)
        Text(
          state.isCarpetDivisionActive ? state.tr('carpetWashHistoryTitle') : state.tr('carWashHistoryTitle'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        VehicleHistoryScreen(
          isEmbedded: true,
          isCarpetFilter: state.isCarpetDivisionActive,
          allowClearAll: false,
        ),
        const SizedBox(height: 14),

        // 5. Shift Closing Logs & Bank Deposits (Admin net profit / salary hidden for Cashier)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () => setState(() => _showShiftReports = !_showShiftReports),
                  leading: const Icon(Icons.summarize_rounded, color: AppColors.primary),
                  title: Text(
                    state.tr('dailyFinancialReportsTab'),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  trailing: Icon(
                    _showShiftReports ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ),
              if (_showShiftReports)
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: FinancialReportsView(isEmbedded: true, isCashierMode: true),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSummaryBanner(dynamic state, bool isMobile) {
    final commissionTitle = state.tr('commissionShort');
    final commissionSub = '${(state.teamCommissionRate * 100).toInt()}% (${state.presentWashersCount} ${state.tr("dutyWorkers")})';
    final revenueSub = state.isCarpetDivisionActive
        ? '${state.carpetWashBookings.where((b) => b.payment.isPaid).length} ${state.tr("myCarpetCleanings")}'
        : '${state.totalCompletedCarsToday} ${state.tr("carsWashed")}';

    final cols = [
      _buildKPIColumn(state.tr('todayRevenue'), CurrencyFormatter.formatShort(state.totalRevenueTodayETB), revenueSub, AppColors.primary, isMobile),
      _buildKPIColumn(state.tr('digitalPay'), CurrencyFormatter.formatShort(state.totalDigitalRevenueETB), state.tr('digitalPayments'), AppColors.telebirrBlue, isMobile),
      _buildKPIColumn(state.tr('cashCollected'), CurrencyFormatter.formatShort(state.totalCashRevenueETB), state.tr('atFrontDesk'), AppColors.cashGreen, isMobile),
      _buildKPIColumn(commissionTitle, CurrencyFormatter.formatShort(state.teamCommissionPoolTodayETB as double), commissionSub, AppColors.oromiaGold, isMobile),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: isMobile
          ? Column(
              children: [
                Row(children: [Expanded(child: cols[0]), const SizedBox(width: 8), Expanded(child: cols[1])]),
                const Divider(height: 16, color: AppColors.cardBorder),
                Row(children: [Expanded(child: cols[2]), const SizedBox(width: 8), Expanded(child: cols[3])]),
              ],
            )
          : Row(
              children: [
                Expanded(child: cols[0]),
                Container(width: 1, height: 36, color: AppColors.cardBorder),
                Expanded(child: cols[1]),
                Container(width: 1, height: 36, color: AppColors.cardBorder),
                Expanded(child: cols[2]),
                Container(width: 1, height: 36, color: AppColors.cardBorder),
                Expanded(child: cols[3]),
              ],
            ),
    );
  }

  Widget _buildKPIColumn(String title, String value, String sub, Color color, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 11 : 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(fontSize: isMobile ? 15.5 : 17, fontWeight: FontWeight.w900, color: color),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 10 : 10.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFinancialActionDesk(
    BuildContext context,
    dynamic state,
    bool isMobile,
    dynamic pendingHandover,
    DailyFinancialClosing? latestDayClosing,
    bool isClosed,
  ) {
    final methodRevenue = state.getRevenueByPaymentMethod() as Map<PaymentMethod, double>;
    final methodCounts = state.getTransactionCountByPaymentMethod() as Map<PaymentMethod, int>;
    final undepositedCash = state.undepositedCashTodayETB as double;
    final cashRevenue = methodRevenue[PaymentMethod.cash] ?? 0.0;
    final cashCount = methodCounts[PaymentMethod.cash] ?? 0;

    final digitalProviders = [
      (method: PaymentMethod.telebirr, label: state.tr('payTelebirr'), color: AppColors.telebirrBlue),
      (method: PaymentMethod.cbeBirr, label: state.tr('payCbeBirr'), color: AppColors.cbeBirrPurple),
      (method: PaymentMethod.bankOfAbyssinia, label: state.tr('payBankOfAbyssinia'), color: const Color(0xFFF59E0B)),
      (method: PaymentMethod.awashBank, label: state.tr('payAwashBank'), color: const Color(0xFFEA580C)),
      (method: PaymentMethod.dashenBank, label: state.tr('payDashenBank'), color: const Color(0xFF0284C7)),
      (method: PaymentMethod.otherBankTransfer, label: state.tr('payBank'), color: Colors.indigo),
    ];

    double digitalRevenue = 0.0;
    int digitalCount = 0;
    for (final p in digitalProviders) {
      digitalRevenue += methodRevenue[p.method] ?? 0.0;
      digitalCount += methodCounts[p.method] ?? 0;
    }

    final actions = [
      _buildDeskActionButton(
        onPressed: () => BankDepositDialog.show(context),
        color: Colors.indigo,
        icon: Icons.account_balance_rounded,
        title: state.tr('depositCashToBank'),
        subtitle: CurrencyFormatter.formatShort(undepositedCash),
      ),
      _buildDeskActionButton(
        onPressed: () => PettyCashDialog.show(context),
        color: Colors.deepOrange,
        icon: Icons.outbox_rounded,
        title: state.tr('logPettyCash'),
        subtitle: CurrencyFormatter.formatShort(state.todayPettyCashExpensesETB as double),
      ),
      _buildDeskActionButton(
        onPressed: () => DailyClosingDialog.show(context),
        color: pendingHandover != null
            ? const Color(0xFFD97706)
            : (isClosed ? AppColors.statusCompleted : AppColors.primary),
        icon: (isClosed || pendingHandover != null) ? Icons.verified_rounded : Icons.pin_rounded,
        title: pendingHandover != null
            ? 'OTP: [ ${pendingHandover.handoverOtp} ]'
            : (isClosed ? state.tr('dailyClosingConfirmed') : state.tr('confirmDailyClosingOtp')),
        subtitle: pendingHandover != null
            ? state.tr('viewVoucher')
            : (isClosed ? state.tr('shiftLockedLabel') : state.tr('reconcileAndGenerateOtp')),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingHandover == null && !(isClosed && latestDayClosing?.isHandoverAccepted == true)) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${state.tr("shiftHandoverMethodTitle")}: ${state.tr("shiftHandoverMethodDesc")}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (isMobile) ...[
            SizedBox(width: double.infinity, child: actions[0]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: actions[1]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: actions[2]),
          ] else
            Row(
              children: [
                Expanded(child: actions[0]),
                const SizedBox(width: 8),
                Expanded(child: actions[1]),
                const SizedBox(width: 8),
                Expanded(child: actions[2]),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPaymentSummaryTile(
                  label: state.tr('cashCollected'),
                  value: '${CurrencyFormatter.formatShort(cashRevenue)} ($cashCount)',
                  color: AppColors.cashGreen,
                  icon: Icons.payments_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isDigitalBreakdownExpanded = !_isDigitalBreakdownExpanded),
                  borderRadius: BorderRadius.circular(10),
                  child: _buildPaymentSummaryTile(
                    label: state.tr('digitalMoneyTransfer'),
                    value: '${CurrencyFormatter.formatShort(digitalRevenue)} ($digitalCount)',
                    color: AppColors.telebirrBlue,
                    icon: Icons.phonelink_ring_rounded,
                    trailingIcon: _isDigitalBreakdownExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ),
            ],
          ),
          if (_isDigitalBreakdownExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: digitalProviders.map((c) {
                  final amt = methodRevenue[c.method] ?? 0.0;
                  final cnt = methodCounts[c.method] ?? 0;
                  final hasPayments = amt > 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasPayments ? c.color.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: hasPayments ? c.color.withOpacity(0.35) : AppColors.cardBorder),
                    ),
                    child: Text(
                      '${c.label}: ${CurrencyFormatter.formatShort(amt)} ($cnt)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: hasPayments ? c.color : AppColors.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeskActionButton({
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Widget _buildPaymentSummaryTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, size: 18, color: color),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: TEAM ATTENDANCE & STATION SHOWER
  // ===========================================================================

  Widget _buildTeamAndShowerTab(BuildContext context, dynamic state, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStationShowerCard(context, state),
        const SizedBox(height: 14),
        SharedWasherCommissionHub(
          state: state,
          role: WasherHubRole.cashier,
          isMobile: isMobile,
          initiallyExpanded: true,
          respectInitiallyExpanded: true,
        ),
      ],
    );
  }

  Widget _buildStationShowerCard(BuildContext context, dynamic state) {
    final showerPrice = state.showerPricePerPerson as double;
    final totalToPay = _showerCount * showerPrice;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shower_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr('stationShowerService'),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        '${showerPrice.toStringAsFixed(0)} ETB ${state.tr("perPerson")} • ${state.tr("showerCommissionNotice")}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.todayShowerUserCount} ${state.tr("showerUsers")}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.tr('numberOfPersons'),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                onPressed: _showerCount > 1 ? () => setState(() => _showerCount--) : null,
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
              ),
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$_showerCount',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showerCount++),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              ),
              for (final n in [1, 2, 5])
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => setState(() => _showerCount += n),
                  child: Text('+$n'),
                ),
              if (_showerCount > 1)
                TextButton(
                  onPressed: () => setState(() => _showerCount = 1),
                  child: Text(state.tr('clear'), style: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payments_rounded, size: 15),
                      const SizedBox(width: 5),
                      Flexible(child: Text(state.tr('payCash'), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  selected: _showerPaymentMethod == PaymentMethod.cash,
                  onSelected: (val) {
                    if (val) setState(() => _showerPaymentMethod = PaymentMethod.cash);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_android_rounded, size: 15),
                      const SizedBox(width: 5),
                      Flexible(child: Text(state.tr('payTelebirr'), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  selected: _showerPaymentMethod == PaymentMethod.telebirr,
                  onSelected: (val) {
                    if (val) setState(() => _showerPaymentMethod = PaymentMethod.telebirr);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: '${state.tr("recordShowerEntry")} • ${CurrencyFormatter.format(totalToPay)}',
            icon: Icons.check_circle_rounded,
            backgroundColor: const Color(0xFF0284C7),
            onPressed: () async {
              final recordedCount = _showerCount;
              final cashierName = state.activeStaffFullName ?? 'Cashier';
              await state.recordShowerEntry(
                userCount: recordedCount,
                paymentMethod: _showerPaymentMethod,
                cashierName: cashierName,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.statusCompleted,
                    content: Text('${state.tr("showerRecordedToast")}: $recordedCount (${CurrencyFormatter.format(totalToPay)})'),
                  ),
                );
                setState(() => _showerCount = 1);
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildShowerStatTile(
                  state.tr('showerTotalRevenue'),
                  CurrencyFormatter.format(state.todayShowerRevenueETB as double),
                  const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShowerStatTile(
                  state.tr('cashCollected'),
                  CurrencyFormatter.format(state.todayShowerCashETB as double),
                  AppColors.cashGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShowerStatTile(
                  state.tr('digitalPay'),
                  CurrencyFormatter.format(state.todayShowerDigitalETB as double),
                  AppColors.telebirrBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowerStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PERSISTENT BANNERS (OTP PENDING / VERIFIED)
  // ===========================================================================

  Widget _buildPendingOtpBanner(BuildContext context, dynamic state, dynamic pendingHandover, bool isMobile) {
    final isAdmin = (pendingHandover.handoverTo as String).contains('Admin');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pin_rounded, color: Color(0xFFF59E0B), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('handoverOtpCode'),
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAdmin ? state.tr('waitingForAdminOtp') : state.tr('waitingForManager'),
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '[ ${pendingHandover.handoverOtp ?? '----'} ]',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${CurrencyFormatter.format(pendingHandover.handoverCashAmount)} ${state.tr("physicalCash")}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () => _confirmAndUnlockPendingShift(context, state),
                icon: const Icon(Icons.lock_open_rounded, size: 13, color: Color(0xFFF59E0B)),
                label: Text(
                  state.tr('cancelHandoverAndAddCars'),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => DailyClosingDialog.show(context),
                icon: const Icon(Icons.receipt_long_rounded, size: 13),
                label: Text(
                  state.tr('viewClosingVoucher'),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedHandoverBanner(BuildContext context, dynamic state, DailyFinancialClosing latestDayClosing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.tr("handoverVerifiedTitle")} • ${state.tr("verifiedBadge")}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                ),
                Text(
                  'OTP [ ${latestDayClosing.handoverOtp ?? '----'} ] • ${CurrencyFormatter.format(latestDayClosing.handoverCashAmount)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _handleUnlockShiftFromDashboard(context, state),
            icon: const Icon(Icons.lock_open_rounded, color: Color(0xFF047857), size: 13),
            label: Text(
              state.tr('unlockAndResumeShift'),
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF059669)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          IconButton(
            tooltip: state.tr('viewClosingVoucher'),
            icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 18),
            onPressed: () => DailyClosingDialog.show(context),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BAY / STATION CAPACITY STRIP
  // ===========================================================================

  Widget _buildStationCapacityBar(
    dynamic state,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
    bool isMobile,
  ) {
    final bookings = state.bookings as List<WashBooking>;
    final langCode = state.currentLang as String;

    if (state.isCarpetDivisionActive as bool) {
      final carpetActive = bookings.where((b) => b.isCarpet && b.status != WashStatus.cancelled && !(b.status == WashStatus.completed && b.payment.isPaid)).toList();
      final washing = carpetActive.where((b) => b.status == WashStatus.washing || b.status == WashStatus.assignedToBay || b.status == WashStatus.pending).toList();
      final drying = carpetActive.where((b) => b.status == WashStatus.drying).toList();
      final valet = carpetActive.where((b) => b.serviceType.requiresLocation && b.status != WashStatus.completed).toList();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 10),
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
                isMobile: isMobile,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniBayCard(
                title: state.tr('carpetDryingRacks'),
                isFree: drying.isEmpty,
                statusText: drying.isEmpty ? state.tr('availableNow') : '${drying.length} ${state.tr("activeLabel")}',
                icon: Icons.dry_cleaning_rounded,
                isMobile: isMobile,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniBayCard(
                title: state.tr('carpetValetDriver'),
                isFree: valet.isEmpty,
                statusText: valet.isEmpty ? state.tr('availableNow') : '${valet.length} ${state.tr("activeLabel")}',
                icon: Icons.local_shipping_rounded,
                isMobile: isMobile,
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

    final isBay1Free = active1 == null && bay1.isVacant;
    final isBay2Free = active2 == null && bay2.isVacant;
    final isVanFree = activeVan == null && van.isVacant;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 10),
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
              statusText: bayStatusText(isBay1Free, active1?.licensePlate ?? bay1.activeLicensePlate),
              icon: BayType.bay1.icon,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniBayCard(
              title: BayType.bay2.localizedName(langCode),
              isFree: isBay2Free,
              statusText: bayStatusText(isBay2Free, active2?.licensePlate ?? bay2.activeLicensePlate),
              icon: BayType.bay2.icon,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMiniBayCard(
              title: BayType.mobileVan.localizedName(langCode),
              isFree: isVanFree,
              statusText: bayStatusText(isVanFree, activeVan?.licensePlate ?? van.activeLicensePlate),
              icon: BayType.mobileVan.icon,
              isMobile: isMobile,
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
    required bool isMobile,
  }) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 7 : 8, horizontal: 8),
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
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 10.5 : 11.5, color: AppColors.textPrimary),
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
            style: TextStyle(fontSize: isMobile ? 9.5 : 10.5, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS: FILTERS, SHIFT UNLOCK DIALOGS, STATUS ADVANCE & SMS
  // ===========================================================================

  List<WashBooking> _getActiveDivisionQueue(List<WashBooking> bookings, bool isCarpetDivision) {
    return bookings.where((b) {
      if (b.status == WashStatus.cancelled) return false;
      if (b.isCarpet != isCarpetDivision) return false;
      return !(b.status == WashStatus.completed && b.payment.isPaid);
    }).toList();
  }

  bool _isWaitingStatus(WashBooking b) =>
      b.status == WashStatus.pending || b.status == WashStatus.assignedToBay || b.status == WashStatus.confirmed;

  bool _isInProgressStatus(WashBooking b) =>
      b.status == WashStatus.washing || b.status == WashStatus.drying;

  bool _isPayReadyStatus(WashBooking b) =>
      (b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && !b.payment.isPaid;

  List<WashBooking> _applyQueueFilters(List<WashBooking> divisionQueue) {
    final byStage = divisionQueue.where((b) {
      switch (_stageFilter) {
        case _QueueStageFilter.all:
          return true;
        case _QueueStageFilter.waiting:
          return _isWaitingStatus(b);
        case _QueueStageFilter.inProgress:
          return _isInProgressStatus(b);
        case _QueueStageFilter.payReady:
          return _isPayReadyStatus(b);
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

  Future<void> _sendCarpetIntakeSmsWithFeedback(BuildContext context, dynamic state, WashBooking b) async {
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
      final msg = next == WashStatus.completed
          ? (booking.isCarpet
              ? '${booking.licensePlate}: ${state.tr("carpetCompletionSmsSent")}'
              : '${booking.licensePlate}: $nextLabel')
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

  void _openMapLocation(BuildContext context, WashBooking b) {
    final query = b.gpsCoordinates ?? b.deliveryLocation ?? 'Bishoftu, Ethiopia';
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
    UrlLauncherHelper.openUrl(mapUrl);
  }

  Future<void> _confirmAndUnlockPendingShift(BuildContext context, dynamic state) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_open_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.tr('confirmUnlockShiftTitle'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(state.tr('confirmUnlockShiftDesc'), style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(state.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(state.tr('confirmUnlockAction')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await state.unlockDayShiftClosing();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('shiftUnlockedSuccess')),
            backgroundColor: AppColors.statusReady,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleUnlockShiftFromDashboard(BuildContext context, dynamic state) async {
    final pinController = TextEditingController();
    String? errorMessage;
    bool isVerifying = false;

    final unlocked = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.tr('enterManagerOrAdminPin'),
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.tr('managerOrAdminPinRequired'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: state.tr('enterPin'),
                    errorText: errorMessage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.pin_rounded),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(state.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: isVerifying
                    ? null
                    : () async {
                        final pin = pinController.text.trim();
                        if (pin.isEmpty) return;
                        setDialogState(() {
                          isVerifying = true;
                          errorMessage = null;
                        });
                        final isMgr = await state.authenticateRoleAsync(UserRole.manager, pin);
                        final isAdmin = isMgr ? false : await state.authenticateRoleAsync(UserRole.admin, pin);
                        if (isMgr || isAdmin) {
                          await state.unlockDayShiftClosing();
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } else {
                          setDialogState(() {
                            isVerifying = false;
                            errorMessage = state.tr('invalidManagerOrAdminPin');
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isVerifying
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(state.tr('unlock')),
              ),
            ],
          );
        },
      ),
    );

    pinController.dispose();

    if (unlocked == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('shiftUnlockedSuccess')),
          backgroundColor: AppColors.statusReady,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
