import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
import 'package:bishe_car_wash/features/admin/domain/models/bank_deposit_record.dart';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/daily_financial_closing.dart';
import 'package:bishe_car_wash/features/admin/domain/models/pending_approval_request.dart';
import 'package:bishe_car_wash/features/admin/domain/models/petty_cash_expense.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/admin/domain/models/washer_dividend.dart';
import 'package:bishe_car_wash/features/admin/domain/models/washer_daily_attendance.dart';
import 'package:bishe_car_wash/features/admin/domain/models/weekly_commission_report.dart';
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
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/consumable_item.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/daily_handover.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/stock_transaction.dart';
import 'package:bishe_car_wash/features/cashier/domain/models/shower_record.dart';
import 'package:bishe_car_wash/features/inventory/data/datasources/initial_inventory_seed.dart';

enum ActiveServiceDivision {
  carWash,
  carpetWash,
}

class AppStateNotifier extends ChangeNotifier {
  final IWashRepository _repository;

  AppStateNotifier({required IWashRepository repository}) : _repository = repository {
    loadData();
  }

  // Active Role & Welcome Portal State
  UserRole _currentRole = UserRole.customer;
  UserRole get currentRole => _currentRole;

  bool _isWelcomeActive = true;
  bool get isWelcomeActive => _isWelcomeActive;

  // Dual Service Division: Car Wash vs Carpet Cleaning
  ActiveServiceDivision _activeServiceDivision = ActiveServiceDivision.carWash;
  ActiveServiceDivision get activeServiceDivision => _activeServiceDivision;

  void setActiveServiceDivision(ActiveServiceDivision division) {
    if (_activeServiceDivision != division) {
      _activeServiceDivision = division;
      notifyListeners();
    }
  }

  bool get isCarWashDivisionActive => _activeServiceDivision == ActiveServiceDivision.carWash;
  bool get isCarpetDivisionActive => _activeServiceDivision == ActiveServiceDivision.carpetWash;

  // Super Admin vs Secondary Admin Role Tracking
  bool _isSuperAdmin = false;
  bool get isSuperAdmin => _isSuperAdmin;

  void setSuperAdminStatus(bool value) {
    _isSuperAdmin = value;
    notifyListeners();
  }

  // Pending Approvals Queue (Secondary Admin -> Super Admin confirmation)
  final List<PendingApprovalRequest> _pendingApprovals = [];
  List<PendingApprovalRequest> get pendingApprovals => List.unmodifiable(_pendingApprovals);

  void submitPendingApproval({
    required ApprovalActionType actionType,
    required String title,
    required String description,
    required Map<String, dynamic> payload,
  }) {
    final req = PendingApprovalRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      actionType: actionType,
      title: title,
      description: description,
      payload: payload,
      requestedAt: DateTime.now(),
      requestedBy: 'Secondary Admin',
    );
    _pendingApprovals.insert(0, req);
    notifyListeners();
  }

  Future<void> approveRequest(String requestId) async {
    final index = _pendingApprovals.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    final req = _pendingApprovals.removeAt(index);

    switch (req.actionType) {
      case ApprovalActionType.changePin:
        if (req.payload['action'] == 'delete') {
          await _repository.deleteStaffCredential(req.payload['id']);
        } else {
          await _repository.updateStaffCredential(
            req.payload['id'],
            req.payload['pin'],
            req.payload['fullName'],
          );
        }
        await _refreshCredentials();
        break;
      case ApprovalActionType.addStaff:
        await _repository.addStaffMember(req.payload['staff'] as StaffMember);
        await _refreshStaff();
        break;
      case ApprovalActionType.deleteStaff:
        await _repository.deleteStaffMember(req.payload['staffId']);
        await _refreshStaff();
        break;
      case ApprovalActionType.updateSalary:
        await _repository.updateStaffSalary(
          req.payload['staffId'],
          req.payload['baseSalary'],
          req.payload['commissionRate'],
        );
        await _refreshStaff();
        break;
      case ApprovalActionType.updatePrice:
        await _repository.updatePackagePrice(
          req.payload['packageId'],
          req.payload['carType'] as CarType,
          req.payload['newPrice'],
        );
        await _refreshPricing();
        break;
      case ApprovalActionType.updateSeniorityShare:
        _seniorityTierPercentages = Map<int, double>.from(req.payload['shares']);
        break;
    }
    notifyListeners();
  }

  void rejectRequest(String requestId) {
    _pendingApprovals.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }

  void goToWelcome() {
    _isWelcomeActive = true;
    notifyListeners();
  }

  String _currentLang = 'EN';
  String get currentLang => _currentLang;
  String get currentLanguage => _currentLang;

  String tr(String key) => AppStrings.get(key, AppLanguage.fromCode(_currentLang));
  void setLanguage(String lang) { _currentLang = lang; notifyListeners(); }

  void switchRole(UserRole role) {
    _currentRole = role;
    _isWelcomeActive = false;
    notifyListeners();
  }

  // Cashier SMS Dispatch Gateway Configuration
  String _cashierSmsPhone = '0962274450';
  String get cashierSmsPhone => _cashierSmsPhone;
  void setCashierSmsPhone(String phone) {
    _cashierSmsPhone = phone.trim();
    notifyListeners();
  }

  // Customer Phone Call Booking Configuration (Hotline)
  String _customerPhoneBookingNumber = '0910046553';
  String get customerPhoneBookingNumber => _customerPhoneBookingNumber;
  Future<void> setCustomerPhoneBookingNumber(String phone) async {
    _customerPhoneBookingNumber = phone.trim();
    notifyListeners();
    try {
      await _repository.saveCustomerPhoneBookingNumber(_customerPhoneBookingNumber);
    } catch (e) {
      debugPrint('Failed to save customer phone booking number to repository: $e');
    }
  }

  // Welcome Advertising Video Reel & TikTok Showcase
  String _adVideoUrl = 'assets/videos/ad_video.mp4';
  String get adVideoUrl => _adVideoUrl;
  void setAdVideoUrl(String url) {
    _adVideoUrl = url.trim();
    notifyListeners();
  }

  String _tiktokUrl = 'https://www.tiktok.com/@bishecarwash';
  String get tiktokUrl => _tiktokUrl;
  void setTikTokUrl(String url) {
    _tiktokUrl = url.trim();
    notifyListeners();
  }

  String _tiktokThumbnailUrl = '';
  String get tiktokThumbnailUrl => _tiktokThumbnailUrl;
  void setTikTokThumbnailUrl(String url) {
    _tiktokThumbnailUrl = url.trim();
    notifyListeners();
  }

  // Super Admin Configured TikTok Rolling Reels (Official @bishecarwash Videos 1 to 7)
  List<TikTokAdVideo> _tiktokReels = [
    const TikTokAdVideo(
      id: 'reel-1',
      title: 'Active Snow Foam Cannon & Pre-Wash',
      subtitle: 'Triple-action foaming & streak-free dirt lift • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7703232736168791303',
      thumbnailUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-2',
      title: 'High-Pressure Chassis Steam Bay',
      subtitle: 'Deep wheel-well & engine chassis steam care • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7703201662713728274',
      thumbnailUrl: 'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-3',
      title: 'Ceramic Shield & Paint Polish',
      subtitle: 'Hydrophobic ceramic shield & ultimate gloss • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7701736769619905799',
      thumbnailUrl: 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-4',
      title: 'Deep Interior & Leather Care',
      subtitle: 'Anti-bacterial steam & luxury cabin detailing • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7700597195816357127',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507136566006-cfc505b114fc?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-5',
      title: 'Wheel-Well & Tire Gloss Treatment',
      subtitle: 'Brake-dust dissolve & deep satin tire dressing • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7699125432259464455',
      thumbnailUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-6',
      title: 'Engine Bay Detailing & Degrease',
      subtitle: 'Precision dry-steam grease wipe & harness coat • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7698005404336573703',
      thumbnailUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
    ),
    const TikTokAdVideo(
      id: 'reel-7',
      title: 'Water-Beading Hydrophobic Rinse',
      subtitle: 'Extreme water repelling & fast crystal dry coat • Watch Reel',
      tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7696533703924682002',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?w=800&auto=format&fit=crop&q=80',
    ),
  ];
  List<TikTokAdVideo> get tiktokReels => List.unmodifiable(_tiktokReels);

  // Inventory: Fixed Assets & Consumables
  List<FixedAsset> _fixedAssets = List.from(InitialInventorySeed.getFixedAssets());
  List<FixedAsset> get fixedAssets => _fixedAssets;

  List<ConsumableItem> _consumables = List.from(InitialInventorySeed.getConsumables());
  List<ConsumableItem> get consumables => _consumables;

  List<DailyHandover> _dailyHandovers = [];
  List<DailyHandover> get dailyHandovers => _dailyHandovers;

  List<StockTransaction> _stockTransactions = [];
  List<StockTransaction> get stockTransactions => _stockTransactions;

  DailyHandover? get activeHandover => _dailyHandovers.cast<DailyHandover?>().firstWhere(
    (h) => h?.status == HandoverStatus.active,
    orElse: () => null,
  );

  Future<void> setTikTokReels(List<TikTokAdVideo> reels) async {
    _tiktokReels = List.from(reels);
    notifyListeners();
    try {
      await _repository.saveTikTokReels(_tiktokReels);
    } catch (e) {
      debugPrint('Failed to save TikTok reels to repository: $e');
    }
  }

  Future<void> addTikTokReel(TikTokAdVideo reel) async {
    _tiktokReels.add(reel);
    notifyListeners();
    try {
      await _repository.saveTikTokReels(_tiktokReels);
    } catch (e) {
      debugPrint('Failed to save TikTok reels to repository: $e');
    }
  }

  Future<void> updateTikTokReel(int index, TikTokAdVideo reel) async {
    if (index >= 0 && index < _tiktokReels.length) {
      _tiktokReels[index] = reel;
      notifyListeners();
      try {
        await _repository.saveTikTokReels(_tiktokReels);
      } catch (e) {
        debugPrint('Failed to save TikTok reels to repository: $e');
      }
    }
  }

  Future<void> removeTikTokReel(int index) async {
    if (index >= 0 && index < _tiktokReels.length && _tiktokReels.length > 1) {
      _tiktokReels.removeAt(index);
      notifyListeners();
      try {
        await _repository.saveTikTokReels(_tiktokReels);
      } catch (e) {
        debugPrint('Failed to save TikTok reels to repository: $e');
      }
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

  /// Authenticate entered PIN for requested role via deep authenticator module (synchronous check)
  bool authenticateRole(UserRole role, String enteredPin) {
    return StaffAuthenticator.authenticate(
      role: role,
      enteredPin: enteredPin,
      credentials: _credentials,
    );
  }

  /// Retrieves the matched credential if PIN and role match an active record.
  StaffCredential? getMatchedCredential(UserRole role, String enteredPin) {
    final pin = enteredPin.trim();
    final roleCredentials = _credentials.where((c) => c.role == role && c.isActive).toList();
    try {
      return roleCredentials.firstWhere((c) => c.pin.trim() == pin);
    } catch (_) {
      return null;
    }
  }

  /// Live verification: calls server-side verify_staff_pin RPC first, then falls back to local.
  Future<bool> authenticateRoleAsync(UserRole role, String enteredPin) async {
    final serverOk = await _repository.verifyStaffPin(role, enteredPin);
    if (serverOk) {
      if (role == UserRole.admin) {
        final cred = getMatchedCredential(role, enteredPin);
        final isSuper = (cred != null && (cred.username.toLowerCase() == 'admin' || cred.id == 'cred-admin')) ||
            enteredPin.trim() == '1234';
        setSuperAdminStatus(isSuper);
      }
      return true;
    }

    if (authenticateRole(role, enteredPin)) {
      if (role == UserRole.admin) {
        final cred = getMatchedCredential(role, enteredPin);
        final isSuper = cred != null && (cred.username.toLowerCase() == 'admin' || cred.id == 'cred-admin');
        setSuperAdminStatus(isSuper);
      }
      return true;
    }
    return false;
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

  /// Clears all booked vehicles from queue, history, and bays, along with all operational history across the app
  Future<void> clearAllBookings() async {
    _bookings = [];
    _commissionLogs = [];
    _activeTrackingBookingId = null;
    _bays = _bays.map((b) => b.copyWith(
      status: BayStatus.vacant,
      activeBookingId: null,
      activeLicensePlate: null,
      assignedWasherName: null,
    )).toList();
    _bankDeposits.clear();
    _dailyFinancialClosings.clear();
    _pettyCashExpenses.clear();
    _washerAttendances.clear();
    _weeklyCommissionReports.clear();
    _dailyHandovers.clear();
    _stockTransactions.clear();
    _pendingApprovals.clear();
    _consumables = List.from(InitialInventorySeed.getConsumables());
    _showerRecords.clear();
    notifyListeners();
    await _repository.clearAllBookings();
    try {
      final freshBays = await _repository.getBays();
      if (freshBays.isNotEmpty) {
        _bays = List.from(freshBays);
      }
    } catch (_) {}
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

  // Shower Service State
  final List<ShowerRecord> _showerRecords = [];
  List<ShowerRecord> get showerRecords => List.unmodifiable(_showerRecords);

  double _showerPricePerPerson = 50.0;
  double get showerPricePerPerson => _showerPricePerPerson;

  void updateShowerPrice(double price) {
    _showerPricePerPerson = price;
    notifyListeners();
  }

  Future<void> recordShowerEntry({
    required int userCount,
    required PaymentMethod paymentMethod,
    required String cashierName,
    String? notes,
  }) async {
    final record = ShowerRecord(
      id: 'SHW-${DateTime.now().millisecondsSinceEpoch}',
      userCount: userCount,
      unitPrice: _showerPricePerPerson,
      totalAmount: userCount * _showerPricePerPerson,
      paymentMethod: paymentMethod,
      recordedAt: DateTime.now(),
      recordedBy: cashierName,
      notes: notes,
    );
    _showerRecords.insert(0, record);
    notifyListeners();
  }

  // Carpet Cleaning Pricing (ETB per m²) Matrix across 3 delivery modes
  double _carpetTypeAStationPrice = 120.0;
  double _carpetTypeAHomePrice = 160.0;
  double _carpetTypeAValetPrice = 190.0;

  double _carpetTypeBStationPrice = 180.0;
  double _carpetTypeBHomePrice = 230.0;
  double _carpetTypeBValetPrice = 260.0;

  double get carpetTypeAStationPrice => _carpetTypeAStationPrice;
  double get carpetTypeAHomePrice => _carpetTypeAHomePrice;
  double get carpetTypeAValetPrice => _carpetTypeAValetPrice;

  double get carpetTypeBStationPrice => _carpetTypeBStationPrice;
  double get carpetTypeBHomePrice => _carpetTypeBHomePrice;
  double get carpetTypeBValetPrice => _carpetTypeBValetPrice;

  double get carpetTypeAPricePerSqM => _carpetTypeAStationPrice;
  double get carpetTypeBPricePerSqM => _carpetTypeBStationPrice;

  double getCarpetPricePerSqM(String carpetType, ServiceType serviceType) {
    final isTypeB = carpetType == 'type_b';
    switch (serviceType) {
      case ServiceType.walkInStation:
        return isTypeB ? _carpetTypeBStationPrice : _carpetTypeAStationPrice;
      case ServiceType.atHomeMobile:
        return isTypeB ? _carpetTypeBHomePrice : _carpetTypeAHomePrice;
      case ServiceType.valetPickUp:
      case ServiceType.phoneCallBooking:
        return isTypeB ? _carpetTypeBValetPrice : _carpetTypeAValetPrice;
    }
  }

  void updateCarpetPackagePrice({
    required String type,
    required ServiceType mode,
    required double price,
  }) {
    if (type == 'type_a') {
      if (mode == ServiceType.walkInStation) _carpetTypeAStationPrice = price;
      if (mode == ServiceType.atHomeMobile) _carpetTypeAHomePrice = price;
      if (mode == ServiceType.valetPickUp || mode == ServiceType.phoneCallBooking) _carpetTypeAValetPrice = price;
    } else {
      if (mode == ServiceType.walkInStation) _carpetTypeBStationPrice = price;
      if (mode == ServiceType.atHomeMobile) _carpetTypeBHomePrice = price;
      if (mode == ServiceType.valetPickUp || mode == ServiceType.phoneCallBooking) _carpetTypeBValetPrice = price;
    }
    notifyListeners();
  }

  void updateCarpetPricing({double? typeAPrice, double? typeBPrice}) {
    if (typeAPrice != null) _carpetTypeAStationPrice = typeAPrice;
    if (typeBPrice != null) _carpetTypeBStationPrice = typeBPrice;
    notifyListeners();
  }

  // Segmented Queues
  List<WashBooking> get carWashBookings => _bookings.where((b) => !b.isCarpet).toList();
  List<WashBooking> get carpetWashBookings => _bookings.where((b) => b.isCarpet).toList();
  int get activeCarQueueCount => _bookings.where((b) => !b.isCarpet && (b.status.isOngoing || b.status == WashStatus.pending)).length;
  int get activeCarpetQueueCount => _bookings.where((b) => b.isCarpet && (b.status.isOngoing || b.status == WashStatus.pending)).length;

  // Computed Properties for Dashboard & Metrics
  int get totalCompletedCarsToday {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return !b.isCarpet && b.status == WashStatus.completed && d.year == now.year && d.month == now.month && d.day == now.day;
    }).length;
  }

  int get totalCompletedCarpetsToday {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return b.isCarpet && b.status == WashStatus.completed && d.year == now.year && d.month == now.month && d.day == now.day;
    }).length;
  }

  int get todayCarpetCleanedCount => totalCompletedCarpetsToday;

  int get activeQueueCount {
    return _bookings.where((b) => b.status.isOngoing || b.status == WashStatus.pending).length;
  }

  int get todayShowerUserCount {
    final now = DateTime.now();
    return _showerRecords.where((s) {
      final d = s.recordedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0, (sum, s) => sum + s.userCount);
  }

  double get todayShowerRevenueETB {
    final now = DateTime.now();
    return _showerRecords.where((s) {
      final d = s.recordedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  double get todayShowerCashETB {
    final now = DateTime.now();
    return _showerRecords.where((s) {
      final d = s.recordedAt;
      return s.isCash && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  double get todayShowerDigitalETB {
    final now = DateTime.now();
    return _showerRecords.where((s) {
      final d = s.recordedAt;
      return s.isDigital && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  double get todayCustomerTipsETB {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return b.payment.isPaid && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, b) => sum + b.payment.tipAmount);
  }

  double get todayCashTipsETB {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return b.payment.isPaid && b.payment.method == PaymentMethod.cash && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, b) => sum + b.payment.tipAmount);
  }

  double get todayDigitalTipsETB {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return b.payment.isPaid && b.payment.method != PaymentMethod.cash && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, b) => sum + b.payment.tipAmount);
  }

  double get todayCarpetRevenueETB {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return b.isCarpet && b.payment.isPaid && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get todayVehicleRevenueETB {
    final now = DateTime.now();
    return _bookings.where((b) {
      final d = b.createdAt;
      return !b.isCarpet && b.payment.isPaid && d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get serviceRevenueTodayETB {
    final now = DateTime.now();
    return _bookings
        .where((b) {
          final d = b.createdAt;
          return b.payment.isPaid && d.year == now.year && d.month == now.month && d.day == now.day;
        })
        .fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  double get totalRevenueTodayETB {
    return serviceRevenueTodayETB + todayShowerRevenueETB + todayCustomerTipsETB;
  }

  double get totalCashRevenueETB {
    final now = DateTime.now();
    final bookCash = _bookings
        .where((b) {
          final d = b.createdAt;
          return b.payment.isPaid && b.payment.method == PaymentMethod.cash && d.year == now.year && d.month == now.month && d.day == now.day;
        })
        .fold(0.0, (sum, b) => sum + b.totalPrice + b.payment.tipAmount);
    return bookCash + todayShowerCashETB;
  }

  double get digitalRevenueETB => totalDigitalRevenueETB;
  double get cashRevenueETB => totalCashRevenueETB;

  double get totalDigitalRevenueETB {
    final now = DateTime.now();
    final bookDig = _bookings
        .where((b) {
          final d = b.createdAt;
          return b.payment.isPaid && b.payment.method != PaymentMethod.cash && d.year == now.year && d.month == now.month && d.day == now.day;
        })
        .fold(0.0, (sum, b) => sum + b.totalPrice + b.payment.tipAmount);
    return bookDig + todayShowerDigitalETB;
  }

  double get totalCommissionsPaidETB {
    return _commissionLogs.fold(0.0, (sum, log) => sum + log.commissionEarnedETB);
  }

  // --- Team Commission Pool & Daily Washer Attendance ---
  double _teamCommissionRate = 0.15; // Default 15%, editable by Admin
  double get teamCommissionRate => _teamCommissionRate;

  void setTeamCommissionRate(double rate) {
    _teamCommissionRate = rate;
    notifyListeners();
  }

  // Shower has 0% washer commission; tips pass 100% to washers
  double get teamCommissionPoolTodayETB => (serviceRevenueTodayETB * _teamCommissionRate) + todayCustomerTipsETB;

  // Daily Washer Attendance: washerId -> isPresent (defaults to true)
  final Map<String, bool> _washerAttendanceToday = {};
  Map<String, bool> get washerAttendanceToday => Map.unmodifiable(_washerAttendanceToday);

  bool isWasherPresentToday(String washerId) => _washerAttendanceToday[washerId] ?? true;

  void setWasherAttendance(String washerId, bool isPresent) {
    _washerAttendanceToday[washerId] = isPresent;
    notifyListeners();
  }

  void markAllWashersPresent() {
    for (final w in availableWashers) {
      _washerAttendanceToday[w.id] = true;
    }
    notifyListeners();
  }

  List<StaffMember> get presentWashersToday =>
      availableWashers.where((w) => isWasherPresentToday(w.id)).toList();

  int get presentWashersCount => presentWashersToday.length;
  int get totalWashersCount => availableWashers.length;

  // Seniority Tier % Share (Editable by Super Admin, sums to 100%)
  // Level 4 (Lead Specialist): 35%, Level 3 (Senior): 30%, Level 2 (Standard): 20%, Level 1 (Junior): 15%
  Map<int, double> _seniorityTierPercentages = {
    4: 35.0,
    3: 30.0,
    2: 20.0,
    1: 15.0,
  };
  Map<int, double> get seniorityTierPercentages => Map.unmodifiable(_seniorityTierPercentages);

  void updateSeniorityTierPercentages(Map<int, double> newPercentages) {
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.updateSeniorityShare,
        title: 'Update Seniority Commission Shares',
        description: 'T4: ${newPercentages[4]}%, T3: ${newPercentages[3]}%, T2: ${newPercentages[2]}%, T1: ${newPercentages[1]}%',
        payload: {'shares': newPercentages},
      );
      return;
    }
    _seniorityTierPercentages = Map.from(newPercentages);
    notifyListeners();
  }

  /// Calculates individual dividend for each active washer based on their assigned commission percentage
  /// and today's attendance. Only washers PRESENT today divide the 100% commission pool.
  /// If some washers are absent, their assigned percentage is automatically redistributed
  /// proportionally across present washers.
  /// Sum of percentage shares for present washers is mathematically GUARANTEED to sum to 100.0%.
  Map<String, WasherDividend> calculateWasherDividends(double pool) {
    final washers = availableWashers;
    if (washers.isEmpty || pool <= 0) {
      final Map<String, WasherDividend> emptyResult = {};
      for (final w in washers) {
        final basePct = (w.commissionRate > 0 ? w.commissionRate : (1.0 / (washers.isEmpty ? 1 : washers.length))) * 100.0;
        emptyResult[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: isWasherPresentToday(w.id),
          percentageShare: 0.0,
          earnedETB: 0.0,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      }
      return emptyResult;
    }

    final present = presentWashersToday;
    if (present.isEmpty) {
      final Map<String, WasherDividend> allAbsent = {};
      for (final w in washers) {
        final basePct = (w.commissionRate > 0 ? w.commissionRate : (1.0 / washers.length)) * 100.0;
        allAbsent[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: false,
          percentageShare: 0.0,
          earnedETB: 0.0,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      }
      return allAbsent;
    }

    // Sum of assigned commission rates among PRESENT washers
    double totalPresentWeight = 0.0;
    for (final w in present) {
      final rate = (w.commissionRate > 0 ? w.commissionRate : (1.0 / washers.length));
      totalPresentWeight += rate;
    }

    if (totalPresentWeight <= 0) return {};

    final Map<String, WasherDividend> result = {};

    for (final w in washers) {
      final isPresent = isWasherPresentToday(w.id);
      final baseRate = (w.commissionRate > 0 ? w.commissionRate : (1.0 / washers.length));
      final basePct = baseRate * 100.0;

      if (!isPresent) {
        result[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: false,
          percentageShare: 0.0,
          earnedETB: 0.0,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      } else {
        // Relative Proportional Redistribution:
        final shareFraction = baseRate / totalPresentWeight;
        final percent = shareFraction * 100.0;
        final amount = shareFraction * pool;

        result[w.id] = WasherDividend(
          washerId: w.id,
          washerName: w.name,
          skillLevel: w.skillSeniorityLevel,
          isPresent: true,
          percentageShare: percent,
          earnedETB: amount,
          customTierName: '${basePct.toStringAsFixed(1)}% Base',
        );
      }
    }

    return result;
  }

  Map<String, WasherDividend> get washerDividendsToday => calculateWasherDividends(teamCommissionPoolTodayETB);

  // --- Owner Bank Accounts for Cash Deposits ---
  static const String ownerAccountAName = 'Commercial Bank of Ethiopia (CBE)';
  static const String ownerAccountANumber = '1000 4829 1048 2';
  static const String ownerAccountBName = 'Awash Bank';
  static const String ownerAccountBNumber = '0142 5930 1823 4';

  // Bank Deposits List (Cash deposits confirmed by Cashier to Owner Bank)
  final List<BankDepositRecord> _bankDeposits = _getInitialBankDeposits();
  List<BankDepositRecord> get bankDeposits => List.unmodifiable(_bankDeposits);
  List<BankDepositRecord> get bankDepositRecords => List.unmodifiable(_bankDeposits);

  // Daily Financial Closings (Confirmed shift reports by Cashier)
  final List<DailyFinancialClosing> _dailyFinancialClosings = _getInitialDailyClosings();
  List<DailyFinancialClosing> get dailyFinancialClosings => List.unmodifiable(_dailyFinancialClosings);

  bool _hasNewCashierClosingAlert = false;
  bool get hasNewCashierClosingAlert => _hasNewCashierClosingAlert;
  DailyFinancialClosing? _latestClosingAlert;
  DailyFinancialClosing? get latestClosingAlert => _latestClosingAlert;

  void dismissCashierClosingAlert() {
    _hasNewCashierClosingAlert = false;
    notifyListeners();
  }

  // Logged-in Staff Context
  String? _activeStaffFullName;
  String? get activeStaffFullName => _activeStaffFullName;
  String? _activeStaffUsername;
  String? get activeStaffUsername => _activeStaffUsername;

  void setActiveStaff(String fullName, String username) {
    _activeStaffFullName = fullName;
    _activeStaffUsername = username;
    notifyListeners();
  }

  void clearActiveStaff() {
    _activeStaffFullName = null;
    _activeStaffUsername = null;
    notifyListeners();
  }

  // Daily Commission Disbursement Idempotency Lock
  bool _isDailyCommissionDisbursedToday = false;
  bool get isDailyCommissionDisbursedToday => _isDailyCommissionDisbursedToday;

  void markDailyCommissionDisbursed() {
    _isDailyCommissionDisbursedToday = true;
    final now = DateTime.now();
    final dividends = washerDividendsToday;
    final carsCount = bookings.where((b) => b.payment.isPaid).length;

    for (final w in availableWashers) {
      final isPres = isWasherPresentToday(w.id);
      final div = dividends[w.id];
      final earned = (isPres && div != null) ? div.earnedETB : 0.0;
      recordWasherDailyAttendance(
        washerId: w.id,
        washerName: w.name,
        date: now,
        isPresent: isPres,
        carsWashedCount: isPres ? carsCount : 0,
        commissionEarnedETB: earned,
      );
    }
    notifyListeners();
  }

  WasherDailyAttendance? getWasherAttendanceForDate(String washerId, DateTime date) {
    for (final a in _washerAttendances) {
      if (a.washerId == washerId &&
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day) {
        return a;
      }
    }
    return null;
  }

  double getDailyCommissionTotalForDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return teamCommissionPoolTodayETB;
    }
    return _washerAttendances
        .where((a) =>
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day)
        .fold(0.0, (sum, a) => sum + a.commissionEarnedETB);
  }

  double getWasherCommissionForDate(String washerId, DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return washerDividendsToday[washerId]?.earnedETB ?? 0.0;
    }
    final record = getWasherAttendanceForDate(washerId, date);
    return record?.commissionEarnedETB ?? 0.0;
  }

  // Petty Cash Expenses (Cashier emergency operational spends)
  final List<PettyCashExpense> _pettyCashExpenses = [];
  List<PettyCashExpense> get pettyCashExpenses => List.unmodifiable(_pettyCashExpenses);

  double get todayPettyCashExpensesETB {
    final now = DateTime.now();
    return _pettyCashExpenses
        .where((e) => e.loggedAt.year == now.year && e.loggedAt.month == now.month && e.loggedAt.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> recordPettyCashExpense({
    required double amount,
    required String category,
    required String reason,
    String? receiptScreenshot,
    String? voucherScreenshot,
    required String cashierName,
  }) async {
    final screenshot = voucherScreenshot ?? receiptScreenshot;
    final expense = PettyCashExpense(
      id: 'PCE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      amount: amount,
      category: category,
      reason: reason,
      receiptScreenshot: screenshot,
      loggedByCashier: cashierName,
      loggedAt: DateTime.now(),
    );
    _pettyCashExpenses.insert(0, expense);
    notifyListeners();
  }

  // Washer Daily Attendance Records
  final List<WasherDailyAttendance> _washerAttendances = [];
  List<WasherDailyAttendance> get washerAttendances => List.unmodifiable(_washerAttendances);

  Future<void> recordWasherDailyAttendance({
    required String washerId,
    required String washerName,
    required DateTime date,
    required bool isPresent,
    bool isExcused = false,
    int carsWashedCount = 0,
    double commissionEarnedETB = 0.0,
    String? notes,
  }) async {
    final existingIdx = _washerAttendances.indexWhere((a) =>
        a.washerId == washerId &&
        a.date.year == date.year &&
        a.date.month == date.month &&
        a.date.day == date.day);

    final record = WasherDailyAttendance(
      id: 'ATT-$washerId-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      washerId: washerId,
      washerName: washerName,
      date: date,
      isPresent: isPresent,
      isExcused: isExcused,
      carsWashedCount: carsWashedCount,
      commissionEarnedETB: commissionEarnedETB,
      notes: notes,
    );

    if (existingIdx != -1) {
      _washerAttendances[existingIdx] = record;
    } else {
      _washerAttendances.add(record);
    }
    notifyListeners();
  }

  static List<BankDepositRecord> _getInitialBankDeposits() {
    return [];
  }

  static List<DailyFinancialClosing> _getInitialDailyClosings() {
    return [];
  }

  /// Calculates breakdown of money received by each PaymentMethod
  Map<PaymentMethod, double> getRevenueByPaymentMethod({DateTime? start, DateTime? end}) {
    final result = <PaymentMethod, double>{
      for (final m in PaymentMethod.values) m: 0.0,
    };
    for (final b in _bookings) {
      if (!b.payment.isPaid) continue;
      if (start != null && b.createdAt.isBefore(start)) continue;
      if (end != null && b.createdAt.isAfter(end)) continue;
      result[b.payment.method] = (result[b.payment.method] ?? 0.0) + b.totalPrice + b.payment.tipAmount;
    }
    for (final s in _showerRecords) {
      if (start != null && s.recordedAt.isBefore(start)) continue;
      if (end != null && s.recordedAt.isAfter(end)) continue;
      result[s.paymentMethod] = (result[s.paymentMethod] ?? 0.0) + s.totalAmount;
    }
    return result;
  }

  /// Calculates count of transactions per PaymentMethod
  Map<PaymentMethod, int> getTransactionCountByPaymentMethod({DateTime? start, DateTime? end}) {
    final result = <PaymentMethod, int>{
      for (final m in PaymentMethod.values) m: 0,
    };
    for (final b in _bookings) {
      if (!b.payment.isPaid) continue;
      if (start != null && b.createdAt.isBefore(start)) continue;
      if (end != null && b.createdAt.isAfter(end)) continue;
      result[b.payment.method] = (result[b.payment.method] ?? 0) + 1;
    }
    for (final s in _showerRecords) {
      if (start != null && s.recordedAt.isBefore(start)) continue;
      if (end != null && s.recordedAt.isAfter(end)) continue;
      result[s.paymentMethod] = (result[s.paymentMethod] ?? 0) + 1;
    }
    return result;
  }

  /// Total cash deposited into owner bank accounts today
  double get totalCashDepositedTodayETB {
    final now = DateTime.now();
    return _bankDeposits
        .where((d) => d.depositedAt.year == now.year && d.depositedAt.month == now.month && d.depositedAt.day == now.day)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Total cash currently sitting in the cashier drawer awaiting bank deposit
  double get undepositedCashTodayETB {
    final diff = totalCashRevenueETB - totalCashDepositedTodayETB - todayPettyCashExpensesETB;
    return diff < 0 ? 0.0 : diff;
  }

  /// Checks if a given date has an approved daily closing report
  bool isDateClosed(DateTime date, {String? shiftType}) {
    return _dailyFinancialClosings.any((c) =>
        c.closingDate.year == date.year &&
        c.closingDate.month == date.month &&
        c.closingDate.day == date.day &&
        c.isConfirmed &&
        (shiftType == null || c.shiftType == shiftType));
  }

  bool get isTodayClosed => isDateClosed(DateTime.now());
  bool get isTodayDayShiftClosed => isDateClosed(DateTime.now(), shiftType: 'day');
  bool get isTodayNightShiftClosed => isDateClosed(DateTime.now(), shiftType: 'night');

  DailyFinancialClosing? get pendingCashierHandover {
    final now = DateTime.now();
    for (final c in _dailyFinancialClosings) {
      if (c.shiftType == 'day' &&
          c.handoverMethod == 'manager_otp' &&
          !c.isHandoverAccepted &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day) {
        return c;
      }
    }
    return null;
  }

  DailyFinancialClosing? get pendingCashierAdminHandover {
    final now = DateTime.now();
    for (final c in _dailyFinancialClosings) {
      if (c.shiftType == 'day' &&
          c.handoverMethod == 'admin_otp' &&
          !c.isHandoverAccepted &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day) {
        return c;
      }
    }
    return null;
  }

  DailyFinancialClosing? get pendingAdminNightHandover {
    final now = DateTime.now();
    for (final c in _dailyFinancialClosings) {
      if (c.shiftType == 'night' &&
          !c.isHandoverAccepted &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day) {
        return c;
      }
    }
    return null;
  }

  DailyFinancialClosing? get latestDayClosing {
    final now = DateTime.now();
    for (final c in _dailyFinancialClosings) {
      if (c.shiftType == 'day' &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day) {
        return c;
      }
    }
    return null;
  }

  DailyFinancialClosing? get latestNightClosing {
    final now = DateTime.now();
    for (final c in _dailyFinancialClosings) {
      if (c.shiftType == 'night' &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day) {
        return c;
      }
    }
    return null;
  }

  double get managerCarriedCashETB {
    final now = DateTime.now();
    for (final c in _dailyFinancialClosings) {
      if (c.shiftType == 'day' &&
          c.handoverMethod == 'manager_otp' &&
          c.isHandoverAccepted &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day) {
        return c.cashRemaining;
      }
    }
    return 0.0;
  }

  Future<bool> acceptCashierHandover({
    required String managerName,
    String? enteredOtp,
  }) async {
    final now = DateTime.now();
    final index = _dailyFinancialClosings.indexWhere(
      (c) =>
          c.shiftType == 'day' &&
          c.handoverMethod == 'manager_otp' &&
          !c.isHandoverAccepted &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day,
    );

    if (index != -1) {
      final record = _dailyFinancialClosings[index];
      if (record.handoverOtp != null && record.handoverOtp!.isNotEmpty) {
        if (enteredOtp == null || enteredOtp.trim() != record.handoverOtp!.trim()) {
          return false;
        }
      }
      final updated = record.copyWith(
        isHandoverAccepted: true,
        acceptedByName: managerName,
        acceptedAt: now,
      );
      _dailyFinancialClosings[index] = updated;
      try {
        await _repository.saveDailyFinancialClosing(updated);
      } catch (e) {
        debugPrint('Failed to save handover acceptance: $e');
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> acceptAdminHandover({
    required String adminName,
    String? enteredOtp,
    String? shiftType,
  }) async {
    final now = DateTime.now();
    final index = _dailyFinancialClosings.indexWhere(
      (c) =>
          (shiftType == null
              ? (c.shiftType == 'night' || c.shiftType == 'day')
              : (shiftType == 'day' ? c.shiftType == 'day' : c.shiftType == 'night')) &&
          !c.isHandoverAccepted &&
          c.closingDate.year == now.year &&
          c.closingDate.month == now.month &&
          c.closingDate.day == now.day,
    );

    if (index != -1) {
      final record = _dailyFinancialClosings[index];
      if (record.handoverOtp != null && record.handoverOtp!.isNotEmpty) {
        if (enteredOtp == null || enteredOtp.trim() != record.handoverOtp!.trim()) {
          return false;
        }
      }
      final updated = record.copyWith(
        isHandoverAccepted: true,
        acceptedByName: adminName,
        acceptedAt: now,
        handoverTo: shiftType == 'day' ? 'Admin / Owner' : record.handoverTo,
      );
      _dailyFinancialClosings[index] = updated;
      try {
        await _repository.saveDailyFinancialClosing(updated);
      } catch (e) {
        debugPrint('Failed to save admin handover acceptance: $e');
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Unlocks today's day shift closing so the cashier can continue recording, washing, and collecting payments for new cars.
  Future<bool> unlockDayShiftClosing() async {
    final now = DateTime.now();
    final index = _dailyFinancialClosings.indexWhere((c) =>
        c.shiftType == 'day' &&
        c.closingDate.year == now.year &&
        c.closingDate.month == now.month &&
        c.closingDate.day == now.day);

    if (index != -1) {
      final closing = _dailyFinancialClosings.removeAt(index);
      try {
        await _repository.deleteDailyFinancialClosing(closing.id);
      } catch (e) {
        debugPrint('Failed to delete daily closing during unlock: $e');
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Cashier records cash deposit to Owner Bank Account A or B
  Future<void> recordBankDeposit({
    required double amount,
    required String accountKey,
    required String referenceSlipNumber,
    String? receiptScreenshot,
    required String cashierName,
    String? notes,
  }) async {
    final accountName = accountKey == 'account_b' ? ownerAccountBName : ownerAccountAName;
    final accountNumber = accountKey == 'account_b' ? ownerAccountBNumber : ownerAccountANumber;
    final bankName = accountKey == 'account_b' ? 'Awash Bank' : 'Commercial Bank of Ethiopia (CBE)';

    final deposit = BankDepositRecord(
      id: 'dep-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      accountKey: accountKey,
      accountName: accountName,
      accountNumber: accountNumber,
      bankName: bankName,
      referenceSlipNumber: referenceSlipNumber,
      receiptScreenshot: receiptScreenshot,
      depositedAt: DateTime.now(),
      cashierName: cashierName,
      notes: notes,
    );

    _bankDeposits.insert(0, deposit);
    notifyListeners();
  }

  /// Confirms daily/shift financial transactions closing summary
  Future<DailyFinancialClosing> confirmDailyClosing({
    required String cashierName,
    String? notes,
    String shiftType = 'day',
    String closedByRole = 'cashier',
    String handoverTo = 'Operational Manager',
    String handoverMethod = 'manager_otp', // 'manager_otp', 'bank_deposit', 'admin_otp'
    String? bankAccountKey,
    String? bankReferenceSlip,
  }) async {
    final now = DateTime.now();
    final paidToday = _bookings.where((b) {
      final d = b.createdAt;
      return b.payment.isPaid && d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final vehiclePaid = paidToday.where((b) => !b.isCarpet).toList();
    final carpetPaid = paidToday.where((b) => b.isCarpet).toList();

    final vehicleRev = vehiclePaid.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final carpetRev = carpetPaid.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final showerRev = todayShowerRevenueETB;
    final tipsRev = paidToday.fold<double>(0.0, (sum, b) => sum + b.payment.tipAmount);

    final serviceGross = vehicleRev + carpetRev;
    final gross = serviceGross + showerRev + tipsRev;

    final serviceCash = paidToday.where((b) => b.payment.method == PaymentMethod.cash).fold<double>(0.0, (sum, b) => sum + b.totalPrice + b.payment.tipAmount);
    final cash = serviceCash + todayShowerCashETB;
    final digital = gross - cash;

    final comm = (serviceGross * teamCommissionRate) + tipsRev;
    final net = (serviceGross - (serviceGross * teamCommissionRate)) + showerRev;
    final deposited = totalCashDepositedTodayETB;
    final petty = todayPettyCashExpensesETB;
    final remainingCash = cash > (deposited + petty) ? cash - (deposited + petty) : 0.0;

    final breakdown = <String, double>{};
    for (final m in PaymentMethod.values) {
      final amt = paidToday.where((b) => b.payment.method == m).fold<double>(0.0, (sum, b) => sum + b.totalPrice + b.payment.tipAmount);
      final showerAmt = _showerRecords.where((s) {
        final d = s.recordedAt;
        return s.paymentMethod == m && d.year == now.year && d.month == now.month && d.day == now.day;
      }).fold<double>(0.0, (sum, s) => sum + s.totalAmount);
      if (amt + showerAmt > 0) {
        breakdown[m.shortName] = amt + showerAmt;
      }
    }

    final divMap = calculateWasherDividends(comm);
    final divSummary = <String, double>{};
    divMap.forEach((id, div) {
      if (div.isPresent && div.earnedETB > 0) {
        divSummary[div.washerName] = div.earnedETB;
      }
    });

    final carried = shiftType == 'night' ? managerCarriedCashETB : 0.0;
    final totalCashToHandover = shiftType == 'night'
        ? (carried + remainingCash)
        : remainingCash;

    // Determine OTP and Handover Target based on method
    String? otp;
    bool isAccepted = false;
    String targetRecipient = handoverTo;
    double finalRemainingCash = remainingCash;
    double finalDeposited = deposited;

    if (shiftType == 'night') {
      targetRecipient = 'Admin / Owner';
      otp = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
      isAccepted = false; // Admin must verify with OTP
    } else {
      if (handoverMethod == 'bank_deposit') {
        final accName = bankAccountKey == 'account_b' ? ownerAccountBName : ownerAccountAName;
        final accNum = bankAccountKey == 'account_b' ? ownerAccountBNumber : ownerAccountANumber;
        targetRecipient = 'Bank Deposit ($accName)';
        isAccepted = true;
        otp = null;
        if (remainingCash > 0) {
          await recordBankDeposit(
            amount: remainingCash,
            accountKey: bankAccountKey ?? 'account_a',
            referenceSlipNumber: bankReferenceSlip ?? 'DEP-${now.millisecondsSinceEpoch}',
            cashierName: cashierName,
            notes: notes ?? 'Automatic deposit during Cashier daily closing fallback',
          );
          finalDeposited += remainingCash;
          finalRemainingCash = 0.0;
        }
      } else if (handoverMethod == 'admin_otp') {
        targetRecipient = 'Admin / Owner';
        otp = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
        isAccepted = false; // Admin must verify with OTP
      } else {
        // manager_otp
        targetRecipient = 'Operational Manager';
        otp = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
        isAccepted = false; // Manager must verify with OTP
      }
    }

    final closing = DailyFinancialClosing(
      id: 'closing-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-$shiftType',
      closingDate: now,
      closedAt: now,
      cashierName: cashierName,
      grossRevenue: gross,
      cashRevenue: cash,
      digitalRevenue: digital,
      providerBreakdown: breakdown,
      carsWashedCount: vehiclePaid.length,
      carpetsCleanedCount: carpetPaid.length,
      carpetRevenue: carpetRev,
      showerUsersCount: todayShowerUserCount,
      showerRevenue: showerRev,
      totalTipsAmount: tipsRev,
      commissionPool: comm,
      netStationProfit: net,
      cashDeposited: finalDeposited,
      pettyCashExpenses: petty,
      cashRemaining: finalRemainingCash,
      washerDividends: divSummary,
      notes: notes,
      isConfirmed: true,
      shiftType: shiftType,
      closedByRole: closedByRole,
      handoverTo: targetRecipient,
      handoverCashAmount: totalCashToHandover,
      isHandoverAccepted: isAccepted,
      carriedCashAmount: carried,
      handoverMethod: shiftType == 'night' ? 'admin_otp' : handoverMethod,
      handoverOtp: otp,
      bankAccountName: handoverMethod == 'bank_deposit' ? (bankAccountKey == 'account_b' ? ownerAccountBName : ownerAccountAName) : null,
      bankAccountNumber: handoverMethod == 'bank_deposit' ? (bankAccountKey == 'account_b' ? ownerAccountBNumber : ownerAccountANumber) : null,
      depositSlipRef: handoverMethod == 'bank_deposit' ? bankReferenceSlip : null,
    );

    _dailyFinancialClosings.removeWhere((c) =>
        c.closingDate.year == now.year &&
        c.closingDate.month == now.month &&
        c.closingDate.day == now.day &&
        c.shiftType == shiftType);
    _dailyFinancialClosings.insert(0, closing);

    try {
      await _repository.saveDailyFinancialClosing(closing);
    } catch (e) {
      debugPrint('Failed to persist daily closing to repository: $e');
    }

    _hasNewCashierClosingAlert = true;
    _latestClosingAlert = closing;

    notifyListeners();
    return closing;
  }

  /// Weekly commission accumulation per washer (Washers are paid weekly)
  Map<String, double> get weeklyWasherCommissions {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final weeklyPaid = _bookings.where((b) {
      return b.payment.isPaid && (b.createdAt.isAfter(startOfWeek) || b.createdAt.isAtSameMomentAs(startOfWeek));
    }).toList();

    final weeklyGross = weeklyPaid.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final weeklyTips = weeklyPaid.fold<double>(0.0, (sum, b) => sum + b.payment.tipAmount);
    final weeklyPool = (weeklyGross * teamCommissionRate) + weeklyTips;

    final dividends = calculateWasherDividends(weeklyPool);
    final result = <String, double>{};
    for (final entry in dividends.entries) {
      result[entry.value.washerName] = entry.value.earnedETB;
    }
    return result;
  }

  /// Total weekly accumulated washer commission pool
  double get weeklyTotalCommissionPool {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final weeklyPaid = _bookings.where((b) {
      return b.payment.isPaid && (b.createdAt.isAfter(startOfWeek) || b.createdAt.isAtSameMomentAs(startOfWeek));
    }).toList();

    final weeklyGross = weeklyPaid.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final weeklyTips = weeklyPaid.fold<double>(0.0, (sum, b) => sum + b.payment.tipAmount);
    return (weeklyGross * teamCommissionRate) + weeklyTips;
  }

  /// Total monthly base salary obligation for active washers (Salaries are paid monthly)
  double get monthlyTotalBaseSalary {
    return availableWashers.fold<double>(0.0, (sum, w) => sum + w.baseSalaryMonthlyETB);
  }

  // --- Weekly Washer Commission Reports (Reported by Cashier to Admin) ---
  final List<WeeklyCommissionReport> _weeklyCommissionReports = _getInitialWeeklyCommissionReports();
  List<WeeklyCommissionReport> get weeklyCommissionReports => List.unmodifiable(_weeklyCommissionReports);
  WeeklyCommissionReport? get latestWeeklyCommissionReport =>
      _weeklyCommissionReports.isNotEmpty ? _weeklyCommissionReports.first : null;

  static List<WeeklyCommissionReport> _getInitialWeeklyCommissionReports() {
    return [];
  }

  /// Cashier submits weekly washer commission report to Admin
  Future<WeeklyCommissionReport> submitWeeklyCommissionReportToAdmin({
    required String cashierName,
    String? notes,
  }) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final pool = weeklyTotalCommissionPool;
    final washerShares = weeklyWasherCommissions;

    final report = WeeklyCommissionReport(
      id: 'wcr-${now.year}-${now.month}-${now.day}-${now.millisecondsSinceEpoch.toString().substring(7)}',
      weekStartDate: startOfWeek,
      weekEndDate: now,
      reportedAt: now,
      cashierName: cashierName,
      totalWeeklyPool: pool,
      washerCommissions: washerShares,
      notes: notes,
      isSubmitted: true,
    );

    _weeklyCommissionReports.insert(0, report);
    notifyListeners();
    return report;
  }

  /// Accountant or Admin disburses the weekly commission report
  Future<void> disburseWeeklyCommission(String reportId) async {
    final idx = _weeklyCommissionReports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      final existing = _weeklyCommissionReports[idx];
      _weeklyCommissionReports[idx] = existing.copyWith(
        isDisbursed: true,
        disbursedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  final Set<int> _paidWeeklyCommissionWeekOffsets = {};

  bool isWeeklyCommissionPaid(int weekOffset) {
    if (_paidWeeklyCommissionWeekOffsets.contains(weekOffset)) return true;
    final now = DateTime.now().subtract(Duration(days: weekOffset * 7));
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return _weeklyCommissionReports.any((r) =>
        r.weekStartDate.year == monday.year &&
        r.weekStartDate.month == monday.month &&
        r.weekStartDate.day == monday.day &&
        r.isDisbursed);
  }

  Future<void> confirmWeeklyCommissionPaid(int weekOffset) async {
    _paidWeeklyCommissionWeekOffsets.add(weekOffset);
    final now = DateTime.now().subtract(Duration(days: weekOffset * 7));
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final existingReportIdx = _weeklyCommissionReports.indexWhere((r) =>
        r.weekStartDate.year == monday.year &&
        r.weekStartDate.month == monday.month &&
        r.weekStartDate.day == monday.day);
    if (existingReportIdx != -1) {
      _weeklyCommissionReports[existingReportIdx] = _weeklyCommissionReports[existingReportIdx].copyWith(
        isDisbursed: true,
        disbursedAt: DateTime.now(),
      );
    } else {
      await submitWeeklyCommissionReportToAdmin(
        cashierName: activeStaffFullName ?? 'Cashier',
        notes: 'Weekly commission confirmed and disbursed by Accountant.',
      );
      if (_weeklyCommissionReports.isNotEmpty) {
        _weeklyCommissionReports[0] = _weeklyCommissionReports[0].copyWith(
          isDisbursed: true,
          disbursedAt: DateTime.now(),
        );
      }
    }
    notifyListeners();
  }

  Future<void> disburseAndReportDailyCommissionToAdmin({required String cashierName}) async {
    markDailyCommissionDisbursed();
    notifyListeners();
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
      final results = await Future.wait([
        _repository.getPackages(),
        _repository.getStaffMembers(),
        _repository.getBays(),
        _repository.getBookings(),
        _repository.getCommissionLogs(),
        _repository.getStaffCredentials(),
        _repository.getTikTokReels(),
        _repository.getFixedAssets(),
        _repository.getConsumables(),
        _repository.getDailyHandovers(),
        _repository.getStockTransactions(),
      ]);
      _packages = List.from(results[0] as List<WashPackage>);
      _staff = List.from(results[1] as List<StaffMember>);
      _bays = List.from(results[2] as List<StationBay>);
      _bookings = List.from(results[3] as List<WashBooking>);
      _commissionLogs = List.from(results[4] as List<CommissionLog>);
      _credentials = List.from(results[5] as List<StaffCredential>);
      final reels = results[6] as List<TikTokAdVideo>;
      if (reels.isNotEmpty) {
        _tiktokReels = List.from(reels);
      }
      final assets = results[7] as List<FixedAsset>;
      if (assets.isNotEmpty) {
        _fixedAssets = List.from(assets);
      }
      final consumables = results[8] as List<ConsumableItem>;
      if (consumables.isNotEmpty) {
        _consumables = List.from(consumables);
      }
      _dailyHandovers = List.from(results[9] as List<DailyHandover>);
      _stockTransactions = List.from(results[10] as List<StockTransaction>);

      try {
        final closings = await _repository.getDailyFinancialClosings();
        if (closings.isNotEmpty) {
          _dailyFinancialClosings.clear();
          _dailyFinancialClosings.addAll(closings);
        }
      } catch (_) {}

      try {
        final hotline = await _repository.getCustomerPhoneBookingNumber();
        if (hotline.isNotEmpty) {
          _customerPhoneBookingNumber = hotline;
        }
      } catch (_) {}
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
    bool isCarpet = false,
    String? carpetType,
    double? carpetAreaSqMeters,
    String? carpetDimensions,
    double? customTotalPrice,
    double tipAmount = 0.0,
  }) async {
    final bookingId = isCarpet
        ? 'CPT-${(100 + _bookings.length + 1)}'
        : 'BSH-${(100 + _bookings.length + 1)}';
    final price = customTotalPrice ?? package.getPriceFor(carType);

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
        tipAmount: tipAmount,
      ),
      createdAt: DateTime.now(),
      scheduledTime: scheduledTime,
      isPhoneBooking: isPhoneBooking,
      gpsCoordinates: gpsCoordinates,
      isCarpet: isCarpet,
      carpetType: carpetType,
      carpetAreaSqMeters: carpetAreaSqMeters,
      carpetDimensions: carpetDimensions,
      customTotalPrice: customTotalPrice,
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
    bool isCarpet = false,
    String? carpetType,
    double? carpetAreaSqMeters,
    String? carpetDimensions,
    double? customTotalPrice,
    double tipAmount = 0.0,
  }) async {
    final bookingId = isCarpet
        ? 'CPT-${(100 + _bookings.length + 1)}'
        : 'BSH-${(100 + _bookings.length + 1)}';
    final price = customTotalPrice ?? package.getPriceFor(carType);
    final finalName = (customerName != null && customerName.trim().isNotEmpty)
        ? customerName.trim()
        : isCarpet
            ? 'Carpet Client (${licensePlate.toUpperCase()})'
            : 'Walk-In (${licensePlate.toUpperCase()})';

    final newBooking = WashBooking(
      id: bookingId,
      customerName: finalName,
      customerPhone: customerPhone,
      serviceType: assignedBay == BayType.mobileVan ? ServiceType.atHomeMobile : ServiceType.walkInStation,
      carType: carType,
      licensePlate: licensePlate.toUpperCase(),
      package: package,
      status: WashStatus.pending, // Gate booked car enters active queue pending wash start
      assignedBay: assignedBay,
      assignedWasherId: washerId,
      assignedWasherName: washerName ?? 'Team Washers',
      payment: PaymentInfo(
        isPaid: markPaid,
        method: paymentMethod,
        amount: price,
        tipAmount: tipAmount,
        transactionRef: transactionRef,
        receiptScreenshot: receiptScreenshot,
        paidAt: markPaid ? DateTime.now() : null,
      ),
      createdAt: DateTime.now(),
      isPhoneBooking: isPhoneBooking,
      isCarpet: isCarpet,
      carpetType: carpetType,
      carpetAreaSqMeters: carpetAreaSqMeters,
      carpetDimensions: carpetDimensions,
      customTotalPrice: customTotalPrice,
    );

    final created = await _repository.createBooking(newBooking);
    await _refreshBookingsAndBays();
    return created;
  }

  String getCustomerCompletionSmsText(WashBooking booking) {
    final customerName = booking.customerName.isNotEmpty ? booking.customerName : 'Valued Customer';
    final amountStr = 'ETB ${booking.totalPrice.toStringAsFixed(2)}';
    if (booking.isCarpet) {
      final cType = booking.carpetType == 'type_b' ? 'Deep Clean (Type B)' : 'Standard Clean (Type A)';
      final dims = booking.carpetDimensions != null && booking.carpetDimensions!.isNotEmpty ? ' (${booking.carpetDimensions})' : '';
      return 'Dear $customerName, your carpet cleaning service ($cType$dims) is completed and ready. Please pay $amountStr. Thank you for choosing Bishe Car Wash & Carpet Cleaning Service!';
    }
    final pkgName = booking.package.name;
    final plate = booking.licensePlate;

    return 'Dear $customerName, your car washing service ($pkgName) for vehicle $plate is completed and ready to pickup. Please pay $amountStr and pick up your vehicle. Thank you for choosing Bishe Car Wash Service!';
  }

  /// Dispatches completion SMS to customer using cashier's personal device SIM / SMS app
  Future<bool> sendCustomerCompletionSms(WashBooking booking) async {
    final rawPhone = booking.customerPhone.trim();
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final message = getCustomerCompletionSmsText(booking);

    debugPrint('--- [SMS DISPATCH GATEWAY] ---');
    debugPrint('From Cashier: $_cashierSmsPhone');
    debugPrint('To Customer: $cleanPhone');
    debugPrint('Message: $message');
    debugPrint('------------------------------');

    if (cleanPhone.isNotEmpty) {
      try {
        final uriStr = 'sms:$cleanPhone?body=${Uri.encodeComponent(message)}';
        UrlLauncherHelper.openUrl(uriStr);
        return true;
      } catch (e) {
        debugPrint('SMS launcher error: $e');
      }
    }
    return true;
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
    double tipAmount = 0.0,
    String? transactionRef,
    String? receiptScreenshot,
  }) async {
    await _repository.processPayment(
      bookingId: bookingId,
      method: method,
      amount: amount,
      tipAmount: tipAmount,
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
    int skillSeniorityLevel = 2,
  }) => addNewStaff(
    name: name,
    phone: phone,
    role: role,
    baseSalary: baseSalary,
    commissionRate: commissionRate,
    skillSeniorityLevel: skillSeniorityLevel,
  );

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
    bool isCarpet = false,
    String? carpetType,
    double? carpetAreaSqMeters,
    String? carpetDimensions,
    double? customTotalPrice,
    double tipAmount = 0.0,
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
    isCarpet: isCarpet,
    carpetType: carpetType,
    carpetAreaSqMeters: carpetAreaSqMeters,
    carpetDimensions: carpetDimensions,
    customTotalPrice: customTotalPrice,
    tipAmount: tipAmount,
  );

  /// Admin edits service pricing by car type
  Future<void> updateServicePrice({
    required String packageId,
    required CarType carType,
    required double newPrice,
  }) async {
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.updatePrice,
        title: 'Price Update for ${carType.displayName}',
        description: 'Update price of package $packageId to $newPrice ETB',
        payload: {
          'packageId': packageId,
          'carType': carType,
          'newPrice': newPrice,
        },
      );
      return;
    }
    await _repository.updatePackagePrice(packageId, carType, newPrice);
    await _refreshPricing();
  }

  /// Admin manages staff base salaries and commission rates
  Future<void> updateStaffSalary({
    required String staffId,
    required double baseSalary,
    required double commissionRate,
  }) async {
    if (!_isSuperAdmin) {
      final staff = _staff.firstWhere((s) => s.id == staffId, orElse: () => StaffMember(id: staffId, name: 'Staff', phone: '', role: StaffRole.washer, baseSalaryMonthlyETB: baseSalary));
      submitPendingApproval(
        actionType: ApprovalActionType.updateSalary,
        title: 'Update Salary for ${staff.name}',
        description: 'Base: $baseSalary ETB, Commission: ${(commissionRate * 100).toInt()}%',
        payload: {
          'staffId': staffId,
          'baseSalary': baseSalary,
          'commissionRate': commissionRate,
        },
      );
      return;
    }
    await _repository.updateStaffSalary(staffId, baseSalary, commissionRate);
    await _refreshStaff();
  }

  /// Admin adds a new staff member (washer, cashier, or secondary admin)
  Future<void> addNewStaff({
    required String name,
    required String phone,
    required StaffRole role,
    required double baseSalary,
    double commissionRate = AppConstants.defaultCommissionRate,
    int skillSeniorityLevel = 2,
  }) async {
    final newMember = StaffMember(
      id: 'stf-${(_staff.length + 1).toString().padLeft(2, '0')}',
      name: name,
      phone: phone,
      role: role,
      baseSalaryMonthlyETB: baseSalary,
      commissionRate: commissionRate,
      skillSeniorityLevel: skillSeniorityLevel,
    );

    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.addStaff,
        title: 'Add ${role.name.toUpperCase()}: $name',
        description: 'Phone: $phone, Salary: $baseSalary ETB',
        payload: {'staff': newMember},
      );
      return;
    }
    await _repository.addStaffMember(newMember);
    await _refreshStaff();
  }

  /// Delete a staff member (washer, cashier, or secondary admin)
  Future<void> deleteStaffMember(String staffId) async {
    final staff = _staff.firstWhere((s) => s.id == staffId, orElse: () => StaffMember(id: staffId, name: 'Staff', phone: '', role: StaffRole.washer, baseSalaryMonthlyETB: 0));
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.deleteStaff,
        title: 'Delete ${staff.role.name.toUpperCase()}: ${staff.name}',
        description: 'Remove staff member from station personnel',
        payload: {'staffId': staffId},
      );
      return;
    }
    await _repository.deleteStaffMember(staffId);
    await _refreshStaff();
  }

  /// Admin updates staff login pin & name
  Future<void> updateStaffCredential({
    required String id,
    required String pin,
    required String fullName,
  }) async {
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.changePin,
        title: 'Change PIN for $fullName',
        description: 'Set new PIN: $pin',
        payload: {
          'id': id,
          'pin': pin,
          'fullName': fullName,
        },
      );
      return;
    }
    await _repository.updateStaffCredential(id, pin, fullName);
    await _refreshCredentials();
  }

  /// Admin creates a new staff login credential (cashier or secondary admin)
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
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.changePin,
        title: 'Create ${role.name.toUpperCase()} PIN: $fullName',
        description: 'Username: @$username',
        payload: {'cred': cred},
      );
      return;
    }
    await _repository.addStaffCredential(cred);
    await _refreshCredentials();
  }

  /// Delete staff credential (PIN)
  Future<void> deleteStaffCredential(String id) async {
    final cred = _credentials.firstWhere((c) => c.id == id, orElse: () => StaffCredential(id: id, username: '', pin: '', role: UserRole.cashier, fullName: 'Staff', isActive: true));
    if (!_isSuperAdmin) {
      submitPendingApproval(
        actionType: ApprovalActionType.changePin,
        title: 'Delete PIN for ${cred.fullName}',
        description: 'Remove login access for @${cred.username}',
        payload: {'id': id, 'action': 'delete'},
      );
      return;
    }
    await _repository.deleteStaffCredential(id);
    await _refreshCredentials();
  }

  Future<void> _refreshBookingsAndBays() async {
    _bays = await _repository.getBays();
    _bookings = await _repository.getBookings();
    _commissionLogs = await _repository.getCommissionLogs();
    notifyListeners();
  }

  // --- Inventory & Stock Management (Option B Audited) ---

  Future<void> saveFixedAsset(FixedAsset asset) async {
    final idx = _fixedAssets.indexWhere((a) => a.id == asset.id);
    if (idx != -1) {
      _fixedAssets[idx] = asset;
    } else {
      _fixedAssets.add(asset);
    }
    notifyListeners();
    await _repository.saveFixedAsset(asset);
  }

  Future<void> decommissionFixedAsset(String id, String reason) async {
    final idx = _fixedAssets.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final updated = _fixedAssets[idx].copyWith(
        condition: AssetCondition.decommissioned,
        decommissionReason: reason,
      );
      _fixedAssets[idx] = updated;
      notifyListeners();
      await _repository.saveFixedAsset(updated);
    }
  }

  Future<bool> deleteFixedAsset(String id) async {
    if (!isSuperAdmin) {
      return false; // Option B: Only Super Admin can permanently delete
    }
    _fixedAssets.removeWhere((a) => a.id == id);
    notifyListeners();
    await _repository.deleteFixedAsset(id);
    return true;
  }

  Future<void> saveConsumable(ConsumableItem item) async {
    final idx = _consumables.indexWhere((c) => c.id == item.id);
    if (idx != -1) {
      _consumables[idx] = item;
    } else {
      _consumables.add(item);
    }
    notifyListeners();
    await _repository.saveConsumable(item);
  }

  Future<void> receiveStock({
    required String itemId,
    required double quantity,
    required double unitCostEtb,
    required String supplier,
    String? unit,
    String? invoiceScreenshot,
    String notes = '',
  }) async {
    final idx = _consumables.indexWhere((c) => c.id == itemId);
    if (idx != -1) {
      final item = _consumables[idx];
      final newStock = item.currentStock + quantity;
      final updated = item.copyWith(
        currentStock: newStock,
        unit: (unit != null && unit.isNotEmpty) ? unit : item.unit,
        unitCostEtb: unitCostEtb > 0 ? unitCostEtb : item.unitCostEtb,
      );
      _consumables[idx] = updated;

      final tx = StockTransaction(
        id: 'STX-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        itemId: item.id,
        itemName: item.name,
        type: 'receiveStock',
        quantity: quantity,
        unit: unit ?? item.unit,
        unitCostEtb: unitCostEtb,
        totalCostEtb: quantity * unitCostEtb,
        supplier: supplier,
        invoiceScreenshot: invoiceScreenshot,
        notes: notes,
      );
      _stockTransactions.insert(0, tx);
      notifyListeners();

      await _repository.saveConsumable(updated);
      await _repository.recordStockTransaction(tx);
    }
  }

  Future<void> exchangeConsumableEmptyForNew({
    required String itemId,
    required double quantity,
    required String washerTeamLeaderName,
    String? notes,
  }) async {
    final idx = _consumables.indexWhere((c) => c.id == itemId);
    if (idx != -1) {
      final item = _consumables[idx];
      final newStock = (item.currentStock - quantity).clamp(0.0, double.infinity);
      final updated = item.copyWith(currentStock: newStock);
      _consumables[idx] = updated;

      final tx = StockTransaction(
        id: 'EXCH-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        itemId: item.id,
        itemName: item.name,
        type: 'emptyExchangeConsumption',
        quantity: quantity,
        unit: item.unit,
        unitCostEtb: item.unitCostEtb,
        totalCostEtb: quantity * item.unitCostEtb,
        supplier: washerTeamLeaderName,
        notes: (notes != null && notes.isNotEmpty)
            ? '$washerTeamLeaderName returned $quantity empty ${item.unit} & received fresh full container(s). $notes'
            : '$washerTeamLeaderName returned $quantity empty ${item.unit} & received fresh full container(s).',
      );
      _stockTransactions.insert(0, tx);
      notifyListeners();

      await _repository.saveConsumable(updated);
      await _repository.recordStockTransaction(tx);
    }
  }

  Future<void> decommissionConsumable(String id, String reason) async {
    final idx = _consumables.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final updated = _consumables[idx].copyWith(
        isDecommissioned: true,
        decommissionReason: reason,
      );
      _consumables[idx] = updated;
      notifyListeners();
      await _repository.saveConsumable(updated);
    }
  }

  Future<bool> deleteConsumable(String id) async {
    if (!isSuperAdmin) {
      return false; // Option B: Only Super Admin can permanently delete
    }
    _consumables.removeWhere((c) => c.id == id);
    notifyListeners();
    await _repository.deleteConsumable(id);
    return true;
  }

  Future<void> startDailyHandover({
    required String washerTeamLeaderName,
    required Map<String, double> issuedQuantities,
    String notes = '',
  }) async {
    final handover = DailyHandover(
      id: 'DHO-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      washerTeamLeaderName: washerTeamLeaderName,
      issuedQuantities: issuedQuantities,
      status: HandoverStatus.active,
      checkedOutAt: DateTime.now(),
      notes: notes,
    );
    _dailyHandovers.insert(0, handover);
    notifyListeners();
    await _repository.saveDailyHandover(handover);
  }

  Future<void> completeDailyHandover({
    required String handoverId,
    required Map<String, double> returnedQuantities,
    String notes = '',
  }) async {
    final idx = _dailyHandovers.indexWhere((h) => h.id == handoverId);
    if (idx != -1) {
      final active = _dailyHandovers[idx];
      final consumed = <String, double>{};

      active.issuedQuantities.forEach((itemId, issued) {
        final returned = returnedQuantities[itemId] ?? 0.0;
        final netConsumed = (issued - returned).clamp(0.0, double.infinity);
        consumed[itemId] = netConsumed;

        // Decrement consumable stock
        final cIdx = _consumables.indexWhere((c) => c.id == itemId);
        if (cIdx != -1) {
          final cItem = _consumables[cIdx];
          final updatedStock = (cItem.currentStock - netConsumed).clamp(0.0, double.infinity);
          final updatedItem = cItem.copyWith(currentStock: updatedStock);
          _consumables[cIdx] = updatedItem;
          _repository.saveConsumable(updatedItem);

          if (netConsumed > 0) {
            final tx = StockTransaction(
              id: 'STX-${DateTime.now().millisecondsSinceEpoch}-$itemId',
              date: DateTime.now(),
              itemId: itemId,
              itemName: cItem.name,
              type: 'dailyConsumption',
              quantity: netConsumed,
              unitCostEtb: cItem.unitCostEtb,
              totalCostEtb: netConsumed * cItem.unitCostEtb,
              notes: 'Daily Handover consumed by ${active.washerTeamLeaderName} team',
            );
            _stockTransactions.insert(0, tx);
            _repository.recordStockTransaction(tx);
          }
        }
      });

      final todayWashes = _bookings.where((b) => b.status == WashStatus.completed).length;

      final completed = active.copyWith(
        returnedQuantities: returnedQuantities,
        consumedQuantities: consumed,
        status: HandoverStatus.completed,
        checkedInAt: DateTime.now(),
        carsWashedDuringShift: todayWashes,
        notes: notes.isNotEmpty ? notes : active.notes,
      );

      _dailyHandovers[idx] = completed;
      notifyListeners();
      await _repository.saveDailyHandover(completed);
    }
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
