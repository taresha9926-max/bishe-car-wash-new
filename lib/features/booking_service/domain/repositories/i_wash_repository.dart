import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

/// Domain port for active bookings, washing bay allocations, and payment processing.
abstract class IBookingRepository {
  Future<List<WashBooking>> getBookings();
  Future<WashBooking?> getBookingById(String id);
  Future<WashBooking> createBooking(WashBooking booking);
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus);
  Future<WashBooking> assignBayAndWasher({
    required String bookingId,
    required BayType bay,
    required String washerId,
    required String washerName,
  });
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
    String? receiptScreenshot,
  });
  Future<List<StationBay>> getBays();
}

/// Domain port for wash service catalog and dynamic pricing configuration.
abstract class IPricingRepository {
  Future<List<WashPackage>> getPackages();
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice);
}

/// Domain port for staff personnel, commission ledgers, and role credentials.
abstract class IStaffRepository {
  Future<List<StaffMember>> getStaffMembers();
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate);
  Future<void> addStaffMember(StaffMember staff);
  Future<List<CommissionLog>> getCommissionLogs();

  // Staff Credentials & Authentication
  Future<List<StaffCredential>> getStaffCredentials();
  Future<void> updateStaffCredential(String id, String pin, String fullName);
  Future<void> addStaffCredential(StaffCredential cred);
}

/// Unified repository interface combining booking, pricing, and staff domain ports.
abstract class IWashRepository implements IBookingRepository, IPricingRepository, IStaffRepository {}
