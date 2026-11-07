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
  final _tipController = TextEditingController();
  bool _isProcessing = false;
  String? _uploadedScreenshotName;
  String? _screenshotBase64;
  double _tipAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.booking.payment.method;
    _tipAmount = widget.booking.payment.tipAmount;
    if (_tipAmount > 0) {
      _tipController.text = _tipAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _refCodeController.dispose();
    _tipController.dispose();
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
                      widget.booking.isCarpet
                          ? '${state.tr("carpetService")}: ${widget.booking.carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
                          : '${state.tr("licensePlate")}: ${widget.booking.licensePlate}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(amountDue + _tipAmount, showDecimals: true),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      widget.booking.isCarpet
                          ? '${widget.booking.carpetAreaSqMeters ?? 0.0} m² (${widget.booking.carpetDimensions ?? ""}) • ${widget.booking.serviceType.localizedName(state.currentLang)}'
                          : '${widget.booking.package.localizedName(state.currentLang)} • ${widget.booking.carType.localizedName(state.currentLang)}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Optional Washer Tip Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volunteer_activism_rounded, size: 16, color: Colors.amber.shade900),
                        const SizedBox(width: 6),
                        Text(
                          state.tr('washersTip'),
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.amber.shade900),
                        ),
                        const Spacer(),
                        if (_tipAmount > 0)
                          Text(
                            '+ETB ${_tipAmount.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.amber.shade900),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final tipVal in [50, 100, 200]) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('+$tipVal'),
                              selected: _tipAmount == tipVal.toDouble(),
                              onSelected: (selected) {
                                setState(() {
                                  _tipAmount = selected ? tipVal.toDouble() : 0.0;
                                  _tipController.text = _tipAmount > 0 ? _tipAmount.toStringAsFixed(0) : '';
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _tipController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: state.tr('customTip'),
                                hintStyle: const TextStyle(fontSize: 11),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _tipAmount = double.tryParse(val) ?? 0.0;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_rounded, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.tr('proofMandatoryNotice'),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _refCodeController,
                  label: '${state.tr('transactionRef')} (Optional)',
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
                      color: _uploadedScreenshotName != null ? AppColors.cashGreen.withOpacity(0.06) : Colors.red.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _uploadedScreenshotName != null ? AppColors.cashGreen : Colors.red.shade300,
                        width: _uploadedScreenshotName != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _uploadedScreenshotName != null ? Icons.image_rounded : Icons.camera_alt_outlined,
                          color: _uploadedScreenshotName != null ? AppColors.cashGreen : Colors.red.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _uploadedScreenshotName != null
                                        ? 'Attached: $_uploadedScreenshotName'
                                        : state.tr('uploadReceipt'),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: _uploadedScreenshotName != null ? AppColors.cashGreen : Colors.red.shade800,
                                    ),
                                  ),
                                  const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text(
                                _uploadedScreenshotName != null
                                    ? state.tr('receiptUploaded')
                                    : state.tr('pleaseUploadProof'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: _uploadedScreenshotName != null ? AppColors.textMuted : Colors.red.shade700,
                                ),
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

    if (_selectedMethod != PaymentMethod.cash) {
      if (_screenshotBase64 == null || _screenshotBase64!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('pleaseUploadProof')),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
    }

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
        tipAmount: _tipAmount,
        transactionRef: refCode,
        receiptScreenshot: _screenshotBase64,
      );

      navigator.pop();

      if (mounted) {
        final totalText = _tipAmount > 0
            ? '${CurrencyFormatter.format(amount + _tipAmount)} (includes ETB ${_tipAmount.toStringAsFixed(0)} tip)'
            : CurrencyFormatter.format(amount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Payment of $totalText recorded successfully!'),
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
