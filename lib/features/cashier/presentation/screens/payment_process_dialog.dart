import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class PaymentProcessDialog extends StatefulWidget {
  final WashBooking booking;

  const PaymentProcessDialog({
    super.key,
    required this.booking,
  });

  static Future<void> show(BuildContext context, WashBooking booking) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentProcessDialog(booking: booking),
    );
  }

  @override
  State<PaymentProcessDialog> createState() => _PaymentProcessDialogState();
}

class _PaymentProcessDialogState extends State<PaymentProcessDialog> {
  late PaymentMethod _selectedMethod;
  final _refCodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.booking.payment.method;
  }

  @override
  void dispose() {
    _refCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountDue = widget.booking.totalPrice;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.point_of_sale_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Collect Payment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // Amount Due Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Bill Amount for ${widget.booking.licensePlate}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(amountDue, showDecimals: true),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    'Package: ${widget.booking.package.name}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Select Payment Channel',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            // Payment Options
            _buildOption(PaymentMethod.cash, 'Physical Cash (Gate Handover)'),
            _buildOption(PaymentMethod.telebirr, 'Telebirr (Ethio Telecom Mobile Money)'),
            _buildOption(PaymentMethod.cbeBirr, 'CBE Birr (Commercial Bank of Ethiopia)'),
            _buildOption(PaymentMethod.otherBankTransfer, 'Other Digital Bank Transfer'),

            if (_selectedMethod.isDigital) ...[
              const SizedBox(height: 12),
              CustomTextField(
                controller: _refCodeController,
                label: 'Digital Transfer Reference / SMS Code',
                hint: 'e.g. TB-8932014 or CBE-9923184',
                prefixIcon: Icons.confirmation_number_outlined,
              ),
            ],
            const SizedBox(height: 20),

            // Action Buttons
            CustomButton(
              text: 'Confirm & Mark as Paid',
              icon: Icons.check_circle_outline,
              backgroundColor: AppColors.cashGreen,
              isLoading: _isProcessing,
              onPressed: () => _handlePaymentConfirm(context, amountDue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(PaymentMethod method, String label) {
    final isSelected = method == _selectedMethod;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? method.color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? method.color : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(method.icon, color: method.color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? method.color : AppColors.textPrimary,
                ),
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              activeColor: method.color,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaymentConfirm(BuildContext context, double amount) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final state = AppStateProvider.read(context);
      final refCode = _refCodeController.text.trim().isNotEmpty
          ? _refCodeController.text.trim()
          : (_selectedMethod.isDigital ? 'DIG-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' : null);

      await state.processPayment(
        bookingId: widget.booking.id,
        method: _selectedMethod,
        amount: amount,
        transactionRef: refCode,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.cashGreen,
            content: Text(
              'Payment of ${CurrencyFormatter.format(amount)} recorded successfully via ${_selectedMethod.shortName}!',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
