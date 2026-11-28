import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/utils/print_export_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/combined_service_header_banner.dart';
import '../../../../core/widgets/expandable_action_card.dart';
import '../../../../core/widgets/liquid_level_gauge.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/storekeeper_chemical_reconciliation_card.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/consumable_item.dart';
import '../../domain/models/fixed_asset.dart';
import '../../domain/models/retail_item.dart';
import '../../domain/models/stock_transaction.dart';
import 'package:bishe_car_wash/features/admin/presentation/widgets/bishe_ai_executive_sheet.dart';

class StorekeeperDashboardScreen extends StatefulWidget {
  const StorekeeperDashboardScreen({super.key});

  @override
  State<StorekeeperDashboardScreen> createState() => _StorekeeperDashboardScreenState();
}

class _StorekeeperDashboardScreenState extends State<StorekeeperDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Tab 1 (Rapid Refill) state
  String _selectedReceiver = 'Washer Team Leader';
  final Map<String, double> _fastItemQuantities = {};
  String _slowCategoryFilter = 'All';

  // Tab 2 (Storeroom Stock) state
  final TextEditingController _consumableSearchCtrl = TextEditingController();
  String _consumableCategoryFilter = 'All';
  String _stockLevelFilter = 'All';

  // Tab 3 (Fixed Assets) state
  final TextEditingController _assetSearchCtrl = TextEditingController();
  String _assetConditionFilter = 'All';
  bool _showRetailShopStock = false;

  // Fast-turnover item codes
  static const Set<String> _fastItemIds = {
    'CS-009',  // Car Shampoo
    'CS-004',  // Foaming Tire Cleaner
    'CS-003',  // Dashboard Protectant
    'CS-010A', // Dashboard Sprays
    'CS-006',  // Air Freshener Perfume
    'CS-013',  // Microfiber Towels
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _consumableSearchCtrl.dispose();
    _assetSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('storekeeperRole'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.liquidCyanNeon, size: 21),
            tooltip: state.tr('aiExecutiveTitle'),
            onPressed: () => BisheAiExecutiveSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          CombinedServiceHeaderBanner(
            title: state.tr('storekeeperCombinedHeader'),
            subtitle: state.tr('storekeeperCombinedSub'),
            badgeText: state.tr('unifiedDesk'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          // Sub-header 3 Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              border: Border(
                bottom: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: isMobile,
              tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              tabs: [
                Tab(
                  icon: const Icon(Icons.autorenew_rounded, size: 17),
                  text: state.tr('rapidRefillTab'),
                ),
                Tab(
                  icon: const Icon(Icons.inventory_2_rounded, size: 17),
                  text: state.tr('storeroomStockTab'),
                ),
                Tab(
                  icon: const Icon(Icons.build_circle_rounded, size: 17),
                  text: state.tr('fixedAssetsTab'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRapidRefillTab(context, state, isMobile),
                _buildStoreroomStockTab(context, state, isMobile),
                _buildFixedAssetsTab(context, state, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: 🔄 RAPID REFILL DESK (ዕቃ በዕቃ መመዝገቢያ)
  // ==========================================

  Widget _buildRapidRefillTab(BuildContext context, dynamic state, bool isMobile) {
    final transactions = state.stockTransactions as List<StockTransaction>;
    final today = DateTime.now();
    final todayExchanges = transactions.where((t) {
      final isExchange = t.type == 'emptyExchangeConsumption' || t.type == 'initialFloatIssue';
      final isSameDay = t.date.year == today.year && t.date.month == today.month && t.date.day == today.day;
      return isExchange && isSameDay;
    }).toList();

    final allConsumables = (state.consumables as List<ConsumableItem>).where((c) => !c.isDecommissioned).toList();
    final fastItems = allConsumables.where((c) => _fastItemIds.contains(c.id)).toList();
    final slowItems = allConsumables.where((c) => !_fastItemIds.contains(c.id)).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Action & Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: Color(0xFF14B8A6), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${todayExchanges.length} Exchanges Today',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            state.tr('fastRefillSubtitle'),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.playlist_add_rounded, size: 15, color: Color(0xFF38BDF8)),
                      label: Text(state.tr('issueInitialFloat'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showInitialFloatDialog(context, state, allConsumables),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                      label: Text(state.tr('printReport'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: AppColors.primary, width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _printExchangeReport(todayExchanges),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Receiver (Head Washer) Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_pin_rounded, color: Color(0xFF14B8A6), size: 18),
                const SizedBox(width: 6),
                Flexible(
                  flex: 2,
                  child: Text(
                    '${state.tr('receiverLabel')}:',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => _showReceiverSelectionDialog(context, state),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedReceiver,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Fast-Turnover Cards Grid (⚡ CS-009, CS-004, CS-003, CS-010A, CS-006, CS-013)
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.tr('fastTurnoverItems'),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1000 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 172,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: fastItems.length,
                itemBuilder: (context, idx) {
                  final item = fastItems[idx];
                  return _buildFastExchangeCard(context, state, item);
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // 4. Slow-Moving / Detailing Items
          ExpandableActionCard(
            icon: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.assetTowelsUrl,
              width: 40,
              height: 40,
              borderRadius: 8,
              fallbackIcon: Icons.access_time_rounded,
              fallbackColor: Colors.deepPurpleAccent,
            ),
            iconPadding: EdgeInsets.zero,
            iconBackgroundColor: Colors.transparent,
            borderColor: Colors.deepPurpleAccent.shade200,
            title: state.tr('slowTurnoverItems'),
            subtitle: 'Abro Polish, Grinder Pads, Water Spot Remover, Headlight, Degreasers',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: Text('${slowItems.length} Items', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.deepPurpleAccent)),
            ),
            initiallyExpanded: false,
            child: _buildSlowItemsSection(context, state, slowItems),
          ),
          const SizedBox(height: 14),

          // 5. Chemical Reconciliation Audit (Live cars washed vs chemicals consumed)
          ExpandableActionCard(
            icon: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.assetShampooUrl,
              width: 40,
              height: 40,
              borderRadius: 8,
              fallbackIcon: Icons.compare_arrows_rounded,
              fallbackColor: Colors.amber,
            ),
            iconPadding: EdgeInsets.zero,
            iconBackgroundColor: Colors.transparent,
            borderColor: Colors.amber,
            title: state.tr('reconciliationTitle'),
            subtitle: state.tr('reconciliationSub'),
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: const Text('Live Audit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.amber)),
            ),
            initiallyExpanded: false,
            child: StorekeeperChemicalReconciliationCard(
              state: state,
              isMobile: isMobile,
              carsWashedCount: (state.bookings as List).where((b) => b.payment.isPaid && !b.isCarpet).length,
              carpetsWashedCount: (state.bookings as List).where((b) => b.payment.isPaid && b.isCarpet).length,
              rangeDays: 1,
              rangeStart: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              rangeEnd: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59),
            ),
          ),
          const SizedBox(height: 14),

          // 6. Today's Returned Empties & Exchanges Audit Timeline
          Row(
            children: [
              const Icon(Icons.history_rounded, color: Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.tr('todayExchangesTitle'),
                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${todayExchanges.length} Recorded',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          todayExchanges.isEmpty
              ? _buildEmptyState('No container refill exchanges logged yet today.', Icons.autorenew_rounded)
              : Column(
                  children: todayExchanges.map((ex) => _buildTodayExchangeTile(context, state, ex)).toList(),
                ),
        ],
      ),
    );
  }

  // --- Fast Item Card (1-Tap Empty-for-Full Exchange) ---
  Widget _buildFastExchangeCard(BuildContext context, dynamic state, ConsumableItem item) {
    final qty = _fastItemQuantities[item.id] ?? 1.0;
    final isOutOfStock = item.currentStock <= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.withValues(alpha: 0.5)
              : const Color(0xFF0D9488).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row 1: Image + Name + Stock badge
          Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: AutoCareAssets.getConsumableImage(item.name, id: item.id),
                width: 36,
                height: 36,
                borderRadius: 8,
                fallbackIcon: AutoCareAssets.getInventoryFallbackIcon(item.name, id: item.id),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.nameAmharic.isNotEmpty)
                      Text(
                        item.nameAmharic,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? Colors.red.withValues(alpha: 0.15)
                      : (item.isLowStock
                          ? Colors.amber.withValues(alpha: 0.15)
                          : const Color(0xFF0D9488).withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOutOfStock
                      ? state.tr('outOfStock')
                      : '${item.currentStock.toStringAsFixed(0)} ${item.unit}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isOutOfStock
                        ? Colors.redAccent
                        : (item.isLowStock ? Colors.amber : const Color(0xFF14B8A6)),
                  ),
                ),
              ),
            ],
          ),

          // Row 2: Quantity Stepper
          Row(
            children: [
              Text(
                '${state.tr('quantityExchanged')}:',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (qty > 1) {
                          setState(() => _fastItemQuantities[item.id] = qty - 1);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        child: Icon(Icons.remove, size: 13, color: Colors.white70),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${qty.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => _fastItemQuantities[item.id] = qty + 1);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        child: Icon(Icons.add, size: 13, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item.unit,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Row 3: 1-Tap Big Green Exchange Confirmation Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: isOutOfStock
                  ? null
                  : () => _executeFastExchange(context, state, item, qty),
              icon: const Icon(Icons.autorenew_rounded, size: 16),
              label: Text(
                state.tr('confirmExchangeBtn'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade800,
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeFastExchange(
    BuildContext context,
    dynamic state,
    ConsumableItem item,
    double qty,
  ) async {
    await state.exchangeConsumableEmptyForNew(
      itemId: item.id,
      quantity: qty,
      washerTeamLeaderName: _selectedReceiver,
      notes: 'Fast 1-tap empty-for-full swap with $_selectedReceiver',
    );

    // Reset stepper to 1
    setState(() => _fastItemQuantities[item.id] = 1.0);

    if (context.mounted) {
      final transactions = state.stockTransactions as List<StockTransaction>;
      final latestTx = transactions.isNotEmpty ? transactions.first : null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${state.tr('exchangeSuccessMsg')} ($qty ${item.unit} ${item.name})'),
          backgroundColor: const Color(0xFF0D9488),
          duration: const Duration(seconds: 6),
          action: latestTx != null
              ? SnackBarAction(
                  label: state.tr('undoExchange'),
                  textColor: Colors.amberAccent,
                  onPressed: () async {
                    await state.undoExchangeConsumable(latestTx.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.tr('undoSuccessMsg')), backgroundColor: Colors.blueGrey),
                      );
                    }
                  },
                )
              : null,
        ),
      );
    }
  }

  // --- Slow-Moving Items Section ---
  Widget _buildSlowItemsSection(BuildContext context, dynamic state, List<ConsumableItem> slowItems) {
    final categories = ['All', 'Detailing Compound', 'Interior Care', 'Engine & Bay Care', 'Workshop Supplies', 'Hardware Fasteners'];
    final filtered = _slowCategoryFilter == 'All'
        ? slowItems
        : slowItems.where((c) => c.category.toLowerCase().contains(_slowCategoryFilter.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSel = _slowCategoryFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 8),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? Colors.white : AppColors.textSecondary)),
                  selected: isSel,
                  onSelected: (_) => setState(() => _slowCategoryFilter = cat),
                  selectedColor: const Color(0xFF0D9488),
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  checkmarkColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        ...filtered.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: AutoCareAssets.getConsumableImage(item.name, id: item.id),
                width: 32,
                height: 32,
                borderRadius: 6,
                fallbackIcon: AutoCareAssets.getInventoryFallbackIcon(item.name, id: item.id),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(
                      '${item.currentStock.toStringAsFixed(1)} ${item.unit} in store • ${item.category}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: item.currentStock <= 0
                    ? null
                    : () => _showSlowItemExchangeDialog(context, state, item),
                icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                label: const Text('Exchange', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // --- Today's Exchange Tile with Undo Action ---
  Widget _buildTodayExchangeTile(BuildContext context, dynamic state, StockTransaction ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: AutoCareAssets.buildPhotoThumbnail(
          imageUrl: AutoCareAssets.getInventoryImage(ex.itemName),
          width: 38,
          height: 38,
          borderRadius: 8,
          fallbackIcon: Icons.autorenew_rounded,
          fallbackColor: const Color(0xFF14B8A6),
        ),
        title: Text(
          ex.itemName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
        ),
        subtitle: Text(
          '${ex.quantity} ${ex.unit} • ${ex.supplier} • ${_formatTime(ex.date)}\n${ex.notes ?? ""}',
          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
        ),
        trailing: OutlinedButton.icon(
          icon: const Icon(Icons.undo_rounded, size: 13, color: Colors.amberAccent),
          label: Text(state.tr('undoExchange'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.amberAccent)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            side: const BorderSide(color: Colors.amberAccent, width: 1.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          onPressed: () => _confirmUndoExchange(context, state, ex),
        ),
      ),
    );
  }

  void _confirmUndoExchange(BuildContext context, dynamic state, StockTransaction ex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 8),
            Text(state.tr('undoExchange'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          '${state.tr('undoExchangeConfirm')}\n\nItem: ${ex.itemName}\nQty: ${ex.quantity} ${ex.unit}\nReceiver: ${ex.supplier}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              await state.undoExchangeConsumable(ex.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.tr('undoSuccessMsg')), backgroundColor: Colors.blueGrey),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
            child: Text(state.tr('undoExchange'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: 📦 STOREROOM STOCK (አጠቃላይ ክምችት)
  // ==========================================

  Widget _buildStoreroomStockTab(BuildContext context, dynamic state, bool isMobile) {
    final consumables = (state.consumables as List<ConsumableItem>).where((c) => !c.isDecommissioned).toList();
    final searchQuery = _consumableSearchCtrl.text.trim().toLowerCase();

    final filtered = consumables.where((c) {
      final matchesSearch = searchQuery.isEmpty ||
          c.name.toLowerCase().contains(searchQuery) ||
          c.nameAmharic.toLowerCase().contains(searchQuery) ||
          c.id.toLowerCase().contains(searchQuery) ||
          c.category.toLowerCase().contains(searchQuery);

      final matchesCategory = _consumableCategoryFilter == 'All' ||
          c.category.toLowerCase().contains(_consumableCategoryFilter.toLowerCase());

      final matchesStock = _stockLevelFilter == 'All' ||
          (_stockLevelFilter == 'Low Stock' && c.isLowStock) ||
          (_stockLevelFilter == 'Healthy' && !c.isLowStock);

      return matchesSearch && matchesCategory && matchesStock;
    }).toList();

    final lowStockCount = consumables.where((c) => c.isLowStock).length;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Top Action Bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            border: Border(bottom: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1.2)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${consumables.length} ${state.tr('storeroomStockTab')}',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  if (lowStockCount > 0)
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 13, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          '$lowStockCount item(s) below reorder threshold',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.redAccent),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 13, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(state.tr('healthyStock'), style: const TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showReceiveDeliveryForAnyItemDialog(context, state, consumables),
                    icon: const Icon(Icons.add_business_rounded, size: 15),
                    label: Text(state.tr('receiveDeliveryBtn'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                    label: Text(state.tr('print'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      side: const BorderSide(color: AppColors.primary, width: 1.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _printConsumablesReport(consumables),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddConsumableDialog(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text('Add Item', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search Bar & Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: TextField(
            controller: _consumableSearchCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: InputDecoration(
              hintText: state.tr('searchInventoryHint'),
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
              suffixIcon: _consumableSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 16),
                      onPressed: () => setState(() => _consumableSearchCtrl.clear()),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Low Stock', 'Healthy'].map((flt) {
                final isSel = _stockLevelFilter == flt;
                Color chipColor = const Color(0xFF0D9488);
                if (flt == 'Low Stock') chipColor = Colors.redAccent;
                if (flt == 'Healthy') chipColor = Colors.green;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(flt, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? Colors.white : AppColors.textSecondary)),
                    selected: isSel,
                    onSelected: (_) => setState(() => _stockLevelFilter = flt),
                    selectedColor: chipColor,
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // 3D Animated Chemical Tank Gauges (top 6 items)
        if (consumables.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.6))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: consumables.take(6).map((c) {
                  final ratio = c.minThreshold > 0
                      ? (c.currentStock / (c.minThreshold * 2.5)).clamp(0.0, 1.0)
                      : (c.currentStock > 0 ? 0.75 : 0.0);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: LiquidLevelGauge(
                      title: c.name,
                      currentLevel: ratio,
                      currentAmountStr: '${c.currentStock.toStringAsFixed(0)} ${c.unit}',
                      maxAmountStr: '${(c.minThreshold * 2.5).toStringAsFixed(0)} ${c.unit}',
                      height: 90,
                      width: 54,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Retail Shop Inventory (Station Merchandise for Customer Sale)
        _buildRetailStockSection(context, state, isMobile),

        // Consumables List
        Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: filtered.isEmpty
              ? _buildEmptyState('No inventory items match your search filter.', Icons.inventory_2_outlined)
              : Column(
                  children: filtered.map((item) => _buildConsumableItemTile(context, state, item, isMobile)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildConsumableItemTile(BuildContext context, dynamic state, ConsumableItem item, bool isMobile) {
    final isLow = item.isLowStock;
    final isOutOfStock = item.currentStock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.withValues(alpha: 0.6)
              : (isLow ? Colors.amber.withValues(alpha: 0.6) : AppColors.cardBorder.withValues(alpha: 0.7)),
          width: isLow ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: AutoCareAssets.getConsumableImage(item.name, id: item.id),
                width: 42,
                height: 42,
                borderRadius: 9,
                fallbackIcon: AutoCareAssets.getInventoryFallbackIcon(item.name, id: item.id),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                    if (item.nameAmharic.isNotEmpty)
                      Text(item.nameAmharic, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? Colors.red.withValues(alpha: 0.2)
                      : (isLow ? Colors.amber.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOutOfStock
                        ? Colors.redAccent
                        : (isLow ? Colors.amber : Colors.green),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isOutOfStock
                      ? 'EMPTY (0)'
                      : (isLow ? 'REORDER ALERT' : 'HEALTHY'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isOutOfStock
                        ? Colors.redAccent
                        : (isLow ? Colors.amber : Colors.greenAccent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                child: Text(item.category, style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600)),
              ),
              Text(
                'Stock: ${item.currentStock.toStringAsFixed(1)} ${item.unit}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isLow ? Colors.redAccent : Colors.white,
                ),
              ),
              Text('(Min: ${item.minThreshold.toStringAsFixed(0)} ${item.unit})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
              Text('ETB ${item.unitCostEtb.toStringAsFixed(0)} / ${item.unit}', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showReceiveStockDialog(context, state, item),
                icon: const Icon(Icons.add_shopping_cart, size: 14),
                label: Text(state.tr('receiveDeliveryBtn'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.greenAccent,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showDecommissionConsumableDialog(context, state, item),
                icon: const Icon(Icons.archive_outlined, size: 14),
                label: const Text('Decommission', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: Colors.orange.shade400),
              ),
              if (state.isSuperAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 17, color: Colors.redAccent),
                  tooltip: 'Super Admin Permanent Delete',
                  onPressed: () => _showDeleteConsumableDialog(context, state, item),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: 🛠️ FIXED ASSETS (የመሳሪያዎች ሁኔታ)
  // ==========================================

  Widget _buildFixedAssetsTab(BuildContext context, dynamic state, bool isMobile) {
    final assets = state.fixedAssets as List<FixedAsset>;
    final searchQuery = _assetSearchCtrl.text.trim().toLowerCase();

    final filtered = assets.where((a) {
      final matchesSearch = searchQuery.isEmpty ||
          a.name.toLowerCase().contains(searchQuery) ||
          a.nameAmharic.toLowerCase().contains(searchQuery) ||
          a.id.toLowerCase().contains(searchQuery) ||
          a.serialNumber.toLowerCase().contains(searchQuery) ||
          a.assignedLocation.toLowerCase().contains(searchQuery);

      final matchesCondition = _assetConditionFilter == 'All' ||
          a.condition.name.toLowerCase() == _assetConditionFilter.toLowerCase();

      return matchesSearch && matchesCondition;
    }).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Top Action Bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            border: Border(bottom: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1.2)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${assets.length} ${state.tr('allFixedAssetsCount')}',
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                    label: Text(state.tr('print'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      side: const BorderSide(color: AppColors.primary, width: 1.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _printFixedAssetsReport(filtered),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFixedAssetDialog(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text('Add Asset', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search Bar & Condition Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: TextField(
            controller: _assetSearchCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Search machinery by name, ID, or bay...',
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
              suffixIcon: _assetSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 16),
                      onPressed: () => setState(() => _assetSearchCtrl.clear()),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'operational', 'needsService', 'decommissioned'].map((cond) {
                final isSel = _assetConditionFilter == cond;
                String label = cond;
                if (cond == 'operational') label = state.tr('itemOperational');
                if (cond == 'needsService') label = state.tr('itemNeedsRepair');
                if (cond == 'decommissioned') label = 'Decommissioned';

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? Colors.white : AppColors.textSecondary)),
                    selected: isSel,
                    onSelected: (_) => setState(() => _assetConditionFilter = cond),
                    selectedColor: cond == 'needsService' ? Colors.amber.shade800 : const Color(0xFF0D9488),
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Assets List
        Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: filtered.isEmpty
              ? _buildEmptyState('No machinery or tools match your search.', Icons.build_circle_outlined)
              : Column(
                  children: filtered.map((asset) => _buildFixedAssetCard(context, state, asset, isMobile)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildFixedAssetCard(BuildContext context, dynamic state, FixedAsset asset, bool isMobile) {
    final isOperational = asset.condition == AssetCondition.operational;
    final isNeedsRepair = asset.condition == AssetCondition.needsService || asset.condition == AssetCondition.underRepair;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOperational
              ? Colors.green.withValues(alpha: 0.4)
              : (isNeedsRepair ? Colors.amber.withValues(alpha: 0.6) : Colors.white24),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: AutoCareAssets.getFixedAssetImage(asset.name, id: asset.id),
                width: 42,
                height: 42,
                borderRadius: 9,
                fallbackIcon: AutoCareAssets.getInventoryFallbackIcon(asset.name, id: asset.id),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset.id} • ${asset.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                    if (asset.nameAmharic.isNotEmpty)
                      Text(asset.nameAmharic, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOperational
                      ? Colors.green.withValues(alpha: 0.15)
                      : (isNeedsRepair ? Colors.amber.withValues(alpha: 0.2) : Colors.white12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOperational
                        ? Colors.greenAccent
                        : (isNeedsRepair ? Colors.amber : Colors.white30),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isOperational
                      ? state.tr('itemOperational').toUpperCase()
                      : (isNeedsRepair ? state.tr('itemNeedsRepair').toUpperCase() : 'DECOMMISSIONED'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isOperational
                        ? Colors.greenAccent
                        : (isNeedsRepair ? Colors.amberAccent : Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF14B8A6)),
              const SizedBox(width: 4),
              Text(asset.assignedLocation, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Text('Qty: ${asset.quantity} • ${asset.category}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          if (asset.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(asset.notes, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
          ],
          const SizedBox(height: 10),

          // 1-Tap Toggle & Details Buttons
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1-Tap Operational / Needs Repair Toggle
              ElevatedButton.icon(
                onPressed: () async {
                  final newCond = isOperational ? AssetCondition.needsService : AssetCondition.operational;
                  await state.saveFixedAsset(asset.copyWith(condition: newCond));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          newCond == AssetCondition.operational
                              ? '${asset.name} marked operational!'
                              : '${asset.name} flagged as needing repair.',
                        ),
                        backgroundColor: newCond == AssetCondition.operational ? Colors.green : Colors.amber.shade800,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isOperational ? Icons.build_rounded : Icons.check_circle_rounded,
                  size: 14,
                ),
                label: Text(
                  isOperational ? state.tr('markNeedsRepair') : state.tr('markOperational'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOperational ? Colors.amber.shade800 : Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showUpdateAssetConditionDialog(context, state, asset),
                icon: const Icon(Icons.tune, size: 14),
                label: Text(state.tr('editAssetDetails'), style: const TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.cardBorder),
                  foregroundColor: Colors.white70,
                ),
              ),
              if (state.isSuperAdmin) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 17, color: Colors.redAccent),
                  tooltip: 'Super Admin Permanent Delete',
                  onPressed: () => _showDeleteAssetDialog(context, state, asset),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DIALOGS & ACTION HANDLERS
  // ==========================================

  void _showReceiverSelectionDialog(BuildContext context, dynamic state) {
    final staff = state.staff as List;
    final washerStaff = staff.where((s) {
      final role = s.role.name.toLowerCase();
      return role.contains('washer') || role.contains('head') || role.contains('lead');
    }).toList();

    final customCtrl = TextEditingController(text: _selectedReceiver);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.person_pin_rounded, color: Color(0xFF14B8A6), size: 20),
            const SizedBox(width: 8),
            Text(state.tr('receiverLabel'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Washer Leader or type name:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  'Washer Team Leader',
                  ...washerStaff.map((s) => s.name.toString()),
                ].map((name) {
                  final isSel = _selectedReceiver == name;
                  return ActionChip(
                    label: Text(name, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600)),
                    backgroundColor: isSel ? const Color(0xFF0D9488) : const Color(0xFF0F172A),
                    onPressed: () {
                      setState(() => _selectedReceiver = name);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                decoration: InputDecoration(
                  labelText: 'Custom Receiver Name',
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              if (customCtrl.text.trim().isNotEmpty) {
                setState(() => _selectedReceiver = customCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
            child: const Text('Set Receiver'),
          ),
        ],
      ),
    );
  }

  void _showSlowItemExchangeDialog(BuildContext context, dynamic state, ConsumableItem item) {
    final qtyCtrl = TextEditingController(text: '1.0');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFF14B8A6), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Exchange: ${item.name}',
                style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Stock: ${item.currentStock.toStringAsFixed(1)} ${item.unit} • Receiver: $_selectedReceiver',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Quantity Exchanged (${item.unit})',
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
              if (qty <= 0) return;
              await state.exchangeConsumableEmptyForNew(
                itemId: item.id,
                quantity: qty,
                washerTeamLeaderName: _selectedReceiver,
                notes: notesCtrl.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.tr('exchangeSuccessMsg')), backgroundColor: const Color(0xFF0D9488)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
            child: Text(state.tr('confirmExchangeBtn'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showInitialFloatDialog(BuildContext context, dynamic state, List<ConsumableItem> items) {
    if (items.isEmpty) return;
    String selectedItemId = items.first.id;
    final qtyCtrl = TextEditingController(text: '1.0');
    final receiverCtrl = TextEditingController(text: _selectedReceiver);
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final selItem = items.firstWhere((c) => c.id == selectedItemId, orElse: () => items.first);
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                const Icon(Icons.playlist_add_rounded, color: Color(0xFF38BDF8), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(state.tr('issueInitialFloat'), style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Item to Issue:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedItemId,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: items.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.currentStock.toStringAsFixed(1)} ${c.unit})'))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedItemId = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Quantity to Issue (${selItem.unit})',
                      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: receiverCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Receiver Name',
                      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Notes (e.g. New washer assigned, monthly float)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                  if (qty <= 0) return;
                  await state.issueInitialFloat(
                    itemId: selectedItemId,
                    quantity: qty,
                    receiverName: receiverCtrl.text.trim().isNotEmpty ? receiverCtrl.text.trim() : 'Washer Team Leader',
                    notes: notesCtrl.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Issued $qty ${selItem.unit} of ${selItem.name} successfully!'), backgroundColor: const Color(0xFF0D9488)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
                child: const Text('Confirm Issue', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReceiveDeliveryForAnyItemDialog(BuildContext context, dynamic state, List<ConsumableItem> items) {
    if (items.isEmpty) return;
    String selectedItemId = items.first.id;
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final supplierCtrl = TextEditingController(text: 'Local Bishoftu Supplier');
    String? invoiceName;
    String? invoiceBase64;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final selItem = items.firstWhere((c) => c.id == selectedItemId, orElse: () => items.first);
          final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
          final unitCost = double.tryParse(costCtrl.text.trim()) ?? selItem.unitCostEtb;
          final totalCost = qty * unitCost;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                const Icon(Icons.add_business_rounded, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Text(state.tr('receiveDeliveryBtn'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Item Received:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedItemId,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: items.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.unit})'))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedItemId = val;
                            costCtrl.text = items.firstWhere((c) => c.id == val, orElse: () => items.first).unitCostEtb.toStringAsFixed(0);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setDialogState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Quantity to Add (${selItem.unit}) *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setDialogState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Unit Cost (ETB) *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Calculated Cost:', style: TextStyle(color: Colors.greenAccent, fontSize: 11.5, fontWeight: FontWeight.w700)),
                          Text(CurrencyFormatter.format(totalCost), style: const TextStyle(color: Colors.greenAccent, fontSize: 13.5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: supplierCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Supplier / Vendor',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        ImagePickerHelper.pickImage(onPicked: (img) {
                          setDialogState(() {
                            invoiceName = img.name;
                            invoiceBase64 = img.base64Data;
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: invoiceName != null ? Colors.green.withValues(alpha: 0.15) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: invoiceName != null ? Colors.green : AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(invoiceName != null ? Icons.check_circle : Icons.camera_alt_outlined, size: 16, color: invoiceName != null ? Colors.greenAccent : AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                invoiceName ?? 'Attach Delivery Note / Slip Photo',
                                style: TextStyle(color: invoiceName != null ? Colors.greenAccent : AppColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final validQty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                  final validCost = double.tryParse(costCtrl.text.trim()) ?? selItem.unitCostEtb;
                  if (validQty <= 0) return;
                  await state.receiveStock(
                    itemId: selectedItemId,
                    quantity: validQty,
                    unitCostEtb: validCost,
                    supplier: supplierCtrl.text.trim().isNotEmpty ? supplierCtrl.text.trim() : 'Local Supplier',
                    unit: selItem.unit,
                    invoiceScreenshot: invoiceBase64,
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Received $validQty ${selItem.unit} of ${selItem.name} successfully!'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                child: const Text('Confirm Receive', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReceiveStockDialog(BuildContext context, dynamic state, ConsumableItem item) {
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: item.unitCostEtb > 0 ? item.unitCostEtb.toStringAsFixed(0) : '');
    final supplierCtrl = TextEditingController();
    String? invoiceName;
    String? invoiceBase64;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
          final unitCost = double.tryParse(costCtrl.text.trim()) ?? item.unitCostEtb;
          final totalCost = qty * unitCost;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text('Receive: ${item.name}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setDialogState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Quantity to Add (${item.unit}) *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setDialogState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Unit Cost (ETB) *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Cost:', style: TextStyle(color: Colors.greenAccent, fontSize: 11.5, fontWeight: FontWeight.w700)),
                          Text(CurrencyFormatter.format(totalCost), style: const TextStyle(color: Colors.greenAccent, fontSize: 13.5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: supplierCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Supplier Name',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        ImagePickerHelper.pickImage(onPicked: (img) {
                          setDialogState(() {
                            invoiceName = img.name;
                            invoiceBase64 = img.base64Data;
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: invoiceName != null ? Colors.green.withValues(alpha: 0.15) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: invoiceName != null ? Colors.green : AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(invoiceName != null ? Icons.check_circle : Icons.camera_alt_outlined, size: 16, color: invoiceName != null ? Colors.greenAccent : AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                invoiceName ?? 'Attach Delivery Note Photo',
                                style: TextStyle(color: invoiceName != null ? Colors.greenAccent : AppColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final validQty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                  final validCost = double.tryParse(costCtrl.text.trim()) ?? item.unitCostEtb;
                  if (validQty <= 0) return;
                  await state.receiveStock(
                    itemId: item.id,
                    quantity: validQty,
                    unitCostEtb: validCost,
                    supplier: supplierCtrl.text.trim().isNotEmpty ? supplierCtrl.text.trim() : 'Local Supplier',
                    unit: item.unit,
                    invoiceScreenshot: invoiceBase64,
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Received $validQty ${item.unit} successfully!'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                child: const Text('Confirm Receive', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddConsumableDialog(BuildContext context, dynamic state) {
    final nameCtrl = TextEditingController();
    final amharicCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Wash Station Core');
    final unitCtrl = TextEditingController(text: 'Liters');
    final stockCtrl = TextEditingController(text: '10');
    final minCtrl = TextEditingController(text: '5');
    final costCtrl = TextEditingController(text: '250');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add Consumable Item', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Item Name (English)', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: amharicCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Item Name (Amharic)', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: categoryCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: unitCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Unit (e.g. Liters, Pieces, Cans)', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Initial Stock', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: minCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Min Reorder Threshold', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: costCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Unit Cost (ETB)', labelStyle: TextStyle(color: AppColors.textSecondary))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final newItem = ConsumableItem(
                  id: 'CS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  name: nameCtrl.text.trim(),
                  nameAmharic: amharicCtrl.text.trim(),
                  category: categoryCtrl.text.trim(),
                  unit: unitCtrl.text.trim(),
                  currentStock: double.tryParse(stockCtrl.text.trim()) ?? 0.0,
                  minThreshold: double.tryParse(minCtrl.text.trim()) ?? 5.0,
                  unitCostEtb: double.tryParse(costCtrl.text.trim()) ?? 0.0,
                );
                await state.saveConsumable(newItem);
              }
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
            child: const Text('Save Item', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showDecommissionConsumableDialog(BuildContext context, dynamic state, ConsumableItem item) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Decommission ${item.name}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mark item as retired from daily use while preserving historical audit logs.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Reason for Decommissioning',
                labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isNotEmpty) {
                await state.decommissionConsumable(item.id, reasonCtrl.text.trim());
              }
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
            child: const Text('Decommission'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConsumableDialog(BuildContext context, dynamic state, ConsumableItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Super Admin: Delete Consumable', style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to permanently delete "${item.name}" from the database?', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () async {
              await state.deleteConsumable(item.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showAddFixedAssetDialog(BuildContext context, dynamic state) {
    final nameCtrl = TextEditingController();
    final amharicCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Wash Machinery');
    final snCtrl = TextEditingController(text: 'SN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final locCtrl = TextEditingController(text: 'Bay 1');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add Fixed Asset', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Asset Name (English)', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: amharicCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Asset Name (Amharic)', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: snCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Serial Number / Asset Tag', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: locCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Assigned Location', labelStyle: TextStyle(color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(labelText: 'Notes / Specifications', labelStyle: TextStyle(color: AppColors.textSecondary))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final newAsset = FixedAsset(
                  id: 'FA-${(state.fixedAssets.length + 1).toString().padLeft(3, '0')}',
                  name: nameCtrl.text.trim(),
                  nameAmharic: amharicCtrl.text.trim(),
                  category: catCtrl.text.trim(),
                  serialNumber: snCtrl.text.trim(),
                  assignedLocation: locCtrl.text.trim(),
                  condition: AssetCondition.operational,
                  notes: notesCtrl.text.trim(),
                );
                await state.saveFixedAsset(newAsset);
              }
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
            child: const Text('Save Asset', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showUpdateAssetConditionDialog(BuildContext context, dynamic state, FixedAsset asset) {
    AssetCondition selectedCondition = asset.condition;
    final locCtrl = TextEditingController(text: asset.assignedLocation);
    final notesCtrl = TextEditingController(text: asset.notes);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Edit ${asset.name}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AssetCondition>(
                value: selectedCondition,
                dropdownColor: const Color(0xFF0F172A),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Working Condition',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: AssetCondition.values.map((cond) {
                  return DropdownMenuItem(value: cond, child: Text(cond.displayName));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCondition = val);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Assigned Location',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Maintenance Notes',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60))),
            ElevatedButton(
              onPressed: () async {
                final updated = asset.copyWith(
                  condition: selectedCondition,
                  assignedLocation: locCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );
                await state.saveFixedAsset(updated);
                if (context.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAssetDialog(BuildContext context, dynamic state, FixedAsset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Super Admin: Delete Asset', style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to permanently delete "${asset.name}" (${asset.id})?', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'), style: const TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () async {
              await state.deleteFixedAsset(asset.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _printExchangeReport(List<StockTransaction> exchanges) {
    PrintExportHelper.printTableReport(
      title: 'Rapid Refill (ዕቃ በዕቃ) Ledger',
      subtitle: 'BISHE Auto Care Storekeeper • Bishoftu',
      headers: ['Date', 'Item', 'Quantity', 'Unit', 'Receiver', 'Total Cost (ETB)', 'Notes'],
      rows: exchanges.map((ex) => [
        DateFormatter.formatDate(ex.date),
        ex.itemName,
        ex.quantity,
        ex.unit,
        ex.supplier,
        CurrencyFormatter.format(ex.totalCostEtb),
        ex.notes ?? '-',
      ]).toList(),
    );
  }

  void _printConsumablesReport(List<ConsumableItem> consumables) {
    PrintExportHelper.printTableReport(
      title: 'Consumables Stockroom Inventory (አላቂ እቃዎች)',
      subtitle: 'BISHE Auto Care Storekeeper • Bishoftu',
      headers: ['Item Name', 'Category', 'Current Stock', 'Unit', 'Min Threshold', 'Unit Cost (ETB)', 'Status'],
      rows: consumables.map((c) => [
        c.name,
        c.category,
        c.currentStock.toStringAsFixed(1),
        c.unit,
        c.minThreshold.toStringAsFixed(1),
        CurrencyFormatter.format(c.unitCostEtb),
        c.isLowStock ? 'LOW STOCK' : 'Healthy',
      ]).toList(),
    );
  }

  void _printFixedAssetsReport(List<FixedAsset> assets) {
    PrintExportHelper.printTableReport(
      title: 'Fixed Assets & Machinery Register (ቋሚ እቃዎች)',
      subtitle: 'BISHE Auto Care Storekeeper • Bishoftu',
      headers: ['Asset ID', 'Name', 'Category', 'Location', 'Condition', 'Notes'],
      rows: assets.map((a) => [
        a.id,
        a.name,
        a.category,
        a.assignedLocation,
        a.condition.displayName,
        a.notes,
      ]).toList(),
    );
  }

  Widget _buildRetailStockSection(BuildContext context, dynamic state, bool isMobile) {
    final retailItems = state.allRetailItems as List<RetailItem>;
    if (retailItems.isEmpty) return const SizedBox.shrink();
    final lowRetailCount = retailItems.where((r) => r.isLowStock).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 12 : 16, 10, isMobile ? 12 : 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _showRetailShopStock ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : AppColors.cardBorder,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => setState(() => _showRetailShopStock = !_showRetailShopStock),
                leading: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFF59E0B)),
                title: Text(
                  '${state.tr("retailStockSection")} (${retailItems.length})',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                subtitle: Text(
                  lowRetailCount > 0 ? '$lowRetailCount low stock' : state.tr('healthyStock'),
                  style: TextStyle(fontSize: 11, color: lowRetailCount > 0 ? Colors.orange : Colors.green),
                ),
                trailing: Icon(
                  _showRetailShopStock ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (_showRetailShopStock) ...[
              const Divider(height: 1, color: AppColors.cardBorder),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: retailItems.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item.isLowStock ? Colors.orange.withValues(alpha: 0.5) : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.localizedName(state.currentLang),
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                Text(
                                  '${CurrencyFormatter.format(item.sellingPriceEtb)} • ${state.tr("inStockLabel")}: ${item.currentStock}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: item.isLowStock ? Colors.orangeAccent : AppColors.cashGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _showRestockRetailItemDialog(context, state, item),
                            icon: const Icon(Icons.add_box_rounded, size: 14, color: Color(0xFFF59E0B)),
                            label: Text(
                              state.tr('restockRetailItem'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRestockRetailItemDialog(BuildContext context, dynamic state, RetailItem item) {
    final qtyCtrl = TextEditingController(text: '10');
    final costCtrl = TextEditingController(text: item.unitCostEtb > 0 ? item.unitCostEtb.toStringAsFixed(0) : '');
    final supplierCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("restockRetailItem")}: ${item.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${state.tr("qtyLabel")} (+)',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Unit Cost (ETB, optional)',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierCtrl,
              decoration: InputDecoration(
                labelText: 'Supplier (optional)',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
            onPressed: () async {
              final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
              if (qty <= 0) return;
              final unitCost = double.tryParse(costCtrl.text.trim());
              final staff = (state.activeStaffFullName != null && (state.activeStaffFullName as String).isNotEmpty)
                  ? state.activeStaffFullName as String
                  : 'Storekeeper';
              Navigator.pop(dlgCtx);
              await AppStateProvider.read(context).restockRetailItem(
                itemId: item.id,
                addedQuantity: qty,
                unitCostEtb: unitCost,
                supplier: supplierCtrl.text.trim(),
                recordedBy: staff,
              );
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }
}
