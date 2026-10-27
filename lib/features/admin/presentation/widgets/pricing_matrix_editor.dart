import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class PricingMatrixEditor extends StatefulWidget {
  final List<WashPackage> packages;

  const PricingMatrixEditor({
    super.key,
    required this.packages,
  });

  @override
  State<PricingMatrixEditor> createState() => _PricingMatrixEditorState();
}

class _PricingMatrixEditorState extends State<PricingMatrixEditor> {
  String? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = widget.packages;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    state.tr('pricingMatrix').toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                  ),
                ),
                ...CarType.values.map((carType) {
                  return Expanded(
                    flex: 2,
                    child: Text(
                      carType.localizedName(state.currentLang).split(' ').first.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Dropdown package selector
          if (packages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: AppColors.background,
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: packages.any((p) => p.id == _selectedPackageId) ? _selectedPackageId : null,
                        hint: const Text(
                          'Select package to inspect detail services...',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        items: packages.map((pkg) {
                          return DropdownMenuItem<String>(
                            value: pkg.id,
                            child: Text(
                              pkg.localizedName(state.currentLang),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedPackageId = val);
                        },
                      ),
                    ),
                  ),
                  if (_selectedPackageId != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                      tooltip: 'Collapse',
                      onPressed: () => setState(() => _selectedPackageId = null),
                    ),
                ],
              ),
            ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              final isSelected = pkg.id == _selectedPackageId;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPackageId = isSelected ? null : pkg.id;
                      });
                    },
                    child: Container(
                      color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        pkg.localizedName(state.currentLang),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${pkg.durationMinutes} min wash',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...CarType.values.map((carType) {
                            final price = pkg.getPriceFor(carType);

                            return Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () => _showEditPriceDialog(context, pkg, carType, price),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        CurrencyFormatter.formatShort(price),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      const Text(
                                        'edit ✏️',
                                        style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Detail services expanded view
                  if (isSelected)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.localizedDescription(state.currentLang),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          ),
                          if (pkg.features.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Included Services:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            ...pkg.features.map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.statusCompleted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ],
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

  void _showEditPriceDialog(
    BuildContext context,
    WashPackage pkg,
    CarType carType,
    double currentPrice,
  ) {
    final state = AppStateProvider.read(context);
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
              '${carType.localizedName(state.currentLang)} Tariff',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: priceController,
              label: 'Price in ETB',
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
                await state.updatePackagePrice(
                  packageId: pkg.id,
                  carType: carType,
                  newPrice: newPrice,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated ${pkg.localizedName(state.currentLang)} for ${carType.localizedName(state.currentLang)} to $newPrice ETB'),
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
