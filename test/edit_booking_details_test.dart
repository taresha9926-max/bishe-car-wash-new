import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';

void main() {
  group('Edit Booking Details & Supabase Schema Verification', () {
    test('Supabase updateBookingDetails sends car_type and never vehicle_type', () async {
      final inMemoryBookings = <Map<String, dynamic>>[
        {
          'id': '0f893b61-c039-4a96-877e-b8ebd7ea7419',
          'license_plate': 'AA-12345',
          'owner_name': 'Original Owner',
          'customer_phone': '0911000000',
          'car_type': 'automobile',
          'status': 'washing',
          'total_amount': 500.0,
          'is_paid': false,
          'created_at': DateTime.now().toIso8601String(),
        }
      ];

      Map<String, dynamic>? lastPatchBody;

      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.contains('wash_packages')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'b0000000-0000-0000-0000-000000000001',
                'name': 'Silver Wash',
                'description': 'Exterior and interior',
                'estimated_minutes': 30,
                'price_automobile': 500,
                'price_minibus': 700,
                'price_truck': 900,
                'features': ['Rinse', 'Foam'],
              }
            ]),
            200,
          );
        }

        if (path.contains('wash_bookings')) {
          if (request.method == 'GET') {
            return http.Response(jsonEncode(inMemoryBookings), 200);
          }
          if (request.method == 'PATCH') {
            lastPatchBody = jsonDecode(request.body) as Map<String, dynamic>;
            final id = request.url.queryParameters['id']?.replaceFirst('eq.', '') ?? '';
            final idx = inMemoryBookings.indexWhere((b) => b['id'] == id);
            if (idx >= 0) {
              inMemoryBookings[idx].addAll(lastPatchBody!);
            }
            return http.Response(jsonEncode(inMemoryBookings), 200);
          }
        }

        return http.Response(jsonEncode([]), 200);
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://mock.supabase.co',
        anonKey: 'mock-anon-key',
        httpClient: mockClient,
      );

      final updated = await repo.updateBookingDetails(
        bookingId: '0f893b61-c039-4a96-877e-b8ebd7ea7419',
        licensePlate: 'ET-99999',
        customerName: 'Abebe Kebede',
        customerPhone: '0912345678',
        carType: CarType.minibus,
        customTotalPrice: 750.0,
        notes: 'VIP customer edit',
      );

      expect(lastPatchBody, isNotNull);
      expect(lastPatchBody!.containsKey('car_type'), isTrue);
      expect(lastPatchBody!['car_type'], equals('minibus'));
      expect(lastPatchBody!.containsKey('vehicle_type'), isFalse);
      expect(lastPatchBody!['license_plate'], equals('ET-99999'));
      expect(lastPatchBody!['owner_name'], equals('Abebe Kebede'));
      expect(lastPatchBody!['customer_phone'], equals('0912345678'));
      expect(lastPatchBody!['total_amount'], equals(750.0));
      expect(updated.licensePlate, equals('ET-99999'));
      expect(updated.customerName, equals('Abebe Kebede'));
      expect(updated.carType, equals(CarType.minibus));
      expect(updated.totalPrice, equals(750.0));
    });

    test('AppStateNotifier updates in-memory booking and triggers listeners on edit', () async {
      final localRepo = WashRepositoryImpl();
      final packages = await localRepo.getPackages();

      final initialBooking = WashBooking(
        id: 'test-edit-001',
        customerName: 'Initial Name',
        customerPhone: '0911111111',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        package: packages.first,
        payment: const PaymentInfo(isPaid: false, method: PaymentMethod.cash, amount: 500.0),
        licensePlate: 'OLD-1111',
        createdAt: DateTime.now(),
      );
      await localRepo.createBooking(initialBooking);

      final notifier = AppStateNotifier(repository: localRepo);
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.bookings.any((b) => b.id == 'test-edit-001'), isTrue);
      expect(notifier.bookings.firstWhere((b) => b.id == 'test-edit-001').licensePlate, equals('OLD-1111'));

      final edited = await notifier.updateBookingDetails(
        bookingId: 'test-edit-001',
        licensePlate: 'NEW-2222',
        customerName: 'Updated Name',
        carType: CarType.truck,
        customTotalPrice: 950.0,
      );

      expect(edited.licensePlate, equals('NEW-2222'));
      expect(edited.customerName, equals('Updated Name'));
      expect(edited.carType, equals(CarType.truck));
      expect(edited.totalPrice, equals(950.0));

      final stateBooking = notifier.bookings.firstWhere((b) => b.id == 'test-edit-001');
      expect(stateBooking.licensePlate, equals('NEW-2222'));
      expect(stateBooking.customerName, equals('Updated Name'));
      expect(stateBooking.carType, equals(CarType.truck));
      expect(stateBooking.totalPrice, equals(950.0));
    });
  });
}
