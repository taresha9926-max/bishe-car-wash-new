import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/commission_item_card.dart';
import '../widgets/pricing_matrix_editor.dart';
import 'commission_logs_screen.dart';
import 'pricing_management_screen.dart';
import 'staff_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final netProfit = state.totalRevenueTodayETB - state.totalCommissionsPaidETB;
    final recentLogs = state.commissionLogs.take(4).toList();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // Bookings paid via digital channels (Telebirr, CBE Birr, etc.)
    final digitalBookings = state.bookings
        .where((b) => b.payment.isPaid && b.payment.method.isDigital)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('adminTitle'),
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Executive Banner
              _buildExecutiveBanner(state),
              const SizedBox(height: 18),

              // 2. Financial & Operational KPIs (Clean Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 750;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.5 : 1.25,
                    children: [
                      _buildMetricCard(
                        state.tr('totalRevenueAdmin'),
                        CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
                        '${state.totalCompletedCarsToday} ${state.tr("carsWashed")}',
                        Icons.account_balance_wallet_rounded,
                        AppColors.primary,
                      ),
                      _buildMetricCard(
                        state.tr('commissionsPaid'),
                        CurrencyFormatter.formatShort(state.totalCommissionsPaidETB),
                        '15% washer split',
                        Icons.handshake_rounded,
                        AppColors.oromiaGold,
                      ),
                      _buildMetricCard(
                        state.tr('netStationProfit'),
                        CurrencyFormatter.formatShort(netProfit > 0 ? netProfit : 0),
                        'After payroll cuts',
                        Icons.trending_up_rounded,
                        AppColors.statusReady,
                      ),
                      _buildMetricCard(
                        state.tr('activeWashers'),
                        '${state.availableWashers.length} Ready',
                        '${state.staff.length} on team',
                        Icons.groups_rounded,
                        AppColors.secondary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Operational Management Modules
              Text(
                state.tr('managementOperations'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildOperationCard(
                      context,
                      title: state.tr('pricingMatrix'),
                      subtitle: state.tr('pricingSubtitle'),
                      icon: Icons.tune_rounded,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PricingManagementScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOperationCard(
                      context,
                      title: state.tr('staffPayroll'),
                      subtitle: state.tr('staffPayrollSub'),
                      icon: Icons.badge_rounded,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Digital Payment Receipts Audit Section
              _buildDigitalReceiptsSection(context, digitalBookings),
              const SizedBox(height: 24),

              // 5. Live Pricing Matrix Editor Widget
              PricingMatrixEditor(packages: state.packages),
              const SizedBox(height: 24),

              // 6. Automated Commission Split Ledger
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('recentCommissions'),
                    style: const TextStyle(
                      fontSize: 17,
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

  Widget _buildDigitalReceiptsSection(BuildContext context, List<WashBooking> bookings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.telebirrBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.telebirrBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Digital Receipts & Verification',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  '${bookings.length} Digital',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (bookings.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text(
                'No digital payments recorded yet today.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.take(6).length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.cardBorder),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final hasScreenshot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty;

                return Row(
                  children: [
                    // Method icon badge
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: b.payment.method.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(b.payment.method.icon, color: b.payment.method.color, size: 19),
                    ),
                    const SizedBox(width: 12),

                    // Plate & Details
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: b.payment.method.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  b.payment.method.shortName,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: b.payment.method.color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Ref: ${b.payment.transactionRef ?? 'N/A'} • ${CurrencyFormatter.format(b.payment.amount)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Screenshot View Button
                    if (hasScreenshot)
                      ElevatedButton.icon(
                        onPressed: () => _showScreenshotDialog(context, b),
                        icon: const Icon(Icons.image_rounded, size: 14),
                        label: const Text('View Receipt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.telebirrBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'No Receipt',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
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
              // Header
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

              // Image display
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

              // Footer
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

  Widget _buildExecutiveBanner(dynamic state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('adminTitle'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.tr("bishoftu")} • Automated Commission & Supabase Cloud Active',
                  style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 2),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
