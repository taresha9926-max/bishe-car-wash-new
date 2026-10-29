// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void openUrlPlatform(String url) {
  try {
    if (url.startsWith('sms:') || url.startsWith('tel:') || url.startsWith('mailto:')) {
      // On web, direct navigation or hidden anchor avoids opening an empty blank tab
      final anchor = html.AnchorElement(href: url);
      anchor.click();
    } else {
      html.window.open(url, '_blank');
    }
  } catch (e) {
    debugPrint('Failed to open URL on web: $e');
  }
}
