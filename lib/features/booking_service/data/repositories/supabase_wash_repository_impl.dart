import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bishe_car_wash/features/admin/domain/models/commission_log.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';

class SupabaseWashRepositoryImpl implements IWashRepository {
  final String supabaseUrl;
  final String anonKey;
  final WashRepositoryImpl _fallback = WashRepositoryImpl();

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

  @override
  Future<List<WashBooking>> getBookings() async {
    try {
      final res = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/wash_bookings?select=*&order=created_at.desc'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return await _fallback.getBookings();
      }
    } catch (_) {}
    return _fallback.getBookings();
  }

  @override
  Future<WashBooking?> getBookingById(String id) => _fallback.getBookingById(id);

  @override
  Future<WashBooking?> getBookingByPlate(String licensePlate) => _fallback.getBookingByPlate(licensePlate);

  @override
  Future<WashBooking> createBooking(WashBooking booking) async {
    try {
      final payload = {
        'id': booking.id,
        'customer_name': booking.customerName,
        'customer_phone': booking.customerPhone,
        'license_plate': booking.licensePlate,
        'car_type': booking.carType.name,
        'status': booking.status.name,
        'total_price': booking.totalPrice,
        'payment_status': booking.payment.isPaid ? 'paid' : 'pending',
        'payment_method': booking.payment.method.name,
      };
      await http.post(
        Uri.parse('$supabaseUrl/rest/v1/wash_bookings'),
        headers: _headers,
        body: jsonEncode(payload),
      );
    } catch (_) {}
    return _fallback.createBooking(booking);
  }

  @override
  Future<WashBooking> updateWashStatus(String bookingId, WashStatus newStatus) async {
    final updated = await _fallback.updateWashStatus(bookingId, newStatus);
    try {
      await http.patch(
        Uri.parse('$supabaseUrl/rest/v1/wash_bookings?id=eq.$bookingId'),
        headers: _headers,
        body: jsonEncode({'status': newStatus.name}),
      );
      if (newStatus == WashStatus.completed) {
        await recordSmsNotification(
          bookingId: updated.id,
          licensePlate: updated.licensePlate,
          recipientPhone: updated.customerPhone,
          amount: updated.totalPrice,
        );
      }
    } catch (_) {}
    return updated;
  }

  @override
  Future<WashBooking> assignBayAndWashers({
    required String bookingId,
    required BayType bay,
    required List<String> washerNames,
  }) =>
      _fallback.assignBayAndWashers(
        bookingId: bookingId,
        bay: bay,
        washerNames: washerNames,
      );

  @override
  Future<WashBooking> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    String? transactionRef,
  }) =>
      _fallback.processPayment(
        bookingId: bookingId,
        method: method,
        amount: amount,
        transactionRef: transactionRef,
      );

  @override
  Future<List<StationBay>> getBays() => _fallback.getBays();

  @override
  Future<List<WashPackage>> getPackages() => _fallback.getPackages();

  @override
  Future<void> updatePackagePrice(String packageId, CarType carType, double newPrice) =>
      _fallback.updatePackagePrice(packageId, carType, newPrice);

  @override
  Future<List<StaffMember>> getStaffMembers() => _fallback.getStaffMembers();

  @override
  Future<void> updateStaffSalary(String staffId, double baseSalary, double commissionRate) =>
      _fallback.updateStaffSalary(staffId, baseSalary, commissionRate);

  @override
  Future<void> addStaffMember(StaffMember staff) => _fallback.addStaffMember(staff);

  @override
  Future<List<CommissionLog>> getCommissionLogs() => _fallback.getCommissionLogs();

  @override
  Future<void> settleCommission(String logId) => _fallback.settleCommission(logId);

  @override
  Future<void> recordSmsNotification({
    required String bookingId,
    required String licensePlate,
    required String recipientPhone,
    required double amount,
  }) async {
    final msg =
        'Dear Customer, vehicle $licensePlate wash is completed at BISHE Car Wash! Total: ${amount.toStringAsFixed(0)} ETB. Payment: Cash, Telebirr, or CBE Birr. Please pick up your vehicle. Thank you!';
    try {
      await http.post(
        Uri.parse('$supabaseUrl/rest/v1/sms_outbox'),
        headers: _headers,
        body: jsonEncode({
          'order_id': bookingId,
          'license_plate': licensePlate,
          'recipient_phone': recipientPhone,
          'message_body': msg,
          'status': 'pending',
        }),
      );
    } catch (_) {}
  }
}
