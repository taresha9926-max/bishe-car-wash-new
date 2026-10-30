import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class UrlLauncherHelper {
  UrlLauncherHelper._();

  /// Cleans and extracts a valid URL from raw text (handling TikTok share sheet text, invisible unicode, etc.)
  static String cleanUrl(String raw) {
    if (raw.trim().isEmpty) return '';
    // 1. Strip invisible Unicode control characters (zero-width spaces, bidi marks from mobile clipboards)
    var text = raw.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u200E\u200F\u202A-\u202E]'), '').trim();

    // 2. Check for tel: or sms: protocols directly
    if (text.startsWith('tel:') || text.startsWith('sms:') || text.startsWith('mailto:')) {
      return text;
    }

    // 3. Extract first valid URL if text surrounds it (e.g. from TikTok "Share Video" text)
    final urlMatch = RegExp(r'https?://[^\s<>"]+').firstMatch(text);
    if (urlMatch != null) {
      text = urlMatch.group(0)!;
    } else {
      // If user typed domain without scheme (e.g. vt.tiktok.com/...)
      final domainMatch = RegExp(r'(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}[^\s<>"]*').firstMatch(text);
      if (domainMatch != null) {
        text = 'https://${domainMatch.group(0)!}';
      } else if (!text.startsWith('http://') && !text.startsWith('https://')) {
        text = 'https://$text';
      }
    }

    // 4. Strip trailing punctuation often copied along with links
    text = text.replaceAll(RegExp(r'[,;.!?\)]+$'), '').trim();
    return text;
  }

  static Future<bool> openUrl(String url) async {
    WidgetsFlutterBinding.ensureInitialized();
    final target = cleanUrl(url);
    if (target.isEmpty) return false;

    final uri = Uri.tryParse(target);
    if (uri == null) {
      debugPrint('Invalid URI formatted: $target');
      return false;
    }

    // 1. Try external application first (TikTok app, native map app, phone dialer)
    try {
      final ok = await ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
      if (ok) return true;
    } catch (e) {
      debugPrint('Error launching externalApplication for $target: $e');
    }

    // 2. Fallback to platform default (browser / webview)
    try {
      return await ul.launchUrl(uri, mode: ul.LaunchMode.platformDefault);
    } catch (e2) {
      debugPrint('Fallback launch failed for $target: $e2');
      return false;
    }
  }
}
