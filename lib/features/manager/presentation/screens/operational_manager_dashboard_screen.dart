import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../cashier/presentation/screens/daily_closing_dialog.dart';
import '../../../cashier/presentation/screens/phone_booking_dialog.dart';
import '../../../cashier/presentation/screens/walk_in_registration_screen.dart';

class _ManagerModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imageUrl;
  final List<Color> gradientColors;
  final String badgeText;
  final Color badgeColor;
  final Widget Function() contentBuilder;

  const _ManagerModuleItem({
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

class OperationalManagerDashboardScreen extends StatefulWidget {
  const OperationalManagerDashboardScreen({super.key});

  @override
  State<OperationalManagerDashboardScreen> createState() => _OperationalManagerDashboardScreenState();
}

class _OperationalManagerDashboardScreenState extends State<OperationalManagerDashboardScreen> {
  int? _activeModuleIndex;
  final _managerInlineOtpController = TextEditingController();

  @override
  void dispose() {
    _managerInlineOtpController.dispose();
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

    final filteredBookings = allBookings.where((b) => b.status != WashStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("operationalManagerTitle")} • ${state.activeStaffFullName}'
            : state.tr('operationalManagerTitle'),
      ),
      floatingActionButton: isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'op_fab_phone',
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  tooltip: state.tr('registerPhoneBooking'),
                  onPressed: () => PhoneBookingDialog.show(context),
                  child: const Icon(Icons.phone_in_talk_rounded, size: 18),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.extended(
                  heroTag: 'op_fab_walkin',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_road_rounded, size: 18),
                  label: Text(
                    state.tr('newWalkIn'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalkInRegistrationScreen()),
                    );
                  },
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'op_fab_phone',
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: Text(
                    state.tr('registerPhoneBooking'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  onPressed: () => PhoneBookingDialog.show(context),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.extended(
                  heroTag: 'op_fab_walkin',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_road_rounded, size: 18),
                  label: Text(
                    state.tr('newWalkIn'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalkInRegistrationScreen()),
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

              // 1. Handover Alert / Custody Banner
              _buildHandoverStatusBanner(context, state, isMobile),
              const SizedBox(height: 14),

              // 2. 6 Modules Header
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
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '6 MODULES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. 3-Row Card Grid View (2 per row = 6 modules)
              _buildManagerModulesGrid(context, state, isMobile, filteredBookings, bay1, bay2, van),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandoverStatusBanner(BuildContext context, dynamic state, bool isMobile) {
    final pending = state.pendingCashierHandover;

    if (pending != null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA580C).withValues(alpha: 0.25),
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
                  imageUrl: AutoCareAssets.cashMoneyUrl,
                  width: 40,
                  height: 40,
                  borderRadius: 10,
                  fallbackIcon: Icons.payments_rounded,
                  fallbackColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.notification_important_rounded, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    state.tr('acceptCashierHandover'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CASH: ${CurrencyFormatter.format(pending.handoverCashAmount)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Cashier ${pending.cashierName} submitted ${CurrencyFormatter.format(pending.handoverCashAmount)} physical cash. Count drawer cash, enter 4-digit Cashier OTP below to confirm & take custody.',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Direct Inline OTP Input & Verification Button
            Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 42,
                  child: TextField(
                    controller: _managerInlineOtpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: Color(0xFFC2410C),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'OTP',
                      hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 2, fontSize: 13),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleInlineManagerVerify(context, state, pending),
                    icon: const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFFC2410C)),
                    label: Text(
                      state.tr('verifyAndTakeCustody'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFC2410C)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final adminPending = state.pendingAdminNightHandover;
    if (adminPending != null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4338CA), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pin_rounded, color: Colors.white, size: 24),
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
                        state.tr('adminNightHandoverCode'),
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          state.tr('pendingAdminReceipt'),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '[ ${adminPending.handoverOtp ?? '----'} ]',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '• ${CurrencyFormatter.format(adminPending.handoverCashAmount)} cash to Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
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
    }

    // Steady-state banner: Carried Cash in Custody
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          AutoCareAssets.buildPhotoThumbnail(
            imageUrl: AutoCareAssets.cashMoneyUrl,
            width: 44,
            height: 44,
            borderRadius: 10,
            fallbackIcon: Icons.account_balance_wallet_rounded,
            fallbackColor: const Color(0xFF38BDF8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.tr('carriedCashierCash'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(state.managerCarriedCashETB),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 10, color: Color(0xFF34D399)),
                          const SizedBox(width: 3),
                          Text(
                            state.tr('handoverConfirmed'),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF34D399)),
                          ),
                        ],
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
  }

  void _handleInlineManagerVerify(BuildContext context, dynamic state, dynamic pending) async {
    final entered = _managerInlineOtpController.text.trim();
    if (entered.isEmpty || entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit Cashier OTP code.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await state.acceptCashierHandover(
      managerName: state.activeStaffFullName ?? 'Dawit Manager',
      enteredOtp: entered,
    );

    if (success) {
      _managerInlineOtpController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('handoverSuccess')),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('invalidOtpCode')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _confirmAcceptHandover(BuildContext context, dynamic state) async {
    final pending = state.pendingCashierHandover;
    if (pending == null) return;

    final otpController = TextEditingController();
    String? errorMessage;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('enterHandoverOtp'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Count ${CurrencyFormatter.format(pending.cashRemaining)} physical cash from Cashier ${pending.cashierName}, then enter the 4-digit code given by the cashier.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, color: AppColors.primary),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(letterSpacing: 8, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  errorText: errorMessage,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final otp = otpController.text.trim();
                final ok = await state.acceptCashierHandover(
                  managerName: state.activeStaffFullName ?? 'Dawit Manager',
                  enteredOtp: otp,
                );
                if (ok) {
                  Navigator.pop(ctx, true);
                } else {
                  setDialogState(() {
                    errorMessage = state.tr('invalidOtpCode');
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                state.tr('verifyAndTakeCustody'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );

    if (accepted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('handoverSuccess')),
          backgroundColor: AppColors.statusReady,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildManagerModulesGrid(
    BuildContext context,
    dynamic state,
    bool isMobile,
    List<WashBooking> filteredBookings,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
  ) {
    final isCarpet = state.isCarpetDivisionActive;
    final relevantBookings = filteredBookings.where((b) => isCarpet ? b.isCarpet : !b.isCarpet).toList();

    final modules = [
      _ManagerModuleItem(
        title: state.tr('cashierHandoverTitle'),
        subtitle: 'Cashier drawer cash: ${CurrencyFormatter.format(state.managerCarriedCashETB)} in custody',
        icon: Icons.account_balance_wallet_rounded,
        imageUrl: AutoCareAssets.cashMoneyUrl,
        gradientColors: const [Color(0xFF0F766E), Color(0xFF115E59)],
        badgeText: CurrencyFormatter.formatShort(state.managerCarriedCashETB),
        badgeColor: AppColors.primary,
        contentBuilder: () => _buildHandoverSummaryCard(state, isMobile),
      ),
      _ManagerModuleItem(
        title: isCarpet ? state.tr('carpetStations') : state.tr('liveStationCapacity'),
        subtitle: isCarpet
            ? 'Wash floor, extraction & ventilated drying racks'
            : '${state.availableBaysCount} Available • Bay 1, Bay 2 & Mobile Van',
        icon: isCarpet ? Icons.texture_rounded : Icons.local_car_wash_rounded,
        imageUrl: isCarpet ? AutoCareAssets.carpetDryingRackUrl : AutoCareAssets.stationBayUrl,
        gradientColors: isCarpet
            ? const [Color(0xFF7C3AED), Color(0xFF6D28D9)]
            : const [Color(0xFF10B981), Color(0xFF059669)],
        badgeText: isCarpet ? '${state.activeCarpetQueueCount} Carpets' : '${state.availableBaysCount} Free',
        badgeColor: isCarpet ? const Color(0xFF7C3AED) : AppColors.statusCompleted,
        contentBuilder: () => _buildCleanStationCapacityBar(context, state, bay1, bay2, van, isMobile),
      ),
      _ManagerModuleItem(
        title: state.tr('attendanceDesk'),
        subtitle: 'Night shift washer attendance & 100% pool distribution',
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
      _ManagerModuleItem(
        title: isCarpet ? state.tr('carpetQueueTitle') : state.tr('queueAndVehicles'),
        subtitle: '${relevantBookings.length} ${isCarpet ? "Carpets" : "Vehicles"} in Queue / Active processing',
        icon: isCarpet ? Icons.texture_rounded : Icons.queue_rounded,
        imageUrl: isCarpet ? AutoCareAssets.carpetTypeAUrl : AutoCareAssets.welcomeHeroUrl,
        gradientColors: isCarpet
            ? const [Color(0xFF6366F1), Color(0xFF4F46E5)]
            : const [Color(0xFF0284C7), Color(0xFF0369A1)],
        badgeText: '${relevantBookings.length} Active',
        badgeColor: isCarpet ? const Color(0xFF6366F1) : Colors.blueAccent,
        contentBuilder: () => relevantBookings.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Text(
                    isCarpet ? 'No carpets currently in queue.' : 'No vehicles currently in queue.',
                    style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            : Column(
                children: relevantBookings.map((b) => _buildQueueRow(context, state, b, isMobile)).toList(),
              ),
      ),
      _ManagerModuleItem(
        title: state.tr('washHistory'),
        subtitle: isCarpet ? 'Audit completed carpets & delivery orders' : 'Audit paid & completed washes by date range',
        icon: Icons.history_edu_rounded,
        imageUrl: isCarpet ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carSedanUrl,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        badgeText: 'History',
        badgeColor: const Color(0xFF4F46E5),
        contentBuilder: () => const VehicleHistoryScreen(isEmbedded: true),
      ),
      _ManagerModuleItem(
        title: state.tr('nightClosingTitle'),
        subtitle: 'Disperse night washer pool & handover total cash to Admin',
        icon: Icons.fact_check_rounded,
        imageUrl: AutoCareAssets.packageTireRimUrl,
        gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        badgeText: 'Closing',
        badgeColor: AppColors.cashGreen,
        contentBuilder: () => _buildNightClosingActionCard(context, state, isMobile),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Grid View with 3 Rows (2 cards per row)
        // Row 1
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildManagerModuleCard(context, modules[0], 0, isMobile)),
              const SizedBox(width: 10),
              Expanded(child: _buildManagerModuleCard(context, modules[1], 1, isMobile)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 2
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildManagerModuleCard(context, modules[2], 2, isMobile)),
              const SizedBox(width: 10),
              Expanded(child: _buildManagerModuleCard(context, modules[3], 3, isMobile)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Row 3
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildManagerModuleCard(context, modules[4], 4, isMobile)),
              const SizedBox(width: 10),
              Expanded(child: _buildManagerModuleCard(context, modules[5], 5, isMobile)),
            ],
          ),
        ),

        // Active Expanded Content Panel
        if (_activeModuleIndex != null && _activeModuleIndex! < modules.length) ...[
          const SizedBox(height: 14),
          _buildActiveManagerModulePanel(context, modules[_activeModuleIndex!], isMobile),
        ],
      ],
    );
  }

  Widget _buildManagerModuleCard(BuildContext context, _ManagerModuleItem item, int index, bool isMobile) {
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

  Widget _buildActiveManagerModulePanel(BuildContext context, _ManagerModuleItem item, bool isMobile) {
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

  Widget _buildHandoverSummaryCard(dynamic state, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cash Custody & Handover Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Day Shift Handover Cash:'),
              Text(
                CurrencyFormatter.format(state.managerCarriedCashETB),
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.cashGreen),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Night Shift Undeposited Cash:'),
              Text(
                CurrencyFormatter.format(state.undepositedCashTodayETB),
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Physical Cash to Admin:', style: TextStyle(fontWeight: FontWeight.w800)),
              Text(
                CurrencyFormatter.format(state.managerCarriedCashETB + state.undepositedCashTodayETB),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F766E)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCleanStationCapacityBar(BuildContext context, dynamic state, StationBay bay1, StationBay bay2, StationBay van, bool isMobile) {
    return Column(
      children: [
        _buildBayMiniTile('Bay 1 (Drive-through)', bay1.isOccupied, bay1.activeBookingId, isMobile),
        const SizedBox(height: 8),
        _buildBayMiniTile('Bay 2 (Detailing)', bay2.isOccupied, bay2.activeBookingId, isMobile),
        const SizedBox(height: 8),
        _buildBayMiniTile('Mobile Van Service', van.isOccupied, van.activeBookingId, isMobile),
      ],
    );
  }

  Widget _buildBayMiniTile(String bayName, bool isOccupied, String? bookingId, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isOccupied ? Icons.do_not_disturb_on_rounded : Icons.check_circle_rounded,
                color: isOccupied ? Colors.orange : AppColors.statusCompleted,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(bayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isOccupied ? Colors.orange.withOpacity(0.12) : AppColors.statusCompleted.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isOccupied ? 'Occupied' : 'Available',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isOccupied ? Colors.orange.shade800 : AppColors.statusCompleted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueRow(BuildContext context, dynamic state, WashBooking booking, bool isMobile) {
    final isCarpet = booking.isCarpet;
    final photoUrl = isCarpet
        ? (booking.carpetType == 'type_b' ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carpetTypeAUrl)
        : AutoCareAssets.carSedanUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: photoUrl,
                width: 40,
                height: 40,
                borderRadius: 8,
                fallbackIcon: isCarpet ? Icons.texture_rounded : Icons.directions_car_rounded,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCarpet
                        ? '${booking.licensePlate} • ${booking.carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
                        : '${booking.licensePlate} • ${booking.package.name}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCarpet && booking.carpetDimensions != null && booking.carpetDimensions!.isNotEmpty
                        ? '${booking.customerName} • ${booking.carpetDimensions} • ${CurrencyFormatter.format(booking.totalPrice)}'
                        : '${booking.customerName} • ${CurrencyFormatter.format(booking.totalPrice)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: booking.payment.isPaid ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              booking.payment.isPaid ? 'PAID' : 'IN QUEUE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: booking.payment.isPaid ? Colors.green.shade800 : Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightClosingActionCard(BuildContext context, dynamic state, bool isMobile) {
    final isClosed = state.isTodayNightShiftClosed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.tr('nightClosingTitle'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Disperses night shift washer commissions and reconciles total combined cash handed over to Admin.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => DailyClosingDialog.show(context, isManagerClosing: true),
              icon: Icon(isClosed ? Icons.verified_rounded : Icons.fact_check_rounded, size: 16),
              label: Text(
                isClosed ? 'Night Closing Confirmed' : 'Initiate Night Shift Closing',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isClosed ? Colors.grey.shade600 : AppColors.cashGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
