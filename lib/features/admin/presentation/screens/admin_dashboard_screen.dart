import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/commission_item_card.dart';
import '../widgets/pricing_matrix_editor.dart';
import '../widgets/revenue_kpi_card.dart';
import 'commission_logs_screen.dart';
import 'pricing_management_screen.dart';
import 'staff_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final netProfit = state.totalRevenueTodayETB - state.totalCommissionsPaidETB;
    final recentLogs = state.commissionLogs.take(3).toList();

    return Scaffold(
      appBar: const AppRoleHeader(
        title: 'Admin Control Hub',
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Executive Overview Header
              _buildExecutiveBanner(),
              const SizedBox(height: 16),

              // KPI Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: RevenueKPICard(
                      title: 'Total Revenue',
                      value: CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
                      subtitle: '${state.totalCompletedCarsToday} cars completed',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RevenueKPICard(
                      title: 'Washer Commissions',
                      value: CurrencyFormatter.formatShort(state.totalCommissionsPaidETB),
                      subtitle: 'Auto-logged on wash completion',
                      icon: Icons.handshake_rounded,
                      color: AppColors.oromiaGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RevenueKPICard(
                      title: 'Net Margin',
                      value: CurrencyFormatter.formatShort(netProfit > 0 ? netProfit : 0),
                      subtitle: 'After staff commissions',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.statusReady,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RevenueKPICard(
                      title: 'Active Washers',
                      value: '${state.availableWashers.length} Staff',
                      subtitle: '${state.staff.length} total team on payroll',
                      icon: Icons.groups_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Admin Control Panels Shortcuts
              const Text(
                'Admin Management Modules',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildModuleShortcut(
                context,
                title: 'Edit Service Pricing by Car Type',
                description: 'Manage price matrix for Automobile, Minibus, and Truck categories.',
                icon: Icons.tune_rounded,
                color: AppColors.primary,
                badge: '${state.packages.length} Packages',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PricingManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildModuleShortcut(
                context,
                title: 'Staff Salaries & Commission Rates',
                description: 'Set base monthly salaries and customize washer commission percentage.',
                icon: Icons.badge_rounded,
                color: AppColors.secondary,
                badge: '${state.staff.length} Staff Members',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaffManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildModuleShortcut(
                context,
                title: 'Washer Commission Audit Logs',
                description: 'Real-time logs recorded automatically whenever any wash is marked completed.',
                icon: Icons.receipt_long_rounded,
                color: AppColors.oromiaGreen,
                badge: '${state.commissionLogs.length} Auto Logs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CommissionLogsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Real-time Pricing Matrix Quick Editor Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Service Pricing Matrix',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PricingManagementScreen(),
                        ),
                      );
                    },
                    child: const Text('Full View'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap any price cell to adjust billing rates across car types in ETB:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              PricingMatrixEditor(packages: state.packages),
              const SizedBox(height: 24),

              // Recent Commission Logs Stream
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Automated Commission Logs',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommissionLogsScreen(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (recentLogs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'No commission logs generated yet. Mark a wash completed to test!',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              else
                ...recentLogs.map((log) => CommissionItemCard(log: log)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BISHE Executive Control Panel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Bishoftu Hub • Automated Washer Commission System Active',
                  style: TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleShortcut(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String badge,
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
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
