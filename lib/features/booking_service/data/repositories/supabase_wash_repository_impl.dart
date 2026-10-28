import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';

class SupabaseWashRepositoryImpl implements IWashRepository {
  final String supabaseUrl;
  final String anonKey;
  final WashRepositoryImpl _fallbackLocalRepo = WashRepositoryImpl();

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
        if ((json['service_type'] ?? '').toString().contains('atHome')) {
          serviceType = ServiceType.atHomeMobile;
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

        return WashBooking(
          id: json['id'].toString(),
          customerName: json['owner_name'] ?? 'Customer',
          customerPhone: json['customer_phone'] ?? '',
          serviceType: serviceType,
          deliveryLocation: json['delivery_location'],
          carType: carType,
          licensePlate: json['license_plate'] ?? '',
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
          ),
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
          commissionLogged: json['commission_logged'] ?? false,
          isPhoneBooking: isPhone,
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

      final payload = {
        'owner_name': booking.customerName,
        'customer_phone': booking.customerPhone,
        'car_type': booking.carType.name,
        'service_type': booking.serviceType.name,
        'package_id': _isUuid(booking.package.id) ? booking.package.id : null,
        'assigned_bay_id': bayId,
        'license_plate': booking.licensePlate,
        'delivery_location': booking.deliveryLocation ?? booking.gpsCoordinates,
        'status': booking.status.name,
        'is_paid': booking.payment.isPaid,
        'payment_method': booking.payment.method.name,
        'total_amount': booking.totalPrice,
        'booking_origin': booking.isPhoneBooking ? 'phone_booking' : (booking.assignedBay != null ? 'gate_walk_in' : 'customer_app'),
        'washer_1_name': booking.assignedWasherName,
        'washer_1_id': _isUuid(booking.assignedWasherId) ? booking.assignedWasherId : null,
        'scheduled_time': booking.scheduledTime?.toIso8601String(),
        'transaction_ref': booking.payment.transactionRef,
        'receipt_url': booking.payment.receiptScreenshot,
      };

      final dynamic res = await _post('wash_bookings', payload);
      if (res != null && res is List && res.isNotEmpty) {
        final newId = res.first['id'].toString();

        if (booking.assignedBay != null) {
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
        if (booking != null && newStatus == WashStatus.completed && !booking.commissionLogged) {
          if (booking.assignedBay != null) {
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
    String? transactionRef,
    String? receiptScreenshot,
  }) async {
    try {
      if (_isUuid(bookingId)) {
        await _patch('wash_bookings?id=eq.$bookingId', {
          'is_paid': true,
          'payment_method': method.name,
          'total_amount': amount,
          'transaction_ref': transactionRef,
          'receipt_url': receiptScreenshot,
        });

        final booking = await getBookingById(bookingId);
        if (booking != null) {
          final updated = booking.copyWith(
            payment: booking.payment.copyWith(
              isPaid: true,
              method: method,
              amount: amount,
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
      transactionRef: transactionRef,
      receiptScreenshot: receiptScreenshot,
    );
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
      return data.map((json) {
        final roleStr = (json['role'] ?? 'cashier').toString().toLowerCase();
        final role = roleStr == 'admin' ? UserRole.admin : UserRole.cashier;
        final rawPin = json['pin_hash']?.toString() ?? '';
        final pin = (rawPin.length > 6 || rawPin.isEmpty)
            ? (role == UserRole.admin ? '1234' : '0000')
            : rawPin;
        return StaffCredential(
          id: json['id'].toString(),
          username: json['username']?.toString() ?? 'staff',
          pin: pin,
          role: role,
          fullName: json['full_name']?.toString() ?? 'Staff Member',
          isActive: json['is_active'] == true,
        );
      }).toList();
    } catch (_) {
      return _fallbackLocalRepo.getStaffCredentials();
    }
  }

  @override
  Future<void> updateStaffCredential(String id, String pin, String fullName) async {
    try {
      await _patch('staff_credentials?id=eq.$id', {
        'pin_hash': pin,
        'full_name': fullName,
      });
    } catch (_) {}
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
}
