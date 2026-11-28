import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../inventory/domain/models/retail_item.dart';
import '../../domain/models/retail_sale_record.dart';
import 'digital_payment_proof_section.dart';

/// Shared Standalone Retail Merchandise POS Card used symmetrically across
/// Cashier (Day Shift) and Operational Manager (Night Shift) desks.
/// Renders items as an expandable accordion list with unit prices and full
/// digital receipt proof + Sentinel SMS reconciliation.
class StationRetailPosCard extends StatefulWidget {
  final bool isManager;

  const StationRetailPosCard({
    super.key,
    this.isManager = false,
  });

  @override
  State<StationRetailPosCard> createState() => _StationRetailPosCardState();
}

class _StationRetailPosCardState extends State<StationRetailPosCard> {
  String? _expandedItemId;
  int _quantity = 1;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  String? _screenshotBase64;

  @override
  void dispose() {
    _buyerController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _toggleExpandItem(String itemId) {
    setState(() {
      if (_expandedItemId == itemId) {
        _expandedItemId = null;
      } else {
        _expandedItemId = itemId;
        _quantity = 1;
        _paymentMethod = PaymentMethod.cash;
        _screenshotBase64 = null;
        _refController.clear();
        _buyerController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final List<RetailItem> items = state.retailItems;
    final List<RetailSaleRecord> sales = state.retailSales;
    final double todayTotal = state.todayRetailRevenueETB;
    final int todayCount = state.todayRetailSalesCount;

    const accent = Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
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
              gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr('retailSalesTitle'),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        state.tr('retailSalesSub'),
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(todayTotal),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '$todayCount ${state.tr("retailUnitsLabel")}',
                        style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            state.tr('tapItemToSellHint'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Text(
                  state.tr('noRetailItemsAvailable'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...items.map((item) => _buildExpandableRetailRow(context, state, item, accent)),

          if (sales.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 10),
            Text(
              state.tr('recentRetailSales'),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            ...sales.take(6).map((r) {
              final localizedTitle = state.retailItemLocalizedName(r.itemId, fallback: r.itemName);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(r.paymentMethod.icon, size: 14, color: r.paymentMethod.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r.quantity}× $localizedTitle',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${CurrencyFormatter.format(r.totalAmount)} (${r.paymentMethod.localizedName(state.currentLang)})'
                            '${(r.customerName ?? '').isNotEmpty ? ' • ${r.customerName}' : ''}'
                            '${(r.transactionRef ?? '').isNotEmpty ? ' • ${r.transactionRef}' : ''} • ${r.recordedBy}',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if ((r.receiptScreenshot ?? '').isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.verified_rounded, size: 14, color: AppColors.cashGreen),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: state.tr('deleteRecord'),
                      onPressed: () async {
                        await state.deleteRetailSale(r.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.tr('recordDeletedToast')),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
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

  Widget _buildExpandableRetailRow(
    BuildContext context,
    dynamic state,
    RetailItem item,
    Color accent,
  ) {
    final isExpanded = _expandedItemId == item.id;
    final totalAmount = item.sellingPriceEtb * _quantity;
    final localizedName = item.localizedName(state.currentLang);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? accent : AppColors.cardBorder,
          width: isExpanded ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('retail_item_row_${item.id}'),
              onTap: () => _toggleExpandItem(item.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(Icons.shopping_bag_outlined, color: accent, size: 17),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.tr("unitPriceLabel")}: ${CurrencyFormatter.format(item.sellingPriceEtb)} • ${state.tr("inStockLabel")}: ${item.currentStock}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: item.isLowStock ? Colors.orangeAccent : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cashGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cashGreen.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        CurrencyFormatter.format(item.sellingPriceEtb),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cashGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? accent : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity Stepper & Subtotal Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${state.tr("qtyLabel")}:',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 20),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFCD34D), size: 20),
                          onPressed: () => setState(() => _quantity++),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyFormatter.format(totalAmount),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFFCD34D)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Optional Buyer / Plate
                  TextField(
                    controller: _buyerController,
                    style: const TextStyle(fontSize: 12.5, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: state.tr('buyerOptionalHint'),
                      hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.directions_car_outlined, size: 17, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    state.tr('paymentMethod'),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: PaymentMethod.values.map((m) {
                      final isChosen = _paymentMethod == m;
                      return ChoiceChip(
                        avatar: Icon(m.icon, size: 14, color: isChosen ? Colors.white : m.color),
                        label: Text(
                          m.localizedName(state.currentLang),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isChosen ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: isChosen,
                        selectedColor: m.color,
                        backgroundColor: const Color(0xFF0F172A),
                        onSelected: (v) {
                          if (v) {
                            setState(() {
                              _paymentMethod = m;
                              if (!m.isDigital) {
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
                    amountDue: totalAmount,
                    refController: _refController,
                    screenshotBase64: _screenshotBase64,
                    onScreenshotChanged: (val) => setState(() => _screenshotBase64 = val),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                      label: Text(
                        '${state.tr("recordRetailSale")} • ${CurrencyFormatter.format(totalAmount)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () async {
                        final proof = DigitalPaymentProofSection.validateAndResolveRef(
                          context: context,
                          state: state,
                          method: _paymentMethod,
                          amountDue: totalAmount,
                          rawRef: _refController.text,
                          screenshotBase64: _screenshotBase64,
                        );
                        if (!proof.ok) return;

                        final staffName = state.activeStaffFullName ??
                            (widget.isManager ? 'Operational Manager' : 'Cashier');
                        final soldQty = _quantity;
                        await state.recordRetailSale(
                          item: item,
                          quantity: soldQty,
                          paymentMethod: _paymentMethod,
                          cashierName: staffName,
                          role: widget.isManager ? 'operationalManager' : 'cashier',
                          customerName: _buyerController.text,
                          receiptScreenshot: _paymentMethod.isDigital ? _screenshotBase64 : null,
                          transactionRef: proof.transactionRef,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.statusCompleted,
                              content: Text(
                                '${state.tr("retailSaleRecordedToast")}: $soldQty× $localizedName (${CurrencyFormatter.format(totalAmount)})',
                              ),
                            ),
                          );
                          setState(() {
                            _quantity = 1;
                            _buyerController.clear();
                            _refController.clear();
                            _screenshotBase64 = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
