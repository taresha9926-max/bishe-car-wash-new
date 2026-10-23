import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

abstract class IWashRepository {
  Future<List<WashBooking>> getBookings();
  Future<WashBooking?> getBookingById(String id);
  Future<WashBooking?> getBookingByPlate(String licensePlate);
  Future<WashBooking> createBooking(WashBooking booking);
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus);
  Future<WashBooking> assignBayAndWashers({
    required String bookingId,
    required BayType bay,
    required List<String> washerNames,
  });
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
  });
  Future<List<StationBay>> getBays();
  Future<List<WashPackage>> getPackages();
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice);
  Future<List<StaffMember>> getStaffMembers();
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate);
  Future<void> addStaffMember(StaffMember staff);
  Future<List<CommissionLog>> getCommissionLogs();
  Future<void> settleCommission(String logId);
  Future<void> recordSmsNotification({
    required String bookingId,
    required String licensePlate,
    required String recipientPhone,
    required double amount,
  });
}
