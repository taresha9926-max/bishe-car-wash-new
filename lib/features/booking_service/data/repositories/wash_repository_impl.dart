import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
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
  List<WashBooking> _bookings = MockWashDataSource.getInitialBookings();
  List<StationBay> _bays = MockWashDataSource.getInitialBays();
  List<WashPackage> _packages = MockWashDataSource.getInitialPackages();
  List<StaffMember> _staff = MockWashDataSource.getInitialStaff();
  List<CommissionLog> _commissions = MockWashDataSource.getInitialCommissions();

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
  Future<WashBooking?> getBookingByPlate(String licensePlate) async {
    final clean = licensePlate.trim().toLowerCase();
    try {
      return _bookings.firstWhere(
        (b) => b.licensePlate.trim().toLowerCase() == clean && b.status != WashStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<WashBooking> createBooking(WashBooking booking) async {
    _bookings = [booking, ..._bookings];
    return booking;
  }

  @override
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Booking $bookingId not found');

    var updated = _bookings[index].copyWith(
      status: newStatus,
      completedAt: newStatus == WashStatus.completed ? DateTime.now() : _bookings[index].completedAt,
    );

    // If completed: split commission 50/50 between the two assigned washers
    if (newStatus == WashStatus.completed && !updated.commissionLogged) {
      if (updated.assignedWasherNames.isNotEmpty) {
        final totalPool = updated.totalPrice * 0.15; // 15% commission pool
        final perWasher = totalPool / (updated.assignedWasherNames.length.clamp(1, 4));

        for (final washerName in updated.assignedWasherNames) {
          final staffIdx = _staff.indexWhere((s) => s.name.toLowerCase() == washerName.toLowerCase());
          final staffId = staffIdx != -1 ? _staff[staffIdx].id : 'stf-${washerName.toLowerCase()}';

          _commissions = [
            CommissionLog(
              id: 'comm-${DateTime.now().millisecondsSinceEpoch}-${washerName.hashCode.abs() % 1000}',
              bookingId: updated.id,
              washerId: staffId,
              washerName: washerName,
              carPlate: updated.licensePlate,
              carType: updated.carType,
              servicePackageName: '${updated.package.name} (${updated.carType.displayName})',
              totalWashPriceETB: updated.totalPrice,
              commissionRate: 0.15,
              commissionEarnedETB: perWasher,
              isSettled: false,
              completedAt: DateTime.now(),
            ),
            ..._commissions,
          ];

          if (staffIdx != -1) {
            final st = _staff[staffIdx];
            _staff[staffIdx] = st.copyWith(
              completedWashesCount: st.completedWashesCount + 1,
              totalCommissionEarnedETB: st.totalCommissionEarnedETB + perWasher,
            );
          }
        }
      }

      // Vacate the assigned bay
      if (updated.assignedBay != null) {
        final bayIdx = _bays.indexWhere((b) => b.type == updated.assignedBay);
        if (bayIdx != -1) {
          _bays[bayIdx] = _bays[bayIdx].copyWith(
            status: BayStatus.vacant,
            clearActive: true,
          );
        }
      }

      updated = updated.copyWith(commissionLogged: true);
    }

    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<WashBooking> assignBayAndWashers({
    required String bookingId,
    required BayType bay,
    required List<String> washerNames,
  }) async {
    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex == -1) throw Exception('Booking $bookingIndex not found');

    final updated = _bookings[bookingIndex].copyWith(
      assignedBay: bay,
      assignedWasherNames: washerNames,
      status: WashStatus.washing,
    );
    _bookings[bookingIndex] = updated;

    final bayIndex = _bays.indexWhere((b) => b.type == bay);
    if (bayIndex != -1) {
      _bays[bayIndex] = _bays[bayIndex].copyWith(
        status: BayStatus.occupied,
        activeBookingId: updated.id,
        activeLicensePlate: updated.licensePlate,
        assignedWasherName: washerNames.join(' & '),
        startedAt: DateTime.now(),
      );
    }

    return updated;
  }

  @override
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Booking $bookingId not found');

    final updated = _bookings[index].copyWith(
      payment: PaymentInfo(
        isPaid: true,
        method: method,
        amount: amount,
        paidAt: DateTime.now(),
        transactionRef: transactionRef ?? 'TX-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<List<StationBay>> getBays() async => List.unmodifiable(_bays);

  @override
  Future<List<WashPackage>> getPackages() async => List.unmodifiable(_packages);

  @override
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice) async {
    final idx = _packages.indexWhere((p) => p.id == packageId);
    if (idx != -1) {
      _packages[idx] = _packages[idx].updatePrice(carType, newPrice);
    }
  }

  @override
  Future<List<StaffMember>> getStaffMembers() async => List.unmodifiable(_staff);

  @override
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate) async {
    final idx = _staff.indexWhere((s) => s.id == staffId);
    if (idx != -1) {
      _staff[idx] = _staff[idx].copyWith(
        baseSalaryMonthlyETB: baseSalary,
        commissionRate: commissionRate,
      );
    }
  }

  @override
  Future<void> addStaffMember(StaffMember staff) async {
    _staff = [..._staff, staff];
  }

  @override
  Future<List<CommissionLog>> getCommissionLogs() async => List.unmodifiable(_commissions);

  @override
  Future<void> settleCommission(String logId) async {
    final idx = _commissions.indexWhere((c) => c.id == logId);
    if (idx != -1) {
      _commissions[idx] = _commissions[idx].copyWith(isSettled: true);
    }
  }

  @override
  Future<void> recordSmsNotification({
    required String bookingId,
    required String licensePlate,
    required String recipientPhone,
    required double amount,
  }) async {}
}
