import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/daily_financial_closing.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/staff_authenticator.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_wash_service_item.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/customer_feedback.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/consumable_item.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/daily_handover.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/stock_transaction.dart';
import 'package:bishe_car_wash/features/cashier/domain/models/bank_incoming_transaction.dart';
import 'package:bishe_car_wash/features/cashier/domain/models/retail_sale_record.dart';
import 'package:bishe_car_wash/features/cashier/domain/models/sentinel_config.dart';

class SupabaseWashRepositoryImpl implements IWashRepository {
  static const String _handoverMetaPrefix = '[HANDOVER_META:';

  static String? extractCleanNotes(String? rawNotes) {
    if (rawNotes == null) return null;
    final idx = rawNotes.indexOf(_handoverMetaPrefix);
    final trimmed = (idx == -1 ? rawNotes : rawNotes.substring(0, idx)).trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String encodeClosingNotesWithMeta(DailyFinancialClosing closing) {
    final cleanNote = extractCleanNotes(closing.notes);
    final meta = {
      'shiftType': closing.shiftType,
      'closedByRole': closing.closedByRole,
      'handoverTo': closing.handoverTo,
      'handoverCashAmount': closing.handoverCashAmount,
      'isHandoverAccepted': closing.isHandoverAccepted,
      'acceptedByName': closing.acceptedByName,
      'acceptedAt': closing.acceptedAt?.toIso8601String(),
      'carriedCashAmount': closing.carriedCashAmount,
      'handoverMethod': closing.handoverMethod,
      'handoverOtp': closing.handoverOtp,
      'bankAccountName': closing.bankAccountName,
      'bankAccountNumber': closing.bankAccountNumber,
      'depositSlipRef': closing.depositSlipRef,
      'carpetsCleanedCount': closing.carpetsCleanedCount,
      'carpetRevenue': closing.carpetRevenue,
      'showerUsersCount': closing.showerUsersCount,
      'showerRevenue': closing.showerRevenue,
      'retailSalesCount': closing.retailSalesCount,
      'retailRevenue': closing.retailRevenue,
      'retailCogs': closing.retailCogs,
      'totalTipsAmount': closing.totalTipsAmount,
    };
    final tag = '$_handoverMetaPrefix${jsonEncode(meta)}]';
    return (cleanNote == null || cleanNote.isEmpty) ? tag : '$cleanNote\n$tag';
  }

  static DailyFinancialClosing applyHandoverMetaToClosing(
    DailyFinancialClosing base,
    String? rawNotes,
  ) {
    if (rawNotes == null) return base;
    final startIdx = rawNotes.indexOf(_handoverMetaPrefix);
    if (startIdx == -1) return base;
    final jsonStart = startIdx + _handoverMetaPrefix.length;
    final endIdx = rawNotes.lastIndexOf(']');
    if (endIdx <= jsonStart) return base;
    try {
      final decoded = jsonDecode(rawNotes.substring(jsonStart, endIdx));
      if (decoded is Map<String, dynamic>) {
        return DailyFinancialClosing(
          id: base.id,
          closingDate: base.closingDate,
          closedAt: base.closedAt,
          cashierName: base.cashierName,
          grossRevenue: base.grossRevenue,
          cashRevenue: base.cashRevenue,
          digitalRevenue: base.digitalRevenue,
          providerBreakdown: base.providerBreakdown,
          carsWashedCount: base.carsWashedCount,
          carpetsCleanedCount: (decoded['carpetsCleanedCount'] as num?)?.toInt() ?? base.carpetsCleanedCount,
          carpetRevenue: (decoded['carpetRevenue'] as num?)?.toDouble() ?? base.carpetRevenue,
          showerUsersCount: (decoded['showerUsersCount'] as num?)?.toInt() ?? base.showerUsersCount,
          showerRevenue: (decoded['showerRevenue'] as num?)?.toDouble() ?? base.showerRevenue,
          retailSalesCount: (decoded['retailSalesCount'] as num?)?.toInt() ?? base.retailSalesCount,
          retailRevenue: (decoded['retailRevenue'] as num?)?.toDouble() ?? base.retailRevenue,
          retailCogs: (decoded['retailCogs'] as num?)?.toDouble() ?? base.retailCogs,
          totalTipsAmount: (decoded['totalTipsAmount'] as num?)?.toDouble() ?? base.totalTipsAmount,
          commissionPool: base.commissionPool,
          netStationProfit: base.netStationProfit,
          cashDeposited: base.cashDeposited,
          pettyCashExpenses: base.pettyCashExpenses,
          cashRemaining: base.cashRemaining,
          washerDividends: base.washerDividends,
          notes: extractCleanNotes(rawNotes),
          isConfirmed: base.isConfirmed,
          shiftType: decoded['shiftType']?.toString() ?? base.shiftType,
          closedByRole: decoded['closedByRole']?.toString() ?? base.closedByRole,
          handoverTo: decoded['handoverTo']?.toString() ?? base.handoverTo,
          handoverCashAmount: (decoded['handoverCashAmount'] as num?)?.toDouble() ?? base.handoverCashAmount,
          isHandoverAccepted: decoded['isHandoverAccepted'] == true,
          acceptedByName: decoded['acceptedByName']?.toString(),
          acceptedAt: decoded['acceptedAt'] != null ? DateTime.tryParse(decoded['acceptedAt'].toString()) : null,
          carriedCashAmount: (decoded['carriedCashAmount'] as num?)?.toDouble() ?? base.carriedCashAmount,
          handoverMethod: decoded['handoverMethod']?.toString() ?? base.handoverMethod,
          handoverOtp: decoded['handoverOtp']?.toString(),
          bankAccountName: decoded['bankAccountName']?.toString(),
          bankAccountNumber: decoded['bankAccountNumber']?.toString(),
          depositSlipRef: decoded['depositSlipRef']?.toString(),
        );
      }
    } catch (e) {
      debugPrint('Failed to decode closing handover meta: $e');
    }
    return base;
  }

  static const String _bookingMetaPrefix = '[BOOKING_META:';

  static String? extractCleanDeliveryLocation(String? raw) {
    if (raw == null) return null;
    final idx = raw.indexOf(_bookingMetaPrefix);
    final trimmed = (idx == -1 ? raw : raw.substring(0, idx)).trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, dynamic> decodeBookingMeta(String? raw) {
    if (raw == null) return const {};
    final startIdx = raw.indexOf(_bookingMetaPrefix);
    if (startIdx == -1) return const {};
    final jsonStart = startIdx + _bookingMetaPrefix.length;
    final endIdx = raw.lastIndexOf(']');
    if (endIdx <= jsonStart) return const {};
    try {
      final decoded = jsonDecode(raw.substring(jsonStart, endIdx));
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return const {};
  }

  static String? encodeDeliveryLocationWithMeta({
    required String? baseText,
    required bool isOnlineBooking,
    required bool isPostponed,
    String? postponedReason,
    DateTime? postponedAt,
    String? postponedByRole,
    bool isHandedOverToManager = false,
    String? handedOverBy,
    String? handoverNote,
    DateTime? handedOverAt,
    String? gpsCoordinates,
    DateTime? paidAt,
    double splitCashAmount = 0.0,
    double splitDigitalAmount = 0.0,
    String overpaymentAction = 'none',
    String verificationStatus = 'unverified',
    String? collectedByRole,
    String? collectedByName,
  }) {
    final clean = extractCleanDeliveryLocation(baseText);
    if (!isOnlineBooking && !isPostponed && !isHandedOverToManager && paidAt == null && (gpsCoordinates == null || gpsCoordinates.isEmpty) && splitCashAmount <= 0 && splitDigitalAmount <= 0 && overpaymentAction == 'none' && verificationStatus == 'unverified' && (collectedByRole == null || collectedByRole.isEmpty) && (collectedByName == null || collectedByName.isEmpty)) {
      return clean;
    }
    final meta = <String, dynamic>{
      if (isOnlineBooking) 'isOnline': true,
      if (isPostponed) 'isPostponed': true,
      if (postponedReason != null && postponedReason.isNotEmpty) 'postponedReason': postponedReason,
      if (postponedAt != null) 'postponedAt': postponedAt.toIso8601String(),
      if (postponedByRole != null && postponedByRole.isNotEmpty) 'postponedByRole': postponedByRole,
      if (isHandedOverToManager) 'isHandedOverToManager': true,
      if (handedOverBy != null && handedOverBy.isNotEmpty) 'handedOverBy': handedOverBy,
      if (handoverNote != null && handoverNote.isNotEmpty) 'handoverNote': handoverNote,
      if (handedOverAt != null) 'handedOverAt': handedOverAt.toIso8601String(),
      if (gpsCoordinates != null && gpsCoordinates.isNotEmpty) 'gps': gpsCoordinates,
      if (paidAt != null) 'paidAt': paidAt.toIso8601String(),
      if (splitCashAmount > 0) 'splitCash': splitCashAmount,
      if (splitDigitalAmount > 0) 'splitDigital': splitDigitalAmount,
      if (overpaymentAction != 'none') 'overpaymentAction': overpaymentAction,
      if (verificationStatus != 'unverified') 'verifStatus': verificationStatus,
      if (collectedByRole != null && collectedByRole.isNotEmpty) 'collectedByRole': collectedByRole,
      if (collectedByName != null && collectedByName.isNotEmpty) 'collectedByName': collectedByName,
    };
    final tag = '$_bookingMetaPrefix${jsonEncode(meta)}]';
    return (clean == null || clean.isEmpty) ? tag : '$clean\n$tag';
  }

  static String? _encodeMetaFromBooking(WashBooking b) {
    final baseLoc = b.deliveryLocation ??
        (b.selectedServices != null && b.selectedServices!.isNotEmpty
            ? 'Services: ${b.selectedServices!.join(", ")}'
            : b.gpsCoordinates);
    return encodeDeliveryLocationWithMeta(
      baseText: baseLoc,
      isOnlineBooking: b.isOnlineBooking,
      isPostponed: b.isPostponed,
      postponedReason: b.postponedReason,
      postponedAt: b.postponedAt,
      postponedByRole: b.postponedByRole,
      isHandedOverToManager: b.isHandedOverToManager,
      handedOverBy: b.handedOverBy,
      handoverNote: b.handoverNote,
      handedOverAt: b.handedOverAt,
      gpsCoordinates: b.gpsCoordinates,
      paidAt: b.payment.paidAt,
      splitCashAmount: b.payment.splitCashAmount,
      splitDigitalAmount: b.payment.splitDigitalAmount,
      overpaymentAction: b.payment.overpaymentAction,
      verificationStatus: b.payment.verificationStatus,
      collectedByRole: b.payment.collectedByRole,
      collectedByName: b.payment.collectedByName,
    );
  }

  final String supabaseUrl;
  final String anonKey;
  final http.Client? _httpClient;
  final WashRepositoryImpl _fallbackLocalRepo = WashRepositoryImpl();
  static DateTime _dataPurgeEpoch = DateTime.parse('2026-11-06T16:25:00Z');
  String? _lastClosingSyncError;

  // In-memory caches to eliminate redundant network roundtrips and cut egress by >90%
  List<WashPackage>? _cachedPackages;
  DateTime? _packagesFetchedAt;
  static const Duration _packagesCacheTtl = Duration(minutes: 15);

  List<StaffMember>? _cachedStaff;
  DateTime? _staffFetchedAt;
  static const Duration _staffCacheTtl = Duration(minutes: 15);

  List<StationBay>? _cachedBays;
  DateTime? _baysFetchedAt;
  static const Duration _baysCacheTtl = Duration(seconds: 30);

  @override
  String? get lastClosingSyncError => _lastClosingSyncError;

  @override
  void clearClosingSyncError() {
    _lastClosingSyncError = null;
  }

  SupabaseWashRepositoryImpl({
    required this.supabaseUrl,
    required this.anonKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  bool _isUuid(String? str) {
    if (str == null || str.length != 36) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str);
  }

  Future<dynamic> _get(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = _httpClient;
      final response = client != null
          ? await client.get(uri, headers: _headers)
          : await http.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      debugPrint('Supabase GET [$endpoint] error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Supabase GET [$endpoint] exception: $e');
      return null;
    }
  }

  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final encodedBody = jsonEncode(data);
      final client = _httpClient;
      final response = client != null
          ? await client.post(uri, headers: _headers, body: encodedBody)
          : await http.post(uri, headers: _headers, body: encodedBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : [];
      }
      debugPrint('Supabase POST [$endpoint] error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Supabase POST [$endpoint] exception: $e');
      return null;
    }
  }

  Future<dynamic> _patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final encodedBody = jsonEncode(data);
      final client = _httpClient;
      final response = client != null
          ? await client.patch(uri, headers: _headers, body: encodedBody)
          : await http.patch(uri, headers: _headers, body: encodedBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : [];
      }
      debugPrint('Supabase PATCH [$endpoint] error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Supabase PATCH [$endpoint] exception: $e');
      return null;
    }
  }

  Future<bool> _delete(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = _httpClient;
      final response = client != null
          ? await client.delete(uri, headers: _headers)
          : await http.delete(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint('Supabase DELETE [$endpoint] error ${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Supabase DELETE [$endpoint] exception: $e');
      return false;
    }
  }

  @override
  Future<List<WashPackage>> getPackages() async {
    if (_cachedPackages != null &&
        _packagesFetchedAt != null &&
        DateTime.now().difference(_packagesFetchedAt!) < _packagesCacheTtl) {
      return _cachedPackages!;
    }
    try {
      final dynamic data = await _get('wash_packages?select=*&order=created_at.asc');
      if (data == null || data is! List || data.isEmpty) {
        return await _fallbackLocalRepo.getPackages();
      }

      final packages = data.map((json) {
        final double autoPrice = double.tryParse(json['price_automobile']?.toString() ?? '300') ?? 300.0;
        final double minibusPrice = double.tryParse(json['price_minibus']?.toString() ?? '450') ?? 450.0;
        final double truckPrice = double.tryParse(json['price_truck']?.toString() ?? '600') ?? 600.0;

        List<String> features = [];
        if (json['features'] != null) {
          if (json['features'] is List) {
            features = List<String>.from(json['features']);
          }
        }

        return WashPackage(
          id: json['id'].toString(),
          name: json['name'] ?? 'Custom Wash',
          description: json['description'] ?? '',
          durationMinutes: json['estimated_minutes'] ?? 30,
          pricingByCarType: {
            CarType.automobile: autoPrice,
            CarType.minibus: minibusPrice,
            CarType.truck: truckPrice,
          },
          features: features,
        );
      }).toList();

      _cachedPackages = packages;
      _packagesFetchedAt = DateTime.now();
      return packages;
    } catch (_) {
      return await _fallbackLocalRepo.getPackages();
    }
  }

  @override
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice) async {
    _cachedPackages = null;
    _packagesFetchedAt = null;
    try {
      if (_isUuid(packageId)) {
        String colName = 'price_automobile';
        if (carType == CarType.minibus) colName = 'price_minibus';
        if (carType == CarType.truck) colName = 'price_truck';
        await _patch('wash_packages?id=eq.$packageId', {colName: newPrice});
      }
    } catch (_) {}
    await _fallbackLocalRepo.updatePackagePrice(packageId, carType, newPrice);
  }

  @override
  Future<List<CarWashServiceItem>> getServiceItems() async {
    try {
      final dynamic data = await _get('staff_credentials?username=eq.app_config_service_items&select=*');
      if (data is List && data.isNotEmpty) {
        final rawJson = data.first['full_name']?.toString() ?? '';
        if (rawJson.isNotEmpty) {
          final dynamic decoded = jsonDecode(rawJson);
          if (decoded is List && decoded.isNotEmpty) {
            return decoded
                .map((e) => CarWashServiceItem.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Supabase getServiceItems exception: $e');
    }
    return _fallbackLocalRepo.getServiceItems();
  }

  @override
  Future<void> saveServiceItems(List<CarWashServiceItem> items) async {
    try {
      final jsonPayload = jsonEncode(items.map((i) => i.toMap()).toList());
      final dynamic existing = await _get('staff_credentials?username=eq.app_config_service_items&select=id');
      if (existing is List && existing.isNotEmpty) {
        await _patch('staff_credentials?username=eq.app_config_service_items', {
          'full_name': jsonPayload,
          'is_active': true,
        });
      } else {
        await _post('staff_credentials', {
          'username': 'app_config_service_items',
          'pin_hash': '4450',
          'role': 'admin',
          'full_name': jsonPayload,
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('Supabase saveServiceItems exception: $e');
    }
    await _fallbackLocalRepo.saveServiceItems(items);
  }

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    if (_cachedStaff != null &&
        _staffFetchedAt != null &&
        DateTime.now().difference(_staffFetchedAt!) < _staffCacheTtl) {
      return _cachedStaff!;
    }
    try {
      final dynamic data = await _get('staff_members?select=*&order=created_at.asc');
      if (data == null || data is! List) {
        return await _fallbackLocalRepo.getStaffMembers();
      }
      if (data.isEmpty) {
        _cachedStaff = [];
        _staffFetchedAt = DateTime.now();
        return [];
      }

      final staff = data.map((json) {
        StaffRole role = StaffRole.washer;
        final roleStr = (json['role'] ?? '').toString().toLowerCase();
        if (roleStr.contains('lead') || roleStr.contains('detailer')) {
          role = StaffRole.leadDetailer;
        } else if (roleStr.contains('cashier')) {
          role = StaffRole.cashier;
        } else if (roleStr.contains('admin')) {
          role = StaffRole.admin;
        }

        return StaffMember(
          id: json['id'].toString(),
          name: json['name'] ?? 'Staff',
          phone: json['phone'] ?? '',
          role: role,
          baseSalaryMonthlyETB: double.tryParse(json['base_salary']?.toString() ?? '5000') ?? 5000.0,
          commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '0.15') ?? 0.15,
          isAvailable: json['is_active'] ?? true,
          completedWashesCount: 0,
          totalCommissionEarnedETB: 0.0,
        );
      }).toList();

      _cachedStaff = staff;
      _staffFetchedAt = DateTime.now();
      return staff;
    } catch (_) {
      return await _fallbackLocalRepo.getStaffMembers();
    }
  }

  @override
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate) async {
    _cachedStaff = null;
    _staffFetchedAt = null;
    try {
      if (_isUuid(staffId)) {
        await _patch('staff_members?id=eq.$staffId', {
          'base_salary': baseSalary,
          'commission_rate': commissionRate,
        });
      }
    } catch (_) {}
    await _fallbackLocalRepo.updateStaffSalary(staffId, baseSalary, commissionRate);
  }

  @override
  Future<void> addStaffMember(StaffMember staff) async {
    _cachedStaff = null;
    _staffFetchedAt = null;
    try {
      await _post('staff_members', {
        'name': staff.name,
        'role': staff.role.name,
        'phone': staff.phone,
        'base_salary': staff.baseSalaryMonthlyETB,
        'commission_rate': staff.commissionRate,
        'is_active': true,
      });
    } catch (_) {}
    await _fallbackLocalRepo.addStaffMember(staff);
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    _cachedStaff = null;
    _staffFetchedAt = null;
    try {
      if (_isUuid(staffId)) {
        await _delete('staff_members?id=eq.$staffId');
      }
    } catch (e) {
      debugPrint('Supabase deleteStaffMember exception: $e');
    }
    await _fallbackLocalRepo.deleteStaffMember(staffId);
  }

  @override
  Future<List<StationBay>> getBays() async {
    if (_cachedBays != null &&
        _baysFetchedAt != null &&
        DateTime.now().difference(_baysFetchedAt!) < _baysCacheTtl) {
      return _cachedBays!;
    }
    try {
      final dynamic data = await _get('station_bays?select=*&order=bay_number.asc');
      if (data == null || data is! List) {
        return await _fallbackLocalRepo.getBays();
      }
      if (data.isEmpty) {
        return const [
          StationBay(type: BayType.bay1, status: BayStatus.vacant),
          StationBay(type: BayType.bay2, status: BayStatus.vacant),
          StationBay(type: BayType.mobileVan, status: BayStatus.vacant),
        ];
      }

      final bays = data.map((json) {
        BayType bayType = BayType.bay1;
        final typeStr = (json['bay_type'] ?? '').toString();
        if (typeStr == 'bay2' || json['bay_number'] == 2) {
          bayType = BayType.bay2;
        } else if (typeStr == 'mobileVan' || json['bay_number'] == 3) {
          bayType = BayType.mobileVan;
        }

        final isOccupied = json['is_occupied'] == true;

        return StationBay(
          type: bayType,
          status: isOccupied ? BayStatus.occupied : BayStatus.vacant,
          activeBookingId: json['current_booking_id']?.toString(),
          activeLicensePlate: json['active_license_plate'],
          assignedWasherName: json['assigned_washer_name'],
          startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at']) : null,
        );
      }).toList();

      _cachedBays = bays;
      _baysFetchedAt = DateTime.now();
      return bays;
    } catch (_) {
      return await _fallbackLocalRepo.getBays();
    }
  }

  WashBooking _mapBookingFromJson(dynamic json, List<WashPackage> packages) {
    CarType carType = CarType.automobile;
    final carStr = (json['car_type'] ?? '').toString().toLowerCase();
    if (carStr.contains('truck')) {
      carType = CarType.truck;
    } else if (carStr.contains('minibus') || carStr.contains('large')) {
      carType = CarType.minibus;
    }

    ServiceType serviceType = ServiceType.walkInStation;
    final stStr = (json['service_type'] ?? '').toString();
    if (stStr.contains('atHome')) {
      serviceType = ServiceType.atHomeMobile;
    } else if (stStr.contains('valet') || stStr.contains('pickUp')) {
      serviceType = ServiceType.valetPickUp;
    } else if (stStr.contains('phone')) {
      serviceType = ServiceType.phoneCallBooking;
    }

    WashStatus status = WashStatus.pending;
    for (var s in WashStatus.values) {
      if (s.name == json['status']) {
        status = s;
        break;
      }
    }

    WashPackage pkg = packages.isNotEmpty
        ? packages.first
        : const WashPackage(
            id: 'pkg-standard',
            name: 'Standard Wash',
            description: 'Standard exterior body wash',
            durationMinutes: 30,
            pricingByCarType: {
              CarType.automobile: 350.0,
              CarType.minibus: 450.0,
              CarType.truck: 650.0,
            },
            features: ['Foam wash', 'Rinse', 'Tire shine'],
          );
    if (json['package_id'] != null) {
      final found = packages.where((p) => p.id == json['package_id'].toString());
      if (found.isNotEmpty) pkg = found.first;
    }

    BayType? assignedBay;
    final bayIdStr = json['assigned_bay_id']?.toString();
    if (bayIdStr == 'b0000000-0000-0000-0000-000000000001') {
      assignedBay = BayType.bay1;
    } else if (bayIdStr == 'b0000000-0000-0000-0000-000000000002') {
      assignedBay = BayType.bay2;
    } else if (bayIdStr == 'b0000000-0000-0000-0000-000000000003') {
      assignedBay = BayType.mobileVan;
    }

    PaymentMethod pMethod = PaymentMethod.cash;
    final mStr = (json['payment_method'] ?? '').toString().toLowerCase();
    if (mStr.contains('telebirr')) {
      pMethod = PaymentMethod.telebirr;
    } else if (mStr.contains('cbe')) {
      pMethod = PaymentMethod.cbeBirr;
    } else if (mStr.contains('abyssinia') || mStr.contains('boa')) {
      pMethod = PaymentMethod.bankOfAbyssinia;
    } else if (mStr.contains('awash')) {
      pMethod = PaymentMethod.awashBank;
    } else if (mStr.contains('dashen') || mStr.contains('amole')) {
      pMethod = PaymentMethod.dashenBank;
    } else if (mStr.contains('bank')) {
      pMethod = PaymentMethod.otherBankTransfer;
    }

    final isPhone = json['booking_origin'] == 'phone_booking';
    final rawPlate = json['license_plate']?.toString() ?? '';
    final isCarpet = (json['is_carpet'] == true) || rawPlate.startsWith('CPT-');
    final carpetType = json['carpet_type']?.toString();
    final carpetAreaSqMeters = json['carpet_area_sq_meters'] != null
        ? double.tryParse(json['carpet_area_sq_meters'].toString())
        : null;
    final carpetDimensions = json['carpet_dimensions']?.toString();
    final customTotalPrice = json['custom_total_price'] != null
        ? double.tryParse(json['custom_total_price'].toString())
        : (json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null);

    final rawLoc = json['delivery_location']?.toString();
    final cleanLoc = extractCleanDeliveryLocation(rawLoc);
    final bookingMeta = decodeBookingMeta(rawLoc);

    List<String>? selectedServices;
    if (json['selected_services'] != null) {
      if (json['selected_services'] is List) {
        selectedServices = (json['selected_services'] as List).map((e) => e.toString()).toList();
      } else if (json['selected_services'] is String) {
        try {
          final dec = jsonDecode(json['selected_services']);
          if (dec is List) selectedServices = dec.map((e) => e.toString()).toList();
        } catch (_) {}
      }
    }
    if (selectedServices == null && cleanLoc != null) {
      if (cleanLoc.startsWith('Services: ')) {
        selectedServices = cleanLoc.substring('Services: '.length).split(', ').map((s) => s.trim()).toList();
      }
    }

    final paidAt = bookingMeta['paidAt'] != null
        ? DateTime.tryParse(bookingMeta['paidAt'].toString())
        : (json['payment_meta'] != null && json['payment_meta'] is Map && json['payment_meta']['paidAt'] != null
            ? DateTime.tryParse(json['payment_meta']['paidAt'].toString())
            : (json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null));
    final postponedAt = bookingMeta['postponedAt'] != null
        ? DateTime.tryParse(bookingMeta['postponedAt'].toString())
        : null;
    final handedOverAt = bookingMeta['handedOverAt'] != null
        ? DateTime.tryParse(bookingMeta['handedOverAt'].toString())
        : null;

    return WashBooking(
      id: json['id'].toString(),
      customerName: json['owner_name'] ?? 'Customer',
      customerPhone: json['customer_phone'] ?? '',
      serviceType: serviceType,
      deliveryLocation: cleanLoc,
      carType: carType,
      licensePlate: rawPlate,
      package: pkg,
      status: status,
      assignedBay: assignedBay,
      assignedWasherId: json['assigned_washer_id']?.toString(),
      assignedWasherName: json['washer_1_name'] ?? json['washer_2_name'],
      payment: PaymentInfo(
        isPaid: json['is_paid'] ?? false,
        method: pMethod,
        amount: double.tryParse(json['total_amount']?.toString() ?? '300') ?? 300.0,
        transactionRef: json['transaction_ref'],
        receiptScreenshot: json['receipt_url'],
        paidAt: paidAt,
        splitCashAmount: double.tryParse(bookingMeta['splitCash']?.toString() ?? '0') ?? 0.0,
        splitDigitalAmount: double.tryParse(bookingMeta['splitDigital']?.toString() ?? '0') ?? 0.0,
        overpaymentAction: bookingMeta['overpaymentAction']?.toString() ?? 'none',
        verificationStatus: bookingMeta['verifStatus']?.toString() ?? 'unverified',
        collectedByRole: bookingMeta['collectedByRole']?.toString(),
        collectedByName: bookingMeta['collectedByName']?.toString(),
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      scheduledTime: json['scheduled_time'] != null ? DateTime.tryParse(json['scheduled_time'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      commissionLogged: json['commission_logged'] ?? false,
      isPhoneBooking: isPhone,
      gpsCoordinates: bookingMeta['gps']?.toString(),
      isCarpet: isCarpet,
      carpetType: carpetType,
      carpetAreaSqMeters: carpetAreaSqMeters,
      carpetDimensions: carpetDimensions,
      customTotalPrice: customTotalPrice,
      selectedServices: selectedServices,
      isOnlineBooking: bookingMeta['isOnline'] == true || json['booking_origin'] == 'customer_app',
      isPostponed: bookingMeta['isPostponed'] == true,
      postponedReason: bookingMeta['postponedReason']?.toString(),
      postponedAt: postponedAt,
      postponedByRole: bookingMeta['postponedByRole']?.toString(),
      isHandedOverToManager: bookingMeta['isHandedOverToManager'] == true,
      handedOverBy: bookingMeta['handedOverBy']?.toString(),
      handoverNote: bookingMeta['handoverNote']?.toString(),
      handedOverAt: handedOverAt,
    );
  }

  @override
  Future<List<WashBooking>> getBookings() async {
    try {
      final dynamic data = await _get('wash_bookings?select=*&order=created_at.desc&limit=60');
      if (data == null || data is! List) {
        return await _fallbackLocalRepo.getBookings();
      }
      if (data.isEmpty) {
        return [];
      }

      final packages = await getPackages();
      return data.map((json) => _mapBookingFromJson(json, packages)).toList();
    } catch (e) {
      debugPrint('Supabase getBookings exception: $e');
      return await _fallbackLocalRepo.getBookings();
    }
  }

  @override
  Future<List<WashBooking>> getPendingOnlineAlerts() async {
    try {
      final dynamic data = await _get(
        'wash_bookings?select=*&status=eq.pending&order=created_at.desc&limit=10',
      );
      if (data == null || data is! List) {
        return await _fallbackLocalRepo.getPendingOnlineAlerts();
      }
      if (data.isEmpty) {
        return [];
      }

      final packages = await getPackages();
      return data
          .map((json) => _mapBookingFromJson(json, packages))
          .where((b) => b.isOnlineBooking && b.status == WashStatus.pending)
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Supabase getPendingOnlineAlerts exception: $e');
      return await _fallbackLocalRepo.getPendingOnlineAlerts();
    }
  }

  @override
  Future<List<WashBooking>> getOlderBookings({required int offset, int limit = 50}) async {
    try {
      final dynamic data = await _get(
        'wash_bookings?select=*&order=created_at.desc&offset=$offset&limit=$limit',
      );
      if (data == null || data is! List) {
        return await _fallbackLocalRepo.getOlderBookings(offset: offset, limit: limit);
      }
      if (data.isEmpty) {
        return [];
      }

      final packages = await getPackages();
      return data.map((json) => _mapBookingFromJson(json, packages)).toList();
    } catch (e) {
      debugPrint('Supabase getOlderBookings exception: $e');
      return await _fallbackLocalRepo.getOlderBookings(offset: offset, limit: limit);
    }
  }

  @override
  Future<List<WashBooking>> getBookingsForDateRange(DateTime start, DateTime end) async {
    try {
      final startIso = start.toUtc().toIso8601String();
      final endIso = end.toUtc().toIso8601String();
      final dynamic data = await _get(
        'wash_bookings?select=*&created_at=gte.$startIso&created_at=lte.$endIso&order=created_at.desc&limit=500',
      );
      if (data == null || data is! List) {
        return await _fallbackLocalRepo.getBookingsForDateRange(start, end);
      }
      if (data.isEmpty) {
        return [];
      }

      final packages = await getPackages();
      return data.map((json) => _mapBookingFromJson(json, packages)).toList();
    } catch (e) {
      debugPrint('Supabase getBookingsForDateRange exception: $e');
      return await _fallbackLocalRepo.getBookingsForDateRange(start, end);
    }
  }

  @override
  Future<WashBooking?> getBookingById(String id) async {
    final all = await getBookings();
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<WashBooking> createBooking(WashBooking booking) async {
    try {
      final bayId = booking.assignedBay == BayType.bay1
          ? 'b0000000-0000-0000-0000-000000000001'
          : (booking.assignedBay == BayType.bay2
              ? 'b0000000-0000-0000-0000-000000000002'
              : (booking.assignedBay == BayType.mobileVan
                  ? 'b0000000-0000-0000-0000-000000000003'
                  : null));

      final payload = {
        'owner_name': booking.customerName,
        'customer_phone': booking.customerPhone,
        'car_type': booking.carType.name,
        'service_type': booking.serviceType.name,
        'package_id': _isUuid(booking.package.id) ? booking.package.id : null,
        'assigned_bay_id': bayId,
        'license_plate': booking.licensePlate,
        'delivery_location': _encodeMetaFromBooking(booking),
        'status': booking.status.name,
        'is_paid': booking.payment.isPaid,
        'payment_method': booking.payment.method.name,
        'total_amount': booking.totalPrice,
        'booking_origin': booking.isPhoneBooking ? 'phone_booking' : (booking.isOnlineBooking ? 'customer_app' : 'gate_walk_in'),
        'washer_1_name': booking.assignedWasherName,
        'washer_1_id': _isUuid(booking.assignedWasherId) ? booking.assignedWasherId : null,
        'scheduled_time': booking.scheduledTime?.toIso8601String(),
        'transaction_ref': booking.payment.transactionRef,
        'receipt_url': booking.payment.receiptScreenshot,
        'is_carpet': booking.isCarpet,
        'carpet_type': booking.carpetType,
        'carpet_area_sq_meters': booking.carpetAreaSqMeters,
        'carpet_dimensions': booking.carpetDimensions,
        'custom_total_price': booking.customTotalPrice,
      };

      dynamic res = await _post('wash_bookings', payload);
      if (res == null && booking.isCarpet) {
        // Fallback: If remote Supabase table has not run the 20261107 migration yet, omit extra columns so POST succeeds!
        final fallbackPayload = Map<String, dynamic>.from(payload)
          ..remove('is_carpet')
          ..remove('carpet_type')
          ..remove('carpet_area_sq_meters')
          ..remove('carpet_dimensions')
          ..remove('custom_total_price');
        res = await _post('wash_bookings', fallbackPayload);
      }
      if (res != null && res is List && res.isNotEmpty) {
        final newId = res.first['id'].toString();

        if (booking.assignedBay != null && !booking.isCarpet) {
          _cachedBays = null;
          _baysFetchedAt = null;
          final bayNum = booking.assignedBay == BayType.bay1 ? 1 : (booking.assignedBay == BayType.bay2 ? 2 : 3);
          await _patch('station_bays?bay_number=eq.$bayNum', {
            'is_occupied': true,
            'current_booking_id': _isUuid(newId) ? newId : null,
            'active_license_plate': booking.licensePlate,
            'assigned_washer_name': booking.assignedWasherName,
            'started_at': DateTime.now().toIso8601String(),
          });
        }

        final persistedBooking = booking.copyWith(id: newId);
        _fallbackLocalRepo.createBooking(persistedBooking);
        return persistedBooking;
      }
    } catch (e) {
      debugPrint('Supabase createBooking exception: $e');
    }
    return _fallbackLocalRepo.createBooking(booking);
  }

  @override
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus) async {
    try {
      if (_isUuid(bookingId)) {
        await _patch('wash_bookings?id=eq.$bookingId', {
          'status': newStatus.name,
          'completed_at': newStatus == WashStatus.completed ? DateTime.now().toIso8601String() : null,
        });

        final booking = await getBookingById(bookingId);
        if (booking != null && newStatus == WashStatus.completed && !booking.commissionLogged && booking.payment.isPaid) {
          if (booking.assignedBay != null && !booking.isCarpet) {
            _cachedBays = null;
            _baysFetchedAt = null;
            final bayNum = booking.assignedBay == BayType.bay1 ? 1 : (booking.assignedBay == BayType.bay2 ? 2 : 3);
            await _patch('station_bays?bay_number=eq.$bayNum', {
              'is_occupied': false,
              'current_booking_id': null,
              'active_license_plate': null,
              'assigned_washer_name': null,
            });
          }

          final washerName = (booking.assignedWasherName != null && booking.assignedWasherName!.trim().isNotEmpty)
              ? booking.assignedWasherName!.trim()
              : 'Team Washers';
          final commissionEarned = (booking.totalPrice * 0.85) * 0.15;

          await _post('commission_logs', {
            'booking_id': _isUuid(booking.id) ? booking.id : null,
            'staff_id': _isUuid(booking.assignedWasherId) ? booking.assignedWasherId : null,
            'staff_name': washerName,
            'car_type': booking.carType.name,
            'service_name': booking.package.name,
            'earned_amount': commissionEarned,
            'license_plate': booking.licensePlate,
            'is_settled': false,
            'logged_at': DateTime.now().toIso8601String(),
          });

          await _patch('wash_bookings?id=eq.$bookingId', {
            'commission_logged': true,
            'commission_amount': commissionEarned,
          });
        }

        if (booking != null) {
          final updated = booking.copyWith(
            status: newStatus,
            completedAt: newStatus == WashStatus.completed ? DateTime.now() : booking.completedAt,
            commissionLogged: newStatus == WashStatus.completed ? true : booking.commissionLogged,
          );
          try {
            await _fallbackLocalRepo.updateWashStatus(bookingId, newStatus);
          } catch (_) {}
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Supabase updateWashStatus exception: $e');
    }
    return await _fallbackLocalRepo.updateWashStatus(bookingId, newStatus);
  }

  @override
  Future<WashBooking> assignBayAndWasher({
    required String bookingId,
    required BayType bay,
    required String washerId,
    required String washerName,
  }) async {
    try {
      if (_isUuid(bookingId)) {
        _cachedBays = null;
        _baysFetchedAt = null;
        final bayNum = bay == BayType.bay1 ? 1 : (bay == BayType.bay2 ? 2 : 3);
        final bayId = bay == BayType.bay1
            ? 'b0000000-0000-0000-0000-000000000001'
            : (bay == BayType.bay2
                ? 'b0000000-0000-0000-0000-000000000002'
                : 'b0000000-0000-0000-0000-000000000003');

        await _patch('wash_bookings?id=eq.$bookingId', {
          'assigned_bay_id': bayId,
          'assigned_washer_id': _isUuid(washerId) ? washerId : null,
          'washer_1_name': washerName,
          'status': WashStatus.washing.name,
        });

        final booking = await getBookingById(bookingId);

        await _patch('station_bays?bay_number=eq.$bayNum', {
          'is_occupied': true,
          'current_booking_id': _isUuid(bookingId) ? bookingId : null,
          'active_license_plate': booking?.licensePlate,
          'assigned_washer_name': washerName,
          'started_at': DateTime.now().toIso8601String(),
        });

        if (booking != null) {
          final updated = booking.copyWith(
            assignedBay: bay,
            assignedWasherId: washerId,
            assignedWasherName: washerName,
            status: WashStatus.washing,
          );
          try {
            await _fallbackLocalRepo.assignBayAndWasher(
              bookingId: bookingId,
              bay: bay,
              washerId: washerId,
              washerName: washerName,
            );
          } catch (_) {}
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Supabase assignBayAndWasher exception: $e');
    }
    return await _fallbackLocalRepo.assignBayAndWasher(
      bookingId: bookingId,
      bay: bay,
      washerId: washerId,
      washerName: washerName,
    );
  }

  @override
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    double tipAmount = 0.0,
    String? transactionRef,
    String? receiptScreenshot,
    double? splitCashAmount,
    double? splitDigitalAmount,
    String? overpaymentAction,
    String? verificationStatus,
    String? collectedByRole,
    String? collectedByName,
  }) async {
    try {
      if (_isUuid(bookingId)) {
        final now = DateTime.now();
        final existing = await getBookingById(bookingId);
        final updatedPayment = (existing?.payment ?? const PaymentInfo(amount: 0)).copyWith(
          isPaid: true,
          method: method,
          amount: amount,
          tipAmount: tipAmount,
          transactionRef: transactionRef,
          receiptScreenshot: receiptScreenshot,
          paidAt: now,
          splitCashAmount: splitCashAmount,
          splitDigitalAmount: splitDigitalAmount,
          overpaymentAction: overpaymentAction,
          verificationStatus: verificationStatus,
          collectedByRole: collectedByRole,
          collectedByName: collectedByName,
        );
        final patchPayload = <String, dynamic>{
          'is_paid': true,
          'payment_method': method.name,
          'total_amount': amount,
          if (transactionRef != null && transactionRef.trim().isNotEmpty) 'transaction_ref': transactionRef,
          if (receiptScreenshot != null && receiptScreenshot.isNotEmpty) 'receipt_url': receiptScreenshot,
          if (existing != null)
            'delivery_location': _encodeMetaFromBooking(
              existing.copyWith(payment: updatedPayment),
            ),
        };

        dynamic res = await _patch('wash_bookings?id=eq.$bookingId', patchPayload);
        if (res == null && patchPayload.containsKey('receipt_url')) {
          // Fallback: If remote schema rejects receipt_url or payload size, retry without receipt_url
          final fallbackPayload = Map<String, dynamic>.from(patchPayload)..remove('receipt_url');
          await _patch('wash_bookings?id=eq.$bookingId', fallbackPayload);
        }

        // Link and match incoming bank SMS credit in cloud
        if (transactionRef != null && transactionRef.trim().isNotEmpty) {
          try {
            await _patch('bank_incoming_transactions?ref_no=ilike.${transactionRef.trim()}', {
              'match_status': 'matched',
              'matched_booking_id': bookingId,
            });
          } catch (_) {}
        }

        final booking = await getBookingById(bookingId);
        if (booking != null) {
          if (booking.status == WashStatus.completed && !booking.commissionLogged) {
            final washerName = (booking.assignedWasherName != null && booking.assignedWasherName!.trim().isNotEmpty)
                ? booking.assignedWasherName!.trim()
                : 'Team Washers';
            final commissionEarned = ((amount * 0.85) * 0.15) + tipAmount;

            try {
              await _post('commission_logs', {
                'booking_id': _isUuid(booking.id) ? booking.id : null,
                'staff_id': _isUuid(booking.assignedWasherId) ? booking.assignedWasherId : null,
                'staff_name': washerName,
                'car_type': booking.carType.name,
                'service_name': booking.package.name,
                'earned_amount': commissionEarned,
                'license_plate': booking.licensePlate,
                'is_settled': false,
                'logged_at': DateTime.now().toIso8601String(),
              });

              await _patch('wash_bookings?id=eq.$bookingId', {
                'commission_logged': true,
                'commission_amount': commissionEarned,
              });
            } catch (_) {}
          }

          final updated = booking.copyWith(
            payment: updatedPayment,
          );
          try {
            await _fallbackLocalRepo.processPayment(
              bookingId: bookingId,
              method: method,
              amount: amount,
              tipAmount: tipAmount,
              transactionRef: transactionRef,
              receiptScreenshot: receiptScreenshot,
              splitCashAmount: splitCashAmount,
              splitDigitalAmount: splitDigitalAmount,
              overpaymentAction: overpaymentAction,
              verificationStatus: verificationStatus,
              collectedByRole: collectedByRole,
              collectedByName: collectedByName,
            );
          } catch (_) {}
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Supabase processPayment exception: $e');
    }
    return await _fallbackLocalRepo.processPayment(
      bookingId: bookingId,
      method: method,
      amount: amount,
      tipAmount: tipAmount,
      transactionRef: transactionRef,
      receiptScreenshot: receiptScreenshot,
      splitCashAmount: splitCashAmount,
      splitDigitalAmount: splitDigitalAmount,
      overpaymentAction: overpaymentAction,
      verificationStatus: verificationStatus,
      collectedByRole: collectedByRole,
      collectedByName: collectedByName,
    );
  }

  @override
  Future<WashBooking> postponeBooking({
    required String bookingId,
    required DateTime nextScheduledTime,
    String? reason,
    String? postponedByRole,
  }) async {
    final now = DateTime.now();
    try {
      if (_isUuid(bookingId)) {
        final existing = await getBookingById(bookingId);
        if (existing != null) {
          if (existing.assignedBay != null && !existing.isCarpet) {
            _cachedBays = null;
            _baysFetchedAt = null;
            final bayNum = existing.assignedBay == BayType.bay1 ? 1 : (existing.assignedBay == BayType.bay2 ? 2 : 3);
            await _patch('station_bays?bay_number=eq.$bayNum', {
              'is_occupied': false,
              'current_booking_id': null,
              'active_license_plate': null,
              'assigned_washer_name': null,
            });
          }
          final updated = existing.copyWith(
            isPostponed: true,
            postponedReason: (reason != null && reason.trim().isNotEmpty) ? reason.trim() : existing.postponedReason,
            postponedAt: now,
            postponedByRole: postponedByRole ?? existing.postponedByRole,
            scheduledTime: nextScheduledTime,
            clearAssignedBay: true,
          );
          await _patch('wash_bookings?id=eq.$bookingId', {
            'assigned_bay_id': null,
            'scheduled_time': nextScheduledTime.toIso8601String(),
            'delivery_location': _encodeMetaFromBooking(updated),
          });
          try {
            await _fallbackLocalRepo.postponeBooking(
              bookingId: bookingId,
              nextScheduledTime: nextScheduledTime,
              reason: reason,
              postponedByRole: postponedByRole,
            );
          } catch (_) {}
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Supabase postponeBooking exception: $e');
    }
    return await _fallbackLocalRepo.postponeBooking(
      bookingId: bookingId,
      nextScheduledTime: nextScheduledTime,
      reason: reason,
      postponedByRole: postponedByRole,
    );
  }

  @override
  Future<WashBooking> handoverBookingToManager({
    required String bookingId,
    required String handedOverBy,
    String? note,
  }) async {
    final now = DateTime.now();
    try {
      if (_isUuid(bookingId)) {
        final existing = await getBookingById(bookingId);
        if (existing != null) {
          final updated = existing.copyWith(
            isHandedOverToManager: true,
            handedOverBy: handedOverBy.trim().isNotEmpty ? handedOverBy.trim() : 'Cashier',
            handoverNote: (note != null && note.trim().isNotEmpty) ? note.trim() : existing.handoverNote,
            handedOverAt: now,
          );
          await _patch('wash_bookings?id=eq.$bookingId', {
            'delivery_location': _encodeMetaFromBooking(updated),
          });
          try {
            await _fallbackLocalRepo.handoverBookingToManager(
              bookingId: bookingId,
              handedOverBy: handedOverBy,
              note: note,
            );
          } catch (_) {}
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Supabase handoverBookingToManager exception: $e');
    }
    return await _fallbackLocalRepo.handoverBookingToManager(
      bookingId: bookingId,
      handedOverBy: handedOverBy,
      note: note,
    );
  }

  @override
  Future<WashBooking> updateBookingDetails({
    required String bookingId,
    String? licensePlate,
    String? customerName,
    String? customerPhone,
    CarType? carType,
    WashPackage? package,
    double? customTotalPrice,
    String? carpetType,
    double? carpetAreaSqMeters,
    String? carpetDimensions,
    String? notes,
  }) async {
    try {
      if (_isUuid(bookingId)) {
        final existing = await getBookingById(bookingId);
        if (existing != null) {
          final effectivePackage = package ?? existing.package;
          final effectiveCarType = carType ?? existing.carType;
          final effectivePrice = customTotalPrice ?? (existing.customTotalPrice ?? effectivePackage.getPriceFor(effectiveCarType));

          PaymentInfo updatedPayment = existing.payment;
          if (existing.payment.isPaid && customTotalPrice != null && customTotalPrice > 0) {
            updatedPayment = existing.payment.copyWith(amount: customTotalPrice);
          }

          final updated = existing.copyWith(
            licensePlate: (licensePlate != null && licensePlate.trim().isNotEmpty) ? licensePlate.trim().toUpperCase() : existing.licensePlate,
            customerName: (customerName != null && customerName.trim().isNotEmpty) ? customerName.trim() : existing.customerName,
            customerPhone: customerPhone != null ? customerPhone.trim() : existing.customerPhone,
            carType: effectiveCarType,
            package: effectivePackage,
            customTotalPrice: effectivePrice,
            carpetType: carpetType ?? existing.carpetType,
            carpetAreaSqMeters: carpetAreaSqMeters ?? existing.carpetAreaSqMeters,
            carpetDimensions: carpetDimensions ?? existing.carpetDimensions,
            deliveryLocation: notes ?? existing.deliveryLocation,
            payment: updatedPayment,
          );

          final patchPayload = <String, dynamic>{
            'license_plate': updated.licensePlate,
            'owner_name': updated.customerName,
            'customer_phone': updated.customerPhone,
            'car_type': updated.carType.name,
            if (_isUuid(updated.package.id)) 'package_id': updated.package.id,
            'total_amount': updated.totalPrice,
            if (updated.customTotalPrice != null) 'custom_total_price': updated.customTotalPrice,
            if (updated.carpetType != null) 'carpet_type': updated.carpetType,
            if (updated.carpetAreaSqMeters != null) 'carpet_area_sq_meters': updated.carpetAreaSqMeters,
            if (updated.carpetDimensions != null) 'carpet_dimensions': updated.carpetDimensions,
            'delivery_location': _encodeMetaFromBooking(updated),
          };

          dynamic res = await _patch('wash_bookings?id=eq.$bookingId', patchPayload);
          if (res == null) {
            // Fallback for schemas missing carpet or custom_total_price columns
            final fallbackPayload = Map<String, dynamic>.from(patchPayload)
              ..remove('carpet_type')
              ..remove('carpet_area_sq_meters')
              ..remove('carpet_dimensions')
              ..remove('custom_total_price');
            await _patch('wash_bookings?id=eq.$bookingId', fallbackPayload);
          }

          try {
            await _fallbackLocalRepo.updateBookingDetails(
              bookingId: bookingId,
              licensePlate: licensePlate,
              customerName: customerName,
              customerPhone: customerPhone,
              carType: carType,
              package: package,
              customTotalPrice: customTotalPrice,
              carpetType: carpetType,
              carpetAreaSqMeters: carpetAreaSqMeters,
              carpetDimensions: carpetDimensions,
              notes: notes,
            );
          } catch (_) {}
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Supabase updateBookingDetails exception: $e');
    }
    return await _fallbackLocalRepo.updateBookingDetails(
      bookingId: bookingId,
      licensePlate: licensePlate,
      customerName: customerName,
      customerPhone: customerPhone,
      carType: carType,
      package: package,
      customTotalPrice: customTotalPrice,
      carpetType: carpetType,
      carpetAreaSqMeters: carpetAreaSqMeters,
      carpetDimensions: carpetDimensions,
      notes: notes,
    );
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    try {
      if (_isUuid(bookingId)) {
        final existing = await getBookingById(bookingId);
        if (existing?.assignedBay != null && !(existing?.isCarpet ?? false)) {
          _cachedBays = null;
          _baysFetchedAt = null;
          final bayNum = existing!.assignedBay == BayType.bay1 ? 1 : (existing.assignedBay == BayType.bay2 ? 2 : 3);
          await _patch('station_bays?bay_number=eq.$bayNum', {
            'is_occupied': false,
            'current_booking_id': null,
            'active_license_plate': null,
            'assigned_washer_name': null,
          });
        }
        await _delete('wash_bookings?id=eq.$bookingId');
      }
    } catch (e) {
      debugPrint('Supabase deleteBooking exception: $e');
    }
    await _fallbackLocalRepo.deleteBooking(bookingId);
  }

  @override
  Future<void> clearAllBookings() async {
    _dataPurgeEpoch = DateTime.now();
    _lastClosingSyncError = null;
    _cachedPackages = null;
    _packagesFetchedAt = null;
    _cachedStaff = null;
    _staffFetchedAt = null;
    _cachedBays = null;
    _baysFetchedAt = null;
    try {
      // 1. Invoke server-side RPC function (truncates bookings, logs, sms, and resets bays)
      await _post('rpc/clear_all_bookings', {});
    } catch (e) {
      debugPrint('Supabase clearAllBookings RPC call error: $e');
    }

    try {
      // 2. Direct REST deletes to guarantee complete purge
      await _delete('wash_bookings?id=neq.00000000-0000-0000-0000-000000000000');
      await _delete('commission_logs?id=neq.00000000-0000-0000-0000-000000000000');
      await _delete('sms_outbox?id=neq.00000000-0000-0000-0000-000000000000');
      await _delete('daily_closings?id=neq.00000000-0000-0000-0000-000000000000');
      
      // 3. Reset station bays to vacant
      await _patch('station_bays?id=neq.00000000-0000-0000-0000-000000000000', {
        'is_occupied': false,
        'current_booking_id': null,
        'active_license_plate': null,
        'assigned_washer_name': null,
        'started_at': null,
      });
    } catch (e) {
      debugPrint('Supabase clearAllBookings direct REST error: $e');
    }

    // 4. Wipe in-memory fallback repository
    await _fallbackLocalRepo.clearAllBookings();
  }

  @override
  Future<List<CommissionLog>> getCommissionLogs() async {
    try {
      final dynamic data = await _get('commission_logs?select=*&order=logged_at.desc&limit=50');
      if (data == null || data is! List) {
        return _fallbackLocalRepo.getCommissionLogs();
      }
      if (data.isEmpty) {
        return [];
      }

      return data.map((json) {
        CarType carType = CarType.automobile;
        final cType = (json['car_type'] ?? '').toString().toLowerCase();
        if (cType.contains('minibus') || cType.contains('truck') || cType.contains('large')) {
          carType = CarType.minibus;
        }

        return CommissionLog(
          id: json['id'].toString(),
          bookingId: json['booking_id']?.toString() ?? '',
          washerId: json['staff_id']?.toString() ?? '',
          washerName: json['staff_name'] ?? 'Washer',
          carPlate: json['license_plate'] ?? '',
          carType: carType,
          servicePackageName: json['service_name'] ?? 'Wash',
          totalWashPriceETB: 500.0,
          commissionRate: 0.15,
          commissionEarnedETB: double.tryParse(json['earned_amount']?.toString() ?? '75') ?? 75.0,
          completedAt: DateTime.tryParse(json['logged_at'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return _fallbackLocalRepo.getCommissionLogs();
    }
  }

  @override
  Future<List<StaffCredential>> getStaffCredentials() async {
    try {
      dynamic data = await _get('staff_credentials?select=*&order=role.asc');
      if (data is! List || data.where((j) => j is Map && !(j['username']?.toString() ?? '').startsWith('app_config_')).isEmpty) {
        final rpcData = await _post('rpc/get_staff_credentials', {});
        if (rpcData is List && rpcData.isNotEmpty) {
          data = rpcData;
        }
      }

      final List<StaffCredential> creds = [];
      if (data is List) {
        creds.addAll(data
            .where((json) => json is Map && !(json['username']?.toString() ?? '').startsWith('app_config_'))
            .map((json) {
              final roleStr = (json['role'] ?? 'cashier').toString().toLowerCase();
              final UserRole role;
              if (roleStr == 'admin') {
                role = UserRole.admin;
              } else if (roleStr == 'manager') {
                role = UserRole.manager;
              } else if (roleStr == 'storekeeper') {
                role = UserRole.storekeeper;
              } else if (roleStr == 'accountant') {
                role = UserRole.accountant;
              } else {
                role = UserRole.cashier;
              }
              final pin = (json['pin_hash'] ?? '').toString().trim();
              return StaffCredential(
                id: json['id'].toString(),
                username: json['username']?.toString() ?? 'staff',
                pin: pin,
                role: role,
                fullName: json['full_name']?.toString() ?? 'Staff Member',
                isActive: json['is_active'] == true,
              );
            }));
      }

      // Deduplicate credentials: each standard role has exactly one primary credential.
      final Map<UserRole, StaffCredential> primaryRoleCreds = {};
      final List<StaffCredential> customStaff = [];

      for (final c in creds) {
        // Drop duplicate / obsolete admin test rows (e.g. tare, dawit with Bishe Super Admin name)
        if (c.role == UserRole.admin &&
            c.username.toLowerCase() != 'admin' &&
            (c.fullName.toLowerCase() == 'bishe super admin' ||
                c.username.toLowerCase() == 'tare' ||
                c.username.toLowerCase() == 'dawit')) {
          continue;
        }

        if (c.username.toLowerCase() == c.role.name ||
            (c.role == UserRole.admin && c.username.toLowerCase() == 'admin')) {
          primaryRoleCreds[c.role] = c;
        } else if (!primaryRoleCreds.containsKey(c.role)) {
          primaryRoleCreds[c.role] = c;
        } else {
          if (!customStaff.any((s) => s.username.toLowerCase() == c.username.toLowerCase())) {
            customStaff.add(c);
          }
        }
      }

      // Check fallback repository to retain locally updated credentials if unreturned by Supabase
      final localCreds = await _fallbackLocalRepo.getStaffCredentials();

      void ensureRole(UserRole role, String defaultId, String defaultUsername, String defaultPin, String defaultName) {
        if (!primaryRoleCreds.containsKey(role)) {
          final localMatch = localCreds.where((c) => c.role == role && c.isActive).firstOrNull;
          if (localMatch != null) {
            primaryRoleCreds[role] = localMatch;
          } else {
            primaryRoleCreds[role] = StaffCredential(
              id: defaultId,
              username: defaultUsername,
              pin: defaultPin,
              role: role,
              fullName: defaultName,
              isActive: true,
            );
          }
        }
      }

      // Ensure default initial credentials exist for unconfigured roles:
      // admin = 4450, cashier = 2233, manager = 7788, accountant = 3344, storekeeper = 3344
      ensureRole(UserRole.admin, 'cred-admin', 'admin', '4450', 'Bishe Super Admin');
      ensureRole(UserRole.cashier, 'cred-cashier', 'cashier', '2233', 'Station Gate Cashier');
      ensureRole(UserRole.manager, 'cred-manager', 'manager', '7788', 'Operational Manager');
      ensureRole(UserRole.accountant, 'cred-accountant', 'accountant', '3344', 'Station Accountant');
      ensureRole(UserRole.storekeeper, 'cred-storekeeper', 'storekeeper', '3344', 'Inventory Storekeeper');

      return [...primaryRoleCreds.values, ...customStaff];
    } catch (_) {
      return _fallbackLocalRepo.getStaffCredentials();
    }
  }

  @override
  Future<bool> verifyStaffPin(UserRole role, String enteredPin) async {
    try {
      final res = await _post('rpc/verify_staff_pin', {
        'p_role': role.name,
        'p_pin': enteredPin.trim(),
      });
      if (res is bool) return res;
      if (res is num) return res == 1;
      if (res is String) return res.toLowerCase() == 'true';
    } catch (e) {
      debugPrint('Supabase verifyStaffPin exception: $e');
    }
    final creds = await getStaffCredentials();
    return StaffAuthenticator.authenticate(
      role: role,
      enteredPin: enteredPin,
      credentials: creds,
    );
  }

  @override
  Future<void> updateStaffCredential(String id, String pin, String fullName) async {
    try {
      String roleName = 'admin';
      final liveCreds = await getStaffCredentials();
      final cred = liveCreds.where((c) => c.id == id).firstOrNull;
      if (cred != null) {
        roleName = cred.role.name;
      } else if (id.toLowerCase().contains('cashier')) {
        roleName = 'cashier';
      } else if (id.toLowerCase().contains('manager')) {
        roleName = 'manager';
      } else if (id.toLowerCase().contains('storekeeper')) {
        roleName = 'storekeeper';
      } else if (id.toLowerCase().contains('accountant')) {
        roleName = 'accountant';
      }

      await _post('rpc/update_staff_pin', {
        'p_role': roleName,
        'p_new_pin': pin.trim(),
        'p_full_name': fullName.trim(),
      });

      if (_isUuid(id)) {
        await _patch('staff_credentials?id=eq.$id', {
          'pin_hash': pin.trim(),
          'full_name': fullName.trim(),
        });
      } else {
        // Initial synthetic credentials (e.g. cred-admin, cred-cashier, cred-manager, cred-accountant, cred-storekeeper)
        final defaultUsername = cred?.username ?? roleName;
        final existing = await _get('staff_credentials?role=eq.$roleName&select=id');
        if (existing is List && existing.isNotEmpty) {
          final targetId = existing.first['id'];
          await _patch('staff_credentials?id=eq.$targetId', {
            'pin_hash': pin.trim(),
            'full_name': fullName.trim(),
          });
        } else {
          await _post('staff_credentials', {
            'username': defaultUsername,
            'pin_hash': pin.trim(),
            'role': roleName,
            'full_name': fullName.trim().isEmpty ? cred?.fullName ?? roleName : fullName.trim(),
            'is_active': true,
          });
        }
      }
    } catch (e) {
      debugPrint('Supabase updateStaffCredential exception: $e');
    }
    await _fallbackLocalRepo.updateStaffCredential(id, pin, fullName);
  }

  @override
  Future<void> addStaffCredential(StaffCredential cred) async {
    try {
      await _post('staff_credentials', {
        'username': cred.username,
        'pin_hash': cred.pin,
        'role': cred.role.name,
        'full_name': cred.fullName,
        'is_active': cred.isActive,
      });
    } catch (_) {}
    await _fallbackLocalRepo.addStaffCredential(cred);
  }

  @override
  Future<void> deleteStaffCredential(String id) async {
    try {
      if (_isUuid(id)) {
        await _delete('staff_credentials?id=eq.$id');
      } else {
        final roleName = id.replaceFirst('cred-', '');
        await _delete('staff_credentials?role=eq.$roleName');
      }
    } catch (e) {
      debugPrint('Supabase deleteStaffCredential exception: $e');
    }
    await _fallbackLocalRepo.deleteStaffCredential(id);
  }

  @override
  Future<List<DailyFinancialClosing>> getDailyFinancialClosings() async {
    try {
      final res = await _get('daily_closings?order=closing_date.desc&limit=30');
      if (res is List) {
        return res.map((item) {
          final map = item as Map<String, dynamic>;
          final cDate = DateTime.tryParse(map['closing_date']?.toString() ?? '') ?? DateTime.now();
          final cClosed = DateTime.tryParse(map['closed_at']?.toString() ?? '') ?? cDate;
          final rawNotes = map['notes']?.toString();
          final base = DailyFinancialClosing(
            id: map['id']?.toString() ?? '',
            closingDate: cDate,
            closedAt: cClosed,
            cashierName: map['cashier_name']?.toString() ?? 'Cashier',
            grossRevenue: (map['gross_revenue'] as num?)?.toDouble() ?? 0.0,
            cashRevenue: (map['cash_revenue'] as num?)?.toDouble() ?? 0.0,
            digitalRevenue: (map['digital_revenue'] as num?)?.toDouble() ?? 0.0,
            providerBreakdown: map['provider_breakdown'] is Map
                ? Map<String, double>.from((map['provider_breakdown'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
                : {},
            carsWashedCount: (map['cars_washed_count'] as num?)?.toInt() ?? 0,
            commissionPool: (map['commission_pool'] as num?)?.toDouble() ?? 0.0,
            netStationProfit: (map['net_station_profit'] as num?)?.toDouble() ?? 0.0,
            cashDeposited: (map['cash_deposited'] as num?)?.toDouble() ?? 0.0,
            pettyCashExpenses: (map['petty_cash_expenses'] as num?)?.toDouble() ?? 0.0,
            cashRemaining: (map['cash_remaining'] as num?)?.toDouble() ?? 0.0,
            washerDividends: map['washer_dividends'] is Map
                ? Map<String, double>.from((map['washer_dividends'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
                : {},
            notes: extractCleanNotes(rawNotes),
            isConfirmed: map['is_confirmed'] == true,
            shiftType: map['id']?.toString().endsWith('-night') == true ? 'night' : 'day',
          );
          return applyHandoverMetaToClosing(base, rawNotes);
        }).where((c) => c.closedAt.isAfter(_dataPurgeEpoch)).toList();
      }
    } catch (e) {
      debugPrint('Supabase getDailyFinancialClosings exception: $e');
    }
    return _fallbackLocalRepo.getDailyFinancialClosings();
  }

  @override
  Future<void> saveDailyFinancialClosing(DailyFinancialClosing closing) async {
    final payload = <String, dynamic>{
      'id': closing.id,
      'closing_date': closing.closingDate.toIso8601String(),
      'closed_at': closing.closedAt.toIso8601String(),
      'cashier_name': closing.cashierName,
      'gross_revenue': closing.grossRevenue,
      'cash_revenue': closing.cashRevenue,
      'digital_revenue': closing.digitalRevenue,
      'cars_washed_count': closing.carsWashedCount,
      'commission_pool': closing.commissionPool,
      'net_station_profit': closing.netStationProfit,
      'cash_deposited': closing.cashDeposited,
      'petty_cash_expenses': closing.pettyCashExpenses,
      'cash_remaining': closing.cashRemaining,
      'provider_breakdown': closing.providerBreakdown,
      'washer_dividends': closing.washerDividends,
      'notes': encodeClosingNotesWithMeta(closing),
      'is_confirmed': closing.isConfirmed,
    };

    final encodedId = Uri.encodeComponent(closing.id);
    try {
      // Check existence first so new rows use plain INSERT (never failing UPDATE RLS check on on_conflict=id),
      // and existing rows verify PATCH actually modified a row under return=representation.
      final existing = await _get('daily_closings?id=eq.$encodedId&select=id');
      if (existing is List && existing.isEmpty) {
        final inserted = await _post('daily_closings', payload);
        if (inserted is List && inserted.isNotEmpty) {
          _lastClosingSyncError = null;
        } else {
          _lastClosingSyncError =
              'Supabase daily_closings INSERT failed. Apply supabase/migrations/20261111_fix_rls_closings_and_bookings.sql.';
          debugPrint('Supabase daily_closings insert failed for ${closing.id}');
        }
      } else if (existing is List && existing.isNotEmpty) {
        final patched = await _patch('daily_closings?id=eq.$encodedId', payload);
        if (patched is List && patched.isNotEmpty) {
          _lastClosingSyncError = null;
        } else {
          _lastClosingSyncError =
              'Supabase daily_closings UPDATE blocked by RLS policy (0 rows updated). Run supabase/migrations/20261111_fix_rls_closings_and_bookings.sql in Supabase SQL Editor.';
          debugPrint(_lastClosingSyncError);
        }
      } else {
        // Network/SELECT error fallback: attempt plain POST
        final inserted = await _post('daily_closings', payload);
        _lastClosingSyncError = (inserted is List && inserted.isNotEmpty)
            ? null
            : 'Supabase daily_closings cloud sync failed; saved locally.';
      }
    } catch (e) {
      _lastClosingSyncError = 'Supabase saveDailyFinancialClosing exception: $e';
      debugPrint(_lastClosingSyncError);
    }
    await _fallbackLocalRepo.saveDailyFinancialClosing(closing);
  }

  @override
  Future<void> deleteDailyFinancialClosing(String id) async {
    _lastClosingSyncError = null;
    try {
      await _delete('daily_closings?id=eq.$id');
    } catch (e) {
      debugPrint('Supabase deleteDailyFinancialClosing exception: $e');
    }
    await _fallbackLocalRepo.deleteDailyFinancialClosing(id);
  }

  @override
  Future<List<TikTokAdVideo>> getTikTokReels() async {
    try {
      final dynamic data = await _get('staff_credentials?username=eq.app_config_tiktok_reels&select=*');
      if (data is List && data.isNotEmpty) {
        final rawJson = data.first['full_name']?.toString() ?? '';
        if (rawJson.isNotEmpty) {
          final dynamic decoded = jsonDecode(rawJson);
          if (decoded is List && decoded.isNotEmpty) {
            return decoded
                .map((e) => TikTokAdVideo.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Supabase getTikTokReels exception: $e');
    }
    return _fallbackLocalRepo.getTikTokReels();
  }

  @override
  Future<void> saveTikTokReels(List<TikTokAdVideo> reels) async {
    final jsonPayload = jsonEncode(reels.map((r) => r.toMap()).toList());
    try {
      final dynamic existing = await _get('staff_credentials?username=eq.app_config_tiktok_reels&select=id');
      if (existing is List && existing.isNotEmpty) {
        await _patch('staff_credentials?username=eq.app_config_tiktok_reels', {
          'full_name': jsonPayload,
          'is_active': true,
        });
      } else {
        await _post('staff_credentials', {
          'username': 'app_config_tiktok_reels',
          'pin_hash': '4450',
          'role': 'admin',
          'full_name': jsonPayload,
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('Supabase saveTikTokReels exception: $e');
    }
    await _fallbackLocalRepo.saveTikTokReels(reels);
  }

  @override
  Future<String> getCustomerPhoneBookingNumber() async {
    try {
      final dynamic data = await _get('staff_credentials?username=eq.app_config_phone_booking&select=*');
      if (data is List && data.isNotEmpty) {
        final phone = data.first['full_name']?.toString() ?? '';
        if (phone.isNotEmpty) return phone;
      }
    } catch (e) {
      debugPrint('Supabase getCustomerPhoneBookingNumber exception: $e');
    }
    return _fallbackLocalRepo.getCustomerPhoneBookingNumber();
  }

  @override
  Future<void> saveCustomerPhoneBookingNumber(String phone) async {
    try {
      final dynamic existing = await _get('staff_credentials?username=eq.app_config_phone_booking&select=id');
      if (existing is List && existing.isNotEmpty) {
        await _patch('staff_credentials?username=eq.app_config_phone_booking', {
          'full_name': phone.trim(),
          'is_active': true,
        });
      } else {
        await _post('staff_credentials', {
          'username': 'app_config_phone_booking',
          'pin_hash': '4450',
          'role': 'admin',
          'full_name': phone.trim(),
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('Supabase saveCustomerPhoneBookingNumber exception: $e');
    }
    await _fallbackLocalRepo.saveCustomerPhoneBookingNumber(phone);
  }

  @override
  Future<String?> getRemoteGeminiApiKey() async {
    try {
      final dynamic data = await _get('staff_credentials?username=eq.app_config_tiktok_reels&select=pin_hash');
      if (data is List && data.isNotEmpty) {
        final pin = data.first['pin_hash']?.toString() ?? '';
        if (pin.contains('GEMINI_KEY:')) {
          final extracted = pin.substring(pin.indexOf('GEMINI_KEY:') + 'GEMINI_KEY:'.length).trim();
          if (extracted.isNotEmpty) return extracted;
        }
      }
    } catch (e) {
      debugPrint('Supabase getRemoteGeminiApiKey exception: $e');
    }
    return _fallbackLocalRepo.getRemoteGeminiApiKey();
  }

  @override
  Future<void> saveRemoteGeminiApiKey(String key) async {
    try {
      await _patch('staff_credentials?username=eq.app_config_tiktok_reels', {
        'pin_hash': '4450|GEMINI_KEY:${key.trim()}',
      });
    } catch (e) {
      debugPrint('Supabase saveRemoteGeminiApiKey exception: $e');
    }
    await _fallbackLocalRepo.saveRemoteGeminiApiKey(key);
  }

  Future<String?> _getStaffConfigPayload(String key) async {
    try {
      final dynamic data = await _get('staff_credentials?username=eq.$key&select=*');
      if (data is List && data.isNotEmpty) {
        final raw = data.first['full_name']?.toString() ?? '';
        if (raw.isNotEmpty) return raw;
      }
    } catch (e) {
      debugPrint('Supabase get config [$key] exception: $e');
    }
    return null;
  }

  Future<void> _saveStaffConfigPayload(String key, String payload) async {
    try {
      final dynamic existing = await _get('staff_credentials?username=eq.$key&select=id');
      if (existing is List && existing.isNotEmpty) {
        await _patch('staff_credentials?username=eq.$key', {
          'full_name': payload,
          'is_active': true,
        });
      } else {
        await _post('staff_credentials', {
          'username': key,
          'pin_hash': '4450',
          'role': 'admin',
          'full_name': payload,
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('Supabase save config [$key] exception: $e');
    }
  }

  @override
  Future<List<CustomerFeedback>> getCustomerFeedback() async {
    final rawJson = await _getStaffConfigPayload('app_config_customer_feedback');
    if (rawJson != null) {
      try {
        final dynamic decoded = jsonDecode(rawJson);
        if (decoded is List) {
          return decoded
              .map((e) => CustomerFeedback.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } catch (e) {
        debugPrint('Supabase decode customer feedback exception: $e');
      }
    }
    return _fallbackLocalRepo.getCustomerFeedback();
  }

  @override
  Future<void> saveCustomerFeedback(List<CustomerFeedback> feedbackList) async {
    final jsonPayload = jsonEncode(feedbackList.map((f) => f.toMap()).toList());
    await _saveStaffConfigPayload('app_config_customer_feedback', jsonPayload);
    await _fallbackLocalRepo.saveCustomerFeedback(feedbackList);
  }

  @override
  Future<Map<String, dynamic>> getPricingAndCommissionConfig() async {
    final rawJson = await _getStaffConfigPayload('app_config_pricing_rules');
    if (rawJson != null) {
      try {
        final dynamic decoded = jsonDecode(rawJson);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('Supabase decode pricing config exception: $e');
      }
    }
    return _fallbackLocalRepo.getPricingAndCommissionConfig();
  }

  @override
  Future<void> savePricingAndCommissionConfig(Map<String, dynamic> config) async {
    await _saveStaffConfigPayload('app_config_pricing_rules', jsonEncode(config));
    await _fallbackLocalRepo.savePricingAndCommissionConfig(config);
  }

  @override
  Future<List<FixedAsset>> getFixedAssets() => _fallbackLocalRepo.getFixedAssets();

  @override
  Future<void> saveFixedAsset(FixedAsset asset) => _fallbackLocalRepo.saveFixedAsset(asset);

  @override
  Future<void> deleteFixedAsset(String id) => _fallbackLocalRepo.deleteFixedAsset(id);

  @override
  Future<List<ConsumableItem>> getConsumables() => _fallbackLocalRepo.getConsumables();

  @override
  Future<void> saveConsumable(ConsumableItem item) => _fallbackLocalRepo.saveConsumable(item);

  @override
  Future<void> deleteConsumable(String id) => _fallbackLocalRepo.deleteConsumable(id);

  @override
  Future<List<DailyHandover>> getDailyHandovers() => _fallbackLocalRepo.getDailyHandovers();

  @override
  Future<void> saveDailyHandover(DailyHandover handover) => _fallbackLocalRepo.saveDailyHandover(handover);

  @override
  Future<List<StockTransaction>> getStockTransactions() => _fallbackLocalRepo.getStockTransactions();

  @override
  Future<void> recordStockTransaction(StockTransaction tx) => _fallbackLocalRepo.recordStockTransaction(tx);

  @override
  Future<List<RetailSaleRecord>> getRetailSales() async {
    final rawJson = await _getStaffConfigPayload('app_config_retail_sales');
    if (rawJson != null) {
      try {
        final dynamic decoded = jsonDecode(rawJson);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => RetailSaleRecord.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (e) {
        debugPrint('Supabase decode retail sales exception: $e');
      }
    }
    return _fallbackLocalRepo.getRetailSales();
  }

  @override
  Future<void> saveRetailSales(List<RetailSaleRecord> sales) async {
    final bounded = sales.take(120).map((s) => s.toJson()).toList();
    await _saveStaffConfigPayload('app_config_retail_sales', jsonEncode(bounded));
    await _fallbackLocalRepo.saveRetailSales(sales);
  }

  // --- DIGITAL PAYMENTS & SENTINEL (SUPABASE + CACHED FALLBACK) ---
  @override
  Future<List<BankIncomingTransaction>> getBankIncomingTransactions() async {
    try {
      final dynamic data = await _get('bank_incoming_transactions?select=*&order=received_at.desc&limit=60');
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map((j) => BankIncomingTransaction.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Supabase getBankIncomingTransactions error: $e');
    }
    return _fallbackLocalRepo.getBankIncomingTransactions();
  }

  @override
  Future<void> deleteBankIncomingTransaction(String id) async {
    // 1. Try RPC delete_bank_incoming_transaction first (bypasses RLS via SECURITY DEFINER)
    try {
      final res = await _post('rpc/delete_bank_incoming_transaction', {'p_id': id});
      if (res != null) {
        await _fallbackLocalRepo.deleteBankIncomingTransaction(id);
        return;
      }
    } catch (e) {
      debugPrint('Supabase deleteBankIncomingTransaction RPC note: $e');
    }

    // 2. Direct REST DELETE fallback
    try {
      final encodedId = Uri.encodeComponent(id);
      await _delete('bank_incoming_transactions?id=eq.$encodedId');
      await _delete('bank_incoming_transactions?ref_no=eq.$encodedId');
    } catch (e) {
      debugPrint('Supabase deleteBankIncomingTransaction REST error: $e');
    }
    await _fallbackLocalRepo.deleteBankIncomingTransaction(id);
  }

  @override
  Future<void> clearAllBankIncomingTransactions() async {
    // 1. Try RPC clear_all_bank_incoming_transactions first (bypasses RLS via SECURITY DEFINER)
    try {
      final res = await _post('rpc/clear_all_bank_incoming_transactions', {});
      if (res != null) {
        await _fallbackLocalRepo.clearAllBankIncomingTransactions();
        return;
      }
    } catch (e) {
      debugPrint('Supabase clearAllBankIncomingTransactions RPC note: $e');
    }

    // 2. Direct REST DELETE fallback
    try {
      await _delete('bank_incoming_transactions?id=not.is.null');
    } catch (e) {
      debugPrint('Supabase clearAllBankIncomingTransactions REST error: $e');
    }
    await _fallbackLocalRepo.clearAllBankIncomingTransactions();
  }

  @override
  Future<void> deleteStationReceipt(String bookingId) async {
    // 1. Try RPC delete_station_receipt first (bypasses RLS via SECURITY DEFINER)
    try {
      final res = await _post('rpc/delete_station_receipt', {'p_booking_id': bookingId});
      if (res != null) {
        await _fallbackLocalRepo.deleteStationReceipt(bookingId);
        return;
      }
    } catch (e) {
      debugPrint('Supabase deleteStationReceipt RPC note: $e');
    }

    // 2. Direct REST PATCH fallback
    try {
      final encodedId = Uri.encodeComponent(bookingId);
      await _patch('wash_bookings?id=eq.$encodedId', {
        'receipt_url': null,
      });
    } catch (e) {
      debugPrint('Supabase deleteStationReceipt error: $e');
    }
    await _fallbackLocalRepo.deleteStationReceipt(bookingId);
  }

  @override
  Future<void> clearAllStationReceipts() async {
    // 1. Try RPC clear_all_station_receipts first (bypasses RLS via SECURITY DEFINER)
    try {
      final res = await _post('rpc/clear_all_station_receipts', {});
      if (res != null) {
        await _fallbackLocalRepo.clearAllStationReceipts();
        return;
      }
    } catch (e) {
      debugPrint('Supabase clearAllStationReceipts RPC note: $e');
    }

    // 2. Direct REST PATCH fallback (PostgREST syntax: not.is.null)
    try {
      await _patch('wash_bookings?receipt_url=not.is.null', {
        'receipt_url': null,
      });
    } catch (e) {
      debugPrint('Supabase clearAllStationReceipts error: $e');
    }
    await _fallbackLocalRepo.clearAllStationReceipts();
  }

  @override
  Future<SentinelConfig> getSentinelConfig() async {
    try {
      final dynamic data = await _get('app_config_sentinel?id=eq.primary&select=*');
      if (data is List && data.isNotEmpty && data.first is Map) {
        return SentinelConfig.fromJson(Map<String, dynamic>.from(data.first as Map));
      }
    } catch (e) {
      debugPrint('Supabase getSentinelConfig error: $e');
    }
    return _fallbackLocalRepo.getSentinelConfig();
  }

  @override
  Future<void> updateSentinelConfig(SentinelConfig config) async {
    try {
      await _patch('app_config_sentinel?id=eq.primary', config.toJson());
    } catch (e) {
      debugPrint('Supabase updateSentinelConfig error: $e');
    }
    await _fallbackLocalRepo.updateSentinelConfig(config);
  }

  @override
  Future<Map<String, dynamic>> ingestBankSms({
    required String provider,
    required String rawSms,
    String? secretToken,
  }) async {
    try {
      final dynamic result = await _post('rpc/ingest_bank_sms', {
        'p_provider': provider,
        'p_raw_sms': rawSms,
        if (secretToken != null) 'p_secret_token': secretToken,
      });
      if (result is Map) {
        await _fallbackLocalRepo.ingestBankSms(provider: provider, rawSms: rawSms, secretToken: secretToken);
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      debugPrint('Supabase ingestBankSms error: $e');
    }
    return _fallbackLocalRepo.ingestBankSms(provider: provider, rawSms: rawSms, secretToken: secretToken);
  }
}
