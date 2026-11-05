class DailyFinancialClosing {
  final String id;
  final DateTime closingDate;
  final DateTime closedAt;
  final String cashierName;
  final double grossRevenue;
  final double cashRevenue;
  final double digitalRevenue;
  final Map<String, double> providerBreakdown;
  final int carsWashedCount;
  final double commissionPool;
  final double netStationProfit;
  final double cashDeposited;
  final double pettyCashExpenses;
  final double cashRemaining;
  final Map<String, double> washerDividends;
  final String? notes;
  final bool isConfirmed;
  final String shiftType; // 'day' or 'night'
  final String closedByRole; // 'cashier' or 'manager'
  final String handoverTo; // 'Operational Manager' or 'Admin / Owner'
  final double handoverCashAmount;
  final bool isHandoverAccepted;
  final String? acceptedByName;
  final DateTime? acceptedAt;
  final double carriedCashAmount;

  const DailyFinancialClosing({
    required this.id,
    required this.closingDate,
    required this.closedAt,
    required this.cashierName,
    required this.grossRevenue,
    required this.cashRevenue,
    required this.digitalRevenue,
    required this.providerBreakdown,
    required this.carsWashedCount,
    required this.commissionPool,
    required this.netStationProfit,
    required this.cashDeposited,
    this.pettyCashExpenses = 0.0,
    required this.cashRemaining,
    required this.washerDividends,
    this.notes,
    this.isConfirmed = true,
    this.shiftType = 'day',
    this.closedByRole = 'cashier',
    this.handoverTo = 'Operational Manager',
    this.handoverCashAmount = 0.0,
    this.isHandoverAccepted = false,
    this.acceptedByName,
    this.acceptedAt,
    this.carriedCashAmount = 0.0,
  });

  DailyFinancialClosing copyWith({
    bool? isHandoverAccepted,
    String? acceptedByName,
    DateTime? acceptedAt,
    bool? isConfirmed,
  }) {
    return DailyFinancialClosing(
      id: id,
      closingDate: closingDate,
      closedAt: closedAt,
      cashierName: cashierName,
      grossRevenue: grossRevenue,
      cashRevenue: cashRevenue,
      digitalRevenue: digitalRevenue,
      providerBreakdown: providerBreakdown,
      carsWashedCount: carsWashedCount,
      commissionPool: commissionPool,
      netStationProfit: netStationProfit,
      cashDeposited: cashDeposited,
      pettyCashExpenses: pettyCashExpenses,
      cashRemaining: cashRemaining,
      washerDividends: washerDividends,
      notes: notes,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      shiftType: shiftType,
      closedByRole: closedByRole,
      handoverTo: handoverTo,
      handoverCashAmount: handoverCashAmount,
      isHandoverAccepted: isHandoverAccepted ?? this.isHandoverAccepted,
      acceptedByName: acceptedByName ?? this.acceptedByName,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      carriedCashAmount: carriedCashAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'closingDate': closingDate.toIso8601String(),
      'closedAt': closedAt.toIso8601String(),
      'cashierName': cashierName,
      'grossRevenue': grossRevenue,
      'cashRevenue': cashRevenue,
      'digitalRevenue': digitalRevenue,
      'providerBreakdown': providerBreakdown,
      'carsWashedCount': carsWashedCount,
      'commissionPool': commissionPool,
      'netStationProfit': netStationProfit,
      'cashDeposited': cashDeposited,
      'pettyCashExpenses': pettyCashExpenses,
      'cashRemaining': cashRemaining,
      'washerDividends': washerDividends,
      'notes': notes,
      'isConfirmed': isConfirmed,
      'shiftType': shiftType,
      'closedByRole': closedByRole,
      'handoverTo': handoverTo,
      'handoverCashAmount': handoverCashAmount,
      'isHandoverAccepted': isHandoverAccepted,
      'acceptedByName': acceptedByName,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'carriedCashAmount': carriedCashAmount,
    };
  }

  factory DailyFinancialClosing.fromMap(Map<String, dynamic> map) {
    return DailyFinancialClosing(
      id: map['id'] ?? '',
      closingDate: DateTime.tryParse(map['closingDate'] ?? '') ?? DateTime.now(),
      closedAt: DateTime.tryParse(map['closedAt'] ?? '') ?? DateTime.now(),
      cashierName: map['cashierName'] ?? 'Cashier',
      grossRevenue: (map['grossRevenue'] as num?)?.toDouble() ?? 0.0,
      cashRevenue: (map['cashRevenue'] as num?)?.toDouble() ?? 0.0,
      digitalRevenue: (map['digitalRevenue'] as num?)?.toDouble() ?? 0.0,
      providerBreakdown: Map<String, double>.from(map['providerBreakdown'] ?? {}),
      carsWashedCount: map['carsWashedCount'] ?? 0,
      commissionPool: (map['commissionPool'] as num?)?.toDouble() ?? 0.0,
      netStationProfit: (map['netStationProfit'] as num?)?.toDouble() ?? 0.0,
      cashDeposited: (map['cashDeposited'] as num?)?.toDouble() ?? 0.0,
      pettyCashExpenses: (map['pettyCashExpenses'] as num?)?.toDouble() ?? 0.0,
      cashRemaining: (map['cashRemaining'] as num?)?.toDouble() ?? 0.0,
      washerDividends: Map<String, double>.from(map['washerDividends'] ?? {}),
      notes: map['notes'],
      isConfirmed: map['isConfirmed'] ?? true,
      shiftType: map['shiftType'] ?? 'day',
      closedByRole: map['closedByRole'] ?? 'cashier',
      handoverTo: map['handoverTo'] ?? 'Operational Manager',
      handoverCashAmount: (map['handoverCashAmount'] as num?)?.toDouble() ?? 0.0,
      isHandoverAccepted: map['isHandoverAccepted'] ?? false,
      acceptedByName: map['acceptedByName'],
      acceptedAt: map['acceptedAt'] != null ? DateTime.tryParse(map['acceptedAt']) : null,
      carriedCashAmount: (map['carriedCashAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
