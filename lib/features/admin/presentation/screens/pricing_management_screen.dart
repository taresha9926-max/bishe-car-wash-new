import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  String? _selectedPackageId;

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
            const SizedBox(height: 10),

            // Dropdown package picker
            _buildPackageDropdown(state, packages),
            const SizedBox(height: 14),

            // Expandable Package List
            ...packages.map((pkg) => _buildPackageCard(context, state, pkg, packages)),

            // Additional Services Tariffs (Carpet & Station Shower)
            _buildCarpetAndShowerPricingSection(context, state),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDropdown(dynamic state, List<WashPackage> packages) {
    if (packages.isEmpty) return const SizedBox.shrink();
    final activeId = _selectedPackageId ?? packages.first.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: packages.any((p) => p.id == activeId) ? activeId : packages.first.id,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.primary, size: 20),
          items: packages.map((pkg) {
            return DropdownMenuItem<String>(
              value: pkg.id,
              child: Text(
                pkg.localizedName(state.currentLang),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedPackageId = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, dynamic state, WashPackage pkg, List<WashPackage> packages) {
    final activeId = _selectedPackageId ?? packages.first.id;
    final isSelected = pkg.id == activeId;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackageId = pkg.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.03),
              blurRadius: isSelected ? 10 : 6,
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
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Radio<String>(
                    value: pkg.id,
                    groupValue: activeId,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onChanged: (_) => setState(() => _selectedPackageId = pkg.id),
                  ),
                  const SizedBox(width: 6),
                  AutoCareAssets.buildPhotoThumbnail(
                    imageUrl: AutoCareAssets.getPackageImage(pkg),
                    width: 44,
                    height: 44,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pkg.localizedName(state.currentLang),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
                      const SizedBox(width: 8),
                      Icon(
                        isSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isSelected)
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
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('includedServices'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            ...pkg.localizedFeatures(state.currentLang).map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.statusCompleted),
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
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    Text(
                      'Tap any category to update price:',
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
                                  AutoCareAssets.buildPhotoThumbnail(
                                    imageUrl: AutoCareAssets.getCarTypeImage(type),
                                    width: 38,
                                    height: 28,
                                    borderRadius: 6,
                                  ),
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
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('edit', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                      SizedBox(width: 2),
                                      Icon(Icons.edit_outlined, size: 9, color: AppColors.textMuted),
                                    ],
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
              )
            else
              // Collapsed summary preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${pkg.features.length} itemized services included',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    ),
                    Row(
                      children: CarType.values.map((type) {
                        final price = pkg.getPriceFor(type);
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            CurrencyFormatter.formatShort(price),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
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

  Widget _buildCarpetAndShowerPricingSection(BuildContext context, dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          state.tr('additionalServicesTariffs'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),

        // Carpet Pricing Card
        Container(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.texture_rounded, color: Color(0xFF6366F1), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('carpetPricingTitle'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          state.tr('carpetPricingSubtitle'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              // Type A Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.tr('carpetTypeA'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(state.tr('carpetTypeADesc'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${state.carpetTypeAPricePerSqM.toStringAsFixed(0)} ETB/m²',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF4338CA)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        onPressed: () => _editCarpetPriceDialog(context, state, isTypeB: false),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 14),
              // Type B Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.tr('carpetTypeB'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(state.tr('carpetTypeBDesc'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${state.carpetTypeBPricePerSqM.toStringAsFixed(0)} ETB/m²',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFB91C1C)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        onPressed: () => _editCarpetPriceDialog(context, state, isTypeB: true),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Station Shower Tariff Card
        Container(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shower_rounded, color: Color(0xFF0284C7), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('showerTariffTitle'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          state.tr('showerCommissionNotice'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.tr('showerFeePerPerson'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(state.tr('publicShowerAtStation'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${state.showerPricePerPerson.toStringAsFixed(0)} ETB',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        onPressed: () => _editShowerPriceDialog(context, state),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editCarpetPriceDialog(BuildContext context, dynamic state, {required bool isTypeB}) {
    final currentPrice = isTypeB ? state.carpetTypeBPricePerSqM as double : state.carpetTypeAPricePerSqM as double;
    final controller = TextEditingController(text: currentPrice.toStringAsFixed(0));
    final label = isTypeB ? state.tr('carpetTypeB') : state.tr('carpetTypeA');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("editPrice")}: $label'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price in ETB / m²',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
            ),
            onPressed: () {
              final newPrice = double.tryParse(controller.text.trim());
              if (newPrice != null && newPrice > 0) {
                Navigator.pop(dialogCtx);
                final appState = AppStateProvider.read(context);
                if (isTypeB) {
                  appState.updateCarpetPricing(typeBPrice: newPrice);
                } else {
                  appState.updateCarpetPricing(typeAPrice: newPrice);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated $label price to $newPrice ETB/m²'),
                    backgroundColor: AppColors.statusCompleted,
                  ),
                );
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }

  void _editShowerPriceDialog(BuildContext context, dynamic state) {
    final currentPrice = state.showerPricePerPerson as double;
    final controller = TextEditingController(text: currentPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("editPrice")}: ${state.tr("showerFeePerPerson")}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price in ETB / person',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newPrice = double.tryParse(controller.text.trim());
              if (newPrice != null && newPrice > 0) {
                Navigator.pop(dialogCtx);
                final appState = AppStateProvider.read(context);
                appState.updateShowerPrice(newPrice);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated shower price to $newPrice ETB/person'),
                    backgroundColor: AppColors.statusCompleted,
                  ),
                );
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }
}
