import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';

enum PaymentMethod {
  cash,
  telebirr,
  cbeBirr,
  otherBankTransfer;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash (Gate / Handover)';
      case PaymentMethod.telebirr:
        return 'Telebirr (Ethio Telecom)';
      case PaymentMethod.cbeBirr:
        return 'CBE Birr (Commercial Bank)';
      case PaymentMethod.otherBankTransfer:
        return 'Bank Transfer / Mobile Banking';
    }
  }

  String get shortName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.cbeBirr:
        return 'CBE Birr';
      case PaymentMethod.otherBankTransfer:
        return 'Bank Transfer';
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
      case PaymentMethod.otherBankTransfer:
        return Icons.credit_card_rounded;
    }
  }

  bool get isDigital => this != PaymentMethod.cash;
}

class PaymentInfo {
  final bool isPaid;
  final PaymentMethod method;
  final double amount;
  final String? transactionRef;
  final DateTime? paidAt;

  const PaymentInfo({
    this.isPaid = false,
    this.method = PaymentMethod.cash,
    required this.amount,
    this.transactionRef,
    this.paidAt,
  });

  PaymentInfo copyWith({
    bool? isPaid,
    PaymentMethod? method,
    double? amount,
    String? transactionRef,
    DateTime? paidAt,
  }) {
    return PaymentInfo(
      isPaid: isPaid ?? this.isPaid,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      transactionRef: transactionRef ?? this.transactionRef,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
