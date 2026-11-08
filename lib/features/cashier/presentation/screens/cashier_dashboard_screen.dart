import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_dispatcher.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'bank_deposit_dialog.dart';
import 'daily_closing_dialog.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../../auth_roles/domain/models/user_role.dart';
import 'payment_process_dialog.dart';
import 'petty_cash_dialog.dart';
import 'phone_booking_dialog.dart';
import 'walk_in_registration_screen.dart';
import 'weekly_commission_report_dialog.dart';
import '../../../../core/widgets/expandable_action_card.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';

class _CashierModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imageUrl;
  final List<Color> gradientColors;
  final String badgeText;
  final Color badgeColor;
  final Widget Function() contentBuilder;

  const _CashierModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageUrl,
    required this.gradientColors,
    required this.badgeText,
    required this.badgeColor,
    required this.contentBuilder,
  });
}

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedFilterIndex = 0; // 0: Queue & Vehicles, 1: Attendance & Commission Desk, 2: Wash History, 3: Closing & Financial Reports
  int? _activeModuleIndex;
  bool _isDigitalBreakdownExpanded = false;
  bool _isWasherRosterExpanded = true;
  int _showerCount = 1;
  PaymentMethod _showerPaymentMethod = PaymentMethod.cash;
  final _showerNotesController = TextEditingController();

  @override
  void dispose() {
    _showerNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final bays = state.bays;
    final allBookings = state.bookings;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    final filteredBookings = _getFilteredBookings(allBookings, state.isCarpetDivisionActive);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("cashierTitle")} • ${state.activeStaffFullName}'
            : state.tr('cashierTitle'),
      ),
      floatingActionButton: isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_phone_intake',
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  tooltip: state.tr('registerPhoneBooking'),
                  onPressed: () => PhoneBookingDialog.show(context, initialCarpetMode: state.isCarpetDivisionActive),
                  child: const Icon(Icons.phone_in_talk_rounded, size: 18),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.extended(
                  heroTag: 'fab_walk_in',
                  backgroundColor: state.isCarpetDivisionActive ? const Color(0xFF7C3AED) : AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: Icon(state.isCarpetDivisionActive ? Icons.texture_rounded : Icons.add_road_rounded, size: 18),
                  label: Text(
                    state.isCarpetDivisionActive ? state.tr('carpetIntakeRegister') : state.tr('newWalkIn'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalkInRegistrationScreen(initialCarpetMode: state.isCarpetDivisionActive),
                      ),
                    );
                  },
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_phone_intake',
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: Text(
                    state.tr('registerPhoneBooking'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  onPressed: () => PhoneBookingDialog.show(context, initialCarpetMode: state.isCarpetDivisionActive),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.extended(
                  heroTag: 'fab_walk_in',
                  backgroundColor: state.isCarpetDivisionActive ? const Color(0xFF7C3AED) : AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: Icon(state.isCarpetDivisionActive ? Icons.texture_rounded : Icons.add_road_rounded, size: 18),
                  label: Text(
                    state.isCarpetDivisionActive ? state.tr('carpetIntakeRegister') : state.tr('newWalkIn'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalkInRegistrationScreen(initialCarpetMode: state.isCarpetDivisionActive),
                      ),
                    );
                  },
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 28 : (isMobile ? 14 : 20),
            vertical: isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DualServiceEntranceTabBar(padding: EdgeInsets.only(bottom: 14)),
              // Active Cashier Handover OTP Banner (Visible when Day Closing submitted via OTP)
              Builder(
                builder: (context) {
                  final activePending = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
                  if (activePending == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: EdgeInsets.all(isMobile ? 12 : 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.pin_rounded, color: Color(0xFFF59E0B), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.tr('handoverOtpCode'),
                                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      activePending.handoverTo.contains('Admin')
                                          ? 'WAITING FOR ADMIN'
                                          : state.tr('waitingForManager'),
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    '[ ${activePending.handoverOtp ?? '----'} ]',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4, color: Color(0xFFF59E0B)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '• ${CurrencyFormatter.format(activePending.handoverCashAmount)} ${state.tr('physicalCash')}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Operational Modules Grid (Card Grid View with 3 Rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.tr('managementOperations'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 15.5 : 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '6 MODULES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCashierModulesGrid(context, state, isMobile, filteredBookings, bay1, bay2, van),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftSummaryBanner(dynamic state, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKPIColumn(
              state.tr('todayRevenue'),
              CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
              state.isCarpetDivisionActive
                  ? '${state.carpetWashBookings.where((b) => b.payment.isPaid).length} ${state.tr("myCarpetCleanings")}'
                  : '${state.totalCompletedCarsToday} ${state.tr("carsWashed")}',
              AppColors.primary,
              isMobile: isMobile,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('digitalPay'),
              CurrencyFormatter.formatShort(state.totalDigitalRevenueETB),
              state.tr('digitalPayments'),
              AppColors.telebirrBlue,
              isMobile: isMobile,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('cashCollected'),
              CurrencyFormatter.formatShort(state.totalCashRevenueETB),
              state.tr('atFrontDesk'),
              AppColors.cashGreen,
              isMobile: isMobile,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.currentLang == 'OM' ? 'Komishiinii' : (state.currentLang == 'AM' ? 'ኮሚሽን' : 'Commission'),
              CurrencyFormatter.formatShort(state.teamCommissionPoolTodayETB as double),
              '${(state.teamCommissionRate * 100).toInt()}% Pool (${state.presentWashersCount} Duty)',
              AppColors.oromiaGold,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIColumn(String title, String value, String sub, Color color, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 10.5 : 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(fontSize: isMobile ? 15 : 17, fontWeight: FontWeight.w900, color: color),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 9.5 : 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCashierOtpDesk(
    BuildContext context,
    dynamic state,
    bool isMobile,
    dynamic pendingHandover,
    DailyFinancialClosing? latestDayClosing,
    bool isClosed,
  ) {
    if (pendingHandover != null) {
      // Pending Manager OTP verification
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isMobile ? 12 : 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pin_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      state.tr('handoverOtpCode'),
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pendingHandover.handoverTo.contains('Admin')
                        ? 'WAITING FOR ADMIN'
                        : state.tr('waitingForManager'),
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
                    '• ${CurrencyFormatter.format(pendingHandover.handoverCashAmount)} ${state.tr('physicalCash')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pendingHandover.handoverTo.contains('Admin')
                        ? 'Give this 4-digit code to Admin after counting physical cash.'
                        : state.tr('waitingForManagerOtpDesc'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _confirmAndUnlockPendingShift(context, state),
                      icon: const Icon(Icons.lock_open_rounded, size: 12, color: Color(0xFFF59E0B)),
                      label: Text(
                        state.tr('cancelHandoverAndAddCars'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: () => DailyClosingDialog.show(context),
                      icon: const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFFF59E0B)),
                      label: Text(
                        state.tr('viewClosingVoucher'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B)),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (latestDayClosing != null && latestDayClosing.isHandoverAccepted) {
      // Completed & Verified
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.tr('handoverVerifiedTitle'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          state.tr('verifiedBadge'),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'OTP [ ${latestDayClosing.handoverOtp ?? '----'} ] • Custody transferred to ${latestDayClosing.acceptedByName ?? 'Manager'} (${CurrencyFormatter.format(latestDayClosing.handoverCashAmount)})',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _handleUnlockShiftFromDashboard(context, state),
                  icon: const Icon(Icons.lock_open_rounded, color: Color(0xFF047857), size: 13),
                  label: Text(
                    state.tr('unlockAndResumeShift'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF059669)),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: state.tr('viewClosingVoucher'),
                  icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 18),
                  onPressed: () => DailyClosingDialog.show(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Steady-state before closing (Always visible info desk!)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        state.tr('shiftHandoverMethodTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.tr('threePartyCustody'),
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  state.tr('shiftHandoverMethodDesc'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        content: Text(
          state.tr('confirmUnlockShiftDesc'),
          style: const TextStyle(fontSize: 13),
        ),
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
                Text(
                  state.tr('managerOrAdminPinRequired'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'PIN',
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

  Widget _buildFinancialActionToolbar(BuildContext context, dynamic state, bool isMobile) {
    final methodRevenue = state.getRevenueByPaymentMethod() as Map<PaymentMethod, double>;
    final methodCounts = state.getTransactionCountByPaymentMethod() as Map<PaymentMethod, int>;
    final undepositedCash = state.undepositedCashTodayETB as double;
    final isClosed = state.isTodayDayShiftClosed as bool;
    final pendingHandover = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
    final latestDayClosing = state.latestDayClosing;

    final cashRevenue = methodRevenue[PaymentMethod.cash] ?? 0.0;
    final cashCount = methodCounts[PaymentMethod.cash] ?? 0;

    final digitalProviders = [
      (method: PaymentMethod.telebirr, label: 'Telebirr', color: AppColors.telebirrBlue),
      (method: PaymentMethod.cbeBirr, label: 'CBE Birr', color: AppColors.cbeBirrPurple),
      (method: PaymentMethod.bankOfAbyssinia, label: 'BoA', color: const Color(0xFFF59E0B)),
      (method: PaymentMethod.awashBank, label: 'Awash Bank', color: const Color(0xFFEA580C)),
      (method: PaymentMethod.dashenBank, label: 'Dashen Bank', color: const Color(0xFF0284C7)),
      (method: PaymentMethod.otherBankTransfer, label: 'Other Bank', color: Colors.indigo),
    ];

    double digitalRevenue = 0.0;
    int digitalCount = 0;
    for (final p in digitalProviders) {
      digitalRevenue += methodRevenue[p.method] ?? 0.0;
      digitalCount += methodCounts[p.method] ?? 0;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
          // Permanent Shift Handover OTP Desk inside Daily Closing Section
          _buildCashierOtpDesk(context, state, isMobile, pendingHandover, latestDayClosing, isClosed),
          const SizedBox(height: 10),

          // 1. Fast Action Buttons: Deposit Cash, Log Petty Cash, & Confirm Daily Closing (OTP)
          if (isMobile) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => BankDepositDialog.show(context),
                icon: AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.cbeLogoUrl,
                  width: 22,
                  height: 22,
                  borderRadius: 6,
                  fallbackIcon: Icons.account_balance_rounded,
                  fallbackColor: Colors.white,
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        state.tr('depositCashToBank'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${CurrencyFormatter.formatShort(undepositedCash)} awaiting deposit',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PettyCashDialog.show(context),
                icon: AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.cashMoneyUrl,
                  width: 22,
                  height: 22,
                  borderRadius: 6,
                  fallbackIcon: Icons.outbox_rounded,
                  fallbackColor: Colors.white,
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        state.tr('logPettyCash'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${CurrencyFormatter.formatShort(state.todayPettyCashExpensesETB as double)} logged',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => DailyClosingDialog.show(context),
                icon: AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.stationBayUrl,
                  width: 22,
                  height: 22,
                  borderRadius: 6,
                  fallbackIcon: (isClosed || pendingHandover != null) ? Icons.verified_rounded : Icons.pin_rounded,
                  fallbackColor: Colors.white,
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pendingHandover != null
                            ? 'OTP: [ ${pendingHandover.handoverOtp} ] • ${state.tr('waitingForManager')}'
                            : (isClosed
                                ? (latestDayClosing?.isHandoverAccepted == true
                                    ? '${state.tr('dailyClosingConfirmed')} • ${state.tr('verifiedBadge')}'
                                    : state.tr('dailyClosingConfirmed'))
                                : state.tr('confirmDailyClosingOtp')),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pendingHandover != null
                          ? state.tr('viewClosingVoucher')
                          : (isClosed ? 'Shift locked' : state.tr('reconcileAndGenerateOtp')),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pendingHandover != null ? const Color(0xFFD97706) : (isClosed ? AppColors.statusCompleted : AppColors.primary),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Deposit Cash Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => BankDepositDialog.show(context),
                    icon: AutoCareAssets.buildPhotoThumbnail(
                      imageUrl: AutoCareAssets.cbeLogoUrl,
                      width: 22,
                      height: 22,
                      borderRadius: 6,
                      fallbackIcon: Icons.account_balance_rounded,
                      fallbackColor: Colors.white,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.tr('depositCashToBank'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                        Text(
                          '${CurrencyFormatter.formatShort(undepositedCash)} awaiting deposit',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Log Petty Cash Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => PettyCashDialog.show(context),
                    icon: AutoCareAssets.buildPhotoThumbnail(
                      imageUrl: AutoCareAssets.cashMoneyUrl,
                      width: 22,
                      height: 22,
                      borderRadius: 6,
                      fallbackIcon: Icons.outbox_rounded,
                      fallbackColor: Colors.white,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.tr('logPettyCash'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                        Text(
                          '${CurrencyFormatter.formatShort(state.todayPettyCashExpensesETB as double)} recorded',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Confirm Daily Closing (OTP) Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => DailyClosingDialog.show(context),
                    icon: AutoCareAssets.buildPhotoThumbnail(
                      imageUrl: AutoCareAssets.stationBayUrl,
                      width: 22,
                      height: 22,
                      borderRadius: 6,
                      fallbackIcon: (isClosed || pendingHandover != null) ? Icons.verified_rounded : Icons.pin_rounded,
                      fallbackColor: Colors.white,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pendingHandover != null
                              ? 'OTP: [ ${pendingHandover.handoverOtp} ]'
                              : (isClosed
                                  ? (latestDayClosing?.isHandoverAccepted == true
                                      ? '${state.tr('dailyClosingConfirmed')} • ${state.tr('verifiedBadge')}'
                                      : state.tr('dailyClosingConfirmed'))
                                  : state.tr('confirmDailyClosingOtp')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                        Text(
                          pendingHandover != null
                              ? state.tr('waitingForManager')
                              : (isClosed ? 'Shift locked • Reconciled' : state.tr('reconcileAndGenerateOtp')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pendingHandover != null ? const Color(0xFFD97706) : (isClosed ? AppColors.statusCompleted : AppColors.primary),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),

          // 2. Clear Categorized Breakdown: Cash Collected vs Digital Money Transfer
          Row(
            children: [
              // Category A: Cash Collected (Gate)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cashGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cashGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: AutoCareAssets.cashMoneyUrl,
                        width: 36,
                        height: 36,
                        borderRadius: 8,
                        fallbackIcon: Icons.payments_rounded,
                        fallbackColor: AppColors.cashGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.tr('cashCollected'),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.cashGreen),
                            ),
                            Text(
                              '${CurrencyFormatter.formatShort(cashRevenue)} ($cashCount)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Category B: Digital Money Transfer (Dropdown Trigger)
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isDigitalBreakdownExpanded = !_isDigitalBreakdownExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.telebirrBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isDigitalBreakdownExpanded
                            ? AppColors.telebirrBlue
                            : AppColors.telebirrBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: AutoCareAssets.cbeLogoUrl,
                          width: 36,
                          height: 36,
                          borderRadius: 8,
                          fallbackIcon: Icons.phonelink_ring_rounded,
                          fallbackColor: AppColors.telebirrBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.tr('digitalMoneyTransfer'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.telebirrBlue),
                              ),
                              Text(
                                '${CurrencyFormatter.formatShort(digitalRevenue)} ($digitalCount)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isDigitalBreakdownExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.telebirrBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2.1 Expandable Digital Providers Dropdown List
          if (_isDigitalBreakdownExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.tr("digitalMoneyTransfer")} Channels:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                      ),
                      Text(
                        'Total: ${CurrencyFormatter.format(digitalRevenue)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.telebirrBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
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
                          border: Border.all(
                            color: hasPayments ? c.color.withOpacity(0.35) : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.method.icon, size: 12, color: hasPayments ? c.color : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${c.label}: ',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: hasPayments ? c.color : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${CurrencyFormatter.formatShort(amt)} ($cnt)',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: hasPayments ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Mobile Queue Row: Stacked cards with generous touch targets and no horizontal overflows.
  Widget _buildCleanQueueRowMobile(BuildContext context, dynamic state, WashBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
          // Header Row: Avatar, License plate, car type pill, phone badge, status pill
          Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: b.isCarpet
                    ? (b.carpetType == 'type_b' ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carpetTypeAUrl)
                    : AutoCareAssets.getPackageImage(b.package),
                width: 36,
                height: 36,
                borderRadius: 8,
                fallbackIcon: b.isCarpet ? Icons.texture_rounded : Icons.local_car_wash_rounded,
              ),
              const SizedBox(width: 8),
              Text(
                b.licensePlate,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: AppColors.textPrimary),
              ),
              if (b.isCarpet) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.texture_rounded, size: 10, color: Color(0xFF6366F1)),
                      const SizedBox(width: 3),
                      Text(
                        b.carpetType == 'type_b' ? 'CARPET (TYPE B)' : 'CARPET (TYPE A)',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF6366F1)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    b.carType.displayName,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
              ],
              if (b.payment.tipAmount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+ETB ${b.payment.tipAmount.toStringAsFixed(0)} Tip',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.amber.shade900),
                  ),
                ),
              ],
              if (b.isPhoneBooking) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_in_talk, size: 10, color: AppColors.primary),
                      SizedBox(width: 2),
                      Text('Phone', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              if (b.serviceType == ServiceType.valetPickUp) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.car_rental_rounded, size: 10, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 2),
                      Text(state.tr('valetBadge'), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: b.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.status.displayName,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: b.status.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Details Row: Package name, customer & price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  b.isCarpet
                      ? 'Carpet Clean (${b.carpetDimensions ?? "${b.carpetAreaSqMeters ?? 0.0} m²"})${b.customerName != null && b.customerName!.isNotEmpty ? " • ${b.customerName}" : ""}'
                      : '${b.serviceDisplayName}${b.customerName != null && b.customerName!.isNotEmpty ? " • ${b.customerName}" : ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                CurrencyFormatter.format(b.totalPrice),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),

          // Location / GPS if mobile van or valet driver pick-up
          if (b.serviceType.requiresLocation) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 13,
                  color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    b.deliveryLocation ?? b.gpsCoordinates ?? (b.serviceType == ServiceType.valetPickUp ? state.tr("valetPickupInBishoftu") : state.tr("bishoftuMobileVan")),
                    style: TextStyle(
                      fontSize: 11,
                      color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _openMapLocation(context, b),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, size: 11, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          state.tr('openInMaps'),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
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

          // Full-width action button
          _buildActionButtonsMobile(context, state, b),
        ],
      ),
    );
  }

  Widget _buildActionButtonsMobile(BuildContext context, dynamic state, WashBooking b) {
    if (b.status == WashStatus.pending || b.status == WashStatus.assignedToBay || b.status == WashStatus.confirmed) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: b.isCarpet ? const Color(0xFF7C3AED) : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: Text(
                b.isCarpet ? state.tr('startWashFloorAction') : state.tr('startWashAction'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.washing),
            ),
          ),
          if (b.isCarpet) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  side: const BorderSide(color: Color(0xFF7C3AED), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.sms_rounded, size: 14),
                label: Text(
                  '${state.tr("sendCarpetIntakeSms")} (${b.licensePlate})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
                onPressed: () async {
                  await state.sendCarpetRegistrationSms(b);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.tr('carpetIntakeSmsSent')),
                        backgroundColor: const Color(0xFF7C3AED),
                        action: SnackBarAction(
                          label: 'Copy SMS',
                          textColor: Colors.amberAccent,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: state.getCarpetRegistrationSmsText(b)));
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      );
    } else if (b.status == WashStatus.washing) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: b.isCarpet ? const Color(0xFF6366F1) : AppColors.bay1Color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.air_rounded, size: 16),
          label: Text(
            b.isCarpet ? state.tr('moveToDryingRacksAction') : state.tr('moveToDryingAction'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.drying),
        ),
      );
    } else if (b.status == WashStatus.drying) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: b.isCarpet ? const Color(0xFF059669) : AppColors.bay2Color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
          label: Text(
            b.isCarpet ? state.tr('markCarpetReadyAction') : state.tr('markCompletedAction'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.completed),
        ),
      );
    } else if ((b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && !b.payment.isPaid) {
      final payLabel = state.currentLang == 'EN'
          ? 'Pay (${CurrencyFormatter.format(b.totalPrice)})'
          : '${state.tr("collectPaymentAction")} (${CurrencyFormatter.format(b.totalPrice)})';

      return SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cashGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.payments_rounded, size: 16),
          label: Text(
            payLabel,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
          ),
          onPressed: () => PaymentProcessDialog.show(context, b),
        ),
      );
    } else if (b.payment.isPaid) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.statusCompleted.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.statusCompleted.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 14, color: AppColors.statusCompleted),
            const SizedBox(width: 6),
            Text(
              'SETTLED & PAID (${b.payment.method.displayName})',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Tablet & Desktop Queue Row: Spacious horizontal layout
  Widget _buildCleanQueueRowDesktop(BuildContext context, dynamic state, WashBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          AutoCareAssets.buildPhotoThumbnail(
            imageUrl: b.isCarpet
                ? (b.carpetType == 'type_b' ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carpetTypeAUrl)
                : AutoCareAssets.getPackageImage(b.package),
            width: 48,
            height: 48,
            borderRadius: 10,
            fallbackIcon: b.isCarpet ? Icons.texture_rounded : Icons.local_car_wash_rounded,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      b.licensePlate,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    if (b.isCarpet) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.texture_rounded, size: 11, color: Color(0xFF6366F1)),
                            const SizedBox(width: 3),
                            Text(
                              b.carpetType == 'type_b' ? 'CARPET (TYPE B)' : 'CARPET (TYPE A)',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6366F1)),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          b.carType.displayName,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    if (b.payment.tipAmount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+ETB ${b.payment.tipAmount.toStringAsFixed(0)} Tip',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                    if (b.isPhoneBooking) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_in_talk, size: 11, color: AppColors.primary),
                            const SizedBox(width: 3),
                            Text(
                              state.tr('phoneCallBooking'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  b.isCarpet
                      ? 'Carpet Clean (${b.carpetDimensions ?? "${b.carpetAreaSqMeters ?? 0.0} m²"}) • ${CurrencyFormatter.format(b.totalPrice)}${b.customerName != null && b.customerName!.isNotEmpty ? " • ${b.customerName}" : ""}'
                      : '${b.serviceDisplayName} • ${CurrencyFormatter.format(b.totalPrice)}${b.customerName != null && b.customerName!.isNotEmpty ? " • ${b.customerName}" : ""}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                if (b.serviceType.requiresLocation) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          b.deliveryLocation ?? b.gpsCoordinates ?? (b.serviceType == ServiceType.valetPickUp ? state.tr("valetPickupInBishoftu") : state.tr("bishoftuMobileVan")),
                          style: TextStyle(
                            fontSize: 11,
                            color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _openMapLocation(context, b),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map, size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                state.tr('openInMaps'),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 1. Readable Status Advancement Action Button
          if (b.status == WashStatus.pending || b.status == WashStatus.assignedToBay || b.status == WashStatus.confirmed) ...[
            if (b.isCarpet) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  side: const BorderSide(color: Color(0xFF7C3AED), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.sms_rounded, size: 13),
                label: Text(state.tr('sendCarpetIntakeSms'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                onPressed: () async {
                  await state.sendCarpetRegistrationSms(b);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.tr('carpetIntakeSmsSent')),
                        backgroundColor: const Color(0xFF7C3AED),
                        action: SnackBarAction(
                          label: 'Copy SMS',
                          textColor: Colors.amberAccent,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: state.getCarpetRegistrationSmsText(b)));
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 6),
            ],
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: b.isCarpet ? const Color(0xFF7C3AED) : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 14),
              label: Text(
                b.isCarpet ? state.tr('startWashFloorAction') : state.tr('startWashAction'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.washing),
            ),
          ] else if (b.status == WashStatus.washing) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: b.isCarpet ? const Color(0xFF6366F1) : AppColors.bay1Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.air_rounded, size: 14),
              label: Text(
                b.isCarpet ? state.tr('moveToDryingRacksAction') : state.tr('moveToDryingAction'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.drying),
            ),
          ] else if (b.status == WashStatus.drying) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: b.isCarpet ? const Color(0xFF059669) : AppColors.bay2Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
              label: Text(
                b.isCarpet ? state.tr('markCarpetReadyAction') : state.tr('markCompletedAction'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.completed),
            ),
          ],

          // 2. Strict Payment Lock: ONLY visible when status == completed AND unpaid!
          if ((b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && !b.payment.isPaid) ...[
            const SizedBox(width: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.payments_rounded, size: 14),
              label: Text(
                state.currentLang == 'EN'
                    ? 'Pay (${CurrencyFormatter.formatShort(b.totalPrice)})'
                    : '${state.tr("collectPaymentAction")} (${CurrencyFormatter.formatShort(b.totalPrice)})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
              onPressed: () => PaymentProcessDialog.show(context, b),
            ),
          ] else if (b.payment.isPaid) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusCompleted.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.statusCompleted.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 12, color: AppColors.statusCompleted),
                  const SizedBox(width: 4),
                  Text(
                    'PAID (${b.payment.method.displayName})',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openMapLocation(BuildContext context, WashBooking b) {
    final query = b.gpsCoordinates ?? b.deliveryLocation ?? "Bishoftu, Ethiopia";
    final mapUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}";
    UrlLauncherHelper.openUrl(mapUrl);
  }

  /// Card Grid View with 3 Rows:
  /// Modern 2-column, 3-row card grid with automotive photography thumbnails,
  /// indicator badges, and inline active panel expansion.
  Widget _buildCashierModulesGrid(
    BuildContext context,
    dynamic state,
    bool isMobile,
    List<WashBooking> filteredBookings,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
  ) {
    final modules = [
      _CashierModuleItem(
        title: state.tr('dailyClosingTitle'),
        subtitle: 'Drawer cash: ${CurrencyFormatter.format(state.undepositedCashTodayETB as double)} • Revenue: ${CurrencyFormatter.format(state.totalRevenueTodayETB as double)}',
        icon: Icons.account_balance_wallet_rounded,
        imageUrl: AutoCareAssets.cashMoneyUrl,
        gradientColors: const [Color(0xFF0F766E), Color(0xFF115E59)],
        badgeText: CurrencyFormatter.formatShort(state.undepositedCashTodayETB as double),
        badgeColor: AppColors.primary,
        contentBuilder: () => Column(
          children: [
            _buildShiftSummaryBanner(state, isMobile),
            const SizedBox(height: 10),
            _buildFinancialActionToolbar(context, state, isMobile),
          ],
        ),
      ),
      _CashierModuleItem(
        title: state.isCarpetDivisionActive ? state.tr('carpetStations') : state.tr('liveStationCapacity'),
        subtitle: state.isCarpetDivisionActive
            ? state.tr('washFloorAndDryingRacks')
            : '${state.availableBaysCount} Available • Bay 1, Bay 2 & Mobile Van',
        icon: state.isCarpetDivisionActive ? Icons.texture_rounded : Icons.local_car_wash_rounded,
        imageUrl: state.isCarpetDivisionActive ? AutoCareAssets.carpetDryingRackUrl : AutoCareAssets.stationBayUrl,
        gradientColors: state.isCarpetDivisionActive
            ? const [Color(0xFF7C3AED), Color(0xFF6D28D9)]
            : const [Color(0xFF10B981), Color(0xFF059669)],
        badgeText: state.isCarpetDivisionActive ? '${state.activeCarpetQueueCount} Carpets' : '${state.availableBaysCount} Free',
        badgeColor: state.isCarpetDivisionActive ? const Color(0xFF7C3AED) : AppColors.statusCompleted,
        contentBuilder: () => _buildCleanStationCapacityBar(context, state, bay1, bay2, van, isMobile),
      ),
      _CashierModuleItem(
        title: state.tr('attendanceDesk'),
        subtitle: 'Washer attendance roster, daily presence & 100% pool distribution',
        icon: Icons.how_to_reg_rounded,
        imageUrl: AutoCareAssets.valetDriverUrl,
        gradientColors: const [AppColors.oromiaGold, Color(0xFFD97706)],
        badgeText: '${state.presentWashersCount} Present',
        badgeColor: AppColors.oromiaGold,
        contentBuilder: () => SharedWasherCommissionHub(
          state: state,
          role: WasherHubRole.cashier,
          isMobile: isMobile,
          initiallyExpanded: true,
        ),
      ),
      _CashierModuleItem(
        title: state.isCarpetDivisionActive ? state.tr('carpetQueueTitle') : state.tr('queueAndVehicles'),
        subtitle: '${filteredBookings.length} ${state.isCarpetDivisionActive ? "Carpets" : "Vehicles"} in Queue / Active processing',
        icon: state.isCarpetDivisionActive ? Icons.texture_rounded : Icons.queue_rounded,
        imageUrl: state.isCarpetDivisionActive ? AutoCareAssets.carpetTypeAUrl : AutoCareAssets.welcomeHeroUrl,
        gradientColors: state.isCarpetDivisionActive
            ? const [Color(0xFF581C87), Color(0xFF7C3AED)]
            : const [Color(0xFF0284C7), Color(0xFF0369A1)],
        badgeText: '${filteredBookings.length} Active',
        badgeColor: state.isCarpetDivisionActive ? const Color(0xFF7C3AED) : Colors.blueAccent,
        contentBuilder: () => filteredBookings.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Text(
                    state.isCarpetDivisionActive ? state.tr('noCarpetsInQueue') : state.tr('noVehiclesInQueue'),
                    style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            : Column(
                children: filteredBookings.map((b) => isMobile
                    ? _buildCleanQueueRowMobile(context, state, b)
                    : _buildCleanQueueRowDesktop(context, state, b)).toList(),
              ),
      ),
      _CashierModuleItem(
        title: state.isCarpetDivisionActive ? state.tr('carpetWashHistoryTitle') : state.tr('carWashHistoryTitle'),
        subtitle: state.isCarpetDivisionActive ? 'Audit completed carpets & delivery orders' : 'Audit paid & completed vehicle washes',
        icon: Icons.history_edu_rounded,
        imageUrl: state.isCarpetDivisionActive ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carSedanUrl,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        badgeText: 'History',
        badgeColor: const Color(0xFF4F46E5),
        contentBuilder: () => VehicleHistoryScreen(isEmbedded: true, isCarpetFilter: state.isCarpetDivisionActive),
      ),
      _CashierModuleItem(
        title: state.tr('closingAndFinancialReports'),
        subtitle: 'Audit daily closings, bank deposits & payment channels',
        icon: Icons.fact_check_rounded,
        imageUrl: AutoCareAssets.packageTireRimUrl,
        gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        badgeText: 'Reports',
        badgeColor: AppColors.cashGreen,
        contentBuilder: () => const FinancialReportsView(isEmbedded: true),
      ),
      _CashierModuleItem(
        title: state.tr('stationShowerService'),
        subtitle: '${state.todayShowerUserCount} ${state.tr("showerUsers")} • ${CurrencyFormatter.format(state.todayShowerRevenueETB as double)}',
        icon: Icons.shower_rounded,
        imageUrl: AutoCareAssets.stationBayUrl,
        gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
        badgeText: '${state.todayShowerUserCount} Users',
        badgeColor: const Color(0xFF0284C7),
        contentBuilder: () => _buildStationShowerModule(context, state, isMobile),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Grid View with 4 Rows
        // Row 1
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCashierModuleCard(context, modules[0], 0, isMobile)),
              const SizedBox(width: 10),
              Expanded(child: _buildCashierModuleCard(context, modules[1], 1, isMobile)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 2
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCashierModuleCard(context, modules[2], 2, isMobile)),
              const SizedBox(width: 10),
              Expanded(child: _buildCashierModuleCard(context, modules[3], 3, isMobile)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 3
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCashierModuleCard(context, modules[4], 4, isMobile)),
              const SizedBox(width: 10),
              Expanded(child: _buildCashierModuleCard(context, modules[5], 5, isMobile)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 4
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCashierModuleCard(context, modules[6], 6, isMobile)),
            ],
          ),
        ),

        // Active Expanded Content Panel
        if (_activeModuleIndex != null && _activeModuleIndex! < modules.length) ...[
          const SizedBox(height: 14),
          _buildActiveCashierModulePanel(context, modules[_activeModuleIndex!], isMobile),
        ],
      ],
    );
  }

  Widget _buildCashierModuleCard(BuildContext context, _CashierModuleItem item, int index, bool isMobile) {
    final isActive = _activeModuleIndex == index;
    final primaryColor = item.gradientColors.first;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_activeModuleIndex == index) {
              _activeModuleIndex = null;
            } else {
              _activeModuleIndex = index;
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isMobile ? 12 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? primaryColor : primaryColor.withValues(alpha: 0.25),
              width: isActive ? 2.0 : 1.2,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoCareAssets.buildPhotoThumbnail(
                    imageUrl: item.imageUrl,
                    width: isMobile ? 38 : 44,
                    height: isMobile ? 38 : 44,
                    borderRadius: 10,
                    fallbackIcon: item.icon,
                    fallbackColor: primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.badgeColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: item.badgeColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: isMobile ? 12.5 : 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isActive ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isActive ? primaryColor : AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCashierModulePanel(BuildContext context, _CashierModuleItem item, bool isMobile) {
    final primaryColor = item.gradientColors.first;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: item.imageUrl,
                        width: 32,
                        height: 32,
                        borderRadius: 8,
                        fallbackIcon: item.icon,
                        fallbackColor: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _activeModuleIndex = null),
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Child content
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: item.contentBuilder(),
          ),
        ],
      ),
    );
  }

  Widget _buildStationShowerModule(BuildContext context, dynamic state, bool isMobile) {
    final showerPrice = state.showerPricePerPerson as double;
    final totalToPay = _showerCount * showerPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shower_rounded, color: Colors.white, size: 26),
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // User count tally selector
          Text(
            state.tr('numberOfPersons'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _showerCount > 1 ? () => setState(() => _showerCount--) : null,
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
              ),
              Container(
                width: 50,
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
              const SizedBox(width: 8),
              for (final n in [1, 2, 5]) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => setState(() => _showerCount = n),
                    child: Text('+$n'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Payment Method Selector
          Text(
            state.tr('paymentMethod'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payments_rounded, size: 15),
                      const SizedBox(width: 5),
                      Text(state.tr('payCash')),
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
                      Text(state.tr('payTelebirr')),
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
          const SizedBox(height: 14),

          // Record Button
          CustomButton(
            text: '${state.tr("recordShowerEntry")} • ${CurrencyFormatter.format(totalToPay)}',
            icon: Icons.check_circle_rounded,
            backgroundColor: const Color(0xFF0284C7),
            onPressed: () async {
              final cashierName = state.activeStaffFullName ?? 'Cashier';
              await state.recordShowerEntry(
                userCount: _showerCount,
                paymentMethod: _showerPaymentMethod,
                cashierName: cashierName,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.statusCompleted,
                    content: Text('Recorded $_showerCount shower user(s) (${CurrencyFormatter.format(totalToPay)})!'),
                  ),
                );
                setState(() {
                  _showerCount = 1;
                });
              }
            },
          ),
          const SizedBox(height: 14),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(state.tr('showerTotalRevenue'), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(state.todayShowerRevenueETB as double),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(state.tr('cashCollected'), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(state.todayShowerCashETB as double),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.cashGreen),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(state.tr('digitalPay'), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(state.todayShowerDigitalETB as double),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.telebirrBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasherAttendanceAndCommissionSection(BuildContext context, dynamic state, bool isMobile) {
    final washers = state.availableWashers;
    final pool = state.teamCommissionPoolTodayETB as double;
    final dividends = state.washerDividendsToday as Map<String, dynamic>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.oromiaGold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.oromiaGold.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Unified Card Header (Title, Pool Pill, Expand/Collapse Chevron)
          InkWell(
            onTap: () => setState(() => _isWasherRosterExpanded = !_isWasherRosterExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.oromiaGold, AppColors.oromiaGold.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                state.tr('dailyWasherCommissionPool'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${state.presentWashersCount} of ${state.totalWashersCount} Washers on Duty • 15% Pool',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.oromiaGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.oromiaGold.withOpacity(0.3)),
                        ),
                        child: Text(
                          CurrencyFormatter.format(pool),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            color: AppColors.oromiaGold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isWasherRosterExpanded ? state.tr('collapseRoster') : state.tr('expandRoster'),
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          Icon(
                            _isWasherRosterExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // 2. Action Toolbar (Disburse, Weekly Report, Mark All Present)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: (pool > 0 && !state.isDailyCommissionDisbursedToday)
                      ? () => _showDisburseCommissionDialog(context, state, pool, state.presentWashersCount)
                      : null,
                  icon: Icon(
                    state.isDailyCommissionDisbursedToday ? Icons.check_circle_rounded : Icons.payments_rounded,
                    size: 14,
                  ),
                  label: Text(
                    state.isDailyCommissionDisbursedToday
                        ? state.tr('disbursedToday')
                        : state.tr('disburseCommission'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isDailyCommissionDisbursedToday ? Colors.grey.shade400 : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    elevation: 0,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => WeeklyCommissionReportDialog.show(context),
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 14),
                  label: Text(
                    state.tr('reportWeeklyCommission'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusCompleted,
                    side: const BorderSide(color: AppColors.statusCompleted),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.done_all_rounded, size: 14),
                  label: Text(state.tr('markAllPresent'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                  onPressed: () {
                    state.markAllWashersPresent();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.tr('markAllPresent')),
                        backgroundColor: AppColors.statusCompleted,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Compact Status Bar: Present / Absent / Total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusCompleted.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.statusCompleted, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${state.presentWashersCount} Present',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.statusCompleted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${state.totalWashersCount - state.presentWashersCount} Absent',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_rounded, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${state.totalWashersCount} Total',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 4. Animated Expandable Content (Roster + Pool Dividends + Absent Protection)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 6),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pool ETB details
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.oromiaGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.oromiaGold.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Commission Pool Today:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Text(
                          CurrencyFormatter.format(pool),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.oromiaGold),
                        ),
                      ],
                    ),
                  ),

                  // Absent washer protection notice
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            state.tr('absentWashersProtection'),
                            style: const TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dividends breakdown list (if any)
                  if (dividends.isNotEmpty) ...[
                    Text(
                      state.tr('assignedCommissionShare'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    ...dividends.values.map((div) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  div.isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  size: 13,
                                  color: div.isPresent ? AppColors.statusCompleted : Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  div.washerName,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: div.isPresent ? FontWeight.w700 : FontWeight.w500,
                                    color: div.isPresent ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    div.customTierName ?? '',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              div.isPresent
                                  ? '${div.percentageShare.toStringAsFixed(1)}% • ${CurrencyFormatter.format(div.earnedETB)}'
                                  : 'Absent (0 ETB)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: div.isPresent ? AppColors.oromiaGold : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],

                  // 8 Washers Attendance Toggle List
                  Text(
                    '${state.tr("attendanceDesk")} (${washers.length} Washers)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  ...washers.map((w) {
                    final isPresent = state.isWasherPresentToday(w.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPresent ? AppColors.statusCompleted.withOpacity(0.35) : Colors.red.withOpacity(0.25),
                          width: 1.1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isPresent ? AppColors.statusCompleted.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                            child: Text(
                              w.name.isNotEmpty ? w.name[0] : 'W',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                color: isPresent ? AppColors.statusCompleted : Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        w.name,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: isPresent ? AppColors.statusCompleted.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isPresent ? state.tr('onDutyBadge') : state.tr('absentBadge'),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: isPresent ? AppColors.statusCompleted : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Base: ${(w.commissionRate * 100).toStringAsFixed(1)}% • Earned: ${isPresent && dividends[w.id] != null ? CurrencyFormatter.format(dividends[w.id]!.earnedETB) : "0 ETB"} • ${w.phone}',
                                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: isPresent,
                            activeColor: AppColors.statusCompleted,
                            onChanged: (val) {
                              state.setWasherAttendance(w.id, val);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _isWasherRosterExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  void _showDisburseCommissionDialog(BuildContext context, dynamic state, double pool, int washerCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 24),
            const SizedBox(width: 8),
            const Text('Disburse Commission Pool', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Confirm distribution of ${CurrencyFormatter.format(pool)} team commission dividends among the $washerCount washer(s) on duty today according to their percentage share (summing to 100%)?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              state.markDailyCommissionDisbursed();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team commission pool recorded and distributed successfully!'),
                  backgroundColor: AppColors.statusReady,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Disbursement', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  List<WashBooking> _getFilteredBookings(List<WashBooking> bookings, bool isCarpetDivision) {
    // Zero cross-contamination: vehicle queue contains only vehicles, carpet queue contains only carpets.
    // Active station queue contains:
    // 1. Any booking currently in progress (pending, confirmed, assignedToBay, washing, drying, readyForPickup)
    // 2. Any completed booking that has NOT yet been paid/settled
    return bookings.where((b) {
      if (b.status == WashStatus.cancelled) return false;
      if (b.isCarpet != isCarpetDivision) return false;
      final isFinishedAndSettled = b.status == WashStatus.completed && b.payment.isPaid;
      return !isFinishedAndSettled;
    }).toList();
  }

  Widget _buildCleanStationCapacityBar(
    BuildContext context,
    dynamic state,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
    bool isMobile,
  ) {
    if (state.isCarpetDivisionActive) {
      final carpetBookings = (state.bookings as List<WashBooking>)
          .where((b) => b.isCarpet && b.status != WashStatus.cancelled && !(b.status == WashStatus.completed && b.payment.isPaid))
          .toList();
      final washingCarpets = carpetBookings.where((b) => b.status == WashStatus.washing || b.status == WashStatus.assignedToBay || b.status == WashStatus.pending).toList();
      final dryingCarpets = carpetBookings.where((b) => b.status == WashStatus.drying).toList();
      final valetCarpets = carpetBookings.where((b) => (b.serviceType == ServiceType.valetPickUp || b.serviceType == ServiceType.atHomeMobile) && b.status != WashStatus.completed).toList();

      final isWashFloorBusy = washingCarpets.isNotEmpty;
      final washFloorStatus = isWashFloorBusy ? '${washingCarpets.length} in wash (${washingCarpets.first.licensePlate})' : state.tr('availableNow');

      final isDryingBusy = dryingCarpets.isNotEmpty;
      final dryingStatus = isDryingBusy ? '${dryingCarpets.length} drying (${dryingCarpets.first.licensePlate})' : state.tr('availableNow');

      final isValetBusy = valetCarpets.isNotEmpty;
      final valetStatus = isValetBusy ? '${valetCarpets.length} active' : state.tr('availableNow');

      return Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStationMiniIndicator(
                state.tr('carpetWashFloor'),
                !isWashFloorBusy,
                washFloorStatus,
                AutoCareAssets.carpetStationWashUrl,
                Icons.waves_rounded,
                isMobile,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStationMiniIndicator(
                state.tr('carpetDryingRacks'),
                !isDryingBusy,
                dryingStatus,
                AutoCareAssets.carpetDryingRackUrl,
                Icons.dry_cleaning_rounded,
                isMobile,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStationMiniIndicator(
                state.tr('carpetValetDriver'),
                !isValetBusy,
                valetStatus,
                AutoCareAssets.valetDriverUrl,
                Icons.local_shipping_rounded,
                isMobile,
              ),
            ),
          ],
        ),
      );
    }

    final bookings = state.bookings as List<WashBooking>;

    // Real-time busy detection from active queue in washing/drying/assigned
    WashBooking? active1;
    WashBooking? active2;
    WashBooking? activeVan;

    for (final b in bookings) {
      if (b.status == WashStatus.washing || b.status == WashStatus.drying || b.status == WashStatus.assignedToBay) {
        if (b.assignedBay == BayType.bay1 && active1 == null) {
          active1 = b;
        } else if (b.assignedBay == BayType.bay2 && active2 == null) {
          active2 = b;
        } else if ((b.assignedBay == BayType.mobileVan || b.serviceType == ServiceType.atHomeMobile) && activeVan == null) {
          activeVan = b;
        }
      }
    }

    final isBay1Busy = active1 != null || !bay1.isVacant;
    final plate1 = active1?.licensePlate ?? bay1.activeLicensePlate;

    final isBay2Busy = active2 != null || !bay2.isVacant;
    final plate2 = active2?.licensePlate ?? bay2.activeLicensePlate;

    final isVanBusy = activeVan != null || !van.isVacant;
    final plateVan = activeVan?.licensePlate ?? van.activeLicensePlate;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBayMiniIndicator(state.tr('bay1'), !isBay1Busy, plate1, state, isMobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('bay2'), !isBay2Busy, plate2, state, isMobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('mobileVan'), !isVanBusy, plateVan, state, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildStationMiniIndicator(String title, bool isFree, String statusText, String imageUrl, IconData fallbackIcon, bool isMobile) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          AutoCareAssets.buildPhotoThumbnail(
            imageUrl: imageUrl,
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            borderRadius: 8,
            fallbackIcon: fallbackIcon,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 10.5 : 11.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 9.5 : 10.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBayMiniIndicator(String title, bool isFree, String? activePlate, dynamic state, bool isMobile) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;
    final statusText = isFree
        ? state.tr('availableNow')
        : (activePlate != null && activePlate.isNotEmpty ? 'Busy ($activePlate)' : state.tr('busyWashing'));

    final isVan = title.toLowerCase().contains('van');
    final bayImageUrl = isVan ? AutoCareAssets.mobileVanUrl : AutoCareAssets.packageFoamUrl;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          AutoCareAssets.buildPhotoThumbnail(
            imageUrl: bayImageUrl,
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            borderRadius: 8,
            fallbackIcon: isVan ? Icons.airport_shuttle_rounded : Icons.local_car_wash_rounded,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 10.5 : 11.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 9.5 : 10.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _advanceBookingStatus(
    BuildContext context,
    WashBooking booking, {
    WashStatus? targetStatus,
  }) async {
    final state = AppStateProvider.read(context);
    final next = targetStatus ?? (
      (booking.status == WashStatus.drying || booking.status == WashStatus.readyForPickup)
          ? WashStatus.completed
          : WashDispatcher.nextStatus(booking.status)
    );
    if (next == null) return;

    await state.updateWashStatus(booking.id, next);

    if (next == WashStatus.completed) {
      await state.sendCustomerCompletionSms(booking);
    }

    if (context.mounted) {
      final msg = next == WashStatus.completed
          ? (booking.isCarpet
              ? '${booking.licensePlate}: ${state.tr("carpetCompletionSmsSent")}'
              : '${booking.licensePlate} completed! Ready for payment • SMS ready for ${booking.customerPhone}')
          : '${booking.licensePlate} updated to ${next.displayName}!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: next == WashStatus.completed ? AppColors.cashGreen : next.color,
          action: next == WashStatus.completed
              ? SnackBarAction(
                  label: 'Copy SMS',
                  textColor: Colors.amberAccent,
                  onPressed: () {
                    final sms = state.getCustomerCompletionSmsText(booking);
                    Clipboard.setData(ClipboardData(text: sms));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer SMS message copied to clipboard!'),
                        duration: Duration(seconds: 2),
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
              Expanded(
                child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
