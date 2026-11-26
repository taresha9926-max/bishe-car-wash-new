import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';
import '../../features/booking_service/domain/models/wash_booking.dart';

/// Shared helper to decode and render payment/deposit receipt images from
/// Data URLs (`data:image/...;base64,...`), raw base64 strings, or HTTP URLs.
class ReceiptImageHelper {
  ReceiptImageHelper._();

  /// Checks if the provided raw string is an HTTP or HTTPS web URL.
  static bool isWebUrl(String? raw) {
    if (raw == null) return false;
    final trimmed = raw.trim().toLowerCase();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  /// Robustly decodes Base64 data from a raw string, stripping Data URL headers,
  /// replacing HTTP space corruption with `+`, stripping newlines, and normalizing padding.
  static Uint8List? tryDecodeBytes(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'placeholder_receipt') return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return null;

    try {
      String payload = trimmed;
      // Strip any Data URL prefix (e.g. data:image/jpeg;base64, or data:application/octet-stream;base64,)
      if (payload.contains(',')) {
        payload = payload.substring(payload.indexOf(',') + 1);
      }
      // Sanitize: remove newlines, carriage returns, tabs, and repair space corruption
      payload = payload
          .replaceAll('\r', '')
          .replaceAll('\n', '')
          .replaceAll('\t', '')
          .replaceAll(' ', '+');
      
      // Normalize Base64 padding
      payload = base64.normalize(payload);
      final decoded = base64Decode(payload);
      return decoded.isNotEmpty ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Launches a web receipt portal URL safely in an external browser.
  static Future<void> launchWebReceipt(String url) async {
    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching web receipt: $e');
    }
  }

  /// Builds an image widget or an interactive receipt preview card.
  static Widget buildImage(
    String? raw, {
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
    Widget? fallback,
    WashBooking? bookingContext,
  }) {
    final fallbackWidget = fallback ??
        const Center(
          child: Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 32),
        );

    if (raw == null || raw.trim().isEmpty) {
      if (bookingContext != null) {
        return _buildPlaceholderReceiptCard(bookingContext, fallbackWidget);
      }
      return fallbackWidget;
    }

    final trimmed = raw.trim();

    // 1. Web Link (Telebirr portal, CBE mobile receipt portal, or CDN URL)
    if (isWebUrl(trimmed)) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, __) {
          // If network image fails (CORS on web or HTML portal URL), show interactive web portal card
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new_rounded, color: AppColors.telebirrBlue, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Online Bank / Telebirr Receipt Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trimmed,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => launchWebReceipt(trimmed),
                    icon: const Icon(Icons.launch_rounded, size: 15),
                    label: const Text('Open Official Portal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.telebirrBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (bookingContext != null) ...[
                    const SizedBox(height: 14),
                    _buildPlaceholderReceiptCard(bookingContext, const SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    // 2. Placeholder or stub string
    if (trimmed == 'placeholder_receipt') {
      return _buildPlaceholderReceiptCard(bookingContext, fallbackWidget);
    }

    // 3. Decode base64 image bytes
    final bytes = tryDecodeBytes(trimmed);
    if (bytes == null || bytes.isEmpty) {
      if (bookingContext != null) {
        return _buildPlaceholderReceiptCard(bookingContext, fallbackWidget);
      }
      return fallbackWidget;
    }

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, _, __) {
        if (bookingContext != null) {
          return _buildPlaceholderReceiptCard(bookingContext, fallbackWidget);
        }
        return fallbackWidget;
      },
    );
  }

  /// Stylized official station digital receipt proof card.
  static Widget _buildPlaceholderReceiptCard(WashBooking? b, Widget fallback) {
    if (b == null) return fallback;
    final method = b.payment.method;
    final paidAmount = b.payment.amount > 0 ? b.payment.amount : b.totalPrice;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161A26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warmGold.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: method.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(method.icon, color: method.color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BISHE CAR WASH STATION',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                      ),
                      Text(
                        'Verified Digital Payment Record',
                        style: TextStyle(fontSize: 10, color: AppColors.telebirrBlue, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: Colors.white24),
            _infoRow('License Plate', b.licensePlate),
            _infoRow('Customer', b.customerName),
            _infoRow('Payment Method', method.displayName),
            _infoRow('Amount Paid', CurrencyFormatter.format(paidAmount)),
            _infoRow('Transaction Ref', b.payment.transactionRef ?? 'CASHIER-CONFIRMED'),
            _infoRow('Status', b.payment.isBankVerified ? 'Bank Verified' : 'Station Confirmed'),
            _infoRow('Date & Time', DateFormatter.formatDate(b.payment.paidAt ?? b.createdAt)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✓ Proof verified and archived at Bishoftu Station',
                style: TextStyle(fontSize: 10, color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays an interactive digital receipt dialog for a completed or paid booking.
  static Future<void> showDigitalReceiptDialog(BuildContext context, WashBooking booking, {dynamic state}) async {
    final imageWidget = buildImage(
      booking.payment.receiptScreenshot,
      bookingContext: booking,
      fit: BoxFit.contain,
    );

    final title = state != null ? state.tr('digitalReceiptTitle') : 'Digital Receipt & Payment Voucher';
    final closeText = state != null ? state.tr('close') : 'Close';

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: const Color(0xFF10131C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warmGold.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: AppColors.liquidCyanNeon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: imageWidget,
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161A26),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(closeText, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
