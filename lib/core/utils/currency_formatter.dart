import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats amount to Ethiopian Birr string, e.g. "450.00 ETB" or "ETB 450"
  static String format(num amount, {bool showDecimals = false, bool prefix = false}) {
    final valueStr = showDecimals ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0);
    if (prefix) {
      return '${AppConstants.currencyCode} $valueStr';
    }
    return '$valueStr ${AppConstants.currencyCode}';
  }

  /// Format with Birr symbol 'Br 450'
  static String formatShort(num amount) {
    return '${AppConstants.currencySymbol} ${amount.toStringAsFixed(0)}';
  }
}
