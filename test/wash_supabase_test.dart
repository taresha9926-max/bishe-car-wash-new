import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

void main() {
  test(
    'SupabaseWashRepositoryImpl loads packages and saves live booking to Supabase',
    () async {
      final repo = SupabaseWashRepositoryImpl(
      supabaseUrl: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    // 1. Packages should load from Supabase or fallback
    final packages = await repo.getPackages();
    expect(packages, isNotEmpty);

    // 2. Create a test booking
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

    // 4. Verify live staff credentials loaded from Supabase
    final creds = await repo.getStaffCredentials();
    expect(creds, isNotEmpty);
    final adminCred = creds.firstWhere((c) => c.role == UserRole.admin);
    final cashierCred = creds.firstWhere((c) => c.role == UserRole.cashier);
    expect(adminCred.pin, equals('4450'));
    expect(cashierCred.pin, equals('2233'));

    // 5. Verify live commission log was created upon completion
    final commLogs = await repo.getCommissionLogs();
    expect(commLogs, isNotEmpty);
    final recentLog = commLogs.firstWhere((l) => l.carPlate == 'TEST-9999');
    expect(recentLog.commissionEarnedETB, equals(packages.first.getPriceFor(CarType.automobile) * 0.15)); // 15% commission of package price

    // 6. Test TikTok Reels cloud persistence across devices
    final initialReels = await repo.getTikTokReels();
    expect(initialReels, isNotEmpty);

    // Save custom reels including the exact user video URL
    final customReels = [
      ...initialReels,
    ];
    customReels[0] = customReels[0].copyWith(
      tiktokUrl: 'https://vt.tiktok.com/ZSgWCxdWL/',
    );
    await repo.saveTikTokReels(customReels);

    // Fetch again from Supabase to verify all customer phones will load this cloud update
    final persistedReels = await repo.getTikTokReels();
    expect(persistedReels.first.tiktokUrl, equals('https://vt.tiktok.com/ZSgWCxdWL/'));

    // Verify staff credentials never expose the system config row
    final filteredCreds = await repo.getStaffCredentials();
    expect(filteredCreds.any((c) => c.username == 'app_config_tiktok_reels'), isFalse);
  },
  timeout: const Timeout(Duration(minutes: 2)),
);
}
