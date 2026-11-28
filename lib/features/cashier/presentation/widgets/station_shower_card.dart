import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/print_export_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/shower_record.dart';
import 'digital_payment_proof_section.dart';

/// Shared Station Public Shower admission desk card used symmetrically
/// by both Day Shift (Cashier) and Night Shift (Operational Manager).
class StationShowerCard extends StatefulWidget {
  final bool isManager;

  const StationShowerCard({
    super.key,
    this.isManager = false,
  });

  @override
  State<StationShowerCard> createState() => _StationShowerCardState();
}

class _StationShowerCardState extends State<StationShowerCard> {
  int _showerCount = 1;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final TextEditingController _refController = TextEditingController();
  String? _screenshotBase64;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final showerPrice = state.showerPricePerPerson;
    final totalToPay = _showerCount * showerPrice;
    final staffLabel = state.activeStaffFullName ?? (widget.isManager ? 'Operational Manager' : 'Cashier');
    final records = state.showerRecords;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shower_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('stationShowerService'),
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          Text(
                            '${showerPrice.toStringAsFixed(0)} ETB ${state.tr("perPerson")} • ${state.tr("showerCommissionNotice")}',
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.todayShowerUserCount} ${state.tr("showerUsers")}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
                      tooltip: state.tr('printReport'),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(5),
                      onPressed: records.isEmpty
                          ? null
                          : () {
                              PrintExportHelper.printTableReport(
                                title: state.tr('stationShowerService'),
                                subtitle: state.tr('appName'),
                                headers: ['ID', state.tr('showerUsers'), state.tr('paymentMethod'), 'Total (ETB)', state.tr('cashierRole'), 'Time'],
                                rows: records.map((s) => [
                                  s.id.substring(0, math.min(8, s.id.length)),
                                  s.userCount,
                                  s.paymentMethod.name.toUpperCase(),
                                  s.totalAmount.toStringAsFixed(2),
                                  s.recordedBy,
                                  s.recordedAt.toString().substring(0, 16),
                                ]).toList(),
                              );
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
                      tooltip: state.tr('exportCsv'),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(5),
                      onPressed: records.isEmpty
                          ? null
                          : () {
                              PrintExportHelper.exportCsv(
                                fileName: 'bishe_shower_log_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                                headers: ['ID', 'Persons', 'Method', 'Total (ETB)', 'Staff', 'Ref', 'Time'],
                                rows: records.map((s) => [
                                  s.id,
                                  s.userCount,
                                  s.paymentMethod.name,
                                  s.totalAmount,
                                  s.recordedBy,
                                  s.transactionRef ?? '',
                                  s.recordedAt.toIso8601String(),
                                ]).toList(),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Customer Count Stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.tr('numberOfPersons'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                      onPressed: _showerCount > 1 ? () => setState(() => _showerCount--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0284C7)),
                        ),
                        child: Text(
                          '$_showerCount',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8)),
                      onPressed: () => setState(() => _showerCount++),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final n in [1, 2, 5])
                      ActionChip(
                        label: Text('+$n', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                        onPressed: () => setState(() => _showerCount += n),
                      ),
                    if (_showerCount > 1)
                      ActionChip(
                        label: Text('${state.tr("clear")} (1)', style: const TextStyle(fontSize: 11.5)),
                        onPressed: () => setState(() => _showerCount = 1),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            state.tr('paymentMethod'),
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: PaymentMethod.values.map((method) {
              final selected = _paymentMethod == method;
              return ChoiceChip(
                avatar: Icon(
                  method.icon,
                  size: 14,
                  color: selected ? Colors.white : method.color,
                ),
                label: Text(
                  method.localizedName(state.currentLang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: selected,
                selectedColor: method.color,
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _paymentMethod = method;
                      if (!method.isDigital) {
                        _screenshotBase64 = null;
                        _refController.clear();
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),

          // Digital Money Transfer Verification (Take Photo, Upload Photo, OCR, Sentinel SMS Match)
          DigitalPaymentProofSection(
            state: state,
            selectedMethod: _paymentMethod,
            amountDue: totalToPay,
            refController: _refController,
            screenshotBase64: _screenshotBase64,
            onScreenshotChanged: (val) => setState(() => _screenshotBase64 = val),
          ),

          const SizedBox(height: 12),
          CustomButton(
            text: '${state.tr("recordShowerEntry")} • ${CurrencyFormatter.format(totalToPay)}',
            icon: Icons.check_circle_rounded,
            backgroundColor: const Color(0xFF0284C7),
            onPressed: () async {
              final proof = DigitalPaymentProofSection.validateAndResolveRef(
                context: context,
                state: state,
                method: _paymentMethod,
                amountDue: totalToPay,
                rawRef: _refController.text,
                screenshotBase64: _screenshotBase64,
              );
              if (!proof.ok) return;

              final recordedCount = _showerCount;
              await state.recordShowerEntry(
                userCount: recordedCount,
                paymentMethod: _paymentMethod,
                cashierName: staffLabel,
                role: widget.isManager ? 'operationalManager' : 'cashier',
                receiptScreenshot: _paymentMethod.isDigital ? _screenshotBase64 : null,
                transactionRef: proof.transactionRef,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.statusCompleted,
                    content: Text('${state.tr("showerRecordedToast")}: $recordedCount (${CurrencyFormatter.format(totalToPay)})'),
                  ),
                );
                setState(() {
                  _showerCount = 1;
                  _screenshotBase64 = null;
                  _refController.clear();
                });
              }
            },
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  state.tr('showerTotalRevenue'),
                  CurrencyFormatter.format(state.todayShowerRevenueETB),
                  const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  state.tr('cashCollected'),
                  CurrencyFormatter.format(state.todayShowerCashETB),
                  AppColors.cashGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatTile(
                  state.tr('digitalPay'),
                  CurrencyFormatter.format(state.todayShowerDigitalETB),
                  AppColors.telebirrBlue,
                ),
              ),
            ],
          ),

          if (records.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 8),
            Text(
              state.tr('recentShowerEntries'),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            ...records.take(5).map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(
                      s.paymentMethod.icon,
                      size: 14,
                      color: s.paymentMethod.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${s.userCount} ${state.tr("showerUsers")} • ${CurrencyFormatter.format(s.totalAmount)} (${s.paymentMethod.localizedName(state.currentLang)})'
                        '${(s.transactionRef ?? '').isNotEmpty ? ' • ${s.transactionRef}' : ''} • ${s.recordedBy}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if ((s.receiptScreenshot ?? '').isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.verified_rounded, size: 14, color: AppColors.cashGreen),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF38BDF8)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showEditShowerDialog(context, state, s),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }

  void _showEditShowerDialog(BuildContext context, dynamic state, ShowerRecord s) {
    int userCount = s.userCount;
    PaymentMethod method = s.paymentMethod;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(state.tr('editRecord'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(state.tr('showerUsers'), style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                    onPressed: userCount > 1 ? () => setDlgState(() => userCount--) : null,
                  ),
                  Text('$userCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                    onPressed: () => setDlgState(() => userCount++),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  PaymentMethod.cash,
                  PaymentMethod.telebirr,
                  PaymentMethod.cbeBirr,
                ].map((m) {
                  return ChoiceChip(
                    label: Text(m.localizedName(state.currentLang), style: const TextStyle(fontSize: 11.5)),
                    selected: method == m,
                    onSelected: (val) {
                      if (val) setDlgState(() => method = m);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await state.deleteShowerRecord(s.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.tr('recordDeletedToast')), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: Text(state.tr('deleteRecord'), style: const TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await state.updateShowerRecord(
                  id: s.id,
                  userCount: userCount,
                  paymentMethod: method,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.tr('bookingUpdatedToast')), backgroundColor: AppColors.cashGreen),
                  );
                }
              },
              child: Text(state.tr('saveChanges')),
            ),
          ],
        ),
      ),
    );
  }
}
