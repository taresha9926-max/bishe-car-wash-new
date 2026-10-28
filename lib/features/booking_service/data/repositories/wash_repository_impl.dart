import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/data/datasources/mock_wash_datasource.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';

class WashRepositoryImpl implements IWashRepository {
  List<WashPackage> _packages = [];
  List<StaffMember> _staff = [];
  List<StationBay> _bays = [];
  List<WashBooking> _bookings = [];
  List<CommissionLog> _commissionLogs = [];
  List<StaffCredential> _credentials = [];

  WashRepositoryImpl() {
    _initData();
  }

  void _initData() {
    _packages = MockWashDataSource.getInitialPackages();
    _staff = MockWashDataSource.getInitialStaff();
    _bays = MockWashDataSource.getInitialBays();
    _bookings = MockWashDataSource.getInitialBookings(_packages);
    _commissionLogs = MockWashDataSource.getInitialCommissionLogs();
    _credentials = MockWashDataSource.getInitialCredentials();
  }

  @override
  Future<List<WashBooking>> getBookings() async {
    return List.unmodifiable(_bookings);
  }

  @override
  Future<WashBooking?> getBookingById(String id) async {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<WashBooking> createBooking(WashBooking booking) async {
    _bookings.insert(0, booking);

    // If bay is already assigned at creation (walk-in gate entry), occupy bay
    if (booking.assignedBay != null) {
      _occupyBay(booking.assignedBay!, booking);
    }
    return booking;
  }

  @override
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }

    var booking = _bookings[index];
    final oldStatus = booking.status;

    booking = booking.copyWith(
      status: newStatus,
      completedAt: newStatus == WashStatus.completed ? DateTime.now() : booking.completedAt,
    );

    // If marked completed, free bay and trigger automatic commission logging
    if (newStatus == WashStatus.completed && oldStatus != WashStatus.completed) {
      if (booking.assignedBay != null) {
        _freeBay(booking.assignedBay!);
      }

      // Automatic washer commission logging
      if (!booking.commissionLogged && booking.assignedWasherId != null) {
        _triggerCommissionLog(booking);
        booking = booking.copyWith(commissionLogged: true);
      }
    }

    _bookings[index] = booking;
    return booking;
  }

  @override
  Future<WashBooking> assignBayAndWasher({
    required String bookingId,
    required BayType bay,
    required String washerId,
    required String washerName,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }

    var booking = _bookings[index];

    // If previously in a different bay, free that bay
    if (booking.assignedBay != null && booking.assignedBay != bay) {
      _freeBay(booking.assignedBay!);
    }

    booking = booking.copyWith(
      assignedBay: bay,
      assignedWasherId: washerId,
      assignedWasherName: washerName,
      status: booking.status == WashStatus.pending ? WashStatus.assignedToBay : booking.status,
    );

    _occupyBay(bay, booking);
    _setWasherBusy(washerId, true);

    _bookings[index] = booking;
    return booking;
  }

  @override
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
    String? receiptScreenshot,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }

    final booking = _bookings[index];
    final updatedPayment = booking.payment.copyWith(
      isPaid: true,
      method: method,
      amount: amount,
      transactionRef: transactionRef,
      receiptScreenshot: receiptScreenshot,
      paidAt: DateTime.now(),
    );

    final updatedBooking = booking.copyWith(payment: updatedPayment);
    _bookings[index] = updatedBooking;
    return updatedBooking;
  }

  @override
  Future<List<StationBay>> getBays() async {
    return List.unmodifiable(_bays);
  }

  @override
  Future<List<WashPackage>> getPackages() async {
    return List.unmodifiable(_packages);
  }

  @override
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice) async {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      _packages[index] = _packages[index].updatePrice(carType, newPrice);
    }
  }

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    return List.unmodifiable(_staff);
  }

  @override
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate) async {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index != -1) {
      _staff[index] = _staff[index].copyWith(
        baseSalaryMonthlyETB: baseSalary,
        commissionRate: commissionRate,
      );
    }
  }

  @override
  Future<void> addStaffMember(StaffMember member) async {
    _staff.add(member);
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    _staff.removeWhere((s) => s.id == staffId);
  }

  @override
  Future<List<CommissionLog>> getCommissionLogs() async {
    return List.unmodifiable(_commissionLogs);
  }

  @override
  Future<List<StaffCredential>> getStaffCredentials() async {
    return List.unmodifiable(_credentials);
  }

  @override
  Future<void> updateStaffCredential(String id, String pin, String fullName) async {
    final index = _credentials.indexWhere((c) => c.id == id);
    if (index != -1) {
      _credentials[index] = _credentials[index].copyWith(
        pin: pin,
        fullName: fullName,
      );
    }
  }

  @override
  Future<void> addStaffCredential(StaffCredential cred) async {
    _credentials.add(cred);
  }

  @override
  Future<void> deleteStaffCredential(String id) async {
    _credentials.removeWhere((c) => c.id == id);
  }

  // --- Helper state management methods ---

  void _occupyBay(BayType bayType, WashBooking booking) {
    final index = _bays.indexWhere((b) => b.type == bayType);
    if (index != -1) {
      _bays[index] = _bays[index].copyWith(
        status: BayStatus.occupied,
        activeBookingId: booking.id,
        activeLicensePlate: booking.licensePlate,
        assignedWasherName: booking.assignedWasherName,
        startedAt: DateTime.now(),
      );
    }
  }

  void _freeBay(BayType bayType) {
    final index = _bays.indexWhere((b) => b.type == bayType);
    if (index != -1) {
      _bays[index] = _bays[index].copyWith(
        status: BayStatus.vacant,
        clearActive: true,
      );
    }
  }

  void _setWasherBusy(String staffId, bool isBusy) {
    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index != -1) {
      _staff[index] = _staff[index].copyWith(isAvailable: !isBusy);
    }
  }

  void _triggerCommissionLog(WashBooking booking) {
    if (booking.assignedWasherId == null) return;

    final staffIndex = _staff.indexWhere((s) => s.id == booking.assignedWasherId);
    final commissionRate = staffIndex != -1 ? _staff[staffIndex].commissionRate : 0.15;
    final commissionEarned = booking.totalPrice * commissionRate;

    final log = CommissionLog(
      id: 'COM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      bookingId: booking.id,
      washerId: booking.assignedWasherId!,
      washerName: booking.assignedWasherName ?? 'Washer',
      carPlate: booking.licensePlate,
      carType: booking.carType,
      servicePackageName: booking.package.name,
      totalWashPriceETB: booking.totalPrice,
      commissionRate: commissionRate,
      commissionEarnedETB: commissionEarned,
      completedAt: DateTime.now(),
    );

    _commissionLogs.insert(0, log);

    // Update staff stats
    if (staffIndex != -1) {
      final staff = _staff[staffIndex];
      _staff[staffIndex] = staff.copyWith(
        isAvailable: true,
        completedWashesCount: staff.completedWashesCount + 1,
        totalCommissionEarnedETB: staff.totalCommissionEarnedETB + commissionEarned,
      );
    }
  }
}
