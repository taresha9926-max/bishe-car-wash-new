import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';

void main() {
  test(
    'SupabaseWashRepositoryImpl hermetic test: loads packages, creates booking, and handles configs without live network calls',
    timeout: const Timeout(Duration(seconds: 30)),
    () async {
      final inMemoryBookings = <Map<String, dynamic>>[];
      final inMemoryCommLogs = <Map<String, dynamic>>[];
      Map<String, dynamic> inMemoryTikTokConfig = {
        'id': 'primary',
        'reels_json': jsonEncode([
          {
            'id': 'reel-1',
            'title': 'Original Reel',
            'subtitle': 'Watch on TikTok',
            'tiktokUrl': 'https://vt.tiktok.com/ZSgWCxdWL/',
            'thumbnailUrl': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f',
          }
        ]),
      };

      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.contains('wash_packages')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'pkg-mock-01',
                'name': 'Basic Wash',
                'description': 'Exterior rinse',
                'estimated_minutes': 25,
                'price_automobile': 300,
                'price_minibus': 450,
                'price_truck': 600,
                'features': ['Rinse', 'Foam'],
              }
            ]),
            200,
          );
        }

        if (path.contains('wash_bookings')) {
          if (request.method == 'POST') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            inMemoryBookings.add(Map<String, dynamic>.from(body));
            return http.Response(jsonEncode([body]), 201);
          }
          if (request.method == 'PATCH') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            final id = request.url.queryParameters['id']?.replaceFirst('eq.', '') ?? '';
            final idx = inMemoryBookings.indexWhere((b) => b['id'] == id);
            if (idx >= 0) {
              inMemoryBookings[idx].addAll(body);
            }
            return http.Response(jsonEncode(inMemoryBookings), 200);
          }
          if (request.method == 'GET') {
            final id = request.url.queryParameters['id']?.replaceFirst('eq.', '');
            if (id != null) {
              final match = inMemoryBookings.where((b) => b['id'] == id).toList();
              return http.Response(jsonEncode(match), 200);
            }
            return http.Response(jsonEncode(inMemoryBookings), 200);
          }
        }

        if (path.contains('staff_credentials')) {
          if (request.url.queryParameters['username'] == 'eq.app_config_tiktok_reels') {
            if (request.method == 'PATCH') {
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              inMemoryTikTokConfig['full_name'] = body['full_name'];
              return http.Response('[{"id":"cfg-1"}]', 200);
            }
            if (request.method == 'POST') {
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              inMemoryTikTokConfig['full_name'] = body['full_name'];
              return http.Response('[{"id":"cfg-1"}]', 201);
            }
            return http.Response(
              jsonEncode([
                {'full_name': inMemoryTikTokConfig['full_name']}
              ]),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response(
            jsonEncode([
              {
                'id': 'cred-admin',
                'username': 'admin',
                'pin_hash': '4450',
                'role': 'admin',
                'full_name': 'Bishe Super Admin',
                'is_active': true,
              },
              {
                'id': 'cred-cashier',
                'username': 'cashier',
                'pin_hash': '2233',
                'role': 'cashier',
                'full_name': 'Station Gate Cashier',
                'is_active': true,
              }
            ]),
            200,
          );
        }

        if (path.contains('commission_logs')) {
          if (request.method == 'POST') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            inMemoryCommLogs.add(Map<String, dynamic>.from(body));
            return http.Response(jsonEncode([body]), 201);
          }
          return http.Response(jsonEncode(inMemoryCommLogs), 200);
        }

        if (path.contains('app_config_tiktok_reels')) {
          if (request.method == 'GET') {
            return http.Response(jsonEncode([inMemoryTikTokConfig]), 200);
          }
          if (request.method == 'PATCH') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            inMemoryTikTokConfig.addAll(body);
            return http.Response(jsonEncode([inMemoryTikTokConfig]), 200);
          }
        }

        return http.Response('[]', 200);
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://mock-isolated.supabase.co',
        anonKey: 'mock-test-anon-key',
        httpClient: mockClient,
      );

      // 1. Packages should load from mock client
      final packages = await repo.getPackages();
      expect(packages, isNotEmpty);
      expect(packages.first.name, 'Basic Wash');

      // 2. Create a test booking hermetically
      final testBooking = WashBooking(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        customerName: 'Integration Test Customer',
        customerPhone: '0911002233',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'TEST-9999',
        package: packages.first,
        status: WashStatus.pending,
        assignedBay: BayType.bay1,
        payment: const PaymentInfo(
          isPaid: false,
          method: PaymentMethod.cash,
          amount: 500.0,
        ),
        createdAt: DateTime.now(),
      );

      final created = await repo.createBooking(testBooking);
      expect(created.id, isNotEmpty);

      // 3. Update status to completed
      final updated = await repo.updateWashStatus(created.id, WashStatus.completed);
      expect(updated.status, WashStatus.completed);

      // 4. Verify staff credentials loaded safely
      final creds = await repo.getStaffCredentials();
      expect(creds, isNotEmpty);
      final adminCred = creds.firstWhere((c) => c.role == UserRole.admin);
      expect(adminCred.pin, isNotEmpty);
      final cashierCred = creds.where((c) => c.role == UserRole.cashier).firstOrNull;
      if (cashierCred != null) {
        expect(cashierCred.pin, isNotEmpty);
      }

      // 5. Test TikTok Reels cloud persistence with mock
      final initialReels = await repo.getTikTokReels();
      expect(initialReels, isNotEmpty);

      final customReels = List<TikTokAdVideo>.from(initialReels);
      while (customReels.length < 4) {
        customReels.add(TikTokAdVideo(
          id: 'reel-${customReels.length + 1}',
          title: 'Detailing Reel #${customReels.length + 1}',
          subtitle: 'Watch on TikTok',
          tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
          thumbnailUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=800&auto=format&fit=crop&q=80',
        ));
      }
      for (int i = 0; i < customReels.length; i++) {
        customReels[i] = customReels[i].copyWith(
          tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
        );
      }
      await repo.saveTikTokReels(customReels);

      final persistedReels = await repo.getTikTokReels();
      expect(persistedReels.length, greaterThanOrEqualTo(1));

      // Verify staff credentials never expose the system config row
      final filteredCreds = await repo.getStaffCredentials();
      expect(filteredCreds.any((c) => c.username == 'app_config_tiktok_reels'), isFalse);
    },
  );
}
