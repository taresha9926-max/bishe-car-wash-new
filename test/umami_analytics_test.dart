import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/services/umami_analytics.dart';

void main() {
  group('UmamiAnalytics Service Tests', () {
    test('trackEvent and trackView execute safely without throwing', () {
      expect(() => UmamiAnalytics.trackEvent('test_event', {'role': 'cashier'}), returnsNormally);
      expect(() => UmamiAnalytics.trackView('/cashier', 'Cashier Desk'), returnsNormally);
      expect(() => UmamiAnalytics.trackEvent('simple_event'), returnsNormally);
      expect(() => UmamiAnalytics.trackView('/welcome'), returnsNormally);
    });
  });
}
