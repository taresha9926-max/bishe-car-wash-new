import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../admin/domain/models/commission_log.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/commission_item_card.dart';

class CommissionLogsScreen extends StatefulWidget {
  const CommissionLogsScreen({super.key});

  @override
  State<CommissionLogsScreen> createState() => _CommissionLogsScreenState();
}

class _CommissionLogsScreenState extends State<CommissionLogsScreen> {
  String _selectedWasherId = 'ALL';

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final allLogs = state.commissionLogs;
    final washers = state.availableWashers;

    final filteredLogs = _selectedWasherId == 'ALL'
        ? allLogs
        : allLogs.where((l) => l.washerId == _selectedWasherId).toList();

    final totalPayout = filteredLogs.fold(0.0, (sum, l) => sum + l.commissionEarnedETB);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.tr('commissionLogsTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payout Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.oromiaGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.handshake_rounded, color: AppColors.oromiaGold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('commissionsPaid'),
                          style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          CurrencyFormatter.format(totalPayout),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text(
                          '${filteredLogs.length} ${state.tr("carsWashed")}',
                          style: const TextStyle(fontSize: 11, color: AppColors.oromiaGold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Washer Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    selected: _selectedWasherId == 'ALL',
                    label: Text(state.tr('all')),
                    onSelected: (_) => setState(() => _selectedWasherId = 'ALL'),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _selectedWasherId == 'ALL' ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...washers.map((w) {
                    final isSel = _selectedWasherId == w.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(w.name),
                        onSelected: (_) => setState(() => _selectedWasherId = w.id),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logs List
            if (filteredLogs.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                alignment: Alignment.center,
                child: Text(
                  state.tr('noRecords'),
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              )
            else
              ...filteredLogs.map((log) => CommissionItemCard(log: log)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
