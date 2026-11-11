import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/daily_financial_closing.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/staff_authenticator.dart';
import 'package:bishe_car_wash/features/booking_service/data/datasources/mock_wash_datasource.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_wash_service_item.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/customer_feedback.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/consumable_item.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/daily_handover.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/stock_transaction.dart';
import 'package:bishe_car_wash/features/inventory/data/datasources/initial_inventory_seed.dart';

class WashRepositoryImpl implements IWashRepository {
  List<WashPackage> _packages = [];
  List<CarWashServiceItem> _serviceItems = List.from(CarWashServiceItem.getInitialServiceItems());
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
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7703232736168791303',
      thumbnailUrl: 'assets/images/reel_1.jpg',
    ),
    const TikTokAdVideo(
      id: 'reel-2',
      title: 'High-Pressure Chassis Steam Bay',
      subtitle: 'Deep wheel-well & engine chassis steam care • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7703201662713728274',
      thumbnailUrl: 'assets/images/reel_2.jpg',
    ),
    const TikTokAdVideo(
      id: 'reel-3',
      title: 'Ceramic Shield & Paint Polish',
      subtitle: 'Hydrophobic ceramic shield & ultimate gloss • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7701736769619905799',
      thumbnailUrl: 'assets/images/reel_3.jpg',
    ),
    const TikTokAdVideo(
      id: 'reel-4',
      title: 'Deep Interior & Leather Care',
      subtitle: 'Anti-bacterial steam & luxury cabin detailing • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7700597195816357127',
      thumbnailUrl: 'assets/images/reel_4.jpg',
    ),
    const TikTokAdVideo(
      id: 'reel-5',
      title: 'Wheel-Well & Tire Gloss Treatment',
      subtitle: 'Brake-dust dissolve & deep satin tire dressing • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7699125432259464455',
      thumbnailUrl: 'assets/images/reel_5.jpg',
    ),
    const TikTokAdVideo(
      id: 'reel-6',
      title: 'Engine Bay Detailing & Degrease',
      subtitle: 'Precision dry-steam grease wipe & harness coat • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7698005404336573703',
      thumbnailUrl: 'assets/images/reel_6.jpg',
    ),
    const TikTokAdVideo(
      id: 'reel-7',
      title: 'Water-Beading Hydrophobic Rinse',
      subtitle: 'Extreme water repelling & fast crystal dry coat • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7696533703924682002',
      thumbnailUrl: 'assets/images/reel_7.jpg',
    ),
  ];

  WashRepositoryImpl() {
    _initData();
  }

  void _initData() {
    _packages = MockWashDataSource.getInitialPackages();
    _staff = MockWashDataSource.getInitialStaff();
    _bays = List.from(MockWashDataSource.getInitialBays());
    _bookings = List.from(MockWashDataSource.getInitialBookings(_packages));
    _commissionLogs = List.from(MockWashDataSource.getInitialCommissionLogs());
    _credentials = List.from(MockWashDataSource.getInitialCredentials());
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
    if (booking.assignedBay != null && !booking.isCarpet) {
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
      if (booking.assignedBay != null && !booking.isCarpet) {
        _freeBay(booking.assignedBay!);
      }

      // Automatic washer commission logging if already paid
      if (!booking.commissionLogged && booking.payment.isPaid) {
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
      status: (booking.status == WashStatus.pending || booking.status == WashStatus.confirmed)
          ? WashStatus.assignedToBay
          : booking.status,
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
    double tipAmount = 0.0,
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
      tipAmount: tipAmount,
      transactionRef: transactionRef,
      receiptScreenshot: receiptScreenshot,
      paidAt: DateTime.now(),
    );

    var updatedBooking = booking.copyWith(payment: updatedPayment);

    // Automatic washer commission logging upon payment for completed vehicle
    if (updatedBooking.status == WashStatus.completed && !updatedBooking.commissionLogged) {
      _triggerCommissionLog(updatedBooking);
      updatedBooking = updatedBooking.copyWith(commissionLogged: true);
    }

    _bookings[index] = updatedBooking;
    return updatedBooking;
  }

  @override
  Future<WashBooking> postponeBooking({
    required String bookingId,
    required DateTime nextScheduledTime,
    String? reason,
    String? postponedByRole,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }
    final booking = _bookings[index];
    if (booking.assignedBay != null && !booking.isCarpet) {
      _freeBay(booking.assignedBay!);
    }
    final updated = booking.copyWith(
      isPostponed: true,
      postponedReason: (reason != null && reason.trim().isNotEmpty) ? reason.trim() : booking.postponedReason,
      postponedAt: DateTime.now(),
      postponedByRole: postponedByRole ?? booking.postponedByRole,
      scheduledTime: nextScheduledTime,
      clearAssignedBay: true,
    );
    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<WashBooking> handoverBookingToManager({
    required String bookingId,
    required String handedOverBy,
    String? note,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking $bookingId not found');
    }
    final booking = _bookings[index];
    final updated = booking.copyWith(
      isHandedOverToManager: true,
      handedOverBy: handedOverBy.trim().isNotEmpty ? handedOverBy.trim() : 'Cashier',
      handoverNote: (note != null && note.trim().isNotEmpty) ? note.trim() : booking.handoverNote,
      handedOverAt: DateTime.now(),
    );
    _bookings[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      if (booking.assignedBay != null && !booking.isCarpet) {
        _freeBay(booking.assignedBay!);
      }
      _bookings.removeAt(index);
    }
  }

  @override
  Future<void> clearAllBookings() async {
    _bookings.clear();
    _commissionLogs.clear();
    _dailyClosings.clear();
    _dailyHandovers.clear();
    _stockTransactions.clear();
    _consumables = List.from(InitialInventorySeed.getConsumables());
    _bays = _bays.map((b) => b.copyWith(
      status: BayStatus.vacant,
      activeBookingId: null,
      activeLicensePlate: null,
      assignedWasherName: null,
    )).toList();
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
  Future<List<CarWashServiceItem>> getServiceItems() async {
    return List.unmodifiable(_serviceItems);
  }

  @override
  Future<void> saveServiceItems(List<CarWashServiceItem> items) async {
    _serviceItems = List.from(items);
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

  final List<DailyFinancialClosing> _dailyClosings = [];

  @override
  String? get lastClosingSyncError => null;

  @override
  void clearClosingSyncError() {}

  @override
  Future<List<DailyFinancialClosing>> getDailyFinancialClosings() async {
    return List.unmodifiable(_dailyClosings);
  }

  @override
  Future<void> saveDailyFinancialClosing(DailyFinancialClosing closing) async {
    _dailyClosings.removeWhere((c) => c.id == closing.id);
    _dailyClosings.insert(0, closing);
  }

  @override
  Future<void> deleteDailyFinancialClosing(String id) async {
    _dailyClosings.removeWhere((c) => c.id == id);
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
    final staffIndex = booking.assignedWasherId != null
        ? _staff.indexWhere((s) => s.id == booking.assignedWasherId)
        : -1;
    final washerId = booking.assignedWasherId ?? 'team-pool';
    final washerName = (booking.assignedWasherName != null && booking.assignedWasherName!.trim().isNotEmpty)
        ? booking.assignedWasherName!.trim()
        : (staffIndex != -1 ? _staff[staffIndex].name : 'Washer Team Pool');
    final commissionRate = staffIndex != -1 ? _staff[staffIndex].commissionRate : 0.15;
    final commissionEarned = booking.totalPrice * commissionRate;

    final log = CommissionLog(
      id: 'COM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      bookingId: booking.id,
      washerId: washerId,
      washerName: washerName,
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

  String _customerPhoneBookingNumber = '0910046553';
  List<CustomerFeedback> _customerFeedback = [];

  @override
  Future<List<TikTokAdVideo>> getTikTokReels() async {
    return List.unmodifiable(_tiktokReels);
  }

  @override
  Future<void> saveTikTokReels(List<TikTokAdVideo> reels) async {
    _tiktokReels = List.from(reels);
  }

  @override
  Future<String> getCustomerPhoneBookingNumber() async {
    return _customerPhoneBookingNumber;
  }

  @override
  Future<void> saveCustomerPhoneBookingNumber(String phone) async {
    _customerPhoneBookingNumber = phone.trim();
  }

  @override
  Future<List<CustomerFeedback>> getCustomerFeedback() async {
    return List.unmodifiable(_customerFeedback);
  }

  @override
  Future<void> saveCustomerFeedback(List<CustomerFeedback> feedbackList) async {
    _customerFeedback = List.from(feedbackList);
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
