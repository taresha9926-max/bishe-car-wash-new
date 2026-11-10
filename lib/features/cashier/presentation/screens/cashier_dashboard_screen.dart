import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../../auth_roles/domain/models/user_role.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/station_money_tab.dart';
import '../widgets/station_queue_tab.dart';
import 'daily_closing_dialog.dart';

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
                    )
                  else if (_tabController.index == 1)
                    StationMoneyTab(
                      isManager: false,
                      isMobile: isMobile,
                      onSwitchToTeamTab: () => _tabController.animateTo(2),
                    )
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
