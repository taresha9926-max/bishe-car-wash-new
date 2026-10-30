import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/consumable_item.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/daily_handover.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/stock_transaction.dart';

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
  Future<void> deleteStaffMember(String staffId);
  Future<List<CommissionLog>> getCommissionLogs();

  // Staff Credentials & Authentication
  Future<List<StaffCredential>> getStaffCredentials();
  Future<bool> verifyStaffPin(UserRole role, String enteredPin);
  Future<void> updateStaffCredential(String id, String pin, String fullName);
  Future<void> addStaffCredential(StaffCredential cred);
  Future<void> deleteStaffCredential(String id);
}

/// Domain port for commercial marketing assets and TikTok reel configurations.
abstract class IMarketingRepository {
  Future<List<TikTokAdVideo>> getTikTokReels();
  Future<void> saveTikTokReels(List<TikTokAdVideo> reels);
}

/// Domain port for fixed assets, consumables stock, and washer team daily handovers.
abstract class IInventoryRepository {
  Future<List<FixedAsset>> getFixedAssets();
  Future<void> saveFixedAsset(FixedAsset asset);
  Future<void> deleteFixedAsset(String id);
  Future<List<ConsumableItem>> getConsumables();
  Future<void> saveConsumable(ConsumableItem item);
  Future<void> deleteConsumable(String id);
  Future<List<DailyHandover>> getDailyHandovers();
  Future<void> saveDailyHandover(DailyHandover handover);
  Future<List<StockTransaction>> getStockTransactions();
  Future<void> recordStockTransaction(StockTransaction tx);
}

/// Unified repository interface combining booking, pricing, staff, marketing, and inventory domain ports.
abstract class IWashRepository
    implements IBookingRepository, IPricingRepository, IStaffRepository, IMarketingRepository, IInventoryRepository {}
