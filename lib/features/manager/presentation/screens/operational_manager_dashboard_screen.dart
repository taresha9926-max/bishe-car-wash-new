import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/closing_sync_warning_banner.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/online_booking_alert_banner.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/presentation/state/app_state_notifier.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../cashier/presentation/screens/daily_closing_dialog.dart';
import '../../../cashier/presentation/widgets/station_bottom_nav_bar.dart';
import '../../../cashier/presentation/widgets/station_money_tab.dart';
import '../../../cashier/presentation/widgets/station_queue_tab.dart';
import '../../../cashier/presentation/widgets/station_retail_pos_card.dart';
import '../../../cashier/presentation/widgets/station_shower_card.dart';
import 'package:bishe_car_wash/features/admin/presentation/widgets/bishe_ai_executive_sheet.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';

/// Option 1 Operational Manager Action Desk (Night Shift):
/// Mirrors Day Shift 4-service cards (Car Wash, Carpet Wash, Shower, Retail Sales),
/// bottom 4-tab bar, inline Cashier/Admin OTP banners, and Handover & Night Close desk.
class OperationalManagerDashboardScreen extends StatefulWidget {
  const OperationalManagerDashboardScreen({super.key});

  @override
  State<OperationalManagerDashboardScreen> createState() =>
      _OperationalManagerDashboardScreenState();
}

class _OperationalManagerDashboardScreenState
    extends State<OperationalManagerDashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _managerInlineOtpController = TextEditingController();
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _managerInlineOtpController.dispose();
    super.dispose();
  }

  void _selectBottomTab(int index) {
    setState(() => _selectedTabIndex = index);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
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

    final activeDivisionQueue = getActiveDivisionQueue(state.bookings, state.isCarpetDivisionActive);
    final deskDivision = state.stationDeskDivision;
    final isWashDivision =
        deskDivision == StationDeskDivision.carWash || deskDivision == StationDeskDivision.carpetWash;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("operationalManagerTitle")} • ${state.activeStaffFullName}'
            : state.tr('operationalManagerTitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.liquidCyanNeon, size: 21),
            tooltip: state.tr('aiExecutiveTitle'),
            onPressed: () => BisheAiExecutiveSheet.show(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          controller: _scrollController,
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
                  DualServiceEntranceTabBar(
                    padding: const EdgeInsets.only(bottom: 12),
                    onServiceSelected: () => _selectBottomTab(0),
                  ),
                  _buildHandoverStatusBanners(context, state, isMobile),
                  const ClosingSyncWarningBanner(),
                  if (_selectedTabIndex == 0) ...[
                    if (isWashDivision) ...[
                      const OnlineBookingAlertBanner(),
                      PrimaryIntakeActionRow(isMobile: isMobile),
                      const SizedBox(height: 12),
                      StationQueueTab(
                        divisionQueue: activeDivisionQueue,
                        bay1: bay1,
                        bay2: bay2,
                        van: van,
                        isMobile: isMobile,
                        isManager: true,
                      ),
                    ] else if (deskDivision == StationDeskDivision.shower)
                      const StationShowerCard(isManager: true)
                    else
                      const StationRetailPosCard(isManager: true),
                  ] else if (_selectedTabIndex == 1)
                    StationMoneyTab(
                      isManager: true,
                      isMobile: isMobile,
                      onSwitchToTeamTab: () => setState(() => _selectedTabIndex = 2),
                    )
                  else if (_selectedTabIndex == 2)
                    SharedWasherCommissionHub(
                      state: state,
                      role: WasherHubRole.cashier,
                      isMobile: isMobile,
                      initiallyExpanded: true,
                      respectInitiallyExpanded: true,
                      showAssignedShareList: false,
                    )
                  else
                    VehicleHistoryScreen(
                      isEmbedded: true,
                      isCarpetFilter: state.isCarpetDivisionActive,
                      allowClearAll: false,
                    ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: StationBottomNavBar(
        selectedIndex: _selectedTabIndex,
        onTap: _selectBottomTab,
        isCarpet: state.isCarpetDivisionActive,
        activeQueueCount: activeDivisionQueue.length,
        drawerOrCustodyCash: state.managerCustodyCashETB,
        isManager: true,
        state: state,
      ),
    );
  }

  // ===========================================================================
  // TOP BANNERS: INDEPENDENT CASHIER OTP VERIFICATION & ADMIN NIGHT OTP
  // ===========================================================================

  Widget _buildHandoverStatusBanners(BuildContext context, dynamic state, bool isMobile) {
    final pendingCashier = state.pendingCashierHandover;
    final pendingAdmin = state.pendingAdminNightHandover;

    return Column(
      children: [
        if (pendingCashier != null) ...[
          _buildPendingCashierOtpCard(context, state, pendingCashier, isMobile),
          const SizedBox(height: 12),
        ],
        if (pendingAdmin != null) ...[
          _buildPendingAdminNightOtpCard(context, state, pendingAdmin, isMobile),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildPendingCashierOtpCard(BuildContext context, dynamic state, dynamic pending, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD97706), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFB45309), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.tr('acceptCashierHandover'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFB45309), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  CurrencyFormatter.format(pending.handoverCashAmount),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${pending.cashierName} • ${state.tr("cashierOtpSubmitPrompt")}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), fontWeight: FontWeight.w600),
          ),
          if ((state.handedOverToManagerBookings as List).isNotEmpty ||
              (pending.notes != null && pending.notes.toString().trim().isNotEmpty)) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.45)),
              ),
              child: Text(
                (state.handedOverToManagerBookings as List).isNotEmpty
                    ? '${state.tr("handedOverVehiclesTitle")} (${(state.handedOverToManagerBookings as List).length}): '
                        '${(state.handedOverToManagerBookings as List).map((v) => "${v.licensePlate}${v.payment.isPaid ? " [PAID]" : ""}").take(5).join(", ")}'
                    : pending.notes.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 48,
                child: TextField(
                  controller: _managerInlineOtpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: state.tr('enterOtp'),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleInlineManagerVerify(context, state),
                    icon: const Icon(Icons.verified_rounded, size: 18),
                    label: Text(
                      state.tr('verifyAndTakeCustody'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAdminNightOtpCard(BuildContext context, dynamic state, dynamic adminPending, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.65), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pin_rounded, color: Color(0xFF38BDF8), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.tr('adminNightHandoverCode'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state.tr('pendingAdminReceipt'),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '[ ${adminPending.handoverOtp ?? '----'} ]',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4, color: Color(0xFF38BDF8)),
                        ),
                        Text(
                          '${CurrencyFormatter.format(adminPending.handoverCashAmount)} ${state.tr("cashToAdminSuffix")}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () => _confirmAndUnlockNightShift(context, state),
                icon: const Icon(Icons.lock_open_rounded, size: 13, color: Color(0xFF38BDF8)),
                label: Text(
                  state.tr('cancelHandoverAndAddCars'),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => DailyClosingDialog.show(context, isManagerClosing: true),
                icon: const Icon(Icons.receipt_long_rounded, size: 13),
                label: Text(
                  state.tr('viewClosingVoucher'),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
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

  Future<void> _confirmAndUnlockNightShift(BuildContext context, dynamic state) async {
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
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: Text(state.tr('unlockShiftAction')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await state.unlockNightShiftClosing();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('shiftUnlockedSuccess')),
            backgroundColor: AppColors.cashGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleInlineManagerVerify(BuildContext context, dynamic state) async {
    final otp = _managerInlineOtpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(state.tr('enterFourDigitOtpError'))),
      );
      return;
    }

    final ok = await state.acceptCashierHandover(
      managerName: state.activeStaffFullName ?? 'Operational Manager',
      enteredOtp: otp,
    );

    if (context.mounted) {
      if (ok) {
        _managerInlineOtpController.clear();
        showClosingSyncResultSnackBar(
          context,
          state,
          successMessage: state.tr('handoverVerifiedSuccess'),
          successColor: const Color(0xFF059669),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text(state.tr('invalidHandoverOtp'))),
        );
      }
    }
  }
}
