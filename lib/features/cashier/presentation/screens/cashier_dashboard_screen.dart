import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/online_booking_alert_banner.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/presentation/state/app_state_notifier.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/station_bottom_nav_bar.dart';
import '../widgets/station_money_tab.dart';
import '../widgets/station_queue_tab.dart';
import '../widgets/station_retail_pos_card.dart';
import '../widgets/station_shower_card.dart';
import 'package:bishe_car_wash/features/admin/presentation/widgets/bishe_ai_executive_sheet.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import 'daily_closing_dialog.dart';

/// Option 1 Cashier Action Desk: 4-service top cards (Car Wash, Carpet Wash, Shower, Retail Sales),
/// bottom 4-tab bar (Queue, Money, Daily Washer Pool, Wash History), and immediate bay control.
class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
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
    final pendingHandover = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
    final deskDivision = state.stationDeskDivision;
    final isWashDivision =
        deskDivision == StationDeskDivision.carWash || deskDivision == StationDeskDivision.carpetWash;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("cashierTitle")} • ${state.activeStaffFullName}'
            : state.tr('cashierTitle'),
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
                  if (pendingHandover != null)
                    _buildPendingOtpBanner(context, state, pendingHandover, isMobile),
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
                      ),
                    ] else if (deskDivision == StationDeskDivision.shower)
                      const StationShowerCard(isManager: false)
                    else
                      const StationRetailPosCard(isManager: false),
                  ] else if (_selectedTabIndex == 1)
                    StationMoneyTab(
                      isManager: false,
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
        drawerOrCustodyCash: state.cashierDrawerBalanceETB,
        isManager: false,
        state: state,
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
        gradient: const LinearGradient(
          colors: [Color(0xFF090D14), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warmAmberSunset.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmAmberSunset.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pin_rounded, color: AppColors.warmAmberSunset, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('handoverOtpCode'),
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warmAmberSunset.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warmAmberSunset.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isAdmin ? state.tr('waitingForAdminOtp') : state.tr('waitingForManager'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.warmAmberSunset),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.slateGlass,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.warmAmberSunset.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warmAmberSunset.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  pendingHandover.handoverOtp ?? '----',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.warmAmberSunset,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${CurrencyFormatter.format(pendingHandover.handoverCashAmount)} ${state.tr("physicalCash")}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
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

  // ===========================================================================
  // SHIFT UNLOCK DIALOGS
  // ===========================================================================

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
}
