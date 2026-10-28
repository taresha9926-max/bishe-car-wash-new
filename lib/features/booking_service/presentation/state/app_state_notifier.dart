import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/pending_approval_request.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/admin/domain/models/washer_dividend.dart';
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

  /// Live verification: checks cache first, then fetches fresh credentials from Supabase if not matched.
  Future<bool> authenticateRoleAsync(UserRole role, String enteredPin) async {
    if (authenticateRole(role, enteredPin)) {
      return true;
    }
    try {
      _credentials = await _repository.getStaffCredentials();
      notifyListeners();
      return authenticateRole(role, enteredPin);
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

  /// Calculates individual dividend for each active washer based on skill & seniority level
  /// and today's attendance. Only washers PRESENT today divide the 100% commission pool.
  /// Sum of percentage shares for present washers is mathematically GUARANTEED to sum to 100.0%.
  Map<String, WasherDividend> calculateWasherDividends(double pool) {
    final present = presentWashersToday;
    if (present.isEmpty || pool <= 0) {
      final Map<String, WasherDividend> emptyResult = {};
      for (final w in availableWashers) {
        emptyResult[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: isWasherPresentToday(w.id),
          percentageShare: 0.0,
          earnedETB: 0.0,
        );
      }
      return emptyResult;
    }

    double totalPresentWeight = 0.0;
    for (final w in present) {
      final tierShare = _seniorityTierPercentages[w.skillSeniorityLevel] ?? 20.0;
      totalPresentWeight += tierShare;
    }

    if (totalPresentWeight <= 0) return {};

    final Map<String, WasherDividend> result = {};

    for (final w in availableWashers) {
      final isPresent = isWasherPresentToday(w.id);
      if (!isPresent) {
        result[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: false,
          percentageShare: 0.0,
          earnedETB: 0.0,
        );
      } else {
        final tierShare = _seniorityTierPercentages[w.skillSeniorityLevel] ?? 20.0;
        final shareFraction = tierShare / totalPresentWeight;
        final percent = shareFraction * 100.0;
        final amount = shareFraction * pool;

        result[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: true,
          percentageShare: percent,
          earnedETB: amount,
        );
      }
    }

    return result;
  }

  Map<String, WasherDividend> get washerDividendsToday => calculateWasherDividends(teamCommissionPoolTodayETB);

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
