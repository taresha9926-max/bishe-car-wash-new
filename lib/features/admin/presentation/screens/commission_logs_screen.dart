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
        title: const Text('Washer Commission Logs'),
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
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL COMMISSION PAYOUT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusReady.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AUTOMATED LOGS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.statusReady,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(totalPayout, showDecimals: true),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sum of ${filteredLogs.length} completed car washes tracked by system',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Filter Chips by Washer
            const Text(
              'Filter by Washer Staff:',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Staff'),
                    selected: _selectedWasherId == 'ALL',
                    onSelected: (_) => setState(() => _selectedWasherId = 'ALL'),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedWasherId == 'ALL' ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...washers.map((washer) {
                    final isSel = washer.id == _selectedWasherId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(washer.name),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedWasherId = washer.id),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
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
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 44, color: AppColors.textMuted),
                    SizedBox(height: 10),
                    Text(
                      'No commission logs recorded for this selection',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Commissions are automatically added when a wash is marked completed.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...filteredLogs.map((log) => CommissionItemCard(log: log)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
