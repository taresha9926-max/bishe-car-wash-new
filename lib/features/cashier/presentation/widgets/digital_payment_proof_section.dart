import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/receipt_ocr_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../domain/models/bank_incoming_transaction.dart';
import '../../domain/models/sentinel_config.dart';

class DigitalProofValidationResult {
  final bool ok;
  final String? transactionRef;

  const DigitalProofValidationResult({
    required this.ok,
    this.transactionRef,
  });
}

/// Shared Digital Transfer verification panel matching Car/Carpet Wash checkout:
/// Target account copy banner, 1-tap Sentinel Bank SMS match, duplicate reference
/// guard, strict mode check, and Take Photo / Upload Photo with OCR scanning.
class DigitalPaymentProofSection extends StatefulWidget {
  final dynamic state;
  final PaymentMethod selectedMethod;
  final double amountDue;
  final TextEditingController refController;
  final String? screenshotBase64;
  final ValueChanged<String?> onScreenshotChanged;
  final String? excludeBookingId;

  const DigitalPaymentProofSection({
    super.key,
    required this.state,
    required this.selectedMethod,
    required this.amountDue,
    required this.refController,
    required this.screenshotBase64,
    required this.onScreenshotChanged,
    this.excludeBookingId,
  });

  /// Enforces mandatory receipt screenshot, auto-matches unmatched Sentinel SMS,
  /// blocks duplicate/already-claimed refs, and enforces Strict Lockdown if enabled.
  static DigitalProofValidationResult validateAndResolveRef({
    required BuildContext context,
    required dynamic state,
    required PaymentMethod method,
    required double amountDue,
    required String rawRef,
    required String? screenshotBase64,
    String? excludeBookingId,
  }) {
    if (!method.isDigital) {
      return const DigitalProofValidationResult(ok: true);
    }

    if (screenshotBase64 == null || screenshotBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('pleaseUploadProof')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return const DigitalProofValidationResult(ok: false);
    }

    String refCode = rawRef.trim();
    final txs = state.bankIncomingTransactions as List<BankIncomingTransaction>;

    if (refCode.isEmpty) {
      final autoMatch = txs.where((tx) {
        if (!tx.isUnmatched) return false;
        if ((tx.amount - amountDue).abs() >= 1.0) return false;
        final providerMatches = method == PaymentMethod.telebirr ? tx.isTelebirr : tx.isCbe;
        if (!providerMatches) return false;
        return state.findDuplicateReceiptOwner(tx.refNo, excludeBookingId: excludeBookingId) == null;
      }).firstOrNull;
      if (autoMatch != null) {
        refCode = autoMatch.refNo.trim();
      }
    }

    if (refCode.isNotEmpty) {
      final dupOwner = state.findDuplicateReceiptOwner(
        refCode,
        excludeBookingId: excludeBookingId,
      ) as String?;
      if (dupOwner != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 ${state.tr("duplicateReceiptNotice")} $dupOwner'),
            backgroundColor: Colors.red.shade900,
            duration: const Duration(seconds: 5),
          ),
        );
        return const DigitalProofValidationResult(ok: false);
      }
    }

    final cleanRef = refCode.toLowerCase();
    final matchedTx = cleanRef.isNotEmpty
        ? txs.where((tx) => tx.refNo.trim().toLowerCase() == cleanRef).firstOrNull
        : null;

    if (matchedTx != null && matchedTx.isMatched && matchedTx.matchedBookingId != excludeBookingId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚨 ${state.tr("duplicateReceiptNotice")} #${matchedTx.matchedBookingId}'),
          backgroundColor: Colors.red.shade900,
          duration: const Duration(seconds: 5),
        ),
      );
      return const DigitalProofValidationResult(ok: false);
    }

    final sentinel = state.sentinelConfig as SentinelConfig;
    if (sentinel.isStrict && matchedTx == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('strictSentinelRequiredNotice')),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
      return const DigitalProofValidationResult(ok: false);
    }

    return DigitalProofValidationResult(
      ok: true,
      transactionRef: refCode.isEmpty ? null : refCode,
    );
  }

  @override
  State<DigitalPaymentProofSection> createState() => _DigitalPaymentProofSectionState();
}

class _DigitalPaymentProofSectionState extends State<DigitalPaymentProofSection> {
  bool _isScanning = false;
  String? _autoDetectedRef;

  Future<void> _handlePickedImage(PickedReceiptImage picked) async {
    final base64Data = picked.base64Data;
    if (base64Data == null || base64Data.isEmpty) return;

    widget.onScreenshotChanged(base64Data);
    setState(() {
      _isScanning = true;
      _autoDetectedRef = null;
    });

    final scannedRef = await ReceiptOcrService.scanReferenceFromBase64(
      base64Image: base64Data,
      geminiApiKey: widget.state.geminiApiKey as String?,
    );
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      if (scannedRef != null && scannedRef.isNotEmpty) {
        _autoDetectedRef = scannedRef;
        widget.refController.text = scannedRef;
      }
    });
  }

  Widget _buildReceiptPreview(String data) {
    try {
      final clean = data.contains(',') ? data.split(',').last : data;
      final bytes = base64Decode(clean);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes,
          height: 54,
          width: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded, color: AppColors.cashGreen, size: 28),
        ),
      );
    } catch (_) {
      return const Icon(Icons.image_rounded, color: AppColors.cashGreen, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.selectedMethod.isDigital) {
      return const SizedBox.shrink();
    }

    final state = widget.state;
    final sentinel = state.sentinelConfig as SentinelConfig;
    final isTelebirr = widget.selectedMethod == PaymentMethod.telebirr;
    final targetAccount = isTelebirr ? sentinel.targetTelebirrPhone : sentinel.targetCbeAccount;
    final targetName = isTelebirr ? sentinel.targetTelebirrName : sentinel.targetCbeName;
    final methodLabel = widget.selectedMethod.localizedName(state.currentLang);

    final txs = state.bankIncomingTransactions as List<BankIncomingTransaction>;
    final matchingSms = txs.where((tx) {
      if (!tx.isUnmatched) return false;
      if (state.findDuplicateReceiptOwner(tx.refNo, excludeBookingId: widget.excludeBookingId) != null) {
        return false;
      }
      final providerMatches = isTelebirr ? tx.isTelebirr : tx.isCbe;
      return providerMatches && (tx.amount - widget.amountDue).abs() < 1.0;
    }).firstOrNull;

    final enteredRef = widget.refController.text.trim();
    final dupOwner = enteredRef.isNotEmpty
        ? state.findDuplicateReceiptOwner(enteredRef, excludeBookingId: widget.excludeBookingId) as String?
        : null;
    final matchedRefTx = enteredRef.isNotEmpty
        ? txs.where((tx) => tx.refNo.trim().toLowerCase() == enteredRef.toLowerCase()).firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.selectedMethod.color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Account / Phone Banner + Copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selectedMethod.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(widget.selectedMethod.icon, color: widget.selectedMethod.color, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$methodLabel • $targetName',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        targetAccount,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: widget.selectedMethod.color),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: targetAccount));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$methodLabel: $targetAccount'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.selectedMethod.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.copy_rounded, size: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // 1-Tap Sentinel Incoming SMS Auto-Suggest
          if (matchingSms != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cashGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.cashGreen.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sms_rounded, color: AppColors.cashGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('detectedRecentBankSms'),
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.cashGreen),
                        ),
                        Text(
                          '${matchingSms.refNo} • ${CurrencyFormatter.format(matchingSms.amount)}'
                          '${(matchingSms.payerName ?? '').isNotEmpty ? ' • ${matchingSms.payerName}' : ''}',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.cashGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        widget.refController.text = matchingSms.refNo;
                      });
                    },
                    child: Text(
                      state.tr('tapToUseRef'),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Transaction Reference Input
          const SizedBox(height: 9),
          TextField(
            controller: widget.refController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: state.tr('transactionRef'),
              hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.receipt_long_rounded, size: 17, color: AppColors.textSecondary),
              filled: true,
              fillColor: const Color(0xFF1E293B),
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

          if (enteredRef.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: dupOwner != null || (sentinel.isStrict && matchedRefTx == null)
                    ? Colors.red.withValues(alpha: 0.16)
                    : (matchedRefTx != null
                        ? AppColors.cashGreen.withValues(alpha: 0.16)
                        : Colors.amber.withValues(alpha: 0.14)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    dupOwner != null
                        ? Icons.gpp_bad_rounded
                        : (matchedRefTx != null ? Icons.verified_rounded : Icons.schedule_rounded),
                    size: 14,
                    color: dupOwner != null || (sentinel.isStrict && matchedRefTx == null)
                        ? Colors.redAccent
                        : (matchedRefTx != null ? AppColors.cashGreen : Colors.amber),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dupOwner != null
                          ? '${state.tr("duplicateReceiptNotice")} $dupOwner'
                          : (matchedRefTx != null
                              ? state.tr('bankVerifiedBadge')
                              : (sentinel.isStrict
                                  ? state.tr('strictSentinelRequiredNotice')
                                  : state.tr('bankPendingSmsBadge'))),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: dupOwner != null || (sentinel.isStrict && matchedRefTx == null)
                            ? Colors.redAccent
                            : (matchedRefTx != null ? AppColors.cashGreen : Colors.amber),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Take Photo & Upload Photo Action Row
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ImagePickerHelper.takePhoto(onPicked: _handlePickedImage),
                  icon: const Icon(Icons.camera_alt_rounded, size: 15, color: Color(0xFF38BDF8)),
                  label: Text(
                    state.tr('takePhoto'),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ImagePickerHelper.pickImage(onPicked: _handlePickedImage),
                  icon: const Icon(Icons.upload_file_rounded, size: 15, color: AppColors.cashGreen),
                  label: Text(
                    state.tr('uploadPhoto'),
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.cashGreen),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cashGreen),
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          if (_isScanning) ...[
            const SizedBox(height: 7),
            Row(
              children: [
                const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.tr('scanningReceipt'),
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],

          if (_autoDetectedRef != null) ...[
            const SizedBox(height: 6),
            Text(
              '${state.tr("autoDetectedRef")}$_autoDetectedRef',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cashGreen),
            ),
          ],

          if (widget.screenshotBase64 != null && widget.screenshotBase64!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.cashGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.cashGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  _buildReceiptPreview(widget.screenshotBase64!),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.tr('receiptUploaded'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.cashGreen),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 17, color: Colors.white70),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => _autoDetectedRef = null);
                      widget.onScreenshotChanged(null);
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              '${state.tr("proofMandatoryNotice")} *',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.red.shade300),
            ),
          ],
        ],
      ),
    );
  }
}
