import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
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

  // Language state
  AppLanguage _currentLanguage = AppLanguage.en;
  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  String tr(String key) => AppStrings.get(key, _currentLanguage);

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

  List<CommissionLog> _commissions = [];
  List<CommissionLog> get commissions => _commissions;

  // Queue Calculations: Base 25 mins per vehicle across 2 on-site bays
  // Formula: ceil(cars ahead / 2) * 25 mins
  int get activeQueueCount {
    return _bookings
        .where((b) =>
            b.serviceType.name == 'station' &&
            (b.status == WashStatus.pending ||
                b.status == WashStatus.confirmed ||
                b.status == WashStatus.assignedToBay))
        .length;
  }

  int get estimatedWaitMinutes {
    final ahead = activeQueueCount;
    if (ahead <= 0) return 5;
    return ((ahead / 2.0).ceil()) * 25;
  }

  DateTime get recommendedArrivalTime {
    return DateTime.now().add(Duration(minutes: estimatedWaitMinutes));
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getBookings(),
        _repository.getBays(),
        _repository.getPackages(),
        _repository.getStaffMembers(),
        _repository.getCommissionLogs(),
      ]);

      _bookings = results[0] as List<WashBooking>;
      _bays = results[1] as List<StationBay>;
      _packages = results[2] as List<WashPackage>;
      _staff = results[3] as List<StaffMember>;
      _commissions = results[4] as List<CommissionLog>;
    } catch (e) {
      _errorMessage = 'Failed to load live data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WashBooking> createBooking(WashBooking booking) async {
    final created = await _repository.createBooking(booking);
    _bookings = [created, ..._bookings];
    notifyListeners();
    return created;
  }

  Future<void> updateWashStatus(String bookingId, WashStatus status) async {
    final updated = await _repository.updateWashStatus(bookingId, status);
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx] = updated;
    }
    // Refresh bays, commissions & staff to reflect automatic updates
    _bays = await _repository.getBays();
    _commissions = await _repository.getCommissionLogs();
    _staff = await _repository.getStaffMembers();
    notifyListeners();
  }

  Future<void> assignBayAndWashers({
    required String bookingId,
    required BayType bay,
    required List<String> washerNames,
  }) async {
    final updated = await _repository.assignBayAndWashers(
      bookingId: bookingId,
      bay: bay,
      washerNames: washerNames,
    );
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx] = updated;
    }
    _bays = await _repository.getBays();
    notifyListeners();
  }

  Future<void> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
  }) async {
    final updated = await _repository.processPayment(
      bookingId: bookingId,
      method: method,
      amount: amount,
      transactionRef: transactionRef,
    );
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> updatePackagePrice(String packageId, CarType carType, double price) async {
    await _repository.updatePackagePrice(packageId, carType, price);
    _packages = await _repository.getPackages();
    notifyListeners();
  }

  Future<void> settleCommission(String logId) async {
    await _repository.settleCommission(logId);
    _commissions = await _repository.getCommissionLogs();
    notifyListeners();
  }

  WashBooking? findBookingByPlate(String plate) {
    final clean = plate.trim().toLowerCase();
    try {
      return _bookings.firstWhere(
        (b) => b.licensePlate.trim().toLowerCase() == clean && b.status != WashStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }
}
