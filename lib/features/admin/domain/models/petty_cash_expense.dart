class PettyCashExpense {
  final String id;
  final double amount;
  final String category;
  final String reason;
  final String? receiptScreenshot;
  final String loggedByCashier;
  final DateTime loggedAt;

  const PettyCashExpense({
    required this.id,
    required this.amount,
    required this.category,
    required this.reason,
    this.receiptScreenshot,
    required this.loggedByCashier,
    required this.loggedAt,
  });

  String get cashierName => loggedByCashier;
  String? get voucherScreenshot => receiptScreenshot;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'reason': reason,
    'receipt_screenshot': receiptScreenshot,
    'logged_by_cashier': loggedByCashier,
    'logged_at': loggedAt.toIso8601String(),
  };

  factory PettyCashExpense.fromJson(Map<String, dynamic> json) => PettyCashExpense(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String? ?? 'General Expense',
    reason: json['reason'] as String? ?? '',
    receiptScreenshot: json['receipt_screenshot'] as String?,
    loggedByCashier: json['logged_by_cashier'] as String? ?? 'Cashier',
    loggedAt: json['logged_at'] != null
        ? DateTime.parse(json['logged_at'] as String)
        : DateTime.now(),
  );
}
