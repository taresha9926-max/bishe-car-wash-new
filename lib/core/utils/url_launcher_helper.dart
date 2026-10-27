import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class UrlLauncherHelper {
  UrlLauncherHelper._();

  static void openUrl(String url) {
    if (kIsWeb) {
      try {
        html.window.open(url, '_blank');
      } catch (e) {
        debugPrint('Failed to open URL on web: $e');
      }
    } else {
      debugPrint('Launch URL: $url');
    }
  }
}
