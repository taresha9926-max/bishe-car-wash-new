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
    DateTime? paidAt,
  }) {
    final clean = extractCleanDeliveryLocation(baseText);
    if (!isOnlineBooking && !isPostponed && paidAt == null) {
      return clean;
    }
    final meta = <String, dynamic>{
      if (isOnlineBooking) 'isOnline': true,
      if (isPostponed) 'isPostponed': true,
      if (postponedReason != null && postponedReason.isNotEmpty) 'postponedReason': postponedReason,
      if (postponedAt != null) 'postponedAt': postponedAt.toIso8601String(),
      if (paidAt != null) 'paidAt': paidAt.toIso8601String(),
    };
    final tag = '$_bookingMetaPrefix${jsonEncode(meta)}]';
    return (clean == null || clean.isEmpty) ? tag : '$clean\n$tag';
  }

  final String supabaseUrl;
  final String anonKey;
  final WashRepositoryImpl _fallbackLocalRepo = WashRepositoryImpl();
  static DateTime _dataPurgeEpoch = DateTime.parse('2026-11-06T16:25:00Z');

  SupabaseWashRepositoryImpl({
    required this.supabaseUrl,
    required this.anonKey,
  });

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
      final response = await http.get(uri, headers: _headers);
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
      final response = await http.post(uri, headers: _headers, body: jsonEncode(data));
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
      final response = await http.patch(uri, headers: _headers, body: jsonEncode(data));
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
      final response = await http.delete(uri, headers: _headers);
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
    try {
      final dynamic data = await _get('wash_packages?select=*&order=created_at.asc');
      if (data == null || data is! List || data.isEmpty) {
        return _fallbackLocalRepo.getPackages();
      }

      return data.map((json) {
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
    } catch (_) {
      return _fallbackLocalRepo.getPackages();
    }
  }

  @override
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice) async {
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
    try {
      final dynamic data = await _get('staff_members?select=*&order=created_at.asc');
      if (data == null || data is! List || data.isEmpty) {
        return _fallbackLocalRepo.getStaffMembers();
      }

      return data.map((json) {
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
    } catch (_) {
      return _fallbackLocalRepo.getStaffMembers();
    }
  }

  @override
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate) async {
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
    try {
      final dynamic data = await _get('station_bays?select=*&order=bay_number.asc');
      if (data == null || data is! List || data.isEmpty) {
        return _fallbackLocalRepo.getBays();
      }

      return data.map((json) {
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
    } catch (_) {
      return _fallbackLocalRepo.getBays();
    }
  }

  @override
  Future<List<WashBooking>> getBookings() async {
    try {
      final dynamic data = await _get('wash_bookings?select=*&order=created_at.desc');
      if (data == null || data is! List || data.isEmpty) {
        return _fallbackLocalRepo.getBookings();
      }

      final packages = await getPackages();

      return data.map((json) {
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

        WashPackage pkg = packages.first;
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
            : (isCarpet && json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null);

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
            : null;
        final postponedAt = bookingMeta['postponedAt'] != null
            ? DateTime.tryParse(bookingMeta['postponedAt'].toString())
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
          ),
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          scheduledTime: json['scheduled_time'] != null ? DateTime.tryParse(json['scheduled_time'].toString()) : null,
          completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
          commissionLogged: json['commission_logged'] ?? false,
          isPhoneBooking: isPhone,
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
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase getBookings exception: $e');
      return _fallbackLocalRepo.getBookings();
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

      final baseLoc = booking.deliveryLocation ??
          (booking.selectedServices != null && booking.selectedServices!.isNotEmpty
              ? 'Services: ${booking.selectedServices!.join(", ")}'
              : booking.gpsCoordinates);

      final payload = {
        'owner_name': booking.customerName,
        'customer_phone': booking.customerPhone,
        'car_type': booking.carType.name,
        'service_type': booking.serviceType.name,
        'package_id': _isUuid(booking.package.id) ? booking.package.id : null,
        'assigned_bay_id': bayId,
        'license_plate': booking.licensePlate,
        'delivery_location': encodeDeliveryLocationWithMeta(
          baseText: baseLoc,
          isOnlineBooking: booking.isOnlineBooking,
          isPostponed: booking.isPostponed,
          postponedReason: booking.postponedReason,
          postponedAt: booking.postponedAt,
          paidAt: booking.payment.paidAt,
        ),
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
          final commissionEarned = booking.totalPrice * 0.15;

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
  }) async {
    try {
      if (_isUuid(bookingId)) {
        final now = DateTime.now();
        final existing = await getBookingById(bookingId);
        await _patch('wash_bookings?id=eq.$bookingId', {
          'is_paid': true,
          'payment_method': method.name,
          'total_amount': amount,
          'transaction_ref': transactionRef,
          'receipt_url': receiptScreenshot,
          if (existing != null)
            'delivery_location': encodeDeliveryLocationWithMeta(
              baseText: existing.deliveryLocation ??
                  (existing.selectedServices != null && existing.selectedServices!.isNotEmpty
                      ? 'Services: ${existing.selectedServices!.join(", ")}'
                      : existing.gpsCoordinates),
              isOnlineBooking: existing.isOnlineBooking,
              isPostponed: existing.isPostponed,
              postponedReason: existing.postponedReason,
              postponedAt: existing.postponedAt,
              paidAt: now,
            ),
        });

        final booking = await getBookingById(bookingId);
        if (booking != null) {
          if (booking.status == WashStatus.completed && !booking.commissionLogged) {
            final washerName = (booking.assignedWasherName != null && booking.assignedWasherName!.trim().isNotEmpty)
                ? booking.assignedWasherName!.trim()
                : 'Team Washers';
            final commissionEarned = (amount * 0.15) + tipAmount;

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
            payment: booking.payment.copyWith(
              isPaid: true,
              method: method,
              amount: amount,
              tipAmount: tipAmount,
              transactionRef: transactionRef,
              receiptScreenshot: receiptScreenshot,
              paidAt: DateTime.now(),
            ),
          );
          try {
            await _fallbackLocalRepo.processPayment(
              bookingId: bookingId,
              method: method,
              amount: amount,
              tipAmount: tipAmount,
              transactionRef: transactionRef,
              receiptScreenshot: receiptScreenshot,
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
    );
  }

  @override
  Future<WashBooking> postponeBooking({
    required String bookingId,
    required DateTime nextScheduledTime,
    String? reason,
  }) async {
    final now = DateTime.now();
    try {
      if (_isUuid(bookingId)) {
        final existing = await getBookingById(bookingId);
        if (existing != null) {
          if (existing.assignedBay != null && !existing.isCarpet) {
            final bayNum = existing.assignedBay == BayType.bay1 ? 1 : (existing.assignedBay == BayType.bay2 ? 2 : 3);
            await _patch('station_bays?bay_number=eq.$bayNum', {
              'is_occupied': false,
              'current_booking_id': null,
              'active_license_plate': null,
              'assigned_washer_name': null,
            });
          }
          await _patch('wash_bookings?id=eq.$bookingId', {
            'assigned_bay_id': null,
            'scheduled_time': nextScheduledTime.toIso8601String(),
            'delivery_location': encodeDeliveryLocationWithMeta(
              baseText: existing.deliveryLocation ??
                  (existing.selectedServices != null && existing.selectedServices!.isNotEmpty
                      ? 'Services: ${existing.selectedServices!.join(", ")}'
                      : existing.gpsCoordinates),
              isOnlineBooking: existing.isOnlineBooking,
              isPostponed: true,
              postponedReason: (reason != null && reason.trim().isNotEmpty) ? reason.trim() : existing.postponedReason,
              postponedAt: now,
              paidAt: existing.payment.paidAt,
            ),
          });
          final updated = existing.copyWith(
            isPostponed: true,
            postponedReason: (reason != null && reason.trim().isNotEmpty) ? reason.trim() : existing.postponedReason,
            postponedAt: now,
            scheduledTime: nextScheduledTime,
            clearAssignedBay: true,
          );
          try {
            await _fallbackLocalRepo.postponeBooking(
              bookingId: bookingId,
              nextScheduledTime: nextScheduledTime,
              reason: reason,
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
    );
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    try {
      if (_isUuid(bookingId)) {
        final existing = await getBookingById(bookingId);
        if (existing?.assignedBay != null && !(existing?.isCarpet ?? false)) {
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
      final dynamic data = await _get('commission_logs?select=*&order=logged_at.desc');
      if (data == null || data is! List || data.isEmpty) {
        return _fallbackLocalRepo.getCommissionLogs();
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
      final dynamic data = await _get('staff_credentials?select=*&order=role.asc');
      if (data == null || data is! List || data.isEmpty) {
        return _fallbackLocalRepo.getStaffCredentials();
      }
      final creds = data
          .map((json) {
            final roleStr = (json['role'] ?? 'cashier').toString().toLowerCase();
            final role = roleStr == 'admin'
                ? UserRole.admin
                : (roleStr == 'storekeeper'
                    ? UserRole.storekeeper
                    : (roleStr == 'accountant' ? UserRole.accountant : UserRole.cashier));
            final rawPin = json['pin_hash']?.toString() ?? '';
            final defaultPin = role == UserRole.admin
                ? '1234'
                : (role == UserRole.storekeeper
                    ? '3344'
                    : (role == UserRole.accountant ? '5566' : '0000'));
            final pin = (rawPin.length > 6 || rawPin.isEmpty) ? defaultPin : rawPin;
            return StaffCredential(
              id: json['id'].toString(),
              username: json['username']?.toString() ?? 'staff',
              pin: pin,
              role: role,
              fullName: json['full_name']?.toString() ?? 'Staff Member',
              isActive: json['is_active'] == true,
            );
          })
          .where((cred) => !cred.username.startsWith('app_config_'))
          .toList();

      if (creds.isEmpty) {
        return _fallbackLocalRepo.getStaffCredentials();
      }
      return creds;
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
    final localCreds = await _fallbackLocalRepo.getStaffCredentials();
    return StaffAuthenticator.authenticate(
      role: role,
      enteredPin: enteredPin,
      credentials: localCreds,
    );
  }

  @override
  Future<void> updateStaffCredential(String id, String pin, String fullName) async {
    try {
      String roleName = 'admin';
      final localCreds = await _fallbackLocalRepo.getStaffCredentials();
      final cred = localCreds.where((c) => c.id == id).firstOrNull;
      if (cred != null) {
        roleName = cred.role.name;
      } else if (id.toLowerCase().contains('cashier')) {
        roleName = 'cashier';
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
          'pin_hash': pin,
          'full_name': fullName,
        });
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
      if (res is List && res.isNotEmpty) {
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

    try {
      // Use PostgREST upsert to seamlessly handle repeat/shift closings without 409 conflict
      final upsertUri = Uri.parse('$supabaseUrl/rest/v1/daily_closings?on_conflict=id');
      final upsertHeaders = Map<String, String>.from(_headers)
        ..['Prefer'] = 'resolution=merge-duplicates';
      final response = await http.post(upsertUri, headers: upsertHeaders, body: jsonEncode(payload));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Upsert succeeded
      } else if (response.statusCode == 409 || response.statusCode == 400) {
        // Fallback: patch existing closing record by ID
        await _patch('daily_closings?id=eq.${closing.id}', payload);
      } else {
        debugPrint('Supabase daily_closings upsert returned ${response.statusCode}: ${response.body}');
        await _patch('daily_closings?id=eq.${closing.id}', payload);
      }
    } catch (e) {
      debugPrint('Supabase saveDailyFinancialClosing exception: $e');
      try {
        await _patch('daily_closings?id=eq.${closing.id}', payload);
      } catch (_) {}
    }
    await _fallbackLocalRepo.saveDailyFinancialClosing(closing);
  }

  @override
  Future<void> deleteDailyFinancialClosing(String id) async {
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
}
