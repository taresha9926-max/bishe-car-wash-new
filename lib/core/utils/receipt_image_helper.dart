import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Shared helper to decode and render payment/deposit receipt images from
/// Data URLs (`data:image/...;base64,...`), raw base64 strings, or HTTP URLs.
class ReceiptImageHelper {
  ReceiptImageHelper._();

  static Uint8List? tryDecodeBytes(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw == 'placeholder_receipt') return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return null;
    try {
      final payload = raw.startsWith('data:image')
          ? (raw.contains(',') ? raw.substring(raw.indexOf(',') + 1) : raw)
          : raw;
      return base64Decode(payload.trim());
    } catch (_) {
      return null;
    }
  }

  static Widget buildImage(
    String? raw, {
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
    Widget? fallback,
  }) {
    final fallbackWidget = fallback ??
        const Center(
          child: Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 32),
        );
    if (raw == null || raw.trim().isEmpty) return fallbackWidget;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return Image.network(
        raw,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallbackWidget,
      );
    }

    final bytes = tryDecodeBytes(raw);
    if (bytes == null || bytes.isEmpty) return fallbackWidget;
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallbackWidget,
    );
  }
}
