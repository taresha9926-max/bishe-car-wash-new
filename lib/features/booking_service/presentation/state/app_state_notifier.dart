import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
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

  // Active Role State
  UserRole _currentRole = UserRole.customer;
  UserRole get currentRole => _currentRole;

  String _currentLang = 'EN';
  String get currentLang => _currentLang;

  String tr(String key) => AppStrings.get(key, AppLanguage.fromCode(_currentLang));
  void setLanguage(String lang) { _currentLang = lang; notifyListeners(); }

  void switchRole(UserRole role) {
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
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

  /// Authenticate entered PIN for requested role via deep authenticator module
  bool authenticateRole(UserRole role, String enteredPin) {
    return StaffAuthenticator.authenticate(
      role: role,
      enteredPin: enteredPin,
      credentials: _credentials,
    );
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

  // --- Team Commission Pool (Washers work as a single team) ---
  double _teamCommissionRate = 0.15; // Default 15%, editable by Admin
  double get teamCommissionRate => _teamCommissionRate;

  void setTeamCommissionRate(double rate) {
    _teamCommissionRate = rate;
    notifyListeners();
  }

  double get teamCommissionPoolTodayETB => totalRevenueTodayETB * _teamCommissionRate;

  /// Calculate individual dividend for each active washer based on skill & seniority level
  Map<String, double> get washerDividendsToday {
    final washers = availableWashers;
    if (washers.isEmpty || teamCommissionPoolTodayETB <= 0) return {};

    final totalWeight = washers.fold<int>(0, (sum, w) => sum + (w.skillSeniorityLevel > 0 ? w.skillSeniorityLevel : 2));
    if (totalWeight == 0) return {};

    final pool = teamCommissionPoolTodayETB;
    final Map<String, double> dividends = {};
    for (final w in washers) {
      final weight = w.skillSeniorityLevel > 0 ? w.skillSeniorityLevel : 2;
      dividends[w.id] = (weight / totalWeight) * pool;
    }
    return dividends;
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
      _packages = await _repository.getPackages();
      _staff = await _repository.getStaffMembers();
      _bays = await _repository.getBays();
      _bookings = await _repository.getBookings();
      _commissionLogs = await _repository.getCommissionLogs();
      _credentials = await _repository.getStaffCredentials();
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
  }) => addNewStaff(name: name, phone: phone, role: role, baseSalary: baseSalary, commissionRate: commissionRate);

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
    await _repository.updatePackagePrice(packageId, carType, newPrice);
    await _refreshPricing();
  }

  /// Admin manages staff base salaries and commission rates
  Future<void> updateStaffSalary({
    required String staffId,
    required double baseSalary,
    required double commissionRate,
  }) async {
    await _repository.updateStaffSalary(staffId, baseSalary, commissionRate);
    await _refreshStaff();
  }

  /// Admin adds a new staff member
  Future<void> addNewStaff({
    required String name,
    required String phone,
    required StaffRole role,
    required double baseSalary,
    double commissionRate = AppConstants.defaultCommissionRate,
  }) async {
    final newMember = StaffMember(
      id: 'stf-${(_staff.length + 1).toString().padLeft(2, '0')}',
      name: name,
      phone: phone,
      role: role,
      baseSalaryMonthlyETB: baseSalary,
      commissionRate: commissionRate,
    );
    await _repository.addStaffMember(newMember);
    await _refreshStaff();
  }

  /// Admin updates staff login pin & name
  Future<void> updateStaffCredential({
    required String id,
    required String pin,
    required String fullName,
  }) async {
    await _repository.updateStaffCredential(id, pin, fullName);
    await _refreshCredentials();
  }

  /// Admin creates a new staff login credential
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
    await _repository.addStaffCredential(cred);
    await _refreshCredentials();
  }

  Future<void> _refreshBookingsAndBays() async {
    _bays = await _repository.getBays();
    _bookings = await _repository.getBookings();
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
