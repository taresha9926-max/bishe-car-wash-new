import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class PricingManagementScreen extends StatelessWidget {
  const PricingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.tr('pricingManagementTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.tr('pricingSubtitle'),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.primaryDark, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              state.tr('servicePackages'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            ...packages.map((pkg) => _buildPackageCard(context, state, pkg)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, dynamic state, WashPackage pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pkg.localizedName(state.currentLang),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${pkg.durationMinutes} mins',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.localizedDescription(state.currentLang),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                ),
                if (pkg.features.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...pkg.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 14),

                Text(
                  state.tr('pricingSubtitle'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),

                // 3 Car Types Row
                Row(
                  children: CarType.values.map((type) {
                    final price = pkg.getPriceFor(type);
                    return Expanded(
                      child: InkWell(
                        onTap: () => _editPrice(context, state, pkg, type, price),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: EdgeInsets.only(right: type != CarType.values.last ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              Icon(type.icon, size: 20, color: AppColors.primary),
                              const SizedBox(height: 4),
                              Text(
                                type.localizedName(state.currentLang).split(' ').first,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(price),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editPrice(
    BuildContext context,
    dynamic state,
    WashPackage pkg,
    CarType type,
    double currentPrice,
  ) {
    final priceController = TextEditingController(text: currentPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("pricingMatrix")}: ${pkg.localizedName(state.currentLang)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${type.localizedName(state.currentLang)} Tariff',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: priceController,
              label: state.tr('priceInEtb'),
              hint: 'e.g. 350',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text.trim());
              if (newPrice != null && newPrice > 0) {
                Navigator.pop(dialogCtx);
                final appState = AppStateProvider.read(context);
                await appState.updatePackagePrice(
                  packageId: pkg.id,
                  carType: type,
                  newPrice: newPrice,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated ${pkg.localizedName(state.currentLang)} price to $newPrice ETB'),
                      backgroundColor: AppColors.statusCompleted,
                    ),
                  );
                }
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }
}
