import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Dedicated OCR Service to extract Telebirr and CBE transaction reference codes
/// from payment receipt screenshots using multimodal vision with zero fluff.
class ReceiptOcrService {
  ReceiptOcrService._();

  static const List<String> _visionModels = [
    'gemini-flash-lite-latest',
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash-lite',
    'gemini-flash-latest',
    'gemini-2.5-flash',
  ];

  /// Scans receipt base64 image for Telebirr / CBE transaction references
  static Future<String?> scanReferenceFromBase64({
    required String base64Image,
    required String? geminiApiKey,
  }) async {
    if (geminiApiKey == null || geminiApiKey.trim().isEmpty) {
      return null;
    }

    try {
      // Clean base64 string
      String cleanBase64 = base64Image;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

      for (final model in _visionModels) {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey',
        );

        final payload = jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are an OCR receipt scanner for Ethiopian digital payments (Telebirr and Commercial Bank of Ethiopia CBE). '
                      'Extract the 8-to-15 character alphanumeric transaction reference number (e.g. Telebirr code starting with DKK or CBE transaction starting with FT, or receipt transaction number). '
                      'Return ONLY the exact alphanumeric reference string in plain text without any explanation, markdown, punctuation or quotes. If none found, reply NONE.',
                },
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': cleanBase64,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 30,
          }
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final rawText = (parts[0]['text'] as String?)?.trim() ?? '';
              final clean = rawText.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
              if (clean.isNotEmpty && clean.toLowerCase() != 'none' && clean.length >= 6) {
                return clean;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('ReceiptOcrService error: $e');
    }
    return null;
  }
}
