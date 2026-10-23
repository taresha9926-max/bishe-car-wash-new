import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final bookings = notifier.bookings;
    final staff = notifier.staff;
    final packages = notifier.packages;
    final commissions = notifier.commissions;

    // Financial Analytics
    final completedBookings = bookings.where((b) => b.payment.isPaid).toList();
    final totalRevenue = completedBookings.fold<double>(0.0, (sum, b) => sum + b.payment.amount);
    final telebirrTotal = completedBookings
        .where((b) => b.payment.method == PaymentMethod.telebirr)
        .fold<double>(0.0, (sum, b) => sum + b.payment.amount);
    final cbeTotal = completedBookings
        .where((b) => b.payment.method == PaymentMethod.cbeBirr)
        .fold<double>(0.0, (sum, b) => sum + b.payment.amount);
    final cashTotal = completedBookings
        .where((b) => b.payment.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.payment.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notifier.tr('adminDashboard'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // 1. Financial & Operational Analytics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Vehicles Today',
                  '${completedBookings.length}',
                  Icons.directions_car_rounded,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  'Total Revenue',
                  '${totalRevenue.toStringAsFixed(0)} ETB',
                  Icons.payments_rounded,
                  AppColors.cashGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payment Channel Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Channel Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _channelItem('Telebirr', '${telebirrTotal.toStringAsFixed(0)} Br', AppColors.telebirrBlue),
                      _channelItem('CBE Birr', '${cbeTotal.toStringAsFixed(0)} Br', AppColors.cbeBirrPurple),
                      _channelItem('Cash', '${cashTotal.toStringAsFixed(0)} Br', AppColors.cashGreen),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Dynamic Pricing Manager
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notifier.tr('pricingManager'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const Icon(Icons.tune_rounded, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...packages.map((pkg) => _buildPackagePriceEditor(context, pkg)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Washer Payroll & Commission Ledger
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notifier.tr('payrollCommissions'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...staff.map((washer) {
                    final earned = commissions
                        .where((c) => c.washerName.toLowerCase() == washer.name.toLowerCase() && !c.isSettled)
                        .fold<double>(0.0, (sum, c) => sum + c.commissionEarnedETB);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(washer.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      title: Text(washer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        'Base: ${washer.baseSalaryMonthlyETB.toStringAsFixed(0)} ETB/mo • Commission: 15% (Unsettled: ${earned.toStringAsFixed(1)} ETB)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        onPressed: earned > 0
                            ? () async {
                                for (final c in commissions.where((c) => c.washerName.toLowerCase() == washer.name.toLowerCase() && !c.isSettled)) {
                                  await notifier.settleCommission(c.id);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Commissions settled for ${washer.name}')),
                                );
                              }
                            : null,
                        child: Text(notifier.tr('settleCommission')),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _channelItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildPackagePriceEditor(BuildContext context, dynamic pkg) {
    final notifier = AppStateProvider.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pkg.name as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 6),
          Row(
            children: [
              _priceBox('Type A', pkg.getPriceFor(CarType.automobile) as double, (val) {
                notifier.updatePackagePrice(pkg.id as String, CarType.automobile, val);
              }),
              const SizedBox(width: 8),
              _priceBox('Type B', pkg.getPriceFor(CarType.minibus) as double, (val) {
                notifier.updatePackagePrice(pkg.id as String, CarType.minibus, val);
              }),
              const SizedBox(width: 8),
              _priceBox('Type C', pkg.getPriceFor(CarType.truck) as double, (val) {
                notifier.updatePackagePrice(pkg.id as String, CarType.truck, val);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceBox(String type, double price, Function(double) onSave) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${price.toStringAsFixed(0)} Br', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
