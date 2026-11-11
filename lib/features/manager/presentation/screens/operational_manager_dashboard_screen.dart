import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../cashier/presentation/widgets/station_money_tab.dart';
import '../../../cashier/presentation/widgets/station_queue_tab.dart';

/// Option 1 Operational Manager Action Desk:
/// Immediate live Queue (with bay/washer dispatch), inline Cashier/Admin OTP banners,
/// clean Handover & Night Close desk + Safe History, and expanded Team roster.
class OperationalManagerDashboardScreen extends StatefulWidget {
  const OperationalManagerDashboardScreen({super.key});

  @override
  State<OperationalManagerDashboardScreen> createState() =>
      _OperationalManagerDashboardScreenState();
}

class _OperationalManagerDashboardScreenState
    extends State<OperationalManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _managerInlineOtpController = TextEditingController();

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
    _managerInlineOtpController.dispose();
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

    final activeDivisionQueue = getActiveDivisionQueue(state.bookings, state.isCarpetDivisionActive);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("operationalManagerTitle")} • ${state.activeStaffFullName}'
            : state.tr('operationalManagerTitle'),
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
                  _buildHandoverStatusBanners(context, state, isMobile),
                  if (state.closingCloudSyncError != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD97706)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 19),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.tr('closingCloudSyncRlsWarning'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  PrimaryIntakeActionRow(isMobile: isMobile),
                  const SizedBox(height: 12),
                  _buildActionTabBar(state, activeDivisionQueue.length, isMobile),
                  const SizedBox(height: 14),
                  if (_tabController.index == 0)
                    StationQueueTab(
                      divisionQueue: activeDivisionQueue,
                      bay1: bay1,
                      bay2: bay2,
                      van: van,
                      isMobile: isMobile,
                      isManager: true,
                    )
                  else if (_tabController.index == 1)
                    StationMoneyTab(
                      isManager: true,
                      isMobile: isMobile,
                      onSwitchToTeamTab: () => _tabController.animateTo(2),
                    )
                  else
                    SharedWasherCommissionHub(
                      state: state,
                      role: WasherHubRole.cashier,
                      isMobile: isMobile,
                      initiallyExpanded: true,
                      respectInitiallyExpanded: true,
                    ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
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
            label: '${state.tr("managerTabHandoverClose")} (${CurrencyFormatter.formatShort(undeposited)})',
            isMobile: isMobile,
          ),
          _buildCompactTab(
            icon: Icons.groups_rounded,
            label: '${state.tr("managerTabTeam")} (${state.presentWashersCount})',
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
          _buildPendingAdminNightOtpCard(state, pendingAdmin, isMobile),
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
                child: TextField(
                  controller: _managerInlineOtpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 4),
                  decoration: InputDecoration(
                    hintText: state.tr('enterOtp'),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleInlineManagerVerify(context, state),
                  icon: const Icon(Icons.verified_rounded, size: 17),
                  label: Text(
                    state.tr('verifyAndTakeCustody'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _buildPendingAdminNightOtpCard(dynamic state, dynamic adminPending, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.65), width: 1.5),
      ),
      child: Row(
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
    );
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
        final syncErr = state.closingCloudSyncError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: syncErr != null ? const Color(0xFFD97706) : const Color(0xFF059669),
            duration: Duration(seconds: syncErr != null ? 7 : 4),
            content: Text(syncErr != null ? state.tr('closingCloudSyncRlsWarning') : state.tr('handoverVerifiedSuccess')),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text(state.tr('invalidHandoverOtp'))),
        );
      }
    }
  }
}
