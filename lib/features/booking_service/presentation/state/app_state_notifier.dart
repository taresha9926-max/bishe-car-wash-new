import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
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

  // Currently active customer booking (for live tracking in Customer UI)
  String? _activeTrackingBookingId;
  String? get activeTrackingBookingId => _activeTrackingBookingId;

  WashBooking? get activeTrackingBooking {
    if (_activeTrackingBookingId == null) {
      // Find the first ongoing booking for quick tracking
      try {
        return _bookings.firstWhere(
          (b) => b.status != WashStatus.completed && b.status != WashStatus.cancelled,
        );
      } catch (_) {
        return _bookings.isNotEmpty ? _bookings.first : null;
      }
    }
    try {
      return _bookings.firstWhere((b) => b.id == _activeTrackingBookingId);
    } catch (_) {
      return _bookings.isNotEmpty ? _bookings.first : null;
    }
  }

  void setActiveTrackingBooking(String bookingId) {
    _activeTrackingBookingId = bookingId;
    notifyListeners();
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

      if (_bookings.isNotEmpty && _activeTrackingBookingId == null) {
        _activeTrackingBookingId = _bookings.first.id;
      }
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
    );

    final created = await _repository.createBooking(newBooking);
    _activeTrackingBookingId = created.id;
    await _refreshData();
    return created;
  }

  /// Cashier registers walk-in gate entry
  Future<WashBooking> registerWalkInGate({
    required String licensePlate,
    required String customerPhone,
    required CarType carType,
    required WashPackage package,
    required BayType assignedBay,
    required String washerId,
    required String washerName,
    required PaymentMethod paymentMethod,
    bool markPaid = false,
    String? transactionRef,
    String? receiptScreenshot,
  }) async {
    final bookingId = 'BSH-${(100 + _bookings.length + 1)}';
    final price = package.getPriceFor(carType);

    final newBooking = WashBooking(
      id: bookingId,
      customerName: 'Gate Walk-In (${licensePlate.toUpperCase()})',
      customerPhone: customerPhone,
      serviceType: assignedBay == BayType.mobileVan ? ServiceType.atHomeMobile : ServiceType.walkInStation,
      carType: carType,
      licensePlate: licensePlate.toUpperCase(),
      package: package,
      status: WashStatus.washing, // Walk-in is immediately stationed to wash
      assignedBay: assignedBay,
      assignedWasherId: washerId,
      assignedWasherName: washerName,
      payment: PaymentInfo(
        isPaid: markPaid,
        method: paymentMethod,
        amount: price,
        transactionRef: transactionRef,
      receiptScreenshot: receiptScreenshot,
        paidAt: markPaid ? DateTime.now() : null,
      ),
      createdAt: DateTime.now(),
    );

    final created = await _repository.createBooking(newBooking);
    await _refreshData();
    return created;
  }

  /// Cashier updates wash status (e.g. Assigned -> Washing -> Drying -> Completed)
  Future<void> updateWashStatus(String bookingId, WashStatus newStatus) async {
    await _repository.updateWashStatus(bookingId, newStatus);
    await _refreshData();
  }

  /// Cashier assigns car to Bay 1, Bay 2 or Mobile Van & selects washer
  Future<void> assignBayAndWasher({
    required String bookingId,
    required BayType bay,
    required String washerId,
    required String washerName,
  }) async {
    await _repository.assignBayAndWasher(
      bookingId: bookingId,
      bay: bay,
      washerId: washerId,
      washerName: washerName,
    );
    await _refreshData();
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
    await _refreshData();
  }

  /// Admin edits service pricing by car type
  Future<void> updateServicePrice({
    required String packageId,
    required CarType carType,
    required double newPrice,
  }) async {
    await _repository.updatePackagePrice(packageId, carType, newPrice);
    await _refreshData();
  }

  /// Admin manages staff base salaries and commission rates
  Future<void> updateStaffSalary({
    required String staffId,
    required double baseSalary,
    required double commissionRate,
  }) async {
    await _repository.updateStaffSalary(staffId, baseSalary, commissionRate);
    await _refreshData();
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
    await _refreshData();
  }

  Future<void> _refreshData() async {
    _packages = await _repository.getPackages();
    _staff = await _repository.getStaffMembers();
    _bays = await _repository.getBays();
    _bookings = await _repository.getBookings();
    _commissionLogs = await _repository.getCommissionLogs();
    notifyListeners();
  }
}
