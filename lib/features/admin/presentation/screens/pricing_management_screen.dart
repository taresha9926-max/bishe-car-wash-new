import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/car_wash_service_item.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../inventory/domain/models/consumable_item.dart';
import '../../../inventory/domain/models/fixed_asset.dart';

/// Centralized Super Admin Hub to manage, edit prices, add new entries,
/// and delete items across 4 separated operational divisions:
/// 1. Car Wash Detailing Services & Vehicle Tariffs
/// 2. Carpet Cleaning Tariffs & Specialty Treatments
/// 3. Storekeeper Consumables Inventory & Unit Costs
/// 4. Storekeeper Fixed Assets & Equipment Valuation
class PricingManagementScreen extends StatefulWidget {
  final int initialTabIndex;

  const PricingManagementScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  late int _activeTab;
  String _searchQuery = '';
  String? _selectedPackageId;
  bool _showCarWashPackages = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTabIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(state.tr('masterPricingAndInventory')),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Super Admin Notice Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primary.withOpacity(0.08),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.tr('superAdminOnlyNotice'),
                    style: const TextStyle(fontSize: 11.5, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // 4 Separated Fields Segmented Navigation
          _buildSegmentedTabBar(state),

          // Search Filter Bar
          _buildSearchBar(state),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildActiveTabContent(context, state),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 4 SEPARATED TABS SELECTOR =================

  Widget _buildSegmentedTabBar(dynamic state) {
    final tabs = [
      {'label': state.tr('carWashTariffs'), 'icon': Icons.local_car_wash_rounded, 'count': state.serviceItems.length},
      {'label': state.tr('carpetTariffs'), 'icon': Icons.texture_rounded, 'count': state.carpetAddonServices.length + 6},
      {'label': state.tr('consumablesPricing'), 'icon': Icons.science_outlined, 'count': state.consumables.length},
      {'label': state.tr('fixedAssetsValuation'), 'icon': Icons.precision_manufacturing_rounded, 'count': state.fixedAssets.length},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _activeTab == index;
            final item = tabs[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  item['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                label: Text(
                  '${item['label']} (${item['count']})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  ),
                ),
                onSelected: (_) {
                  setState(() {
                    _activeTab = index;
                    _searchQuery = '';
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSearchBar(dynamic state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        decoration: InputDecoration(
          hintText: state.tr('searchPlaceholder'),
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant.withOpacity(0.5),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context, dynamic state) {
    switch (_activeTab) {
      case 0:
        return _buildCarWashServicesTab(context, state);
      case 1:
        return _buildCarpetServicesTab(context, state);
      case 2:
        return _buildConsumablesTab(context, state);
      case 3:
        return _buildFixedAssetsTab(context, state);
      default:
        return const SizedBox.shrink();
    }
  }

  // ================= 1. CAR WASH SERVICES & TARIFFS =================

  Widget _buildCarWashServicesTab(BuildContext context, dynamic state) {
    final List<CarWashServiceItem> items = state.serviceItems;
    final filtered = items.where((i) {
      if (_searchQuery.isEmpty) return true;
      return i.name.toLowerCase().contains(_searchQuery) ||
          i.category.toLowerCase().contains(_searchQuery) ||
          (i.description?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('carWashTariffs'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  _showCarWashPackages
                      ? '${state.packages.length} ${state.tr("presetPackagesTab")}'
                      : '${items.length} ${state.tr("customDetailingTab")} • ${state.activeServiceItems.length} active',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            if (!_showCarWashPackages)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(state.tr('addNewService'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: () => _showAddCarWashServiceDialog(context, state),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Dual Sub-Tab Switcher: Custom Detailing vs Preset Packages
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showCarWashPackages = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: !_showCarWashPackages ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rounded, size: 16, color: !_showCarWashPackages ? Colors.white : AppColors.textPrimary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${state.tr("customDetailingTab")} (${items.length})',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: !_showCarWashPackages ? Colors.white : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showCarWashPackages = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _showCarWashPackages ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 16, color: _showCarWashPackages ? Colors.white : AppColors.textPrimary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${state.tr("presetPackagesTab")} (${state.packages.length})',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _showCarWashPackages ? Colors.white : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (_showCarWashPackages) ...[
          // Package Presets view
          _buildDeliveryAddonsCard(context, state, isCarpet: false),
        ...state.packages.map((pkg) => _buildPackageCard(context, state, pkg, state.packages)),
        ] else ...[
          // Atomic Car Wash Detailing Services List
          if (filtered.isEmpty)
            _buildEmptyState(state, 'No car wash services found')
          else
            ...filtered.map((item) => _buildCarWashServiceCard(context, state, item)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCarWashServiceCard(BuildContext context, dynamic state, CarWashServiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.isActive ? AppColors.cardBorder : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip / Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    size: 20,
                    color: _getCategoryColor(item.category),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.localizedName(state.currentLang),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: item.isActive ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(item.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.localizedCategory(state.currentLang).toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: _getCategoryColor(item.category),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.description!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: item.isActive,
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => state.toggleServiceItemActive(item.id),
                ),
              ],
            ),
            const Divider(height: 16),

            // Tariffs across Automobile, Minibus, Truck
            Row(
              children: CarType.values.map((carType) {
                final tariff = item.getPriceFor(carType);
                return Expanded(
                  child: InkWell(
                    onTap: () => _showEditCarWashServiceDialog(context, state, item),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: EdgeInsets.only(right: carType != CarType.values.last ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            carType.localizedName(state.currentLang).split(' ').first,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(tariff),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Actions: Edit and Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditCarWashServiceDialog(context, state, item),
                  icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                  label: Text(state.tr('editService'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDeleteService(context, state, item),
                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
                  label: Text(state.tr('deleteService'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'exterior':
        return Colors.blue;
      case 'polish':
        return Colors.amber.shade800;
      case 'interior':
        return Colors.purple;
      case 'engine':
        return Colors.deepOrange;
      case 'specialty':
      default:
        return const Color(0xFF0F766E);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'exterior':
        return Icons.local_car_wash_rounded;
      case 'polish':
        return Icons.auto_awesome_rounded;
      case 'interior':
        return Icons.airline_seat_recline_extra_rounded;
      case 'engine':
        return Icons.bolt_rounded;
      case 'specialty':
      default:
        return Icons.diamond_rounded;
    }
  }

  void _showAddCarWashServiceDialog(BuildContext context, dynamic state) {
    final nameController = TextEditingController();
    final nameAmharicController = TextEditingController();
    final nameOromoController = TextEditingController();
    final descController = TextEditingController();
    final autoPriceController = TextEditingController(text: '500');
    final minibusPriceController = TextEditingController(text: '700');
    final truckPriceController = TextEditingController(text: '1200');
    String selectedCategory = 'exterior';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(state.tr('addNewService')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Service Name (EN)',
                  hint: 'e.g. Diamond Detailing',
                  prefixIcon: Icons.cleaning_services_outlined,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: nameAmharicController,
                  label: 'የአገልግሎት ስም (AM)',
                  hint: 'ለምሳሌ፡ ዳይመንድ ዲቴይሊንግ',
                  prefixIcon: Icons.translate_rounded,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: nameOromoController,
                  label: 'Maqaa Tajaajilaa (OM)',
                  hint: 'fakkeenya: Daayimandii',
                  prefixIcon: Icons.language_rounded,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: state.tr('serviceCategory'),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    DropdownMenuItem(value: 'exterior', child: Text(AppStrings.translateCategoryName('exterior', state.currentLang))),
                    DropdownMenuItem(value: 'polish', child: Text(AppStrings.translateCategoryName('polish', state.currentLang))),
                    DropdownMenuItem(value: 'interior', child: Text(AppStrings.translateCategoryName('interior', state.currentLang))),
                    DropdownMenuItem(value: 'engine', child: Text(AppStrings.translateCategoryName('engine', state.currentLang))),
                    DropdownMenuItem(value: 'specialty', child: Text(AppStrings.translateCategoryName('specialty', state.currentLang))),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descController,
                  label: 'Description',
                  hint: 'Detailed steps & chemicals used',
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: 12),
                const Text('Vehicle Tariffs (ETB):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: autoPriceController,
                        label: 'Auto',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CustomTextField(
                        controller: minibusPriceController,
                        label: 'Minibus',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CustomTextField(
                        controller: truckPriceController,
                        label: 'Truck',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final autoPrice = double.tryParse(autoPriceController.text.trim()) ?? 500.0;
                final minibusPrice = double.tryParse(minibusPriceController.text.trim()) ?? 700.0;
                final truckPrice = double.tryParse(truckPriceController.text.trim()) ?? 1200.0;

                final newItem = CarWashServiceItem(
                  id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  nameAmharic: nameAmharicController.text.trim().isNotEmpty ? nameAmharicController.text.trim() : null,
                  nameOromo: nameOromoController.text.trim().isNotEmpty ? nameOromoController.text.trim() : null,
                  category: selectedCategory,
                  description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                  pricingByCarType: {
                    CarType.automobile: autoPrice,
                    CarType.minibus: minibusPrice,
                    CarType.truck: truckPrice,
                  },
                  isActive: true,
                );

                Navigator.pop(dialogCtx);
                await state.addCustomServiceItem(newItem);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added new car wash service: ${newItem.localizedName(state.currentLang)}'),
                      backgroundColor: AppColors.statusCompleted,
                    ),
                  );
                }
              },
              child: Text(state.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCarWashServiceDialog(BuildContext context, dynamic state, CarWashServiceItem item) {
    final nameController = TextEditingController(text: item.name);
    final nameAmharicController = TextEditingController(text: item.nameAmharic ?? '');
    final nameOromoController = TextEditingController(text: item.nameOromo ?? '');
    final descController = TextEditingController(text: item.description ?? '');
    final autoPriceController = TextEditingController(text: item.getPriceFor(CarType.automobile).toStringAsFixed(0));
    final minibusPriceController = TextEditingController(text: item.getPriceFor(CarType.minibus).toStringAsFixed(0));
    final truckPriceController = TextEditingController(text: item.getPriceFor(CarType.truck).toStringAsFixed(0));
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('${state.tr("editService")}: ${item.localizedName(state.currentLang)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Service Name (EN)',
                  prefixIcon: Icons.cleaning_services_outlined,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: nameAmharicController,
                  label: 'የአገልግሎት ስም (AM)',
                  hint: 'የአማርኛ ስም',
                  prefixIcon: Icons.translate_rounded,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: nameOromoController,
                  label: 'Maqaa Tajaajilaa (OM)',
                  hint: 'Maqaa Afaan Oromoo',
                  prefixIcon: Icons.language_rounded,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: ['exterior', 'polish', 'interior', 'engine', 'specialty'].contains(selectedCategory)
                      ? selectedCategory
                      : 'exterior',
                  decoration: InputDecoration(
                    labelText: state.tr('serviceCategory'),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    DropdownMenuItem(value: 'exterior', child: Text(AppStrings.translateCategoryName('exterior', state.currentLang))),
                    DropdownMenuItem(value: 'polish', child: Text(AppStrings.translateCategoryName('polish', state.currentLang))),
                    DropdownMenuItem(value: 'interior', child: Text(AppStrings.translateCategoryName('interior', state.currentLang))),
                    DropdownMenuItem(value: 'engine', child: Text(AppStrings.translateCategoryName('engine', state.currentLang))),
                    DropdownMenuItem(value: 'specialty', child: Text(AppStrings.translateCategoryName('specialty', state.currentLang))),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descController,
                  label: 'Description',
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: 12),
                const Text('Vehicle Tariffs (ETB):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: autoPriceController,
                        label: 'Auto',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CustomTextField(
                        controller: minibusPriceController,
                        label: 'Minibus',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CustomTextField(
                        controller: truckPriceController,
                        label: 'Truck',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final autoPrice = double.tryParse(autoPriceController.text.trim()) ?? item.getPriceFor(CarType.automobile);
                final minibusPrice = double.tryParse(minibusPriceController.text.trim()) ?? item.getPriceFor(CarType.minibus);
                final truckPrice = double.tryParse(truckPriceController.text.trim()) ?? item.getPriceFor(CarType.truck);

                final updated = item.copyWith(
                  name: name,
                  nameAmharic: nameAmharicController.text.trim().isNotEmpty ? nameAmharicController.text.trim() : null,
                  nameOromo: nameOromoController.text.trim().isNotEmpty ? nameOromoController.text.trim() : null,
                  category: selectedCategory,
                  description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                  pricingByCarType: {
                    CarType.automobile: autoPrice,
                    CarType.minibus: minibusPrice,
                    CarType.truck: truckPrice,
                  },
                );

                Navigator.pop(dialogCtx);
                await state.updateCustomServiceItem(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated service: ${updated.localizedName(state.currentLang)}'),
                      backgroundColor: AppColors.statusCompleted,
                    ),
                  );
                }
              },
              child: Text(state.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteService(BuildContext context, dynamic state, CarWashServiceItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(state.tr('deleteService')),
        content: Text('${state.tr("confirmDeleteService")}\n\nService: "${item.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await state.deleteCustomServiceItem(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted service: ${item.name}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(state.tr('delete')),
          ),
        ],
      ),
    );
  }

  // ================= 2. CARPET SERVICES & TARIFFS =================

  Widget _buildCarpetServicesTab(BuildContext context, dynamic state) {
    final addons = state.carpetAddonServices as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('carpetTariffs'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const Text(
                  'Standard Area Rates (ETB/m²) & Specialty Treatments',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text(state.tr('addNewCarpetService'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              onPressed: () => _showAddCarpetAddonDialog(context, state),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Base Area Tariff Matrix Card (Type A & Type B)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AutoCareAssets.buildPhotoThumbnail(
                    imageUrl: AutoCareAssets.carpetTypeAUrl,
                    width: 38,
                    height: 38,
                    borderRadius: 8,
                    fallbackIcon: Icons.texture_rounded,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('carpetMatrixTitle'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          state.tr('carpetMatrixSubtitle'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // SECTION 1: TYPE A (NORMAL)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF4338CA)),
                    const SizedBox(width: 8),
                    Text(
                      state.tr('carpetTypeA'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF4338CA)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              _buildMatrixRow(
                context,
                state,
                imageUrl: AutoCareAssets.carpetStationWashUrl,
                title: state.tr('carpetTypeAStation'),
                subtitle: '${state.tr("atStationService")} • ${state.tr("baseStationRatePerSqm")}',
                price: state.carpetTypeAStationPrice,
                onEdit: () => _editCarpetMatrixDialog(context, state, type: 'type_a', mode: ServiceType.walkInStation, label: state.tr('carpetTypeAStation')),
              ),
              const SizedBox(height: 18),

              // SECTION 2: TYPE B (HEAVY DUTY)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFB91C1C)),
                    const SizedBox(width: 8),
                    Text(
                      state.tr('carpetTypeB'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              _buildMatrixRow(
                context,
                state,
                imageUrl: AutoCareAssets.carpetStationWashUrl,
                title: state.tr('carpetTypeBStation'),
                subtitle: '${state.tr("atStationService")} • ${state.tr("baseStationRatePerSqm")}',
                price: state.carpetTypeBStationPrice,
                onEdit: () => _editCarpetMatrixDialog(context, state, type: 'type_b', mode: ServiceType.walkInStation, label: state.tr('carpetTypeBStation')),
              ),
              const SizedBox(height: 18),
              _buildDeliveryAddonsCard(context, state, isCarpet: true),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AutoCareAssets.buildPhotoThumbnail(
                    imageUrl: AutoCareAssets.publicShowerUrl,
                    width: 38,
                    height: 38,
                    borderRadius: 8,
                    fallbackIcon: Icons.shower_rounded,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.tr('showerTariffTitle'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(state.tr('showerFeePerPerson'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${state.showerPricePerPerson.toStringAsFixed(0)} ETB',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    onPressed: () => _editShowerPriceDialog(context, state),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dynamic Carpet Specialty Add-on Services (Editable & Deletable)
        Text(
          'Specialty Carpet Treatments (${addons.length})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        ...addons.map((addon) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4338CA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_fix_high_rounded, size: 18, color: Color(0xFF4338CA)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addon['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        if (addon['description'] != null)
                          Text(addon['description'] as String, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format((addon['price'] as num?)?.toDouble() ?? 0.0),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF4338CA)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                    onPressed: () => _showEditCarpetAddonDialog(context, state, addon),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                    onPressed: () => _confirmDeleteCarpetAddon(context, state, addon),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showAddCarpetAddonDialog(BuildContext context, dynamic state) {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '300');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(state.tr('addNewCarpetService')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Treatment / Service Name',
              hint: 'e.g. Odor Neutralizing Deep Wash',
              prefixIcon: Icons.cleaning_services_outlined,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: priceController,
              label: 'Price in ETB',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: descController,
              label: 'Description',
              prefixIcon: Icons.description_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4338CA), foregroundColor: Colors.white),
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 300.0;
              if (name.isNotEmpty) {
                Navigator.pop(dialogCtx);
                state.addCarpetAddonService({
                  'id': 'cpt_${DateTime.now().millisecondsSinceEpoch}',
                  'name': name,
                  'category': 'Specialty',
                  'price': price,
                  'description': descController.text.trim(),
                });
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showEditCarpetAddonDialog(BuildContext context, dynamic state, Map<String, dynamic> addon) {
    final nameController = TextEditingController(text: addon['name'] as String? ?? '');
    final priceController = TextEditingController(text: ((addon['price'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0));
    final descController = TextEditingController(text: addon['description'] as String? ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("editCarpetService")}: ${addon["name"]}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: nameController, label: 'Name'),
            const SizedBox(height: 10),
            CustomTextField(controller: priceController, label: 'Price (ETB)', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            CustomTextField(controller: descController, label: 'Description'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4338CA), foregroundColor: Colors.white),
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? (addon['price'] as num).toDouble();
              if (name.isNotEmpty) {
                Navigator.pop(dialogCtx);
                state.updateCarpetAddonService({
                  ...addon,
                  'name': name,
                  'price': price,
                  'description': descController.text.trim(),
                });
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCarpetAddon(BuildContext context, dynamic state, Map<String, dynamic> addon) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(state.tr('deleteCarpetServiceConfirm')),
        content: Text('Delete "${addon["name"]}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(dialogCtx);
              state.deleteCarpetAddonService(addon['id'] as String);
            },
            child: Text(state.tr('delete')),
          ),
        ],
      ),
    );
  }

  // ================= 3. STOREKEEPER CONSUMABLES INVENTORY =================

  Widget _buildConsumablesTab(BuildContext context, dynamic state) {
    final List<ConsumableItem> items = state.consumables;
    final filtered = items.where((i) {
      if (_searchQuery.isEmpty) return true;
      return i.name.toLowerCase().contains(_searchQuery) ||
          i.nameAmharic.toLowerCase().contains(_searchQuery) ||
          i.category.toLowerCase().contains(_searchQuery);
    }).toList();

    final totalValuation = items.fold<double>(0.0, (sum, i) => sum + (i.currentStock * i.unitCostEtb));
    final lowStockCount = items.where((i) => i.isLowStock).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Summary Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildKpiStat('Total Items', '${items.length}', Icons.science_outlined, AppColors.primary),
              _buildKpiStat('Low Stock Alert', '$lowStockCount', Icons.warning_amber_rounded, lowStockCount > 0 ? Colors.orange : Colors.green),
              _buildKpiStat('Stock Valuation', CurrencyFormatter.format(totalValuation), Icons.account_balance_wallet_outlined, const Color(0xFF0F766E)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Header & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('consumablesPricing'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  'Manage consumable unit costs, stock levels & units',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text(state.tr('addNewConsumable'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              onPressed: () => _showAddConsumableDialog(context, state),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          _buildEmptyState(state, 'No consumable items found')
        else
          ...filtered.map((item) => _buildConsumableCard(context, state, item)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildConsumableCard(BuildContext context, dynamic state, ConsumableItem item) {
    final stockValuation = item.currentStock * item.unitCostEtb;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isLowStock ? Colors.orange.shade300 : AppColors.cardBorder,
          width: item.isLowStock ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.science_rounded, size: 20, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    if (item.nameAmharic.isNotEmpty)
                      Text(item.nameAmharic, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${item.category} • Unit: ${item.unit}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isLowStock ? Colors.orange.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.currentStock.toStringAsFixed(1)} ${item.unit}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: item.isLowStock ? Colors.orange.shade900 : Colors.green.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Min: ${item.minThreshold.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),

          // Price & Valuation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.tr('unitCostEtb'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text(
                    CurrencyFormatter.format(item.unitCostEtb),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F766E)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Value', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text(
                    CurrencyFormatter.format(stockValuation),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Actions: Edit and Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditConsumableDialog(context, state, item),
                icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0F766E)),
                label: Text(state.tr('editConsumable'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteConsumable(context, state, item),
                icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
                label: Text(state.tr('delete'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddConsumableDialog(BuildContext context, dynamic state) {
    final nameController = TextEditingController();
    final nameAmharicController = TextEditingController();
    final categoryController = TextEditingController(text: 'General Supplies');
    final unitController = TextEditingController(text: 'Liters');
    final costController = TextEditingController(text: '500');
    final stockController = TextEditingController(text: '10');
    final thresholdController = TextEditingController(text: '5');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(state.tr('addNewConsumable')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameController, label: 'Item Name (EN)', hint: 'e.g. Snow Foam Car Shampoo'),
              const SizedBox(height: 10),
              CustomTextField(controller: nameAmharicController, label: 'Name in Amharic', hint: 'e.g. የመኪና ሻምፑ'),
              const SizedBox(height: 10),
              CustomTextField(controller: categoryController, label: 'Category', hint: 'e.g. Detailing Chemicals'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: unitController, label: 'Unit (Liters/Cans/Pieces)')),
                  const SizedBox(width: 8),
                  Expanded(child: CustomTextField(controller: costController, label: 'Unit Price (ETB)', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: stockController, label: 'Initial Stock', keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: CustomTextField(controller: thresholdController, label: 'Min Alert Stock', keyboardType: TextInputType.number)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final unitCost = double.tryParse(costController.text.trim()) ?? 0.0;
              final stock = double.tryParse(stockController.text.trim()) ?? 0.0;
              final minThresh = double.tryParse(thresholdController.text.trim()) ?? 5.0;

              final newItem = ConsumableItem(
                id: 'CS-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                nameAmharic: nameAmharicController.text.trim(),
                category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : 'General Supplies',
                unit: unitController.text.trim().isNotEmpty ? unitController.text.trim() : 'Units',
                currentStock: stock,
                minThreshold: minThresh,
                unitCostEtb: unitCost,
                isDailyHandoverItem: true,
              );

              Navigator.pop(dialogCtx);
              await state.saveConsumable(newItem);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added consumable: $name'), backgroundColor: AppColors.statusCompleted),
                );
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showEditConsumableDialog(BuildContext context, dynamic state, ConsumableItem item) {
    final nameController = TextEditingController(text: item.name);
    final nameAmharicController = TextEditingController(text: item.nameAmharic);
    final categoryController = TextEditingController(text: item.category);
    final unitController = TextEditingController(text: item.unit);
    final costController = TextEditingController(text: item.unitCostEtb.toStringAsFixed(0));
    final stockController = TextEditingController(text: item.currentStock.toStringAsFixed(1));
    final thresholdController = TextEditingController(text: item.minThreshold.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("editConsumable")}: ${item.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameController, label: 'Item Name (EN)'),
              const SizedBox(height: 10),
              CustomTextField(controller: nameAmharicController, label: 'Name in Amharic'),
              const SizedBox(height: 10),
              CustomTextField(controller: categoryController, label: 'Category'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: unitController, label: 'Unit')),
                  const SizedBox(width: 8),
                  Expanded(child: CustomTextField(controller: costController, label: 'Unit Price (ETB)', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: stockController, label: 'Current Stock', keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: CustomTextField(controller: thresholdController, label: 'Min Alert Stock', keyboardType: TextInputType.number)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final unitCost = double.tryParse(costController.text.trim()) ?? item.unitCostEtb;
              final stock = double.tryParse(stockController.text.trim()) ?? item.currentStock;
              final minThresh = double.tryParse(thresholdController.text.trim()) ?? item.minThreshold;

              final updated = item.copyWith(
                name: name,
                nameAmharic: nameAmharicController.text.trim(),
                category: categoryController.text.trim(),
                unit: unitController.text.trim(),
                unitCostEtb: unitCost,
                currentStock: stock,
                minThreshold: minThresh,
              );

              Navigator.pop(dialogCtx);
              await state.saveConsumable(updated);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated consumable: $name'), backgroundColor: AppColors.statusCompleted),
                );
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteConsumable(BuildContext context, dynamic state, ConsumableItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(state.tr('deleteConsumableConfirm')),
        content: Text('Permanently delete "${item.name}" from storekeeper inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await state.deleteConsumable(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted consumable: ${item.name}'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(state.tr('delete')),
          ),
        ],
      ),
    );
  }

  // ================= 4. STOREKEEPER FIXED ASSETS & MACHINERY =================

  Widget _buildFixedAssetsTab(BuildContext context, dynamic state) {
    final List<FixedAsset> assets = state.fixedAssets;
    final filtered = assets.where((a) {
      if (_searchQuery.isEmpty) return true;
      return a.name.toLowerCase().contains(_searchQuery) ||
          a.nameAmharic.toLowerCase().contains(_searchQuery) ||
          a.serialNumber.toLowerCase().contains(_searchQuery) ||
          a.category.toLowerCase().contains(_searchQuery) ||
          a.assignedLocation.toLowerCase().contains(_searchQuery);
    }).toList();

    final totalValuation = assets.fold<double>(0.0, (sum, a) => sum + (a.quantity * a.assetValueEtb));
    final operationalCount = assets.where((a) => a.condition == AssetCondition.operational).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Summary Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildKpiStat('Total Assets', '${assets.length}', Icons.precision_manufacturing_rounded, AppColors.secondary),
              _buildKpiStat('Operational', '$operationalCount / ${assets.length}', Icons.verified_rounded, Colors.green),
              _buildKpiStat('Asset Valuation', CurrencyFormatter.format(totalValuation), Icons.account_balance_outlined, const Color(0xFFC2410C)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Header & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('fixedAssetsValuation'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const Text(
                  'Manage machinery valuation in ETB, serial numbers & location',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2410C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text(state.tr('addNewFixedAsset'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              onPressed: () => _showAddFixedAssetDialog(context, state),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          _buildEmptyState(state, 'No fixed assets found')
        else
          ...filtered.map((asset) => _buildFixedAssetCard(context, state, asset)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFixedAssetCard(BuildContext context, dynamic state, FixedAsset asset) {
    final totalValuation = asset.quantity * asset.assetValueEtb;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2410C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.precision_manufacturing_rounded, size: 20, color: Color(0xFFC2410C)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    if (asset.nameAmharic.isNotEmpty)
                      Text(asset.nameAmharic, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.category} • S/N: ${asset.serialNumber}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getConditionColor(asset.condition).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  asset.condition.displayName,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _getConditionColor(asset.condition),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Details Row: Location, Quantity, Price & Total Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: ${asset.assignedLocation} (Qty: ${asset.quantity})',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.tr("assetValueEtb")}: ${CurrencyFormatter.format(asset.assetValueEtb)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFC2410C)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Value', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text(
                    CurrencyFormatter.format(totalValuation),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Actions: Edit and Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditFixedAssetDialog(context, state, asset),
                icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFC2410C)),
                label: Text(state.tr('editFixedAsset'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC2410C))),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteFixedAsset(context, state, asset),
                icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
                label: Text(state.tr('delete'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(AssetCondition condition) {
    switch (condition) {
      case AssetCondition.operational:
        return Colors.green.shade800;
      case AssetCondition.needsService:
        return Colors.orange.shade800;
      case AssetCondition.underRepair:
        return Colors.amber.shade900;
      case AssetCondition.decommissioned:
        return Colors.red.shade800;
    }
  }

  void _showAddFixedAssetDialog(BuildContext context, dynamic state) {
    final nameController = TextEditingController();
    final nameAmharicController = TextEditingController();
    final categoryController = TextEditingController(text: 'Machinery');
    final snController = TextEditingController(text: 'SN-${DateTime.now().millisecondsSinceEpoch % 10000}');
    final locationController = TextEditingController(text: 'Bay 1 & Bay 2');
    final valueController = TextEditingController(text: '25000');
    final qtyController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    AssetCondition selectedCondition = AssetCondition.operational;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(state.tr('addNewFixedAsset')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, label: 'Asset Name (EN)', hint: 'e.g. High Pressure Washer 250 Bar'),
                const SizedBox(height: 10),
                CustomTextField(controller: nameAmharicController, label: 'Name in Amharic', hint: 'e.g. ከፍተኛ ግፊት ማሽን'),
                const SizedBox(height: 10),
                CustomTextField(controller: categoryController, label: 'Category', hint: 'e.g. Wash Machinery'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: snController, label: 'Serial Number')),
                    const SizedBox(width: 8),
                    Expanded(child: CustomTextField(controller: locationController, label: 'Location')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: valueController, label: 'Asset Valuation (ETB)', keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: CustomTextField(controller: qtyController, label: 'Quantity', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<AssetCondition>(
                  value: selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Operational Condition',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: AssetCondition.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCondition = val);
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: notesController, label: 'Notes'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2410C), foregroundColor: Colors.white),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final assetValue = double.tryParse(valueController.text.trim()) ?? 0.0;
                final qty = int.tryParse(qtyController.text.trim()) ?? 1;

                final newAsset = FixedAsset(
                  id: 'FA-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  nameAmharic: nameAmharicController.text.trim(),
                  category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : 'Machinery',
                  serialNumber: snController.text.trim().isNotEmpty ? snController.text.trim() : 'SN-BISHE',
                  assignedLocation: locationController.text.trim().isNotEmpty ? locationController.text.trim() : 'Station',
                  condition: selectedCondition,
                  quantity: qty,
                  assetValueEtb: assetValue,
                  notes: notesController.text.trim(),
                );

                Navigator.pop(dialogCtx);
                await state.saveFixedAsset(newAsset);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added fixed asset: $name'), backgroundColor: AppColors.statusCompleted),
                  );
                }
              },
              child: Text(state.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFixedAssetDialog(BuildContext context, dynamic state, FixedAsset asset) {
    final nameController = TextEditingController(text: asset.name);
    final nameAmharicController = TextEditingController(text: asset.nameAmharic);
    final categoryController = TextEditingController(text: asset.category);
    final snController = TextEditingController(text: asset.serialNumber);
    final locationController = TextEditingController(text: asset.assignedLocation);
    final valueController = TextEditingController(text: asset.assetValueEtb.toStringAsFixed(0));
    final qtyController = TextEditingController(text: asset.quantity.toString());
    final notesController = TextEditingController(text: asset.notes);
    AssetCondition selectedCondition = asset.condition;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('${state.tr("editFixedAsset")}: ${asset.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, label: 'Asset Name (EN)'),
                const SizedBox(height: 10),
                CustomTextField(controller: nameAmharicController, label: 'Name in Amharic'),
                const SizedBox(height: 10),
                CustomTextField(controller: categoryController, label: 'Category'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: snController, label: 'Serial Number')),
                    const SizedBox(width: 8),
                    Expanded(child: CustomTextField(controller: locationController, label: 'Location')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: valueController, label: 'Asset Valuation (ETB)', keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: CustomTextField(controller: qtyController, label: 'Quantity', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<AssetCondition>(
                  value: selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Operational Condition',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: AssetCondition.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCondition = val);
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: notesController, label: 'Notes'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2410C), foregroundColor: Colors.white),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final assetValue = double.tryParse(valueController.text.trim()) ?? asset.assetValueEtb;
                final qty = int.tryParse(qtyController.text.trim()) ?? asset.quantity;

                final updated = asset.copyWith(
                  name: name,
                  nameAmharic: nameAmharicController.text.trim(),
                  category: categoryController.text.trim(),
                  serialNumber: snController.text.trim(),
                  assignedLocation: locationController.text.trim(),
                  condition: selectedCondition,
                  quantity: qty,
                  assetValueEtb: assetValue,
                  notes: notesController.text.trim(),
                );

                Navigator.pop(dialogCtx);
                await state.saveFixedAsset(updated);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Updated fixed asset: $name'), backgroundColor: AppColors.statusCompleted),
                  );
                }
              },
              child: Text(state.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFixedAsset(BuildContext context, dynamic state, FixedAsset asset) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(state.tr('deleteFixedAssetConfirm')),
        content: Text('Permanently delete "${asset.name}" (S/N: ${asset.serialNumber}) from registry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await state.deleteFixedAsset(asset.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted fixed asset: ${asset.name}'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(state.tr('delete')),
          ),
        ],
      ),
    );
  }

  // ================= SHARED UTILITIES & MATRIX ROWS =================

  Widget _buildKpiStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEmptyState(dynamic state, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(
    BuildContext context,
    dynamic state, {
    required String imageUrl,
    required String title,
    required String subtitle,
    required double price,
    required VoidCallback onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: imageUrl,
                width: 36,
                height: 36,
                borderRadius: 8,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${price.toStringAsFixed(0)} ETB/m²',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              onPressed: onEdit,
            ),
          ],
        ),
      ],
    );
  }

  void _editCarpetMatrixDialog(
    BuildContext context,
    dynamic state, {
    required String type,
    required ServiceType mode,
    required String label,
  }) {
    final currentPrice = state.getCarpetPricePerSqM(type, mode) as double;
    final controller = TextEditingController(text: currentPrice.toStringAsFixed(0));

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
                appState.updateCarpetPackagePrice(type: type, mode: mode, price: newPrice);
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

  Widget _buildDeliveryAddonsCard(BuildContext context, dynamic state, {required bool isCarpet}) {
    final valetFee = isCarpet ? state.carpetValetDeliveryFee as double : state.carValetDeliveryFee as double;
    final homeFee = isCarpet ? state.carpetHomeDeliveryFee as double : state.carHomeDeliveryFee as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCarpet ? state.tr('carpetDeliveryFeesTitle') : state.tr('carWashDeliveryFeesTitle'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.tr('oncePerOrderTag'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildMatrixRow(
            context,
            state,
            imageUrl: isCarpet ? AutoCareAssets.carpetValetPickupUrl : AutoCareAssets.valetDriverUrl,
            title: isCarpet ? state.tr('carpetValetTitle') : state.tr('serviceValetPickUp'),
            subtitle: '+ ${state.tr("oncePerOrderTag")}',
            price: valetFee,
            onEdit: () => _editDeliveryAddonDialog(
              context,
              state,
              isCarpet: isCarpet,
              mode: ServiceType.valetPickUp,
              label: isCarpet ? state.tr('carpetValetTitle') : state.tr('serviceValetPickUp'),
            ),
          ),
          const Divider(height: 14),
          _buildMatrixRow(
            context,
            state,
            imageUrl: isCarpet ? AutoCareAssets.carpetHomeWashUrl : AutoCareAssets.mobileVanUrl,
            title: isCarpet ? state.tr('carpetHomeTitle') : state.tr('atHomeMobile'),
            subtitle: '+ ${state.tr("oncePerOrderTag")}',
            price: homeFee,
            onEdit: () => _editDeliveryAddonDialog(
              context,
              state,
              isCarpet: isCarpet,
              mode: ServiceType.atHomeMobile,
              label: isCarpet ? state.tr('carpetHomeTitle') : state.tr('atHomeMobile'),
            ),
          ),
        ],
      ),
    );
  }

  void _editDeliveryAddonDialog(
    BuildContext context,
    dynamic state, {
    required bool isCarpet,
    required ServiceType mode,
    required String label,
  }) {
    final currentFee = state.getDeliveryAddonFee(mode, isCarpet: isCarpet) as double;
    final controller = TextEditingController(text: currentFee.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("editPrice")}: $label'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '${state.tr("priceInEtb")} (${state.tr("oncePerOrderTag")})',
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
              final newFee = double.tryParse(controller.text.trim());
              if (newFee != null && newFee >= 0) {
                Navigator.pop(dialogCtx);
                AppStateProvider.read(context).updateDeliveryAddonFee(
                  isCarpet: isCarpet,
                  mode: mode,
                  fee: newFee,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated $label add-on fee to $newFee ETB'),
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

  Widget _buildPackageCard(BuildContext context, dynamic state, WashPackage pkg, List<WashPackage> packages) {
    final activeId = _selectedPackageId ?? packages.first.id;
    final isSelected = pkg.id == activeId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () => setState(() => _selectedPackageId = pkg.id),
            leading: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.getPackageImage(pkg),
              width: 40,
              height: 40,
              borderRadius: 8,
            ),
            title: Text(pkg.localizedName(state.currentLang), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: Text('${pkg.durationMinutes} mins • ${pkg.features.length} features included', style: const TextStyle(fontSize: 11)),
            trailing: Icon(isSelected ? Icons.expand_less : Icons.expand_more),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pkg.localizedDescription(state.currentLang), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: CarType.values.map((type) {
                      final price = pkg.getPriceFor(type);
                      return Expanded(
                        child: InkWell(
                          onTap: () => _editPackagePrice(context, state, pkg, type, price),
                          child: Container(
                            margin: EdgeInsets.only(right: type != CarType.values.last ? 6 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(type.localizedName(state.currentLang).split(' ').first, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(CurrencyFormatter.format(price), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                                Text(state.tr('edit'), style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (pkg.features.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...pkg.localizedFeatures(state.currentLang).map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 12, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
      ),
    );
  }

  void _editPackagePrice(
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
            Text('${type.localizedName(state.currentLang)} Tariff', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
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
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text.trim());
              if (newPrice != null && newPrice > 0) {
                Navigator.pop(dialogCtx);
                final appState = AppStateProvider.read(context);
                await appState.updatePackagePrice(packageId: pkg.id, carType: type, newPrice: newPrice);
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }
}
