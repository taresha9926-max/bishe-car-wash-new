class BankDepositRecord {
  final String id;
  final double amount;
  final String accountKey; // 'account_a' or 'account_b'
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String referenceSlipNumber;
  final String? receiptScreenshot; // Base64 data URL or receipt URL
  final DateTime depositedAt;
  final String cashierName;
  final String? notes;

  const BankDepositRecord({
    required this.id,
    required this.amount,
    required this.accountKey,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.referenceSlipNumber,
    this.receiptScreenshot,
    required this.depositedAt,
    required this.cashierName,
    this.notes,
  });

  String get targetAccount => '$bankName ($accountName)';
  String get bankSlipNumber => referenceSlipNumber;
  String? get receiptImageUrl => receiptScreenshot;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'accountKey': accountKey,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'referenceSlipNumber': referenceSlipNumber,
      'receiptScreenshot': receiptScreenshot,
      'depositedAt': depositedAt.toIso8601String(),
      'cashierName': cashierName,
      'notes': notes,
    };
  }

  factory BankDepositRecord.fromMap(Map<String, dynamic> map) {
    return BankDepositRecord(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      accountKey: map['accountKey'] ?? 'account_a',
      accountName: map['accountName'] ?? 'Owner Account A',
      accountNumber: map['accountNumber'] ?? '',
      bankName: map['bankName'] ?? 'CBE',
      referenceSlipNumber: map['referenceSlipNumber'] ?? '',
      receiptScreenshot: map['receiptScreenshot'],
      depositedAt: DateTime.tryParse(map['depositedAt'] ?? '') ?? DateTime.now(),
      cashierName: map['cashierName'] ?? 'Cashier',
      notes: map['notes'],
    );
  }
}
