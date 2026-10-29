import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
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
      barrierDismissible: true,
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
  String? _uploadedScreenshotName;
  String? _screenshotBase64;

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

  void _pickScreenshot() {
    ImagePickerHelper.pickImage(onPicked: (img) {
      setState(() {
        _uploadedScreenshotName = img.name;
        _screenshotBase64 = img.base64Data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final amountDue = widget.booking.totalPrice;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.point_of_sale_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        state.tr('paymentDialogTitle'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                      '${state.tr("licensePlate")}: ${widget.booking.licensePlate}',
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
                      '${widget.booking.package.localizedName(state.currentLang)} • ${widget.booking.carType.localizedName(state.currentLang)}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                state.tr('paymentMethod'),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              // Payment Options
              _buildOption(PaymentMethod.cash, state.tr('payCash')),
              _buildOption(PaymentMethod.telebirr, state.tr('payTelebirr')),
              _buildOption(PaymentMethod.cbeBirr, state.tr('payCbeBirr')),
              _buildOption(PaymentMethod.bankOfAbyssinia, 'Bank of Abyssinia (BoA)'),
              _buildOption(PaymentMethod.awashBank, 'Awash Bank'),
              _buildOption(PaymentMethod.dashenBank, 'Dashen Bank (Amole)'),
              _buildOption(PaymentMethod.otherBankTransfer, state.tr('payBank')),

              // Digital Payment Fields
              if (_selectedMethod.isDigital) ...[
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _refCodeController,
                  label: state.tr('transactionRef'),
                  hint: 'e.g. TB-8932014 or CBE-9923184',
                  prefixIcon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: 10),

                // Screenshot Upload Box
                InkWell(
                  onTap: _pickScreenshot,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _uploadedScreenshotName != null ? AppColors.cashGreen : AppColors.cardBorder,
                        width: _uploadedScreenshotName != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _uploadedScreenshotName != null ? Icons.image_rounded : Icons.upload_file_rounded,
                          color: _uploadedScreenshotName != null ? AppColors.cashGreen : AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _uploadedScreenshotName != null
                                    ? 'Attached: $_uploadedScreenshotName'
                                    : state.tr('uploadReceipt'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _uploadedScreenshotName != null ? AppColors.cashGreen : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _uploadedScreenshotName != null
                                    ? state.tr('receiptUploaded')
                                    : state.tr('uploadReceipt'),
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (_uploadedScreenshotName != null)
                          const Icon(Icons.check_circle_rounded, color: AppColors.cashGreen, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Action Buttons
              CustomButton(
                text: state.tr('confirmAndPay'),
                icon: Icons.check_circle_outline,
                backgroundColor: AppColors.cashGreen,
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : () => _handlePaymentConfirm(context, amountDue),
              ),
            ],
          ),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? method.color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(method.icon, color: method.color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? method.color : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: method.color, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaymentConfirm(BuildContext context, double amount) async {
    final state = AppStateProvider.read(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    setState(() {
      _isProcessing = true;
    });

    try {
      final refCode = _selectedMethod.isDigital && _refCodeController.text.trim().isNotEmpty
          ? _refCodeController.text.trim()
          : null;

      await state.processPayment(
        bookingId: widget.booking.id,
        method: _selectedMethod,
        amount: amount,
        transactionRef: refCode,
        receiptScreenshot: _screenshotBase64,
      );

      navigator.pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Payment of ${CurrencyFormatter.format(amount)} recorded successfully!'),
              ],
            ),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
