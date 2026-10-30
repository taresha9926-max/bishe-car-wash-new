import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/consumable_item.dart';
import '../../domain/models/daily_handover.dart';
import '../../domain/models/fixed_asset.dart';

class StorekeeperDashboardScreen extends StatefulWidget {
  const StorekeeperDashboardScreen({super.key});

  @override
  State<StorekeeperDashboardScreen> createState() => _StorekeeperDashboardScreenState();
}

class _StorekeeperDashboardScreenState extends State<StorekeeperDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _assetFilter = 'All';
  String _consumableFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      ),
      body: Column(
        children: [
          // Sub-header tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.sync_alt_rounded, size: 20), text: 'Daily Handover'),
                Tab(icon: Icon(Icons.inventory_2_rounded, size: 20), text: 'Consumables (አላቂ)'),
                Tab(icon: Icon(Icons.build_circle_rounded, size: 20), text: 'Fixed Assets (ቋሚ)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHandoverTab(context, state, isMobile),
                _buildConsumablesTab(context, state, isMobile),
                _buildFixedAssetsTab(context, state, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: DAILY HANDOVER DESK
  // ==========================================

  Widget _buildHandoverTab(BuildContext context, dynamic state, bool isMobile) {
    final active = state.activeHandover;
    final handovers = state.dailyHandovers as List<DailyHandover>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Handover Banner
          if (active != null)
            _buildActiveHandoverCard(context, state, active, isMobile)
          else
            _buildStartHandoverCard(context, state, isMobile),

          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              const Text(
                'Shift Handover Audit Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '${handovers.length} Total Logs',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (handovers.isEmpty)
            _buildEmptyState('No past shift handovers recorded yet.', Icons.assignment_outlined)
          else
            ...handovers.map((h) => _buildHandoverHistoryCard(context, state, h, isMobile)),
        ],
      ),
    );
  }

  Widget _buildStartHandoverCard(BuildContext context, dynamic state, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '☀️ Morning Shift Handover',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'Issue daily consumables & supplies to Washer Team Leader',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showStartHandoverDialog(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.outgoing_mail, size: 18),
            label: const Text('Start Morning Handover', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveHandoverCard(BuildContext context, dynamic state, DailyHandover active, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVE SHIFT HANDOVER',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.amber.shade900),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Checked out: ${_formatTime(active.checkedOutAt)}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Washer Team Leader: ${active.washerTeamLeaderName}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          const Text('Issued Morning Supplies:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: active.issuedQuantities.entries.map((e) {
              final item = state.consumables.firstWhere((c) => c.id == e.key, orElse: () => null);
              final name = item != null ? item.name : e.key;
              final unit = item != null ? item.unit : '';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text('$name: ${e.value} $unit', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showCompleteHandoverDialog(context, state, active),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
            label: const Text('Evening Return & Reconcile', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverHistoryCard(BuildContext context, dynamic state, DailyHandover h, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_formatDate(h.date)} • ${h.washerTeamLeaderName}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: h.status == HandoverStatus.completed ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: h.status == HandoverStatus.completed ? Colors.green.shade300 : Colors.amber.shade300),
                  ),
                  child: Text(
                    h.status.displayName,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: h.status == HandoverStatus.completed ? Colors.green.shade800 : Colors.amber.shade900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (h.carsWashedDuringShift > 0)
              Text(
                '🚗 Cars Washed During Shift: ${h.carsWashedDuringShift}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: h.consumedQuantities.entries.map((e) {
                final item = state.consumables.firstWhere((c) => c.id == e.key, orElse: () => null);
                final name = item != null ? item.name : e.key;
                final unit = item != null ? item.unit : '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(6)),
                  child: Text('Consumed: $name (${e.value} $unit)', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: CONSUMABLES STOCKROOM (አላቂ እቃዎች)
  // ==========================================

  Widget _buildConsumablesTab(BuildContext context, dynamic state, bool isMobile) {
    final consumables = state.consumables as List<ConsumableItem>;
    final lowStockCount = consumables.where((c) => c.isLowStock && !c.isDecommissioned).length;

    return Column(
      children: [
        // Top action bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${consumables.length} Registered Consumables',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  if (lowStockCount > 0)
                    Text(
                      '⚠️ $lowStockCount item(s) below reorder threshold',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.red.shade700),
                    )
                  else
                    const Text('🟢 All stock levels healthy', style: TextStyle(fontSize: 11.5, color: Colors.green)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddConsumableDialog(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Consumable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            itemCount: consumables.length,
            itemBuilder: (context, idx) {
              final item = consumables[idx];
              return _buildConsumableCard(context, state, item, isMobile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConsumableCard(BuildContext context, dynamic state, ConsumableItem item, bool isMobile) {
    final isLow = item.isLowStock && !item.isDecommissioned;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: item.isDecommissioned ? Colors.grey.shade400 : (isLow ? Colors.red.shade300 : Colors.transparent),
          width: isLow ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: item.isDecommissioned ? Colors.grey : AppColors.textPrimary,
                          decoration: item.isDecommissioned ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (item.nameAmharic.isNotEmpty)
                        Text(
                          item.nameAmharic,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                if (item.isDecommissioned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                    child: const Text('DECOMMISSIONED', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.black54)),
                  )
                else if (isLow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red.shade300)),
                    child: Text('REORDER ALERT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.red.shade800)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                  child: Text(item.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${item.currentStock} ${item.unit}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isLow ? Colors.red.shade700 : AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Text('(Min: ${item.minThreshold} ${item.unit})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const Spacer(),
                Text('ETB ${item.unitCostEtb.toStringAsFixed(0)} / ${item.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!item.isDecommissioned) ...[
                  OutlinedButton.icon(
                    onPressed: () => _showReceiveStockDialog(context, state, item),
                    icon: const Icon(Icons.add_shopping_cart, size: 14),
                    label: const Text('Receive Stock', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: Colors.green),
                      foregroundColor: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDecommissionConsumableDialog(context, state, item),
                    icon: const Icon(Icons.archive_outlined, size: 14),
                    label: const Text('Decommission', style: TextStyle(fontSize: 11.5)),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                  ),
                ],
                if (state.isSuperAdmin) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    tooltip: 'Super Admin Permanent Delete',
                    onPressed: () => _showDeleteConsumableDialog(context, state, item),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: FIXED ASSETS REGISTRY (ቋሚ እቃዎች)
  // ==========================================

  Widget _buildFixedAssetsTab(BuildContext context, dynamic state, bool isMobile) {
    final assets = state.fixedAssets as List<FixedAsset>;
    final filtered = _assetFilter == 'All'
        ? assets
        : assets.where((a) => a.condition.name.toLowerCase() == _assetFilter.toLowerCase()).toList();

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '${assets.length} Fixed Assets',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddFixedAssetDialog(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Fixed Asset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: ['All', 'operational', 'needsService', 'underRepair', 'decommissioned'].map((cond) {
              final isSel = _assetFilter == cond;
              String label = cond;
              if (cond == 'operational') label = 'Operational';
              if (cond == 'needsService') label = 'Needs Service';
              if (cond == 'underRepair') label = 'Under Repair';
              if (cond == 'decommissioned') label = 'Decommissioned';

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600)),
                  selected: isSel,
                  onSelected: (_) => setState(() => _assetFilter = cond),
                  selectedColor: AppColors.primary.withOpacity(0.18),
                  checkmarkColor: AppColors.primary,
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final asset = filtered[idx];
              return _buildFixedAssetCard(context, state, asset, isMobile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFixedAssetCard(BuildContext context, dynamic state, FixedAsset asset, bool isMobile) {
    Color condColor;
    switch (asset.condition) {
      case AssetCondition.operational:
        condColor = Colors.green;
        break;
      case AssetCondition.needsService:
        condColor = Colors.amber.shade800;
        break;
      case AssetCondition.underRepair:
        condColor = Colors.orange.shade800;
        break;
      case AssetCondition.decommissioned:
        condColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${asset.id} • ${asset.name}',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: asset.condition == AssetCondition.decommissioned ? Colors.grey : AppColors.textPrimary,
                        ),
                      ),
                      if (asset.nameAmharic.isNotEmpty)
                        Text(asset.nameAmharic, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: condColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: condColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    asset.condition.displayName.toUpperCase(),
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: condColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(asset.assignedLocation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 14),
                Text('Category: ${asset.category}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
            if (asset.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(asset.notes, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
            ],
            if (asset.decommissionReason != null) ...[
              const SizedBox(height: 4),
              Text('Decommission Reason: ${asset.decommissionReason}', style: const TextStyle(fontSize: 11.5, color: Colors.redAccent, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showUpdateAssetConditionDialog(context, state, asset),
                  icon: const Icon(Icons.tune, size: 14),
                  label: const Text('Update Condition', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                ),
                if (asset.condition != AssetCondition.decommissioned) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDecommissionAssetDialog(context, state, asset),
                    icon: const Icon(Icons.archive_outlined, size: 14),
                    label: const Text('Decommission', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                  ),
                ],
                if (state.isSuperAdmin) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    tooltip: 'Super Admin Permanent Delete',
                    onPressed: () => _showDeleteAssetDialog(context, state, asset),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DIALOGS & ACTIONS
  // ==========================================

  void _showStartHandoverDialog(BuildContext context, dynamic state) {
    final leaderCtrl = TextEditingController(text: 'Washer Team Leader');
    final dailyItems = (state.consumables as List<ConsumableItem>).where((c) => c.isDailyHandoverItem && !c.isDecommissioned).toList();
    final quantities = <String, TextEditingController>{};
    for (var item in dailyItems) {
      double defaultQty = 2.0;
      if (item.name.toLowerCase().contains('shampoo')) defaultQty = 5.0;
      if (item.name.toLowerCase().contains('towel')) defaultQty = 20.0;
      if (item.name.toLowerCase().contains('cloth')) defaultQty = 10.0;
      quantities[item.id] = TextEditingController(text: defaultQty.toString());
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Morning Handover to Team Leader', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: leaderCtrl,
                  decoration: InputDecoration(
                    labelText: 'Washer Team Leader Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Daily Consumables to Issue:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                ...dailyItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${item.name} (${item.unit})', style: const TextStyle(fontSize: 12.5)),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: quantities[item.id],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final issued = <String, double>{};
              quantities.forEach((id, ctrl) {
                final qty = double.tryParse(ctrl.text.trim()) ?? 0.0;
                if (qty > 0) issued[id] = qty;
              });
              await state.startDailyHandover(
                washerTeamLeaderName: leaderCtrl.text.trim(),
                issuedQuantities: issued,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Confirm Handover'),
          ),
        ],
      ),
    );
  }

  void _showCompleteHandoverDialog(BuildContext context, dynamic state, DailyHandover active) {
    final returnedCtrls = <String, TextEditingController>{};
    active.issuedQuantities.forEach((id, issued) {
      returnedCtrls[id] = TextEditingController(text: '0.0');
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Evening Return & Reconcile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Team Leader: ${active.washerTeamLeaderName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const Text('Enter Remaining Supplies Returned to Store:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                const SizedBox(height: 8),
                ...active.issuedQuantities.entries.map((e) {
                  final item = state.consumables.firstWhere((c) => c.id == e.key, orElse: () => null);
                  final name = item != null ? item.name : e.key;
                  final unit = item != null ? item.unit : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('$name\nIssued: ${e.value} $unit', style: const TextStyle(fontSize: 12)),
                        ),
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: returnedCtrls[e.key],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Returned',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final returned = <String, double>{};
              returnedCtrls.forEach((id, ctrl) {
                final qty = double.tryParse(ctrl.text.trim()) ?? 0.0;
                returned[id] = qty;
              });
              await state.completeDailyHandover(
                handoverId: active.id,
                returnedQuantities: returned,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            child: const Text('Complete & Close Shift'),
          ),
        ],
      ),
    );
  }

  void _showReceiveStockDialog(BuildContext context, dynamic state, ConsumableItem item) {
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: item.unitCostEtb > 0 ? item.unitCostEtb.toStringAsFixed(0) : '');
    final supplierCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Receive New Stock: ${item.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity to Add (${item.unit})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Unit Cost (ETB)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierCtrl,
              decoration: InputDecoration(
                labelText: 'Supplier Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
              final cost = double.tryParse(costCtrl.text.trim()) ?? item.unitCostEtb;
              if (qty > 0) {
                await state.receiveStock(
                  itemId: item.id,
                  quantity: qty,
                  unitCostEtb: cost,
                  supplier: supplierCtrl.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Confirm Receive'),
          ),
        ],
      ),
    );
  }

  void _showAddConsumableDialog(BuildContext context, dynamic state) {
    final nameCtrl = TextEditingController();
    final amharicCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Washing & Supplies');
    final unitCtrl = TextEditingController(text: 'Liters');
    final stockCtrl = TextEditingController(text: '10');
    final minCtrl = TextEditingController(text: '5');
    final costCtrl = TextEditingController(text: '250');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Consumable Item', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Item Name (English)')),
              const SizedBox(height: 8),
              TextField(controller: amharicCtrl, decoration: const InputDecoration(labelText: 'Item Name (Amharic)')),
              const SizedBox(height: 8),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 8),
              TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (e.g. Liters, Cans, Pieces)')),
              const SizedBox(height: 8),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current Stock')),
              const SizedBox(height: 8),
              TextField(controller: minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Reorder Threshold')),
              const SizedBox(height: 8),
              TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Unit Cost (ETB)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save Item'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Decommission ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Under Option B, decommissioning marks this item as retired from daily use while preserving historical audit logs.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Reason for Decommissioning',
                hintText: 'e.g. Expired batch, replaced with new formula',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isNotEmpty) {
                await state.decommissionConsumable(item.id, reasonCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
            child: const Text('Confirm Decommission'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConsumableDialog(BuildContext context, dynamic state, ConsumableItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Super Admin: Permanent Delete'),
        content: Text('Are you sure you want to permanently delete "${item.name}" from the database? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await state.deleteConsumable(item.id);
              Navigator.pop(ctx);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Fixed Asset', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Asset Name (English)')),
              const SizedBox(height: 8),
              TextField(controller: amharicCtrl, decoration: const InputDecoration(labelText: 'Asset Name (Amharic)')),
              const SizedBox(height: 8),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 8),
              TextField(controller: snCtrl, decoration: const InputDecoration(labelText: 'Serial Number / Asset Tag')),
              const SizedBox(height: 8),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Assigned Location')),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes / Specifications')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save Asset'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Update ${asset.name} Condition'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<AssetCondition>(
                value: selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Working Condition',
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
                decoration: InputDecoration(
                  labelText: 'Assigned Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Maintenance Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updated = asset.copyWith(
                  condition: selectedCondition,
                  assignedLocation: locCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );
                await state.saveFixedAsset(updated);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDecommissionAssetDialog(BuildContext context, dynamic state, FixedAsset asset) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Decommission ${asset.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Under Option B, decommissioning marks this machinery as retired/scrapped with an official reason while preserving asset records.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Reason for Decommissioning',
                hintText: 'e.g. Motor burnt beyond repair, replaced with new unit',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isNotEmpty) {
                await state.decommissionFixedAsset(asset.id, reasonCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
            child: const Text('Confirm Decommission'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAssetDialog(BuildContext context, dynamic state, FixedAsset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Super Admin: Permanent Delete'),
        content: Text('Are you sure you want to permanently delete asset "${asset.name}" (${asset.id}) from the database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await state.deleteFixedAsset(asset.id);
              Navigator.pop(ctx);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
