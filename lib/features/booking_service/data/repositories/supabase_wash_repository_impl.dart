import 'dart:convert';
import 'dart:io';
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';

/// Clean Architecture Supabase PostgREST Repository Implementation
/// Connects directly to the live 'bishe car wash' Supabase cloud project.
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

  Future<dynamic> _get(String endpoint) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final request = await client.getUrl(uri);
      _headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(body);
      }
      throw Exception('Supabase GET $endpoint error: ${response.statusCode} - $body');
    } finally {
      client.close();
    }
  }

  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final request = await client.postUrl(uri);
      _headers.forEach((k, v) => request.headers.set(k, v));
      request.add(utf8.encode(jsonEncode(data)));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(body);
      }
      throw Exception('Supabase POST $endpoint error: ${response.statusCode} - $body');
    } finally {
      client.close();
    }
  }

  Future<dynamic> _patch(String endpoint, Map<String, dynamic> data) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final request = await client.patchUrl(uri);
      _headers.forEach((k, v) => request.headers.set(k, v));
      request.add(utf8.encode(jsonEncode(data)));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body.isNotEmpty ? jsonDecode(body) : null;
      }
      throw Exception('Supabase PATCH $endpoint error: ${response.statusCode} - $body');
    } finally {
      client.close();
    }
  }

  @override
  Future<List<WashPackage>> getPackages() async {
    try {
      final List<dynamic> data = await _get('wash_packages?select=*&order=created_at.asc');
      if (data.isEmpty) return _fallbackLocalRepo.getPackages();

      return data.map((json) {
        final List<String> features = [];
        if (json['features'] != null) {
          for (var item in json['features']) {
            features.add(item.toString());
          }
        }

        final autoPrice = double.tryParse(json['price_automobile']?.toString() ?? '300') ?? 300.0;
        final minibusPrice = double.tryParse(json['price_minibus']?.toString() ?? '450') ?? 450.0;
        final truckPrice = double.tryParse(json['price_truck']?.toString() ?? '600') ?? 600.0;

        return WashPackage(
          id: json['id'].toString(),
          name: json['name'] ?? 'Wash Package',
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
      String colName;
      switch (carType) {
        case CarType.automobile:
          colName = 'price_automobile';
          break;
        case CarType.minibus:
          colName = 'price_minibus';
          break;
        case CarType.truck:
          colName = 'price_truck';
          break;
      }

      await _patch('wash_packages?id=eq.$packageId', {colName: newPrice});
    } catch (_) {
      await _fallbackLocalRepo.updatePackagePrice(packageId, carType, newPrice);
    }
  }

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    try {
      final List<dynamic> data = await _get('staff_members?select=*&order=created_at.asc');
      if (data.isEmpty) return _fallbackLocalRepo.getStaffMembers();

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
          phone: json['phone'] ?? '+251 91 000 0000',
          role: role,
          baseSalaryMonthlyETB: double.tryParse(json['base_salary']?.toString() ?? '4500') ?? 4500.0,
          commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '0.15') ?? 0.15,
          isAvailable: json['is_active'] ?? true,
        );
      }).toList();
    } catch (_) {
      return _fallbackLocalRepo.getStaffMembers();
    }
  }

  @override
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate) async {
    try {
      await _patch('staff_members?id=eq.$staffId', {
        'base_salary': baseSalary,
        'commission_rate': commissionRate,
      });
    } catch (_) {
      await _fallbackLocalRepo.updateStaffSalary(staffId, baseSalary, commissionRate);
    }
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
    } catch (_) {
      await _fallbackLocalRepo.addStaffMember(staff);
    }
  }

  @override
  Future<List<StationBay>> getBays() async {
    try {
      final List<dynamic> data = await _get('station_bays?select=*&order=bay_number.asc');
      if (data.isEmpty) return _fallbackLocalRepo.getBays();

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
      final List<dynamic> data = await _get('wash_bookings?select=*&order=created_at.desc');
      if (data.isEmpty) return _fallbackLocalRepo.getBookings();

      final packages = await getPackages();

      return data.map((json) {
        CarType carType = CarType.automobile;
        final carStr = (json['car_type'] ?? '').toString().toLowerCase();
        if (carStr.contains('minibus')) carType = CarType.minibus;
        if (carStr.contains('truck')) carType = CarType.truck;

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

        BayType? assignedBay;
        if (json['assigned_bay_id'] != null) {
          final bId = json['assigned_bay_id'].toString();
          if (bId.endsWith('01')) assignedBay = BayType.bay1;
          if (bId.endsWith('02')) assignedBay = BayType.bay2;
          if (bId.endsWith('03')) assignedBay = BayType.mobileVan;
        }

        WashPackage pkg;
        try {
          pkg = packages.firstWhere((p) => p.id == json['package_id']);
        } catch (_) {
          pkg = packages.first;
        }

        PaymentMethod method = PaymentMethod.cash;
        final pMethod = (json['payment_method'] ?? '').toString();
        if (pMethod.contains('telebirr')) method = PaymentMethod.telebirr;
        if (pMethod.contains('cbe')) method = PaymentMethod.cbeBirr;

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
          assignedWasherName: json['washer_1_name'],
          payment: PaymentInfo(
            isPaid: json['is_paid'] ?? false,
            method: method,
            amount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? pkg.getPriceFor(carType),
            transactionRef: json['transaction_ref'],
          ),
          createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
          commissionLogged: json['commission_logged'] ?? false,
        );
      }).toList();
    } catch (_) {
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
      final List<dynamic> res = await _post('wash_bookings', {
        'owner_name': booking.customerName,
        'customer_phone': booking.customerPhone,
        'car_type': booking.carType.name,
        'service_type': booking.serviceType.name,
        'package_id': booking.package.id.length == 36 ? booking.package.id : null,
        'license_plate': booking.licensePlate,
        'delivery_location': booking.deliveryLocation,
        'status': booking.status.name,
        'is_paid': booking.payment.isPaid,
        'payment_method': booking.payment.method.name,
        'total_amount': booking.totalPrice,
      });

      if (res.isNotEmpty) {
        final newId = res.first['id'].toString();
        return booking.copyWith(id: newId);
      }
      return _fallbackLocalRepo.createBooking(booking);
    } catch (_) {
      return _fallbackLocalRepo.createBooking(booking);
    }
  }

  @override
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus) async {
    try {
      await _patch('wash_bookings?id=eq.$bookingId', {
        'status': newStatus.name,
        'completed_at': newStatus == WashStatus.completed ? DateTime.now().toIso8601String() : null,
      });

      final booking = await getBookingById(bookingId);
      if (booking != null && newStatus == WashStatus.completed && !booking.commissionLogged) {
        // Free bay in Supabase
        if (booking.assignedBay != null) {
          final bayNum = booking.assignedBay == BayType.bay1 ? 1 : (booking.assignedBay == BayType.bay2 ? 2 : 3);
          await _patch('station_bays?bay_number=eq.$bayNum', {
            'is_occupied': false,
            'current_booking_id': null,
            'active_license_plate': null,
            'assigned_washer_name': null,
          });
        }

        // Automatic Commission Log in Supabase
        if (booking.assignedWasherId != null) {
          final staffMembers = await getStaffMembers();
          final staff = staffMembers.firstWhere(
            (s) => s.id == booking.assignedWasherId,
            orElse: () => staffMembers.first,
          );
          final earned = booking.totalPrice * staff.commissionRate;

          await _post('commission_logs', {
            'booking_id': booking.id.length == 36 ? booking.id : null,
            'staff_id': staff.id.length == 36 ? staff.id : null,
            'staff_name': staff.name,
            'car_type': booking.carType.displayName,
            'service_name': booking.package.name,
            'license_plate': booking.licensePlate,
            'earned_amount': earned,
            'is_settled': false,
          });

          await _patch('wash_bookings?id=eq.$bookingId', {'commission_logged': true});
        }
      }
      return booking ?? (await _fallbackLocalRepo.updateWashStatus(bookingId, newStatus));
    } catch (_) {
      return await _fallbackLocalRepo.updateWashStatus(bookingId, newStatus);
    }
  }

  @override
  Future<WashBooking> assignBayAndWasher({
    required String bookingId,
    required BayType bay,
    required String washerId,
    required String washerName,
  }) async {
    try {
      final bayNum = bay == BayType.bay1 ? 1 : (bay == BayType.bay2 ? 2 : 3);
      final booking = await getBookingById(bookingId);

      await _patch('wash_bookings?id=eq.$bookingId', {
        'assigned_washer_id': washerId.length == 36 ? washerId : null,
        'washer_1_name': washerName,
        'status': WashStatus.washing.name,
      });

      await _patch('station_bays?bay_number=eq.$bayNum', {
        'is_occupied': true,
        'current_booking_id': bookingId.length == 36 ? bookingId : null,
        'active_license_plate': booking?.licensePlate,
        'assigned_washer_name': washerName,
        'started_at': DateTime.now().toIso8601String(),
      });

      return (await getBookingById(bookingId)) ??
          (await _fallbackLocalRepo.assignBayAndWasher(
            bookingId: bookingId,
            bay: bay,
            washerId: washerId,
            washerName: washerName,
          ));
    } catch (_) {
      return await _fallbackLocalRepo.assignBayAndWasher(
        bookingId: bookingId,
        bay: bay,
        washerId: washerId,
        washerName: washerName,
      );
    }
  }

  @override
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
  }) async {
    try {
      await _patch('wash_bookings?id=eq.$bookingId', {
        'is_paid': true,
        'payment_method': method.name,
        'total_amount': amount,
        'transaction_ref': transactionRef,
      });

      return (await getBookingById(bookingId)) ??
          (await _fallbackLocalRepo.processPayment(
            bookingId: bookingId,
            method: method,
            amount: amount,
            transactionRef: transactionRef,
          ));
    } catch (_) {
      return await _fallbackLocalRepo.processPayment(
        bookingId: bookingId,
        method: method,
        amount: amount,
        transactionRef: transactionRef,
      );
    }
  }

  @override
  Future<List<CommissionLog>> getCommissionLogs() async {
    try {
      final List<dynamic> data = await _get('commission_logs?select=*&order=logged_at.desc');
      if (data.isEmpty) return _fallbackLocalRepo.getCommissionLogs();

      return data.map((json) {
        CarType carType = CarType.automobile;
        final cType = (json['car_type'] ?? '').toString().toLowerCase();
        if (cType.contains('minibus')) carType = CarType.minibus;
        if (cType.contains('truck')) carType = CarType.truck;

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
}
