import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/staff_authenticator.dart';
import 'package:bishe_car_wash/features/booking_service/data/datasources/mock_wash_datasource.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/consumable_item.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/daily_handover.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/stock_transaction.dart';
import 'package:bishe_car_wash/features/inventory/data/datasources/initial_inventory_seed.dart';

class WashRepositoryImpl implements IWashRepository {
  List<WashPackage> _packages = [];
  List<StaffMember> _staff = [];
  List<StationBay> _bays = [];
  List<WashBooking> _bookings = [];
  List<CommissionLog> _commissionLogs = [];
  List<StaffCredential> _credentials = [];
  List<FixedAsset> _fixedAssets = List.from(InitialInventorySeed.getFixedAssets());
  List<ConsumableItem> _consumables = List.from(InitialInventorySeed.getConsumables());
  List<DailyHandover> _dailyHandovers = [];
  List<StockTransaction> _stockTransactions = [];
  List<TikTokAdVideo> _tiktokReels = [
    const TikTokAdVideo(
      id: 'reel-1',
      title: 'Active Snow Foam Cannon & Pre-Wash',
      subtitle: 'Triple-action foaming & streak-free dirt lift • Watch Reel',
      tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
      thumbnailUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-2',
      title: 'High-Pressure Steam Bay & Undercarriage',
      subtitle: 'Deep wheel-well & engine chassis steam care • Watch Reel',
      tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
      thumbnailUrl: 'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-3',
      title: 'Diamond Ceramic Coating & Mirror Polish',
      subtitle: 'Hydrophobic ceramic shield & ultimate gloss • Watch Reel',
      tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
      thumbnailUrl: 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-4',
      title: 'Interior Deep Steam & Leather Conditioning',
      subtitle: 'Odor eradication & luxury cabin detailing • Watch Reel',
      tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=800&auto=format&fit=crop&q=80',
    ),
  ];

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
  Future<bool> verifyStaffPin(UserRole role, String enteredPin) async {
    return StaffAuthenticator.authenticate(
      role: role,
      enteredPin: enteredPin,
      credentials: _credentials,
    );
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

  @override
  Future<List<TikTokAdVideo>> getTikTokReels() async {
    return List.unmodifiable(_tiktokReels);
  }

  @override
  Future<void> saveTikTokReels(List<TikTokAdVideo> reels) async {
    _tiktokReels = List.from(reels);
  }

  @override
  Future<List<FixedAsset>> getFixedAssets() async {
    return List.unmodifiable(_fixedAssets);
  }

  @override
  Future<void> saveFixedAsset(FixedAsset asset) async {
    final idx = _fixedAssets.indexWhere((a) => a.id == asset.id);
    if (idx != -1) {
      _fixedAssets[idx] = asset;
    } else {
      _fixedAssets.add(asset);
    }
  }

  @override
  Future<void> deleteFixedAsset(String id) async {
    _fixedAssets.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<ConsumableItem>> getConsumables() async {
    return List.unmodifiable(_consumables);
  }

  @override
  Future<void> saveConsumable(ConsumableItem item) async {
    final idx = _consumables.indexWhere((c) => c.id == item.id);
    if (idx != -1) {
      _consumables[idx] = item;
    } else {
      _consumables.add(item);
    }
  }

  @override
  Future<void> deleteConsumable(String id) async {
    _consumables.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<DailyHandover>> getDailyHandovers() async {
    return List.unmodifiable(_dailyHandovers);
  }

  @override
  Future<void> saveDailyHandover(DailyHandover handover) async {
    final idx = _dailyHandovers.indexWhere((h) => h.id == handover.id);
    if (idx != -1) {
      _dailyHandovers[idx] = handover;
    } else {
      _dailyHandovers.insert(0, handover);
    }
  }

  @override
  Future<List<StockTransaction>> getStockTransactions() async {
    return List.unmodifiable(_stockTransactions);
  }

  @override
  Future<void> recordStockTransaction(StockTransaction tx) async {
    _stockTransactions.insert(0, tx);
  }
}
