import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/features/admin/domain/models/bank_deposit_record.dart';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/daily_financial_closing.dart';
import 'package:bishe_car_wash/features/admin/domain/models/pending_approval_request.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/admin/domain/models/washer_dividend.dart';
import 'package:bishe_car_wash/features/admin/domain/models/weekly_commission_report.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/staff_authenticator.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';

class AppStateNotifier extends ChangeNotifier {
  final IWashRepository _repository;

  AppStateNotifier({required IWashRepository repository}) : _repository = repository {
    loadData();
  }

  // Active Role & Welcome Portal State
  UserRole _currentRole = UserRole.customer;
  UserRole get currentRole => _currentRole;

  bool _isWelcomeActive = true;
  bool get isWelcomeActive => _isWelcomeActive;

  // Super Admin vs Secondary Admin Role Tracking
  bool _isSuperAdmin = false;
  bool get isSuperAdmin => _isSuperAdmin;

  void setSuperAdminStatus(bool value) {
    _isSuperAdmin = value;
    notifyListeners();
  }

  // Pending Approvals Queue (Secondary Admin -> Super Admin confirmation)
  final List<PendingApprovalRequest> _pendingApprovals = [];
  List<PendingApprovalRequest> get pendingApprovals => List.unmodifiable(_pendingApprovals);

  void submitPendingApproval({
    required ApprovalActionType actionType,
    required String title,
    required String description,
    required Map<String, dynamic> payload,
  }) {
    final req = PendingApprovalRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      actionType: actionType,
      title: title,
      description: description,
      payload: payload,
      requestedAt: DateTime.now(),
      requestedBy: 'Secondary Admin',
    );
    _pendingApprovals.insert(0, req);
    notifyListeners();
  }

  Future<void> approveRequest(String requestId) async {
    final index = _pendingApprovals.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    final req = _pendingApprovals.removeAt(index);

    switch (req.actionType) {
      case ApprovalActionType.changePin:
        if (req.payload['action'] == 'delete') {
          await _repository.deleteStaffCredential(req.payload['id']);
        } else {
          await _repository.updateStaffCredential(
            req.payload['id'],
            req.payload['pin'],
            req.payload['fullName'],
          );
        }
        await _refreshCredentials();
        break;
      case ApprovalActionType.addStaff:
        await _repository.addStaffMember(req.payload['staff'] as StaffMember);
        await _refreshStaff();
        break;
      case ApprovalActionType.deleteStaff:
        await _repository.deleteStaffMember(req.payload['staffId']);
        await _refreshStaff();
        break;
      case ApprovalActionType.updateSalary:
        await _repository.updateStaffSalary(
          req.payload['staffId'],
          req.payload['baseSalary'],
          req.payload['commissionRate'],
        );
        await _refreshStaff();
        break;
      case ApprovalActionType.updatePrice:
        await _repository.updatePackagePrice(
          req.payload['packageId'],
          req.payload['carType'] as CarType,
          req.payload['newPrice'],
        );
        await _refreshPricing();
        break;
      case ApprovalActionType.updateSeniorityShare:
        _seniorityTierPercentages = Map<int, double>.from(req.payload['shares']);
        break;
    }
    notifyListeners();
  }

  void rejectRequest(String requestId) {
    _pendingApprovals.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }

  void goToWelcome() {
    _isWelcomeActive = true;
    notifyListeners();
  }

  String _currentLang = 'EN';
  String get currentLang => _currentLang;

  String tr(String key) => AppStrings.get(key, AppLanguage.fromCode(_currentLang));
  void setLanguage(String lang) { _currentLang = lang; notifyListeners(); }

  void switchRole(UserRole role) {
    _currentRole = role;
    _isWelcomeActive = false;
    notifyListeners();
  }

  // Repository Data Caches
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<WashBooking> _bookings = [];
  List<WashBooking> get bookings => _bookings;

  List<StationBay> _bays = [];
  List<StationBay> get bays => _bays;

  List<WashPackage> _packages = [];
  List<WashPackage> get packages => _packages;

  List<StaffMember> _staff = [];
  List<StaffMember> get staff => _staff;

  List<CommissionLog> _commissionLogs = [];
  List<CommissionLog> get commissionLogs => _commissionLogs;

  List<StaffCredential> _credentials = [];
  List<StaffCredential> get credentials => _credentials;

  /// Authenticate entered PIN for requested role via deep authenticator module (synchronous check)
  bool authenticateRole(UserRole role, String enteredPin) {
    return StaffAuthenticator.authenticate(
      role: role,
      enteredPin: enteredPin,
      credentials: _credentials,
    );
  }

  /// Retrieves the matched credential if PIN and role match an active record.
  StaffCredential? getMatchedCredential(UserRole role, String enteredPin) {
    final pin = enteredPin.trim();
    final roleCredentials = _credentials.where((c) => c.role == role && c.isActive).toList();
    try {
      return roleCredentials.firstWhere((c) => c.pin.trim() == pin);
    } catch (_) {
      return null;
    }
  }

  /// Live verification: checks cache first, then fetches fresh credentials from Supabase if not matched.
  Future<bool> authenticateRoleAsync(UserRole role, String enteredPin) async {
    if (authenticateRole(role, enteredPin)) {
      if (role == UserRole.admin) {
        final cred = getMatchedCredential(role, enteredPin);
        final isSuper = cred != null && (cred.username.toLowerCase() == 'admin' || cred.id == 'cred-admin');
        setSuperAdminStatus(isSuper);
      }
      return true;
    }
    try {
      _credentials = await _repository.getStaffCredentials();
      notifyListeners();
      final ok = authenticateRole(role, enteredPin);
      if (ok && role == UserRole.admin) {
        final cred = getMatchedCredential(role, enteredPin);
        final isSuper = cred != null && (cred.username.toLowerCase() == 'admin' || cred.id == 'cred-admin');
        setSuperAdminStatus(isSuper);
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  // Currently active customer booking (for live tracking in Customer UI)
  String? _activeTrackingBookingId;
  String? get activeTrackingBookingId => _activeTrackingBookingId;

  WashBooking? get activeTrackingBooking {
    if (_activeTrackingBookingId == null) return null;
    try {
      return _bookings.firstWhere((b) => b.id == _activeTrackingBookingId);
    } catch (_) {
      return null;
    }
  }

  void setActiveTrackingBooking(String bookingId) {
    _activeTrackingBookingId = bookingId;
    notifyListeners();
  }

  void clearActiveTrackingBooking() {
    _activeTrackingBookingId = null;
    notifyListeners();
  }

  /// Privacy-safe lookup for a customer's specific vehicle
  WashBooking? findBookingByPhoneOrPlate(String query) {
    final clean = query.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');
    if (clean.isEmpty) return null;
    try {
      return _bookings.firstWhere((b) {
        final pPlate = b.licensePlate.toUpperCase().replaceAll(' ', '').replaceAll('-', '');
        final pPhone = b.customerPhone.replaceAll(' ', '').replaceAll('-', '');
        return pPlate.contains(clean) || clean.contains(pPlate) || pPhone.contains(clean) || clean.contains(pPhone);
      });
    } catch (_) {
      return null;
    }
  }

  // Computed Properties for Dashboard & Metrics
  int get totalCompletedCarsToday {
    return _bookings.where((b) => b.status == WashStatus.completed).length;
  }

  int get activeQueueCount {
    return _bookings.where((b) => b.status.isOngoing || b.status == WashStatus.pending).length;
  }

  double get totalRevenueTodayETB {
    return _bookings
        .where((b) => b.payment.isPaid)
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get totalCashRevenueETB {
    return _bookings
        .where((b) => b.payment.isPaid && b.payment.method == PaymentMethod.cash)
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get digitalRevenueETB => totalDigitalRevenueETB;
  double get cashRevenueETB => totalCashRevenueETB;

  double get totalDigitalRevenueETB {
    return _bookings
        .where((b) => b.payment.isPaid && b.payment.method != PaymentMethod.cash)
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get totalCommissionsPaidETB {
    return _commissionLogs.fold(0.0, (sum, log) => sum + log.commissionEarnedETB);
  }

  // --- Team Commission Pool & Daily Washer Attendance ---
  double _teamCommissionRate = 0.15; // Default 15%, editable by Admin
  double get teamCommissionRate => _teamCommissionRate;

  void setTeamCommissionRate(double rate) {
    _teamCommissionRate = rate;
    notifyListeners();
  }

  double get teamCommissionPoolTodayETB => totalRevenueTodayETB * _teamCommissionRate;

  // Daily Washer Attendance: washerId -> isPresent (defaults to true)
  final Map<String, bool> _washerAttendanceToday = {};
  Map<String, bool> get washerAttendanceToday => Map.unmodifiable(_washerAttendanceToday);

  bool isWasherPresentToday(String washerId) => _washerAttendanceToday[washerId] ?? true;

  void setWasherAttendance(String washerId, bool isPresent) {
    _washerAttendanceToday[washerId] = isPresent;
    notifyListeners();
  }

  void markAllWashersPresent() {
    for (final w in availableWashers) {
      _washerAttendanceToday[w.id] = true;
    }
    notifyListeners();
  }

  List<StaffMember> get presentWashersToday =>
      availableWashers.where((w) => isWasherPresentToday(w.id)).toList();

  int get presentWashersCount => presentWashersToday.length;
  int get totalWashersCount => availableWashers.length;

  // Seniority Tier % Share (Editable by Super Admin, sums to 100%)
  // Level 4 (Lead Specialist): 35%, Level 3 (Senior): 30%, Level 2 (Standard): 20%, Level 1 (Junior): 15%
  Map<int, double> _seniorityTierPercentages = {
    4: 35.0,
    3: 30.0,
    2: 20.0,
    1: 15.0,
  };
  Map<int, double> get seniorityTierPercentages => Map.unmodifiable(_seniorityTierPercentages);

  void updateSeniorityTierPercentages(Map<int, double> newPercentages) {
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.updateSeniorityShare,
        title: 'Update Seniority Commission Shares',
        description: 'T4: ${newPercentages[4]}%, T3: ${newPercentages[3]}%, T2: ${newPercentages[2]}%, T1: ${newPercentages[1]}%',
        payload: {'shares': newPercentages},
      );
      return;
    }
    _seniorityTierPercentages = Map.from(newPercentages);
    notifyListeners();
  }

  /// Calculates individual dividend for each active washer based on their assigned commission percentage
  /// and today's attendance. Only washers PRESENT today divide the 100% commission pool.
  /// If some washers are absent, their assigned percentage is automatically redistributed
  /// proportionally across present washers.
  /// Sum of percentage shares for present washers is mathematically GUARANTEED to sum to 100.0%.
  Map<String, WasherDividend> calculateWasherDividends(double pool) {
    final washers = availableWashers;
    if (washers.isEmpty || pool <= 0) {
      final Map<String, WasherDividend> emptyResult = {};
      for (final w in washers) {
        final basePct = (w.commissionRate > 0 ? w.commissionRate : (1.0 / (washers.isEmpty ? 1 : washers.length))) * 100.0;
        emptyResult[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: isWasherPresentToday(w.id),
          percentageShare: 0.0,
          earnedETB: 0.0,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      }
      return emptyResult;
    }

    final present = presentWashersToday;
    if (present.isEmpty) {
      final Map<String, WasherDividend> allAbsent = {};
      for (final w in washers) {
        final basePct = (w.commissionRate > 0 ? w.commissionRate : (1.0 / washers.length)) * 100.0;
        allAbsent[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: false,
          percentageShare: 0.0,
          earnedETB: 0.0,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      }
      return allAbsent;
    }

    // Sum of assigned commission rates among PRESENT washers
    double totalPresentWeight = 0.0;
    for (final w in present) {
      final rate = (w.commissionRate > 0 ? w.commissionRate : (1.0 / washers.length));
      totalPresentWeight += rate;
    }

    if (totalPresentWeight <= 0) return {};

    final Map<String, WasherDividend> result = {};

    for (final w in washers) {
      final isPresent = isWasherPresentToday(w.id);
      final baseRate = (w.commissionRate > 0 ? w.commissionRate : (1.0 / washers.length));
      final basePct = baseRate * 100.0;

      if (!isPresent) {
        result[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: false,
          percentageShare: 0.0,
          earnedETB: 0.0,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      } else {
        // Relative Proportional Redistribution:
        final shareFraction = baseRate / totalPresentWeight;
        final percent = shareFraction * 100.0;
        final amount = shareFraction * pool;

        result[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: true,
          percentageShare: percent,
          earnedETB: amount,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      }
    }

    return result;
  }

  Map<String, WasherDividend> get washerDividendsToday => calculateWasherDividends(teamCommissionPoolTodayETB);

  // --- Owner Bank Accounts for Cash Deposits ---
  static const String ownerAccountAName = 'Commercial Bank of Ethiopia (CBE)';
  static const String ownerAccountANumber = '1000 4829 1048 2';
  static const String ownerAccountBName = 'Awash Bank';
  static const String ownerAccountBNumber = '0142 5930 1823 4';

  // Bank Deposits List (Cash deposits confirmed by Cashier to Owner Bank)
  final List<BankDepositRecord> _bankDeposits = _getInitialBankDeposits();
  List<BankDepositRecord> get bankDeposits => List.unmodifiable(_bankDeposits);

  // Daily Financial Closings (Confirmed shift reports by Cashier)
  final List<DailyFinancialClosing> _dailyFinancialClosings = _getInitialDailyClosings();
  List<DailyFinancialClosing> get dailyFinancialClosings => List.unmodifiable(_dailyFinancialClosings);

  static List<BankDepositRecord> _getInitialBankDeposits() {
    final now = DateTime.now();
    return [
      BankDepositRecord(
        id: 'dep-1',
        amount: 5200.0,
        accountKey: 'account_a',
        accountName: 'Account A (CBE)',
        accountNumber: ownerAccountANumber,
        bankName: 'Commercial Bank of Ethiopia',
        referenceSlipNumber: 'CBE-DEP-849201',
        depositedAt: now.subtract(const Duration(days: 1, hours: 2)),
        cashierName: 'Abebech T.',
        notes: 'Yesterday evening cash collection deposit',
      ),
      BankDepositRecord(
        id: 'dep-2',
        amount: 4800.0,
        accountKey: 'account_b',
        accountName: 'Account B (Awash Bank)',
        accountNumber: ownerAccountBNumber,
        bankName: 'Awash Bank',
        referenceSlipNumber: 'AW-SLIP-773192',
        depositedAt: now.subtract(const Duration(days: 3, hours: 3)),
        cashierName: 'Abebech T.',
        notes: 'Mid-week cash handover deposit',
      ),
    ];
  }

  static List<DailyFinancialClosing> _getInitialDailyClosings() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    return [
      DailyFinancialClosing(
        id: 'closing-${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}',
        closingDate: yesterday,
        closedAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 30),
        cashierName: 'Abebech Tadesse',
        grossRevenue: 8600.0,
        cashRevenue: 5200.0,
        digitalRevenue: 3400.0,
        providerBreakdown: {
          'Cash': 5200.0,
          'Telebirr': 1800.0,
          'CBE Birr': 1100.0,
          'Awash Bank': 500.0,
        },
        carsWashedCount: 16,
        commissionPool: 1290.0,
        netStationProfit: 7310.0,
        cashDeposited: 5200.0,
        cashRemaining: 0.0,
        washerDividends: {
          'Teshale Bekele (Lead)': 451.5,
          'Chala Gutu (Senior)': 387.0,
          'Dawit Alemu (Standard)': 258.0,
          'Yared Haile (Junior)': 193.5,
        },
        notes: 'Full shift settled smoothly. All cash deposited to CBE.',
        isConfirmed: true,
      ),
      DailyFinancialClosing(
        id: 'closing-${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}',
        closingDate: twoDaysAgo,
        closedAt: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 20, 15),
        cashierName: 'Abebech Tadesse',
        grossRevenue: 7400.0,
        cashRevenue: 4800.0,
        digitalRevenue: 2600.0,
        providerBreakdown: {
          'Cash': 4800.0,
          'Telebirr': 1400.0,
          'CBE Birr': 1200.0,
        },
        carsWashedCount: 14,
        commissionPool: 1110.0,
        netStationProfit: 6290.0,
        cashDeposited: 4800.0,
        cashRemaining: 0.0,
        washerDividends: {
          'Teshale Bekele (Lead)': 388.5,
          'Chala Gutu (Senior)': 333.0,
          'Dawit Alemu (Standard)': 222.0,
          'Yared Haile (Junior)': 166.5,
        },
        notes: 'Shift completed without incident.',
        isConfirmed: true,
      ),
    ];
  }

  /// Calculates breakdown of money received by each PaymentMethod
  Map<PaymentMethod, double> getRevenueByPaymentMethod({DateTime? start, DateTime? end}) {
    final result = <PaymentMethod, double>{
      for (final m in PaymentMethod.values) m: 0.0,
    };
    for (final b in _bookings) {
      if (!b.payment.isPaid) continue;
      if (start != null && b.createdAt.isBefore(start)) continue;
      if (end != null && b.createdAt.isAfter(end)) continue;
      result[b.payment.method] = (result[b.payment.method] ?? 0.0) + b.totalPrice;
    }
    return result;
  }

  /// Calculates count of transactions per PaymentMethod
  Map<PaymentMethod, int> getTransactionCountByPaymentMethod({DateTime? start, DateTime? end}) {
    final result = <PaymentMethod, int>{
      for (final m in PaymentMethod.values) m: 0,
    };
    for (final b in _bookings) {
      if (!b.payment.isPaid) continue;
      if (start != null && b.createdAt.isBefore(start)) continue;
      if (end != null && b.createdAt.isAfter(end)) continue;
      result[b.payment.method] = (result[b.payment.method] ?? 0) + 1;
    }
    return result;
  }

  /// Total cash deposited into owner bank accounts today
  double get totalCashDepositedTodayETB {
    final now = DateTime.now();
    return _bankDeposits
        .where((d) => d.depositedAt.year == now.year && d.depositedAt.month == now.month && d.depositedAt.day == now.day)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Total cash currently sitting in the cashier drawer awaiting bank deposit
  double get undepositedCashTodayETB {
    final diff = totalCashRevenueETB - totalCashDepositedTodayETB;
    return diff < 0 ? 0.0 : diff;
  }

  /// Checks if a given date has an approved daily closing report
  bool isDateClosed(DateTime date) {
    return _dailyFinancialClosings.any((c) =>
        c.closingDate.year == date.year &&
        c.closingDate.month == date.month &&
        c.closingDate.day == date.day &&
        c.isConfirmed);
  }

  bool get isTodayClosed => isDateClosed(DateTime.now());

  /// Cashier records cash deposit to Owner Bank Account A or B
  Future<void> recordBankDeposit({
    required double amount,
    required String accountKey,
    required String referenceSlipNumber,
    String? receiptScreenshot,
    required String cashierName,
    String? notes,
  }) async {
    final accountName = accountKey == 'account_b' ? ownerAccountBName : ownerAccountAName;
    final accountNumber = accountKey == 'account_b' ? ownerAccountBNumber : ownerAccountANumber;
    final bankName = accountKey == 'account_b' ? 'Awash Bank' : 'Commercial Bank of Ethiopia (CBE)';

    final deposit = BankDepositRecord(
      id: 'dep-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      accountKey: accountKey,
      accountName: accountName,
      accountNumber: accountNumber,
      bankName: bankName,
      referenceSlipNumber: referenceSlipNumber,
      receiptScreenshot: receiptScreenshot,
      depositedAt: DateTime.now(),
      cashierName: cashierName,
      notes: notes,
    );

    _bankDeposits.insert(0, deposit);
    notifyListeners();
  }

  /// Cashier confirms daily financial transactions closing summary
  Future<DailyFinancialClosing> confirmDailyClosing({
    required String cashierName,
    String? notes,
  }) async {
    final now = DateTime.now();
    final paidToday = _bookings.where((b) {
      final d = b.createdAt;
      return b.payment.isPaid && d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final gross = paidToday.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final cash = paidToday.where((b) => b.payment.method == PaymentMethod.cash).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digital = gross - cash;
    final comm = gross * teamCommissionRate;
    final net = gross - comm;
    final deposited = totalCashDepositedTodayETB;
    final remainingCash = cash > deposited ? cash - deposited : 0.0;

    final breakdown = <String, double>{};
    for (final m in PaymentMethod.values) {
      final amt = paidToday.where((b) => b.payment.method == m).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
      if (amt > 0) {
        breakdown[m.shortName] = amt;
      }
    }

    final divMap = calculateWasherDividends(comm);
    final divSummary = <String, double>{};
    divMap.forEach((id, div) {
      if (div.isPresent && div.earnedETB > 0) {
        divSummary[div.washerName] = div.earnedETB;
      }
    });

    final closing = DailyFinancialClosing(
      id: 'closing-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      closingDate: now,
      closedAt: now,
      cashierName: cashierName,
      grossRevenue: gross,
      cashRevenue: cash,
      digitalRevenue: digital,
      providerBreakdown: breakdown,
      carsWashedCount: paidToday.length,
      commissionPool: comm,
      netStationProfit: net,
      cashDeposited: deposited,
      cashRemaining: remainingCash,
      washerDividends: divSummary,
      notes: notes,
      isConfirmed: true,
    );

    _dailyFinancialClosings.removeWhere((c) =>
        c.closingDate.year == now.year &&
        c.closingDate.month == now.month &&
        c.closingDate.day == now.day);
    _dailyFinancialClosings.insert(0, closing);

    notifyListeners();
    return closing;
  }

  /// Weekly commission accumulation per washer (Washers are paid weekly)
  Map<String, double> get weeklyWasherCommissions {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final weeklyPaid = _bookings.where((b) {
      return b.payment.isPaid && (b.createdAt.isAfter(startOfWeek) || b.createdAt.isAtSameMomentAs(startOfWeek));
    }).toList();

    final weeklyGross = weeklyPaid.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final weeklyPool = weeklyGross * teamCommissionRate;

    final dividends = calculateWasherDividends(weeklyPool);
    final result = <String, double>{};
    for (final entry in dividends.entries) {
      result[entry.value.washerName] = entry.value.earnedETB;
    }
    return result;
  }

  /// Total weekly accumulated washer commission pool
  double get weeklyTotalCommissionPool {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final weeklyPaid = _bookings.where((b) {
      return b.payment.isPaid && (b.createdAt.isAfter(startOfWeek) || b.createdAt.isAtSameMomentAs(startOfWeek));
    }).toList();

    return weeklyPaid.fold<double>(0.0, (sum, b) => sum + b.totalPrice) * teamCommissionRate;
  }

  /// Total monthly base salary obligation for active washers (Salaries are paid monthly)
  double get monthlyTotalBaseSalary {
    return availableWashers.fold<double>(0.0, (sum, w) => sum + w.baseSalaryMonthlyETB);
  }

  // --- Weekly Washer Commission Reports (Reported by Cashier to Admin) ---
  final List<WeeklyCommissionReport> _weeklyCommissionReports = _getInitialWeeklyCommissionReports();
  List<WeeklyCommissionReport> get weeklyCommissionReports => List.unmodifiable(_weeklyCommissionReports);
  WeeklyCommissionReport? get latestWeeklyCommissionReport =>
      _weeklyCommissionReports.isNotEmpty ? _weeklyCommissionReports.first : null;

  static List<WeeklyCommissionReport> _getInitialWeeklyCommissionReports() {
    final now = DateTime.now();
    final lastSunday = now.subtract(Duration(days: now.weekday));
    final prevMonday = lastSunday.subtract(const Duration(days: 6));

    return [
      WeeklyCommissionReport(
        id: 'wcr-${lastSunday.year}-${lastSunday.month}-${lastSunday.day}',
        weekStartDate: DateTime(prevMonday.year, prevMonday.month, prevMonday.day),
        weekEndDate: DateTime(lastSunday.year, lastSunday.month, lastSunday.day, 21, 0),
        reportedAt: DateTime(lastSunday.year, lastSunday.month, lastSunday.day, 21, 15),
        cashierName: 'Abebech Tadesse',
        totalWeeklyPool: 7850.0,
        washerCommissions: {
          'Teshale Bekele (Lead)': 2747.5,
          'Chala Gutu (Senior)': 2355.0,
          'Dawit Alemu (Standard)': 1570.0,
          'Yared Haile (Junior)': 1177.5,
        },
        notes: 'Official weekly washer commission report disbursed and verified for last week.',
        isSubmitted: true,
      ),
    ];
  }

  /// Cashier submits weekly washer commission report to Admin
  Future<WeeklyCommissionReport> submitWeeklyCommissionReportToAdmin({
    required String cashierName,
    String? notes,
  }) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final pool = weeklyTotalCommissionPool;
    final washerShares = weeklyWasherCommissions;

    final report = WeeklyCommissionReport(
      id: 'wcr-${now.year}-${now.month}-${now.day}-${now.millisecondsSinceEpoch.toString().substring(7)}',
      weekStartDate: startOfWeek,
      weekEndDate: now,
      reportedAt: now,
      cashierName: cashierName,
      totalWeeklyPool: pool,
      washerCommissions: washerShares,
      notes: notes,
      isSubmitted: true,
    );

    _weeklyCommissionReports.insert(0, report);
    notifyListeners();
    return report;
  }

  int get availableBaysCount {
    return _bays.where((b) => b.type != BayType.mobileVan && b.isVacant).length;
  }

  bool get isMobileVanAvailable {
    final van = _bays.firstWhere(
      (b) => b.type == BayType.mobileVan,
      orElse: () => const StationBay(type: BayType.mobileVan),
    );
    return van.isVacant;
  }

  List<StaffMember> get availableWashers {
    return _staff.where((s) => s.role == StaffRole.washer || s.role == StaffRole.leadDetailer).toList();
  }

  // --- Actions ---

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPackages(),
        _repository.getStaffMembers(),
        _repository.getBays(),
        _repository.getBookings(),
        _repository.getCommissionLogs(),
        _repository.getStaffCredentials(),
      ]);
      _packages = results[0] as List<WashPackage>;
      _staff = results[1] as List<StaffMember>;
      _bays = results[2] as List<StationBay>;
      _bookings = results[3] as List<WashBooking>;
      _commissionLogs = results[4] as List<CommissionLog>;
      _credentials = results[5] as List<StaffCredential>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Customer books a new car wash
  Future<WashBooking> bookNewWash({
    required String customerName,
    required String customerPhone,
    required ServiceType serviceType,
    required CarType carType,
    required String licensePlate,
    required WashPackage package,
    String? deliveryLocation,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    DateTime? scheduledTime,
    bool isPhoneBooking = false,
    String? gpsCoordinates,
  }) async {
    final bookingId = 'BSH-${(100 + _bookings.length + 1)}';
    final price = package.getPriceFor(carType);

    final newBooking = WashBooking(
      id: bookingId,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceType: serviceType,
      deliveryLocation: deliveryLocation,
      carType: carType,
      licensePlate: licensePlate.toUpperCase(),
      package: package,
      status: WashStatus.pending,
      payment: PaymentInfo(
        isPaid: false,
        method: paymentMethod,
        amount: price,
      ),
      createdAt: DateTime.now(),
      scheduledTime: scheduledTime,
      isPhoneBooking: isPhoneBooking,
      gpsCoordinates: gpsCoordinates,
    );

    final created = await _repository.createBooking(newBooking);
    _activeTrackingBookingId = created.id;
    await _refreshBookingsAndBays();
    return created;
  }

  /// Cashier registers walk-in gate entry
  Future<WashBooking> registerWalkInGate({
    String? customerName,
    required String licensePlate,
    required String customerPhone,
    required CarType carType,
    required WashPackage package,
    required BayType assignedBay,
    String? washerId,
    String? washerName,
    required PaymentMethod paymentMethod,
    bool markPaid = false,
    String? transactionRef,
    String? receiptScreenshot,
    bool isPhoneBooking = false,
  }) async {
    final bookingId = 'BSH-${(100 + _bookings.length + 1)}';
    final price = package.getPriceFor(carType);
    final finalName = (customerName != null && customerName.trim().isNotEmpty)
        ? customerName.trim()
        : 'Walk-In (${licensePlate.toUpperCase()})';

    final newBooking = WashBooking(
      id: bookingId,
      customerName: finalName,
      customerPhone: customerPhone,
      serviceType: assignedBay == BayType.mobileVan ? ServiceType.atHomeMobile : ServiceType.walkInStation,
      carType: carType,
      licensePlate: licensePlate.toUpperCase(),
      package: package,
      status: WashStatus.washing, // Walk-in is immediately stationed to wash
      assignedBay: assignedBay,
      assignedWasherId: washerId,
      assignedWasherName: washerName ?? 'Team Washers',
      payment: PaymentInfo(
        isPaid: markPaid,
        method: paymentMethod,
        amount: price,
        transactionRef: transactionRef,
        receiptScreenshot: receiptScreenshot,
        paidAt: markPaid ? DateTime.now() : null,
      ),
      createdAt: DateTime.now(),
      isPhoneBooking: isPhoneBooking,
    );

    final created = await _repository.createBooking(newBooking);
    await _refreshBookingsAndBays();
    return created;
  }

  /// Cashier updates wash status (e.g. Assigned -> Washing -> Drying -> Completed)
  Future<void> updateWashStatus(String bookingId, WashStatus newStatus) async {
    await _repository.updateWashStatus(bookingId, newStatus);
    await _refreshBookingsAndBays();
  }

  /// Cashier assigns car to Bay 1, Bay 2 or Mobile Van
  Future<void> assignBayAndWasher({
    required String bookingId,
    required BayType bay,
    String? washerId,
    String? washerName,
  }) async {
    await _repository.assignBayAndWasher(
      bookingId: bookingId,
      bay: bay,
      washerId: washerId ?? 'stf-01',
      washerName: washerName ?? 'Team Washers',
    );
    await _refreshBookingsAndBays();
  }

  /// Cashier collects payment (Cash or Digital Money Transfer - Telebirr, CBE Birr)
  Future<void> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
    String? receiptScreenshot,
  }) async {
    await _repository.processPayment(
      bookingId: bookingId,
      method: method,
      amount: amount,
      transactionRef: transactionRef,
      receiptScreenshot: receiptScreenshot,
    );
    await _refreshBookingsAndBays();
  }

  Future<void> updatePackagePrice({
    required String packageId,
    required CarType carType,
    required double newPrice,
  }) => updateServicePrice(packageId: packageId, carType: carType, newPrice: newPrice);

  Future<void> addStaffMember({
    required String name,
    required String phone,
    required StaffRole role,
    required double baseSalary,
    double commissionRate = AppConstants.defaultCommissionRate,
    int skillSeniorityLevel = 2,
  }) => addNewStaff(
    name: name,
    phone: phone,
    role: role,
    baseSalary: baseSalary,
    commissionRate: commissionRate,
    skillSeniorityLevel: skillSeniorityLevel,
  );

  Future<WashBooking> registerWalkIn({
    String? customerName,
    required String licensePlate,
    required String customerPhone,
    required CarType carType,
    required WashPackage package,
    required BayType assignedBay,
    String? assignedWasherId,
    String? assignedWasherName,
    required PaymentMethod paymentMethod,
    bool markPaid = false,
    String? transactionRef,
    String? receiptScreenshot,
    bool isPhoneBooking = false,
  }) => registerWalkInGate(
    customerName: customerName,
    licensePlate: licensePlate,
    customerPhone: customerPhone,
    carType: carType,
    package: package,
    assignedBay: assignedBay,
    washerId: assignedWasherId,
    washerName: assignedWasherName ?? 'Team Washers',
    paymentMethod: paymentMethod,
    markPaid: markPaid,
    transactionRef: transactionRef,
    receiptScreenshot: receiptScreenshot,
    isPhoneBooking: isPhoneBooking,
  );

  /// Admin edits service pricing by car type
  Future<void> updateServicePrice({
    required String packageId,
    required CarType carType,
    required double newPrice,
  }) async {
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.updatePrice,
        title: 'Price Update for ${carType.displayName}',
        description: 'Update price of package $packageId to $newPrice ETB',
        payload: {
          'packageId': packageId,
          'carType': carType,
          'newPrice': newPrice,
        },
      );
      return;
    }
    await _repository.updatePackagePrice(packageId, carType, newPrice);
    await _refreshPricing();
  }

  /// Admin manages staff base salaries and commission rates
  Future<void> updateStaffSalary({
    required String staffId,
    required double baseSalary,
    required double commissionRate,
  }) async {
    if (!_isSuperAdmin) {
      final staff = _staff.firstWhere((s) => s.id == staffId, orElse: () => StaffMember(id: staffId, name: 'Staff', phone: '', role: StaffRole.washer, baseSalaryMonthlyETB: baseSalary));
      submitPendingApproval(
        actionType: ApprovalActionType.updateSalary,
        title: 'Update Salary for ${staff.name}',
        description: 'Base: $baseSalary ETB, Commission: ${(commissionRate * 100).toInt()}%',
        payload: {
          'staffId': staffId,
          'baseSalary': baseSalary,
          'commissionRate': commissionRate,
        },
      );
      return;
    }
    await _repository.updateStaffSalary(staffId, baseSalary, commissionRate);
    await _refreshStaff();
  }

  /// Admin adds a new staff member (washer, cashier, or secondary admin)
  Future<void> addNewStaff({
    required String name,
    required String phone,
    required StaffRole role,
    required double baseSalary,
    double commissionRate = AppConstants.defaultCommissionRate,
    int skillSeniorityLevel = 2,
  }) async {
    final newMember = StaffMember(
      id: 'stf-${(_staff.length + 1).toString().padLeft(2, '0')}',
      name: name,
      phone: phone,
      role: role,
      baseSalaryMonthlyETB: baseSalary,
      commissionRate: commissionRate,
      skillSeniorityLevel: skillSeniorityLevel,
    );

    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.addStaff,
        title: 'Add ${role.name.toUpperCase()}: $name',
        description: 'Phone: $phone, Salary: $baseSalary ETB',
        payload: {'staff': newMember},
      );
      return;
    }
    await _repository.addStaffMember(newMember);
    await _refreshStaff();
  }

  /// Delete a staff member (washer, cashier, or secondary admin)
  Future<void> deleteStaffMember(String staffId) async {
    final staff = _staff.firstWhere((s) => s.id == staffId, orElse: () => StaffMember(id: staffId, name: 'Staff', phone: '', role: StaffRole.washer, baseSalaryMonthlyETB: 0));
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.deleteStaff,
        title: 'Delete ${staff.role.name.toUpperCase()}: ${staff.name}',
        description: 'Remove staff member from station personnel',
        payload: {'staffId': staffId},
      );
      return;
    }
    await _repository.deleteStaffMember(staffId);
    await _refreshStaff();
  }

  /// Admin updates staff login pin & name
  Future<void> updateStaffCredential({
    required String id,
    required String pin,
    required String fullName,
  }) async {
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.changePin,
        title: 'Change PIN for $fullName',
        description: 'Set new PIN: $pin',
        payload: {
          'id': id,
          'pin': pin,
          'fullName': fullName,
        },
      );
      return;
    }
    await _repository.updateStaffCredential(id, pin, fullName);
    await _refreshCredentials();
  }

  /// Admin creates a new staff login credential (cashier or secondary admin)
  Future<void> addStaffCredential({
    required String username,
    required String pin,
    required UserRole role,
    required String fullName,
  }) async {
    final cred = StaffCredential(
      id: 'cred-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      pin: pin,
      role: role,
      fullName: fullName,
      isActive: true,
    );
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.changePin,
        title: 'Create ${role.name.toUpperCase()} PIN: $fullName',
        description: 'Username: @$username',
        payload: {'cred': cred},
      );
      return;
    }
    await _repository.addStaffCredential(cred);
    await _refreshCredentials();
  }

  /// Delete staff credential (PIN)
  Future<void> deleteStaffCredential(String id) async {
    final cred = _credentials.firstWhere((c) => c.id == id, orElse: () => StaffCredential(id: id, username: '', pin: '', role: UserRole.cashier, fullName: 'Staff', isActive: true));
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.changePin,
        title: 'Delete PIN for ${cred.fullName}',
        description: 'Remove login access for @${cred.username}',
        payload: {'id': id, 'action': 'delete'},
      );
      return;
    }
    await _repository.deleteStaffCredential(id);
    await _refreshCredentials();
  }

  Future<void> _refreshBookingsAndBays() async {
    _bays = await _repository.getBays();
    _bookings = await _repository.getBookings();
    _commissionLogs = await _repository.getCommissionLogs();
    notifyListeners();
  }

  Future<void> _refreshPricing() async {
    _packages = await _repository.getPackages();
    notifyListeners();
  }

  Future<void> _refreshStaff() async {
    _staff = await _repository.getStaffMembers();
    _commissionLogs = await _repository.getCommissionLogs();
    notifyListeners();
  }

  Future<void> _refreshCredentials() async {
    _credentials = await _repository.getStaffCredentials();
    notifyListeners();
  }

  Future<void> _refreshData() async {
    _packages = await _repository.getPackages();
    _staff = await _repository.getStaffMembers();
    _bays = await _repository.getBays();
    _bookings = await _repository.getBookings();
    _commissionLogs = await _repository.getCommissionLogs();
    _credentials = await _repository.getStaffCredentials();
    notifyListeners();
  }
}
