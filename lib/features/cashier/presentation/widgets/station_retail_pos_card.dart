import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../inventory/domain/models/retail_item.dart';
import '../../domain/models/retail_sale_record.dart';

/// Shared Retail Merchandise POS Card used symmetrically inside StationMoneyTab
/// for both Day Shift (Cashier) and Night Shift (Operational Manager).
class StationRetailPosCard extends StatefulWidget {
  final bool isManager;
  final bool initiallyExpanded;

  const StationRetailPosCard({
    super.key,
    this.isManager = false,
    this.initiallyExpanded = false,
  });

  @override
  State<StationRetailPosCard> createState() => _StationRetailPosCardState();
}

class _StationRetailPosCardState extends State<StationRetailPosCard> {
  late bool _expanded;
  String? _selectedItemId;
  int _quantity = 1;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _refController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _buyerController.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final List<RetailItem> items = state.retailItems;
    final List<RetailSaleRecord> sales = state.retailSales;
    final double todayTotal = state.todayRetailRevenueETB;
    final int todayCount = state.todayRetailSalesCount;

    final selectedItem = items.isEmpty
        ? null
        : items.where((i) => i.id == _selectedItemId).firstOrNull ?? items.first;
    final unitPrice = selectedItem?.sellingPriceEtb ?? 0.0;
    final totalAmount = unitPrice * _quantity;

    const accent = Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded ? accent.withValues(alpha: 0.55) : AppColors.cardBorder,
          width: 1.2,
        ),
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
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: accent.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.shopping_bag_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('retailSalesTitle'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            state.tr('retailSalesSub'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accent.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        '$todayCount • ${CurrencyFormatter.formatShort(todayTotal)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFCD34D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.all(14),
              child: items.isEmpty
                  ? Text(
                      state.tr('noRetailItemsAvailable'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item selector chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: items.map((item) {
                            final isSelected = selectedItem?.id == item.id;
                            final stockNote = item.currentStock > 0 ? ' (${item.currentStock})' : '';
                            return InkWell(
                              onTap: () => setState(() => _selectedItemId = item.id),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? accent.withValues(alpha: 0.2) : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? accent : AppColors.cardBorder,
                                    width: isSelected ? 1.4 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${item.localizedName(state.currentLang)}$stockNote',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? const Color(0xFFFDE68A) : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.format(item.sellingPriceEtb),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? accent : AppColors.cashGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Quantity Stepper & Total Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedItem!.localizedName(state.currentLang),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${state.tr("qtyLabel")}: $_quantity • ${CurrencyFormatter.format(totalAmount)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.5,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.white70),
                                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 22, color: accent),
                                onPressed: () => setState(() => _quantity++),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Payment Method Chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            PaymentMethod.cash,
                            PaymentMethod.telebirr,
                            PaymentMethod.cbeBirr,
                            PaymentMethod.bankOfAbyssinia,
                          ].map((m) {
                            final sel = _paymentMethod == m;
                            return ChoiceChip(
                              showCheckmark: false,
                              label: Text(
                                m.localizedName(state.currentLang),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                                  color: sel ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                              selected: sel,
                              selectedColor: m == PaymentMethod.cash ? AppColors.cashGreen : AppColors.telebirrBlue,
                              backgroundColor: const Color(0xFF1E293B),
                              onSelected: (_) => setState(() => _paymentMethod = m),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),

                        // Optional Customer / Plate + Digital Reference
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _buyerController,
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: state.tr('buyerOptionalHint'),
                                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFF1E293B),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            if (_paymentMethod != PaymentMethod.cash) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _refController,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: state.tr('retailTxRefHint'),
                                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    isDense: true,
                                    filled: true,
                                    fillColor: const Color(0xFF1E293B),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Record Sale Button
                        CustomButton(
                          text: '${state.tr("recordRetailSale")} • ${CurrencyFormatter.format(totalAmount)}',
                          icon: Icons.point_of_sale_rounded,
                          backgroundColor: accent,
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final staffName = (state.activeStaffFullName != null &&
                                    state.activeStaffFullName!.isNotEmpty)
                                ? state.activeStaffFullName!
                                : (widget.isManager ? 'Operational Manager' : 'Station Cashier');
                            final qtySold = _quantity;
                            await state.recordRetailSale(
                              item: selectedItem,
                              quantity: qtySold,
                              paymentMethod: _paymentMethod,
                              cashierName: staffName,
                              role: widget.isManager ? 'operationalManager' : 'cashier',
                              customerName: _buyerController.text.trim().isEmpty
                                  ? null
                                  : _buyerController.text.trim(),
                              transactionRef: _refController.text.trim().isEmpty
                                  ? null
                                  : _refController.text.trim(),
                            );
                            if (mounted) {
                              setState(() {
                                _quantity = 1;
                                _buyerController.clear();
                                _refController.clear();
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.statusCompleted,
                                  content: Text(
                                    '${state.tr("retailSaleRecordedToast")} ($qtySold × ${selectedItem.localizedName(state.currentLang)})',
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        // Recent Sales History
                        if (sales.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          const SizedBox(height: 8),
                          Text(
                            state.tr('recentRetailSales'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...sales.take(5).map((r) {
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
                                    r.isCash ? Icons.payments_rounded : Icons.phone_android_rounded,
                                    size: 14,
                                    color: r.isCash ? AppColors.cashGreen : AppColors.telebirrBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${r.quantity}× ${r.itemName} • ${CurrencyFormatter.format(r.totalAmount)} (${r.isCash ? state.tr("payCash") : r.paymentMethod.shortName})${r.customerName != null ? " • ${r.customerName}" : ""}',
                                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 15, color: Colors.redAccent),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => state.deleteRetailSale(r.id),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
