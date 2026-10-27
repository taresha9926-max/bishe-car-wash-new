import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/staff_member.dart';
import '../widgets/commission_item_card.dart';
import '../widgets/pricing_matrix_editor.dart';
import 'commission_logs_screen.dart';
import 'credentials_management_screen.dart';
import 'pricing_management_screen.dart';
import 'staff_management_screen.dart';

enum AdminTimeFilter {
  today,
  thisWeek,
  thisMonth,
  allTime;

  String localizedLabel(dynamic state) {
    switch (this) {
      case AdminTimeFilter.today:
        return state.tr('filterToday');
      case AdminTimeFilter.thisWeek:
        return state.tr('filterThisWeek');
      case AdminTimeFilter.thisMonth:
        return state.tr('filterThisMonth');
      case AdminTimeFilter.allTime:
        return state.tr('filterAllTime');
    }
  }
}

class _OperationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _OperationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.onTap,
  });
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminTimeFilter _selectedFilter = AdminTimeFilter.today;

  List<WashBooking> _filterBookings(List<WashBooking> bookings, AdminTimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case AdminTimeFilter.today:
        return bookings.where((b) =>
          b.createdAt.year == now.year &&
          b.createdAt.month == now.month &&
          b.createdAt.day == now.day,
        ).toList();
      case AdminTimeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return bookings.where((b) => b.createdAt.isAfter(startMonday) || b.createdAt.isAtSameMomentAs(startMonday)).toList();
      case AdminTimeFilter.thisMonth:
        return bookings.where((b) =>
          b.createdAt.year == now.year &&
          b.createdAt.month == now.month,
        ).toList();
      case AdminTimeFilter.allTime:
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    // Time-filtered bookings
    final filteredBookings = _filterBookings(state.bookings, _selectedFilter);
    final paidBookings = filteredBookings.where((b) => b.payment.isPaid).toList();
    final completedCars = filteredBookings.where((b) => b.status == WashStatus.completed).length;

    // Financial Metrics
    final totalRevenue = paidBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final cashRevenue = paidBookings.where((b) => b.payment.method == PaymentMethod.cash).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digitalRevenue = paidBookings.where((b) => b.payment.method != PaymentMethod.cash).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final commissionPool = totalRevenue * state.teamCommissionRate;
    final netProfit = totalRevenue - commissionPool;

    // Digital receipts for the period
    final digitalBookings = paidBookings.where((b) => b.payment.method.isDigital).toList();
    final recentLogs = state.commissionLogs.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('adminTitle'),
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
              // 1. Executive Banner (Responsive)
              _buildExecutiveBanner(state, isMobile),
              const SizedBox(height: 14),

              // 2. Interactive Time Filter Selector
              _buildTimeFilterBar(state),
              const SizedBox(height: 14),

              // 3. Financial & Operational KPIs (Responsive Grid with no text clipping)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final isMedium = constraints.maxWidth >= 550 && !isWide;
                  final crossAxisCount = isWide ? 4 : 2;
                  final childAspectRatio = isWide
                      ? 1.6
                      : (isMedium ? 1.55 : (constraints.maxWidth < 360 ? 1.2 : 1.35));

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isMobile ? 10 : 12,
                    mainAxisSpacing: isMobile ? 10 : 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildMetricCard(
                        state.tr('totalRevenueAdmin'),
                        CurrencyFormatter.formatShort(totalRevenue),
                        '$completedCars ${state.tr("carsWashed")}',
                        Icons.account_balance_wallet_rounded,
                        AppColors.primary,
                        isMobile: isMobile,
                      ),
                      _buildMetricCard(
                        state.tr('commissionsPaid'),
                        CurrencyFormatter.formatShort(commissionPool),
                        '${(state.teamCommissionRate * 100).toStringAsFixed(0)}% team pool',
                        Icons.handshake_rounded,
                        AppColors.oromiaGold,
                        isMobile: isMobile,
                      ),
                      _buildMetricCard(
                        state.tr('netStationProfit'),
                        CurrencyFormatter.formatShort(netProfit > 0 ? netProfit : 0),
                        state.tr('afterPayrollCuts'),
                        Icons.trending_up_rounded,
                        AppColors.statusReady,
                        isMobile: isMobile,
                      ),
                      _buildMetricCard(
                        state.tr('activeWashers'),
                        '${state.availableWashers.length} Active',
                        '${state.staff.length} on team',
                        Icons.groups_rounded,
                        AppColors.secondary,
                        isMobile: isMobile,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),

              // 4. Cash vs Digital Settlement Bar (Responsive Wrap)
              _buildCashVsDigitalBar(state, totalRevenue, cashRevenue, digitalRevenue),
              const SizedBox(height: 18),

              // 5. 15% Team Commission Seniority Distribution Section (Responsive CTA button)
              _buildCommissionSenioritySection(context, state, commissionPool, isMobile),
              const SizedBox(height: 22),

              // 6. Operational Management Modules (Responsive: Full-width list on Mobile, Row on Tablet/Desktop)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('managementOperations'),
                    style: TextStyle(
                      fontSize: isMobile ? 15.5 : 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '3 MODULES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildManagementOperations(context, state, isMobile),
              const SizedBox(height: 22),

              // 7. Digital Payment Receipts Audit Section
              _buildDigitalReceiptsSection(context, digitalBookings, isMobile),
              const SizedBox(height: 22),

              // 8. Live Pricing Matrix Editor Widget
              PricingMatrixEditor(packages: state.packages),
              const SizedBox(height: 22),

              // 9. Automated Commission Split Ledger
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('recentCommissions'),
                    style: TextStyle(
                      fontSize: isMobile ? 15.5 : 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommissionLogsScreen()),
                      );
                    },
                    child: Text(state.tr('viewAll'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (recentLogs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'No commission logs recorded yet today.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              else
                ...recentLogs.map((log) => CommissionItemCard(log: log)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterBar(dynamic state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: AdminTimeFilter.values.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter.localizedLabel(state),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
              ),
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCashVsDigitalBar(dynamic state, double total, double cash, double digital) {
    final cashPercent = total > 0 ? (cash / total) : 0.5;
    final digitalPercent = total > 0 ? (digital / total) : 0.5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.tr('cashVsDigital'),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                '${CurrencyFormatter.format(total)} Total',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (cashPercent * 100).toInt().clamp(1, 99),
                    child: Container(color: Colors.green),
                  ),
                  Expanded(
                    flex: (digitalPercent * 100).toInt().clamp(1, 99),
                    child: Container(color: AppColors.telebirrBlue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                    'Cash: ${CurrencyFormatter.format(cash)} (${(cashPercent * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.telebirrBlue, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                    'Digital: ${CurrencyFormatter.format(digital)} (${(digitalPercent * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionSenioritySection(
    BuildContext context,
    dynamic state,
    double pool,
    bool isMobile,
  ) {
    final washers = state.availableWashers as List<StaffMember>;
    final totalWeight = washers.fold<int>(0, (sum, w) => sum + (w.skillSeniorityLevel > 0 ? w.skillSeniorityLevel : 2));

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.oromiaGold.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header
          if (isMobile) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.oromiaGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr('teamCommissionDistribution'),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${washers.length} Washers • ${(state.teamCommissionRate * 100).toStringAsFixed(0)}% Pool: ${CurrencyFormatter.format(pool)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: pool > 0 ? () => _showDisburseDialog(context, state, pool, washers.length) : null,
                icon: const Icon(Icons.payments_rounded, size: 15),
                label: Text(
                  state.tr('disburseCommission'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.oromiaGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('teamCommissionDistribution'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${washers.length} Washers • ${(state.teamCommissionRate * 100).toStringAsFixed(0)}% Gross Pool: ${CurrencyFormatter.format(pool)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: pool > 0 ? () => _showDisburseDialog(context, state, pool, washers.length) : null,
                  icon: const Icon(Icons.payments_rounded, size: 14),
                  label: Text(
                    state.tr('disburseCommission'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),

          // Washers dividend cards list
          if (washers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('No active washers on team roster.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: washers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final w = washers[index];
                final weight = w.skillSeniorityLevel > 0 ? w.skillSeniorityLevel : 2;
                final dividend = (totalWeight > 0 && pool > 0) ? (weight / totalWeight) * pool : 0.0;
                final stars = '⭐' * weight.clamp(1, 5);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          w.name.isNotEmpty ? w.name[0] : 'W',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    w.seniorityTierName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(stars, style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(dividend),
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Weight ${weight}x (${((weight / (totalWeight > 0 ? totalWeight : 1)) * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Responsive Management Operations:
  /// - Mobile: Generous full-width stacked cards with clear titles, full subtitles, and indicator badges.
  /// - Tablet / Desktop: 3-column side-by-side row.
  Widget _buildManagementOperations(BuildContext context, dynamic state, bool isMobile) {
    final operations = [
      _OperationItem(
        title: state.tr('pricingMatrix'),
        subtitle: state.tr('pricingSubtitle'),
        icon: Icons.tune_rounded,
        color: AppColors.primary,
        badge: '${state.packages.length} Tariffs',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PricingManagementScreen()),
          );
        },
      ),
      _OperationItem(
        title: state.tr('staffPayroll'),
        subtitle: state.tr('staffPayrollSub'),
        icon: Icons.badge_rounded,
        color: AppColors.secondary,
        badge: '${state.staff.length} Crew',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
          );
        },
      ),
      _OperationItem(
        title: state.tr('staffPins'),
        subtitle: state.tr('staffPinsSub'),
        icon: Icons.pin_outlined,
        color: AppColors.accent,
        badge: 'Security',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CredentialsManagementScreen()),
          );
        },
      ),
    ];

    if (isMobile) {
      return Column(
        children: operations.map((op) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildOperationCardMobile(context, op),
        )).toList(),
      );
    }

    return Row(
      children: operations.map((op) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: op == operations.last ? 0 : 12),
          child: _buildOperationCardDesktop(context, op),
        ),
      )).toList(),
    );
  }

  Widget _buildOperationCardMobile(BuildContext context, _OperationItem op) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: op.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: op.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(op.icon, color: op.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            op.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (op.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: op.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              op.badge!,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: op.color),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      op.subtitle,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.25),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationCardDesktop(BuildContext context, _OperationItem op) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: op.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: op.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(op.icon, color: op.color, size: 22),
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
                            op.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.textPrimary),
                          ),
                        ),
                        if (op.badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: op.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              op.badge!,
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: op.color),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      op.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisburseDialog(BuildContext context, dynamic state, double pool, int washerCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 24),
            const SizedBox(width: 8),
            Text(state.tr('disburseCommission'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Approve distribution of ${CurrencyFormatter.format(pool)} team commission dividends among all $washerCount active washers according to their seniority tier weights?',
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
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.tr('commissionDisbursedSuccess')),
                  backgroundColor: AppColors.statusReady,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Payout', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalReceiptsSection(
    BuildContext context,
    List<WashBooking> bookings,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.telebirrBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.telebirrBlue, size: 19),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        'Digital Receipts & Verification',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  '${bookings.length} Digital',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (bookings.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text(
                'No digital payments recorded in this period.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.take(6).length,
              separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.cardBorder),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final hasScreenshot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty;

                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: b.payment.method.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(b.payment.method.icon, color: b.payment.method.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                b.licensePlate,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: b.payment.method.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  b.payment.method.shortName,
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: b.payment.method.color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ref: ${b.payment.transactionRef ?? 'N/A'} • ${CurrencyFormatter.format(b.payment.amount)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (hasScreenshot)
                      ElevatedButton.icon(
                        onPressed: () => _showScreenshotDialog(context, b),
                        icon: const Icon(Icons.image_rounded, size: 13),
                        label: const Text('Receipt', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.telebirrBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'No Receipt',
                          style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showScreenshotDialog(BuildContext context, WashBooking booking) {
    final screenshot = booking.payment.receiptScreenshot ?? '';
    Widget imageWidget;

    try {
      if (screenshot.startsWith('data:image')) {
        final commaIdx = screenshot.indexOf(',');
        final base64Data = commaIdx != -1 ? screenshot.substring(commaIdx + 1) : screenshot;
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('Unable to load receipt image')),
        );
      } else if (screenshot.startsWith('http://') || screenshot.startsWith('https://')) {
        imageWidget = Image.network(
          screenshot,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('Unable to load receipt from web')),
        );
      } else {
        final bytes = base64Decode(screenshot);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('Unable to decode receipt image')),
        );
      }
    } catch (_) {
      imageWidget = const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Invalid or corrupted image format', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(booking.payment.method.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receipt • ${booking.licensePlate}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          Text(
                            'Ref: ${booking.payment.transactionRef ?? 'N/A'} • ${booking.payment.method.displayName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  color: Colors.black.withOpacity(0.04),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: InteractiveViewer(
                    maxScale: 3.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageWidget,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${CurrencyFormatter.format(booking.payment.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveBanner(dynamic state, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 18 : 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: isMobile ? 20 : 22),
          ),
          SizedBox(width: isMobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      state.tr('adminTitle'),
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withOpacity(0.4)),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.lightGreenAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.tr("bishoftu")} • 15% Seniority Commission & Live Supabase Cloud',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isMobile ? 10.5 : 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color, {
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(icon, color: color, size: isMobile ? 18 : 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
