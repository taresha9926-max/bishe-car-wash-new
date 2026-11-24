import 'package:flutter/foundation.dart';
import 'umami_analytics_stub.dart'
    if (dart.library.js_interop) 'umami_analytics_web.dart' as platform;

/// Privacy-preserving analytics service backed by Umami
class UmamiAnalytics {
  UmamiAnalytics._();

  /// Logs a custom event (e.g. 'booking_confirmed', 'payment_received')
  static void trackEvent(String eventName, [Map<String, dynamic>? data]) {
    if (!kIsWeb) return;
    try {
      platform.platformTrackEvent(eventName, data);
    } catch (e) {
      debugPrint('UmamiAnalytics trackEvent error: $e');
    }
  }

  /// Logs a route/view transition (e.g. '/customer', '/cashier')
  static void trackView(String path, [String? title]) {
    if (!kIsWeb) return;
    try {
      platform.platformTrackView(path, title);
    } catch (e) {
      debugPrint('UmamiAnalytics trackView error: $e');
    }
  }
}
