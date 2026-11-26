import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/receipt_image_helper.dart';
import '../../../../core/utils/print_export_helper.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../cashier/domain/models/bank_incoming_transaction.dart';
import '../../../cashier/domain/models/sentinel_config.dart';

class SentinelCrossRefCard extends StatefulWidget {
  final List<WashBooking> digitalBookings;
  final bool isMobile;

  const SentinelCrossRefCard({
    super.key,
    required this.digitalBookings,
    required this.isMobile,
  });

  @override
  State<SentinelCrossRefCard> createState() => _SentinelCrossRefCardState();
}

class _SentinelCrossRefCardState extends State<SentinelCrossRefCard> {
  int _activeSubTab = 0; // 0 = Station Receipts, 1 = Bank SMS Feed
  bool _onlyUnmatchedSms = false;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final sentinel = state.sentinelConfig ?? const SentinelConfig();
    final bankTxns = state.bankIncomingTransactions;
    final isOnline = sentinel.isOnline;

    final activeStationReceipts = widget.digitalBookings
        .where((b) => !state.isStationReceiptDeleted(b.id))
        .toList();

    final filteredTxns = _onlyUnmatchedSms
        ? bankTxns.where((t) => t.isUnmatched).toList()
        : bankTxns;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10131C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.telebirrBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.telebirrBlue, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.tr('digitalReceiptsTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  '${activeStationReceipts.length} ${state.tr("digitalPay")}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sentinel Hardware Status Header
          _buildHardwareStatusHeader(context, state, sentinel, isOnline),
          const SizedBox(height: 12),

          // Settlement Target Accounts Strip
          _buildSettlementStrip(context, state, sentinel),
          const SizedBox(height: 14),

          // Sub-Tab Switcher (Station Receipts vs Bank SMS Feed)
          Row(
            children: [
              Expanded(
                child: _buildSubTabButton(
                  title: '${state.tr("stationReceiptsTab")} (${activeStationReceipts.length})',
                  icon: Icons.receipt_long_rounded,
                  isActive: _activeSubTab == 0,
                  onTap: () => setState(() => _activeSubTab = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubTabButton(
                  title: '${state.tr("incomingBankSmsTab")} (${bankTxns.length})',
                  icon: Icons.cell_tower_rounded,
                  isActive: _activeSubTab == 1,
                  onTap: () => setState(() => _activeSubTab = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tab Content
          if (_activeSubTab == 0)
            _buildStationReceiptsView(context, state, activeStationReceipts)
          else
            _buildBankSmsFeedView(context, state, filteredTxns),
        ],
      ),
    );
  }

  Widget _buildHardwareStatusHeader(
    BuildContext context,
    dynamic state,
    SentinelConfig sentinel,
    bool isOnline,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFF064E3B).withValues(alpha: 0.3)
            : const Color(0xFF7F1D1D).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? const Color(0xFF059669) : Colors.red.shade800,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? const Color(0xFF10B981) : Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: (isOnline ? const Color(0xFF10B981) : Colors.redAccent)
                          .withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('sentinelTitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF059669) : Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOnline
                      ? state.tr('sentinelStatusOnline')
                      : state.tr('sentinelStatusOffline'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sentinel.batteryLevel > 20
                        ? Icons.battery_charging_full_rounded
                        : Icons.battery_alert_rounded,
                    size: 15,
                    color: sentinel.batteryLevel > 20
                        ? const Color(0xFF10B981)
                        : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${sentinel.batteryLevel}% ${state.tr("batteryLevel")}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (sentinel.lastHeartbeat != null)
                Text(
                  '${state.tr("lastHeartbeat")}: ${DateFormatter.formatTime(sentinel.lastHeartbeat!)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Security Policy Switcher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 16, color: Color(0xFFFCD34D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sentinel.isStrict
                        ? state.tr('policyStrictMode')
                        : state.tr('policyFlexibleMode'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: sentinel.isStrict ? const Color(0xFFF87171) : const Color(0xFF34D399),
                    ),
                  ),
                ),
                Switch(
                  value: sentinel.isStrict,
                  activeColor: Colors.redAccent,
                  inactiveThumbColor: const Color(0xFF10B981),
                  inactiveTrackColor: const Color(0xFF064E3B),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (isStrict) async {
                    final newMode = isStrict ? 'strict' : 'flexible';
                    await state.setSentinelSecurityMode(newMode);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isStrict
                                ? state.tr('policyStrictMode')
                                : state.tr('policyFlexibleMode'),
                          ),
                          backgroundColor: isStrict ? Colors.orange.shade800 : Colors.teal.shade800,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementStrip(BuildContext context, dynamic state, SentinelConfig sentinel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161A26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: sentinel.targetTelebirrPhone));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Telebirr: ${sentinel.targetTelebirrPhone} copied'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.phone_android_rounded, size: 14, color: Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Telebirr: ${sentinel.targetTelebirrPhone}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 16, color: Colors.white24),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: sentinel.targetCbeAccount));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CBE: ${sentinel.targetCbeAccount} copied'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.account_balance_rounded, size: 14, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'CBE: ${sentinel.targetCbeAccount}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.15) : const Color(0xFF161A26),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isActive ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationReceiptsView(BuildContext context, dynamic state, List<WashBooking> receipts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action toolbar: Print, Export, Clear All
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              '${receipts.length} ${state.tr("stationReceiptsTab")}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.print_rounded, size: 16, color: AppColors.primary),
                  tooltip: state.tr('print'),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  onPressed: receipts.isEmpty
                      ? null
                      : () {
                          PrintExportHelper.printTableReport(
                            title: 'Station Digital Receipts & Verification Log',
                            subtitle: 'BISHE Car Wash Station • Bishoftu',
                            headers: ['Plate', 'Customer', 'Service', 'Method', 'Amount (ETB)', 'Ref No', 'Status', 'Date'],
                            rows: receipts.map((b) => [
                              b.licensePlate,
                              b.customerName,
                              b.isCarpet ? 'Carpet' : b.package.name,
                              b.payment.method.name,
                              b.payment.amount > 0 ? b.payment.amount : b.totalPrice,
                              b.payment.transactionRef ?? '-',
                              b.payment.isBankVerified ? 'Verified' : 'Pending',
                              DateFormatter.formatDate(b.createdAt),
                            ]).toList(),
                          );
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFFFBBF24)),
                  tooltip: state.tr('exportCsv'),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  onPressed: receipts.isEmpty
                      ? null
                      : () {
                          PrintExportHelper.exportCsv(
                            fileName: 'bishe_station_receipts_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                            headers: ['Booking ID', 'Plate', 'Customer', 'Phone', 'Service', 'Method', 'Amount (ETB)', 'Ref No', 'Verified', 'Date'],
                            rows: receipts.map((b) => [
                              b.id,
                              b.licensePlate,
                              b.customerName,
                              b.customerPhone,
                              b.isCarpet ? 'Carpet' : b.package.name,
                              b.payment.method.name,
                              b.payment.amount > 0 ? b.payment.amount : b.totalPrice,
                              b.payment.transactionRef ?? '',
                              b.payment.isBankVerified ? 'YES' : 'NO',
                              b.createdAt.toIso8601String(),
                            ]).toList(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Station receipts exported to CSV'), duration: Duration(seconds: 2)),
                          );
                        },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, size: 17, color: Colors.redAccent),
                  tooltip: state.tr('clearAll'),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  onPressed: receipts.isEmpty
                      ? null
                      : () => _confirmAction(
                            context: context,
                            title: state.tr('confirmClearAll'),
                            message: state.tr('clearAllReceiptsConfirm'),
                            onConfirm: () async {
                              await state.clearAllStationReceipts();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.tr('allReceiptsClearedSuccess')), duration: const Duration(seconds: 2)),
                                );
                              }
                            },
                          ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (receipts.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              state.tr('noDigitalReceipts'),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: receipts.take(20).length,
            separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.cardBorder),
            itemBuilder: (context, index) {
              final b = receipts[index];
              final hasScreenshot = b.payment.receiptScreenshot != null &&
                  b.payment.receiptScreenshot!.trim().isNotEmpty;
              final isVerified = b.payment.isBankVerified;
              final isPending = b.payment.isPendingSms;
              final isSplit = b.payment.isSplit;

              return Row(
                children: [
                  GestureDetector(
                    onTap: hasScreenshot ? () => _showScreenshotDialog(context, state, b) : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: b.payment.method.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: hasScreenshot
                            ? Border.all(color: AppColors.telebirrBlue.withValues(alpha: 0.45))
                            : null,
                      ),
                      child: hasScreenshot
                          ? ReceiptImageHelper.buildImage(
                              b.payment.receiptScreenshot,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              bookingContext: b,
                              fallback: Icon(b.payment.method.icon, color: b.payment.method.color, size: 20),
                            )
                          : Icon(b.payment.method.icon, color: b.payment.method.color, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${b.licensePlate} • ${isSplit ? state.tr("splitPayment") : b.payment.method.localizedName(state.currentLang)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  state.tr('bankVerifiedBadge'),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              )
                            else if (isPending)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  state.tr('bankPendingSmsBadge'),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ref: ${b.payment.transactionRef ?? "N/A"} • ${CurrencyFormatter.format(b.payment.amount > 0 ? b.payment.amount : b.totalPrice)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (hasScreenshot)
                    ElevatedButton.icon(
                      onPressed: () => _showScreenshotDialog(context, state, b),
                      icon: const Icon(Icons.image_rounded, size: 13),
                      label: Text(state.tr('viewReceipt'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.telebirrBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                    tooltip: state.tr('deleteItem'),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () => _confirmAction(
                      context: context,
                      title: state.tr('deleteItem'),
                      message: state.tr('deleteReceiptConfirm'),
                      onConfirm: () async {
                        await state.deleteStationReceipt(b.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.tr('receiptDeletedSuccess')), duration: const Duration(seconds: 1)),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildBankSmsFeedView(
    BuildContext context,
    dynamic state,
    List<BankIncomingTransaction> txns,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${txns.length} ${state.tr("incomingBankSmsTab")}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() => _onlyUnmatchedSms = !_onlyUnmatchedSms),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: _onlyUnmatchedSms
                          ? Colors.amber.shade900.withValues(alpha: 0.3)
                          : const Color(0xFF161A26),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _onlyUnmatchedSms ? Colors.amber : Colors.white12,
                      ),
                    ),
                    child: Text(
                      state.tr('unmatchedCredits'),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _onlyUnmatchedSms ? Colors.amberAccent : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.print_rounded, size: 16, color: AppColors.primary),
                  tooltip: state.tr('print'),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(5),
                  onPressed: txns.isEmpty
                      ? null
                      : () {
                          PrintExportHelper.printTableReport(
                            title: 'Bishe Sentinel Incoming Bank SMS Credits',
                            subtitle: 'Telebirr & CBE Live Mobile Credits • Bishoftu Station',
                            headers: ['Provider', 'Ref No', 'Amount (ETB)', 'Payer Name', 'Phone', 'Status', 'Received At'],
                            rows: txns.map((t) => [
                              t.provider.toUpperCase(),
                              t.refNo,
                              t.amount.toStringAsFixed(2),
                              t.payerName ?? '-',
                              t.payerPhone ?? '-',
                              t.isMatched ? 'Matched' : 'Unmatched',
                              DateFormatter.formatDate(t.receivedAt),
                            ]).toList(),
                          );
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFFFBBF24)),
                  tooltip: state.tr('exportCsv'),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(5),
                  onPressed: txns.isEmpty
                      ? null
                      : () {
                          PrintExportHelper.exportCsv(
                            fileName: 'bishe_incoming_bank_sms_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                            headers: ['ID', 'Provider', 'Ref No', 'Amount (ETB)', 'Payer Name', 'Payer Phone', 'Status', 'Matched Booking ID', 'Received At'],
                            rows: txns.map((t) => [
                              t.id,
                              t.provider,
                              t.refNo,
                              t.amount,
                              t.payerName ?? '',
                              t.payerPhone ?? '',
                              t.matchStatus,
                              t.matchedBookingId ?? '',
                              t.receivedAt.toIso8601String(),
                            ]).toList(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bank SMS feed exported to CSV'), duration: Duration(seconds: 2)),
                          );
                        },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, size: 17, color: Colors.redAccent),
                  tooltip: state.tr('clearAll'),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(5),
                  onPressed: txns.isEmpty
                      ? null
                      : () => _confirmAction(
                            context: context,
                            title: state.tr('confirmClearAll'),
                            message: state.tr('clearAllSmsConfirm'),
                            onConfirm: () async {
                              await state.clearAllBankIncomingTransactions();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.tr('allSmsClearedSuccess')), duration: const Duration(seconds: 2)),
                                );
                              }
                            },
                          ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (txns.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: const Text(
              'No incoming SMS recorded yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: txns.take(20).length,
            separatorBuilder: (_, __) => const Divider(height: 12, color: AppColors.cardBorder),
            itemBuilder: (context, index) {
              final t = txns[index];
              final isCbe = t.isCbe;
              final isMatched = t.isMatched;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _showRawSmsDialog(context, state, t),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isCbe
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                              : const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCbe ? Icons.account_balance_rounded : Icons.phone_android_rounded,
                          size: 16,
                          color: isCbe ? const Color(0xFFA78BFA) : const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showRawSmsDialog(context, state, t),
                        borderRadius: BorderRadius.circular(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  CurrencyFormatter.format(t.amount),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? const Color(0xFF059669).withValues(alpha: 0.2)
                                        : Colors.amber.shade900.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isMatched
                                        ? state.tr('matchedBooking')
                                        : state.tr('unmatchedCredits'),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: isMatched
                                          ? const Color(0xFF10B981)
                                          : Colors.amberAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.payerName ?? "Unknown"} • Ref: ${t.refNo}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatTime(t.receivedAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                      tooltip: state.tr('deleteItem'),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(5),
                      onPressed: () => _confirmAction(
                        context: context,
                        title: state.tr('deleteItem'),
                        message: state.tr('deleteSmsConfirm'),
                        onConfirm: () async {
                          await state.deleteBankIncomingTransaction(t.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.tr('smsDeletedSuccess')), duration: const Duration(seconds: 1)),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    final state = AppStateProvider.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(state.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await onConfirm();
            },
            child: Text(state.tr('deleteItem'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRawSmsDialog(
    BuildContext context,
    dynamic state,
    BankIncomingTransaction txn,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              txn.isCbe ? Icons.account_balance_rounded : Icons.phone_android_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${txn.provider.toUpperCase()} • ${CurrencyFormatter.format(txn.amount)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${state.tr("payerInfo")}: ${txn.payerName ?? "N/A"} (${txn.payerPhone ?? ""})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Ref: ${txn.refNo}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 10),
            Text(state.tr('rawSms'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10131C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                txn.rawSms ?? '',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('close')),
          ),
        ],
      ),
    );
  }

  void _showScreenshotDialog(
    BuildContext context,
    dynamic state,
    WashBooking booking,
  ) {
    final imageWidget = ReceiptImageHelper.buildImage(
      booking.payment.receiptScreenshot,
      fit: BoxFit.contain,
      bookingContext: booking,
      fallback: Center(
        child: Text(state.tr('noReceiptImageAvailable'), style: const TextStyle(color: Colors.white70)),
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF161A26),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(booking.payment.method.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${booking.licensePlate} • ${CurrencyFormatter.format(booking.payment.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  color: Colors.black26,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: InteractiveViewer(maxScale: 3.0, child: imageWidget),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
