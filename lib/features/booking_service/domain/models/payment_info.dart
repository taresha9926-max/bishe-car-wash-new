import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';

enum PaymentMethod {
  cash,
  telebirr,
  cbeBirr,
  bankOfAbyssinia,
  awashBank,
  dashenBank,
  otherBankTransfer;

  String localizedName(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case PaymentMethod.cash:
        return AppStrings.get('payCash', lang);
      case PaymentMethod.telebirr:
        return AppStrings.get('payTelebirr', lang);
      case PaymentMethod.cbeBirr:
        return AppStrings.get('payCbeBirr', lang);
      case PaymentMethod.bankOfAbyssinia:
        return AppStrings.get('payBankOfAbyssinia', lang);
      case PaymentMethod.awashBank:
        return AppStrings.get('payAwashBank', lang);
      case PaymentMethod.dashenBank:
        return AppStrings.get('payDashenBank', lang);
      case PaymentMethod.otherBankTransfer:
        return AppStrings.get('payBank', lang);
    }
  }

  String get displayName => localizedName('EN');

  String get shortName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.cbeBirr:
        return 'CBE Birr';
      case PaymentMethod.bankOfAbyssinia:
        return 'Bank of Abyssinia';
      case PaymentMethod.awashBank:
        return 'Awash Bank';
      case PaymentMethod.dashenBank:
        return 'Dashen Bank';
      case PaymentMethod.otherBankTransfer:
        return 'Other Bank';
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.cash:
        return AppColors.cashGreen;
      case PaymentMethod.telebirr:
        return AppColors.telebirrBlue;
      case PaymentMethod.cbeBirr:
        return AppColors.cbeBirrPurple;
      case PaymentMethod.bankOfAbyssinia:
        return const Color(0xFFF59E0B); // Amber / Gold for BoA
      case PaymentMethod.awashBank:
        return const Color(0xFFEA580C); // Warm Orange for Awash
      case PaymentMethod.dashenBank:
        return const Color(0xFF0284C7); // Deep Blue for Dashen
      case PaymentMethod.otherBankTransfer:
        return Colors.indigo;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.telebirr:
        return Icons.phone_android_rounded;
      case PaymentMethod.cbeBirr:
        return Icons.account_balance_rounded;
      case PaymentMethod.bankOfAbyssinia:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.awashBank:
        return Icons.account_balance_rounded;
      case PaymentMethod.dashenBank:
        return Icons.credit_card_rounded;
      case PaymentMethod.otherBankTransfer:
        return Icons.sync_alt_rounded;
    }
  }

  bool get isDigital => this != PaymentMethod.cash;
}

class PaymentInfo {
  final bool isPaid;
  final PaymentMethod method;
  final double amount;
  final String? transactionRef;
  final String? receiptScreenshot; // Base64 or receipt URL
  final DateTime? paidAt;

  const PaymentInfo({
    this.isPaid = false,
    this.method = PaymentMethod.cash,
    required this.amount,
    this.transactionRef,
    this.receiptScreenshot,
    this.paidAt,
  });

  PaymentInfo copyWith({
    bool? isPaid,
    PaymentMethod? method,
    double? amount,
    String? transactionRef,
    String? receiptScreenshot,
    DateTime? paidAt,
  }) {
    return PaymentInfo(
      isPaid: isPaid ?? this.isPaid,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      transactionRef: transactionRef ?? this.transactionRef,
      receiptScreenshot: receiptScreenshot ?? this.receiptScreenshot,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
