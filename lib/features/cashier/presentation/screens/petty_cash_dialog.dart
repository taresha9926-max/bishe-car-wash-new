import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class PettyCashDialog extends StatefulWidget {
  const PettyCashDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PettyCashDialog(),
    );
  }

  @override
  State<PettyCashDialog> createState() => _PettyCashDialogState();
}

class _PettyCashDialogState extends State<PettyCashDialog> {
  String _selectedCategory = 'fuel';
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _cashierNameController = TextEditingController(text: 'Cashier On Duty');

  bool _isSubmitting = false;
  String? _uploadedReceiptName;
  String? _receiptBase64;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _cashierNameController.dispose();
    super.dispose();
  }

  void _pickReceiptImage() {
    ImagePickerHelper.pickImage(onPicked: (img) {
      setState(() {
        _uploadedReceiptName = img.name;
        _receiptBase64 = img.base64Data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final availableCash = state.undepositedCashTodayETB;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final categories = [
      {'key': 'fuel', 'label': state.tr('pettyCategoryFuel'), 'icon': Icons.local_gas_station_rounded},
      {'key': 'plumbing', 'label': state.tr('pettyCategoryPlumbing'), 'icon': Icons.plumbing_rounded},
      {'key': 'supplies', 'label': state.tr('pettyCategorySupplies'), 'icon': Icons.inventory_2_rounded},
      {'key': 'staff_lunch', 'label': state.tr('pettyCategoryStaffLunch'), 'icon': Icons.restaurant_rounded},
      {'key': 'other', 'label': state.tr('pettyCategoryOther'), 'icon': Icons.receipt_long_rounded},
    ];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.outbox_rounded, color: Colors.deepOrange, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('logPettyCash'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            state.tr('pettyCashExpense'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Available Drawer Cash
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.tr('cashAwaitingDeposit'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.format(availableCash),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.cashGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Category Selector
              Text(
                state.tr('pettyCategory'),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_rounded, size: 20, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['key'] as String,
                    child: Row(
                      children: [
                        Icon(cat['icon'] as IconData, size: 18, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        Text(cat['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),

              // Expense Amount
              CustomTextField(
                controller: _amountController,
                label: '${state.tr('depositAmount')} *',
                hint: 'e.g. 350',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money_rounded,
              ),
              const SizedBox(height: 12),

              // Reason
              CustomTextField(
                controller: _reasonController,
                label: '${state.tr('pettyCashReason')} *',
                hint: 'e.g. Generator diesel fuel for power cut',
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 12),

              // Mandatory Voucher Proof
              Row(
                children: [
                  Text(
                    state.tr('uploadReceipt'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickReceiptImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    color: _uploadedReceiptName != null ? AppColors.cashGreen.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _uploadedReceiptName != null ? AppColors.cashGreen : Colors.red.shade300,
                      width: _uploadedReceiptName != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _uploadedReceiptName != null ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                        color: _uploadedReceiptName != null ? AppColors.cashGreen : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _uploadedReceiptName ?? state.tr('pettyCashScreenshotRequired'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _uploadedReceiptName != null ? AppColors.cashGreen : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Cashier Name
              CustomTextField(
                controller: _cashierNameController,
                label: state.tr('reportedByCashier'),
                hint: 'Abebech Tadesse',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 18),

              // Submit Button
              CustomButton(
                text: state.tr('logPettyCash'),
                icon: Icons.check_circle_outline,
                backgroundColor: Colors.deepOrange,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handlePettyCashSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePettyCashSubmit() async {
    final state = AppStateProvider.read(context);
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expense amount.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('pettyCashReason')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_receiptBase64 == null || _receiptBase64!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('pettyCashScreenshotRequired')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final cashierName = _cashierNameController.text.trim().isNotEmpty
        ? _cashierNameController.text.trim()
        : 'Cashier On Duty';

    setState(() => _isSubmitting = true);

    try {
      await state.recordPettyCashExpense(
        amount: amount,
        category: _selectedCategory,
        reason: reason,
        cashierName: cashierName,
        voucherScreenshot: _receiptBase64,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('pettyCashSuccess')),
            backgroundColor: AppColors.statusCompleted,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording petty cash: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
