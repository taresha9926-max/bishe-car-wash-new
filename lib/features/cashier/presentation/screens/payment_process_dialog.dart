import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/receipt_ocr_service.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth_roles/domain/models/user_role.dart';
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
  final _tipController = TextEditingController();
  final _agreedPriceController = TextEditingController();
  final _splitCashController = TextEditingController();
  final _splitDigitalController = TextEditingController();

  bool _isProcessing = false;
  bool _isSplitPayment = false;
  bool _isScanningReceipt = false;
  String? _uploadedScreenshotName;
  String? _screenshotBase64;
  double _tipAmount = 0.0;
  String _overpaymentAction = 'refund_cash'; // 'refund_cash' or 'washer_tip'

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.booking.payment.method == PaymentMethod.cash
        ? PaymentMethod.cash
        : widget.booking.payment.method;
    _agreedPriceController.text = widget.booking.totalPrice.toStringAsFixed(0);
    _tipAmount = widget.booking.payment.tipAmount;
    if (_tipAmount > 0) {
      _tipController.text = _tipAmount.toStringAsFixed(0);
    }

    // Default split values if split payment is toggled
    final half = (widget.booking.totalPrice / 2).roundToDouble();
    _splitCashController.text = half.toStringAsFixed(0);
    _splitDigitalController.text = (widget.booking.totalPrice - half).toStringAsFixed(0);
  }

  @override
  void dispose() {
    _refCodeController.dispose();
    _tipController.dispose();
    _agreedPriceController.dispose();
    _splitCashController.dispose();
    _splitDigitalController.dispose();
    super.dispose();
  }

  void _onImageLoaded(PickedReceiptImage img) async {
    setState(() {
      _uploadedScreenshotName = img.name;
      _screenshotBase64 = img.base64Data;
    });

    // Auto-scan reference number if not manually entered
    if (_refCodeController.text.trim().isEmpty && img.base64Data != null && mounted) {
      final state = AppStateProvider.read(context);
      setState(() {
        _isScanningReceipt = true;
      });
      try {
        final scannedRef = await ReceiptOcrService.scanReferenceFromBase64(
          base64Image: img.base64Data!,
          geminiApiKey: state.geminiApiKey,
        );
        if (mounted && scannedRef != null && scannedRef.isNotEmpty) {
          setState(() {
            _refCodeController.text = scannedRef;
          });
          try {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              SnackBar(
                content: Text('${state.tr("autoDetectedRef")}$scannedRef'),
                backgroundColor: AppColors.cashGreen,
                duration: const Duration(seconds: 3),
              ),
            );
          } catch (_) {}
        }
      } finally {
        if (mounted) {
          setState(() {
            _isScanningReceipt = false;
          });
        }
      }
    }
  }

  void _pickScreenshot() {
    ImagePickerHelper.pickImage(onPicked: _onImageLoaded);
  }

  void _takePhoto() {
    ImagePickerHelper.takePhoto(onPicked: _onImageLoaded);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final liveBooking = state.bookings.where((b) => b.id == widget.booking.id).firstOrNull ?? widget.booking;
    final isAlreadyPaid = liveBooking.payment.isPaid;
    final parsedAgreed = double.tryParse(_agreedPriceController.text.trim());
    final amountDue = (parsedAgreed != null && parsedAgreed > 0) ? parsedAgreed : liveBooking.totalPrice;

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
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.point_of_sale_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            state.tr('paymentDialogTitle'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),

              if (isAlreadyPaid)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('paymentAlreadyCollected'),
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.tr("doubleCollectionDisabled")} (${liveBooking.payment.method.localizedName(state.currentLang)}: ${CurrencyFormatter.format(liveBooking.payment.amount)})',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: widget.booking.isCarpet
                              ? (widget.booking.carpetType == 'type_b' ? AutoCareAssets.carpetTypeBUrl : AutoCareAssets.carpetTypeAUrl)
                              : AutoCareAssets.carSedanUrl,
                          width: 36,
                          height: 36,
                          borderRadius: 8,
                          fallbackIcon: widget.booking.isCarpet ? Icons.texture_rounded : Icons.directions_car_rounded,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.booking.isCarpet
                                ? '${state.tr("carpetService")}: ${widget.booking.carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
                                : '${state.tr("licensePlate")}: ${widget.booking.licensePlate}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
              const SizedBox(height: 12),

              // Cashier Negotiable Final Price Adjustment (matches customer "Prices are negotiable" flow)
              TextField(
                controller: _agreedPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: state.tr('finalNegotiatedPriceEtb'),
                  helperText: '${state.tr("bookedReferenceTariff")}: ${CurrencyFormatter.format(widget.booking.totalPrice)}',
                  prefixIcon: const Icon(Icons.handshake_outlined, size: 18, color: AppColors.primary),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

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
                        Expanded(
                          child: Text(
                            state.tr('washersTip'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.amber.shade900),
                          ),
                        ),
                        if (_tipAmount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '+ETB ${_tipAmount.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.amber.shade900),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final tipVal in [50, 100, 200])
                          ChoiceChip(
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
                        SizedBox(
                          width: 110,
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const SizedBox(height: 14),

              // Mode Toggle: Standard Method vs Split Payment
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isSplitPayment ? AppColors.primary : AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.call_split_rounded,
                            size: 18,
                            color: _isSplitPayment ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.tr('splitPayment'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _isSplitPayment ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isSplitPayment,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _isSplitPayment = val;
                          if (val) {
                            final half = (amountDue / 2).roundToDouble();
                            _splitCashController.text = half.toStringAsFixed(0);
                            _splitDigitalController.text = (amountDue - half).toStringAsFixed(0);
                            if (_selectedMethod == PaymentMethod.cash) {
                              _selectedMethod = PaymentMethod.telebirr;
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              if (_isSplitPayment) ...[
                // Split Payment Inputs
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _splitCashController,
                        label: state.tr('cashPortion'),
                        hint: 'e.g. 200',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_rounded,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: _splitDigitalController,
                        label: state.tr('digitalPortion'),
                        hint: 'e.g. 300',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.phone_android_rounded,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Digital Channel for Split Payment:',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildOption(PaymentMethod.telebirr, state.tr('payTelebirr')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOption(PaymentMethod.cbeBirr, state.tr('payCbeBirr')),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  state.tr('paymentMethod'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),

                // Payment Options
                _buildOption(PaymentMethod.cash, state.tr('payCash')),
                _buildOption(PaymentMethod.telebirr, state.tr('payTelebirr')),
                _buildOption(PaymentMethod.cbeBirr, state.tr('payCbeBirr')),
                _buildOption(PaymentMethod.bankOfAbyssinia, state.tr('payBankOfAbyssinia')),
                _buildOption(PaymentMethod.awashBank, state.tr('payAwashBank')),
                _buildOption(PaymentMethod.dashenBank, state.tr('payDashenBank')),
                _buildOption(PaymentMethod.otherBankTransfer, state.tr('payBank')),
              ],

              // Target Account Notice Banner
              if (_selectedMethod.isDigital || _isSplitPayment) ...[
                const SizedBox(height: 10),
                Builder(
                  builder: (ctx) {
                    final isTelebirr = _selectedMethod == PaymentMethod.telebirr;
                    final sentinel = state.sentinelConfig;
                    final targetNumber = isTelebirr
                        ? (sentinel?.targetTelebirrPhone ?? '0962274450')
                        : (sentinel?.targetCbeAccount ?? '1000542824388');
                    final targetName = isTelebirr
                        ? (sentinel?.targetTelebirrName ?? 'Tariku Gebretsadike')
                        : (sentinel?.targetCbeName ?? 'Tariku G/tsadik G/silase');
                    final providerTitle = isTelebirr ? 'Telebirr' : 'CBE';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: (isTelebirr ? AppColors.telebirrBlue : AppColors.cbeBirrPurple).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isTelebirr ? AppColors.telebirrBlue : AppColors.cbeBirrPurple).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isTelebirr ? Icons.phone_android_rounded : Icons.account_balance_rounded,
                            color: isTelebirr ? AppColors.telebirrBlue : AppColors.cbeBirrPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$providerTitle: $targetNumber',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                Text(
                                  targetName,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white70),
                            tooltip: 'Copy Number',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: targetNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied $providerTitle account ($targetNumber) to clipboard'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              // Overpayment Prompt (if paid > reference tariff)
              if (parsedAgreed != null && parsedAgreed > widget.booking.totalPrice) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade400, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.lightBlueAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${state.tr("overpaymentDetected")}: +ETB ${(parsedAgreed - widget.booking.totalPrice).toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.lightBlueAccent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(state.tr('refundCashDrawer'), style: const TextStyle(fontSize: 11)),
                            value: 'refund_cash',
                            groupValue: _overpaymentAction,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setState(() => _overpaymentAction = val ?? 'refund_cash'),
                          ),
                          RadioListTile<String>(
                            title: Text(state.tr('addAsWasherTip'), style: const TextStyle(fontSize: 11)),
                            value: 'washer_tip',
                            groupValue: _overpaymentAction,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setState(() => _overpaymentAction = val ?? 'washer_tip'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Digital Payment Fields & Sentinel Live Verification
              if (_selectedMethod.isDigital || _isSplitPayment) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2415),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warmAmberSunset.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, size: 18, color: AppColors.warmAmberSunset),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.tr('proofMandatoryNotice'),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade200),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _refCodeController,
                  label: state.tr('transactionRef'),
                  hint: 'e.g. DKK0G3C37O or FT263237JRB8',
                  prefixIcon: Icons.confirmation_number_outlined,
                  onChanged: (_) => setState(() {}),
                ),

                // Intelligent 1-Tap Auto-Suggest from Sentinel
                Builder(
                  builder: (ctx) {
                    final digitalDue = _isSplitPayment
                        ? (double.tryParse(_splitDigitalController.text.trim()) ?? 0.0)
                        : amountDue;
                    final targetProvider = _selectedMethod.name.toLowerCase();
                    final matchingIncoming = state.bankIncomingTransactions.where((tx) =>
                      tx.isUnmatched &&
                      tx.provider.toLowerCase() == targetProvider &&
                      (tx.amount - digitalDue).abs() < 1.0
                    ).firstOrNull;

                    if (matchingIncoming != null && _refCodeController.text.trim().isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _refCodeController.text = matchingIncoming.refNo;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${state.tr("detectedRecentBankSms")}: ${matchingIncoming.refNo} (ETB ${matchingIncoming.amount.toStringAsFixed(0)})',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.greenAccent),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade900.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    state.tr('tapToUseRef'),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.amberAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // OCR Scanning Progress indicator
                if (_isScanningReceipt) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.tr('scanningReceipt'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Live Bank Cross-Reference Status Banner
                Builder(
                  builder: (ctx) {
                    final cleanRef = _refCodeController.text.trim().toLowerCase();
                    if (cleanRef.isEmpty) return const SizedBox.shrink();

                    // Check duplicate receipt usage across station bookings
                    final duplicateBooking = state.bookings.where((b) =>
                      b.id != widget.booking.id &&
                      b.payment.transactionRef != null &&
                      b.payment.transactionRef!.trim().toLowerCase() == cleanRef
                    ).firstOrNull;

                    if (duplicateBooking != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF450A0A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.block_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '🚨 DUPLICATE RECEIPT: Already used for ${duplicateBooking.licensePlate} (${duplicateBooking.customerName})!',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final matchedTx = state.bankIncomingTransactions
                        .where((tx) => tx.refNo.trim().toLowerCase() == cleanRef)
                        .firstOrNull;

                    if (matchedTx != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.statusCompleted),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${state.tr("bankVerifiedBadge")}: ETB ${CurrencyFormatter.format(matchedTx.amount)} (${matchedTx.payerName ?? "Customer"})',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.greenAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // No match yet
                    if (state.sentinelConfig?.isStrict == true) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade400),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.tr('policyStrictMode'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top_rounded, color: Colors.amberAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.tr('bankPendingSmsBadge'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.amberAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Digital Receipt Proof: Take Photo (Camera) or Upload File
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(
                          state.tr('takePhoto'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0284C7),
                          side: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickScreenshot,
                        icon: const Icon(Icons.upload_file_rounded, size: 18),
                        label: Text(
                          state.tr('uploadPhoto'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                          side: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_uploadedScreenshotName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cashGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cashGreen, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.cashGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attached: $_uploadedScreenshotName',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cashGreen),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() {
                            _uploadedScreenshotName = null;
                            _screenshotBase64 = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Text(
                    '${state.tr("proofMandatoryNotice")} *',
                    style: TextStyle(fontSize: 10.5, color: Colors.red.shade400, fontWeight: FontWeight.w600),
                  ),
                ],
                if (_isScanningReceipt)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('AI Scanning receipt reference...', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 20),

              // Action Buttons
              if (isAlreadyPaid)
                CustomButton(
                  text: '${state.tr("settledPaidBadge")} (${state.tr("close")})',
                  icon: Icons.check_circle_rounded,
                  backgroundColor: const Color(0xFF064E3B),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                )
              else
                CustomButton(
                  text: state.tr('confirmAndPay'),
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.cashGreen,
                  isLoading: _isProcessing,
                  onPressed: (_isProcessing || isAlreadyPaid) ? null : () => _handlePaymentConfirm(context, amountDue),
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
          color: isSelected ? method.color.withValues(alpha: 0.18) : const Color(0xFF1E293B),
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? method.color : Colors.white,
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
    if (_isProcessing) return;

    final state = AppStateProvider.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    final liveBooking = state.bookings.where((b) => b.id == widget.booking.id).firstOrNull ?? widget.booking;
    if (liveBooking.payment.isPaid) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('🚨 ${state.tr("paymentAlreadyCollected")}! ${state.tr("doubleCollectionDisabled")}'),
          backgroundColor: Colors.orange.shade900,
        ),
      );
      if (mounted && navigator.canPop()) {
        navigator.pop();
      }
      return;
    }

    double splitCash = 0.0;
    double splitDigital = 0.0;

    if (_isSplitPayment) {
      splitCash = double.tryParse(_splitCashController.text.trim()) ?? 0.0;
      splitDigital = double.tryParse(_splitDigitalController.text.trim()) ?? 0.0;

      if ((splitCash + splitDigital - amount).abs() > 0.5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('splitTotalMismatch')),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
    }

    final isDigitalOrSplitDigital = (!_isSplitPayment && _selectedMethod.isDigital) ||
        (_isSplitPayment && splitDigital > 0);

    if (isDigitalOrSplitDigital) {
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

    String? refCode = isDigitalOrSplitDigital && _refCodeController.text.trim().isNotEmpty
        ? _refCodeController.text.trim()
        : null;

    // If reference was omitted, check if Sentinel already captured an exact matching bank SMS
    if (refCode == null && isDigitalOrSplitDigital) {
      final digitalAmount = _isSplitPayment ? splitDigital : amount;
      final autoMatch = state.bankIncomingTransactions.where((tx) =>
        tx.isUnmatched &&
        tx.provider.toLowerCase() == _selectedMethod.name.toLowerCase() &&
        (tx.amount - digitalAmount).abs() < 1.0
      ).firstOrNull;
      if (autoMatch != null) {
        refCode = autoMatch.refNo;
      }
    }

    // Check against live incoming bank transactions
    final cleanRef = (refCode ?? '').trim().toLowerCase();

    // Strict Double Receipt Reference Protection (Bookings, Retail, and Shower)
    if (isDigitalOrSplitDigital && cleanRef.isNotEmpty) {
      final dupOwner = state.findDuplicateReceiptOwner(
        refCode!,
        excludeBookingId: widget.booking.id,
      ) as String?;

      if (dupOwner != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🚨 ${state.tr("duplicateReceiptNotice")} $dupOwner',
            ),
            backgroundColor: Colors.red.shade900,
            duration: const Duration(seconds: 6),
          ),
        );
        return;
      }
    }

    final matchedTx = cleanRef.isNotEmpty
        ? state.bankIncomingTransactions
            .where((tx) => tx.refNo.trim().toLowerCase() == cleanRef)
            .firstOrNull
        : null;

    // 2. Block if this bank SMS was already claimed by another completed wash
    if (matchedTx != null && matchedTx.isMatched && matchedTx.matchedBookingId != null && matchedTx.matchedBookingId != widget.booking.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚨 REUSED BANK SMS BLOCKED: Bank reference "$refCode" was already claimed by booking #${matchedTx.matchedBookingId}!',
          ),
          backgroundColor: Colors.red.shade900,
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    // Enforce Policy 2 (Strict Lockdown)
    if (isDigitalOrSplitDigital && state.sentinelConfig.isStrict && matchedTx == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${state.tr("policyStrictMode")}: Bank credit SMS must be received by Sentinel before vehicle release.'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final verificationStatus = matchedTx != null
        ? 'verified'
        : (isDigitalOrSplitDigital ? 'pending_sms' : 'unverified');

    setState(() {
      _isProcessing = true;
    });

    final collectorRole = state.currentRole == UserRole.manager ? 'operationalManager' : 'cashier';
    final collectorName = state.activeStaffFullName ?? (state.currentRole == UserRole.manager ? 'Operational Manager' : 'Cashier');

    try {
      await state.processPayment(
        bookingId: widget.booking.id,
        method: _isSplitPayment ? PaymentMethod.cash : _selectedMethod,
        amount: amount,
        tipAmount: _tipAmount,
        transactionRef: refCode,
        receiptScreenshot: _screenshotBase64,
        splitCashAmount: _isSplitPayment ? splitCash : 0.0,
        splitDigitalAmount: _isSplitPayment ? splitDigital : 0.0,
        overpaymentAction: _overpaymentAction,
        verificationStatus: verificationStatus,
        collectedByRole: collectorRole,
        collectedByName: collectorName,
      );

      if (mounted && navigator.canPop()) {
        navigator.pop();
      }

      final totalText = _tipAmount > 0
          ? '${CurrencyFormatter.format(amount + _tipAmount)} (includes ETB ${_tipAmount.toStringAsFixed(0)} tip)'
          : CurrencyFormatter.format(amount);
      try {
        messenger.showSnackBar(
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
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        try {
          messenger.showSnackBar(
            SnackBar(content: Text('Payment error: $e'), backgroundColor: Colors.red),
          );
        } catch (_) {}
      }
    }
  }
}
