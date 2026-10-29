// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void openUrlPlatform(String url) {
  try {
    html.window.open(url, '_blank');
  } catch (e) {
    debugPrint('Failed to open URL on web: $e');
  }
}
