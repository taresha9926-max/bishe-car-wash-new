class BankIncomingTransaction {
  final String id;
  final String provider; // 'cbe' or 'telebirr'
  final String refNo;
  final double amount;
  final String? payerName;
  final String? payerPhone;
  final String? targetAccount;
  final String? rawSms;
  final String? matchedBookingId;
  final String matchStatus; // 'unmatched', 'matched', 'discrepancy'
  final String? receiptUrl;
  final DateTime receivedAt;

  const BankIncomingTransaction({
    required this.id,
    required this.provider,
    required this.refNo,
    required this.amount,
    this.payerName,
    this.payerPhone,
    this.targetAccount,
    this.rawSms,
    this.matchedBookingId,
    this.matchStatus = 'unmatched',
    this.receiptUrl,
    required this.receivedAt,
  });

  bool get isMatched => matchStatus == 'matched' || (matchedBookingId != null && matchedBookingId!.isNotEmpty);
  bool get isUnmatched => !isMatched;
  bool get isTelebirr => provider.toLowerCase() == 'telebirr';
  bool get isCbe => provider.toLowerCase() == 'cbe' || provider.toLowerCase() == 'cbebirr';

  BankIncomingTransaction copyWith({
    String? id,
    String? provider,
    String? refNo,
    double? amount,
    String? payerName,
    String? payerPhone,
    String? targetAccount,
    String? rawSms,
    String? matchedBookingId,
    String? matchStatus,
    String? receiptUrl,
    DateTime? receivedAt,
  }) {
    return BankIncomingTransaction(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      refNo: refNo ?? this.refNo,
      amount: amount ?? this.amount,
      payerName: payerName ?? this.payerName,
      payerPhone: payerPhone ?? this.payerPhone,
      targetAccount: targetAccount ?? this.targetAccount,
      rawSms: rawSms ?? this.rawSms,
      matchedBookingId: matchedBookingId ?? this.matchedBookingId,
      matchStatus: matchStatus ?? this.matchStatus,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  factory BankIncomingTransaction.fromJson(Map<String, dynamic> json) {
    return BankIncomingTransaction(
      id: json['id']?.toString() ?? '',
      provider: json['provider']?.toString().toLowerCase() ?? 'telebirr',
      refNo: json['ref_no']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      payerName: json['payer_name']?.toString(),
      payerPhone: json['payer_phone']?.toString(),
      targetAccount: json['target_account']?.toString(),
      rawSms: json['raw_sms']?.toString(),
      matchedBookingId: json['matched_booking_id']?.toString(),
      matchStatus: json['match_status']?.toString() ?? 'unmatched',
      receiptUrl: json['receipt_url']?.toString(),
      receivedAt: json['received_at'] != null
          ? DateTime.tryParse(json['received_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'ref_no': refNo,
      'amount': amount,
      'payer_name': payerName,
      'payer_phone': payerPhone,
      'target_account': targetAccount,
      'raw_sms': rawSms,
      'matched_booking_id': matchedBookingId,
      'match_status': matchStatus,
      'receipt_url': receiptUrl,
      'received_at': receivedAt.toIso8601String(),
    };
  }
}
