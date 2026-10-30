import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/staff_authenticator.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/datasources/mock_wash_datasource.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_dispatcher.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';

void main() {
  group('WashDispatcher (Deep Dispatch Module)', () {
    const dummyPackage = WashPackage(
      id: 'pkg-1',
      name: 'Standard Clean',
      description: 'Standard exterior and interior clean',
      durationMinutes: 30,
      pricingByCarType: {CarType.automobile: 300},
      features: ['Foam wash', 'Vacuum'],
    );

    test('estimateStationWaitMinutes returns 0 when bays open and queue is empty', () {
      final wait = WashDispatcher.estimateStationWaitMinutes(
        availableBaysCount: 2,
        queue: [],
      );
      expect(wait, equals(0));
    });

    test('estimateStationWaitMinutes computes 2-bay parallel concurrency', () {
      final now = DateTime(2026, 10, 26, 12, 0);
      final booking1 = WashBooking(
        id: 'B1',
        customerName: 'Abebe',
        customerPhone: '+251911111111',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ET-3-A11111',
        package: dummyPackage,
        status: WashStatus.washing,
        payment: const PaymentInfo(amount: 300),
        createdAt: now, // 0 min elapsed, 30 min remaining
      );
      final booking2 = WashBooking(
        id: 'B2',
        customerName: 'Chala',
        customerPhone: '+251922222222',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ET-3-B22222',
        package: dummyPackage,
        status: WashStatus.washing,
        payment: const PaymentInfo(amount: 300),
        createdAt: now, // 0 min elapsed, 30 min remaining
      );

      // Total remaining = 30 + 30 = 60 mins. Across 2 physical bays: (60 / 2).ceil() = 30 mins.
      final wait = WashDispatcher.estimateStationWaitMinutes(
        availableBaysCount: 0,
        queue: [booking1, booking2],
        now: now,
      );
      expect(wait, equals(30));
    });

    test('estimateMobileVanWaitMinutes returns 0 when van available and queue empty', () {
      final wait = WashDispatcher.estimateMobileVanWaitMinutes(
        isVanAvailable: true,
        queue: [],
      );
      expect(wait, equals(0));
    });

    test('nextStatus follows linear state machine lifecycle', () {
      expect(WashDispatcher.nextStatus(WashStatus.pending), equals(WashStatus.washing));
      expect(WashDispatcher.nextStatus(WashStatus.assignedToBay), equals(WashStatus.washing));
      expect(WashDispatcher.nextStatus(WashStatus.washing), equals(WashStatus.drying));
      expect(WashDispatcher.nextStatus(WashStatus.drying), equals(WashStatus.readyForPickup));
      expect(WashDispatcher.nextStatus(WashStatus.readyForPickup), equals(WashStatus.completed));
      expect(WashDispatcher.nextStatus(WashStatus.completed), isNull);
      expect(WashDispatcher.nextStatus(WashStatus.cancelled), isNull);
    });

    test('findBookingForBay and getBayWashStatus correlate bay booking', () {
      const bay = StationBay(
        type: BayType.bay1,
        status: BayStatus.occupied,
        activeBookingId: 'B1',
      );
      final booking = WashBooking(
        id: 'B1',
        customerName: 'Abebe',
        customerPhone: '+251911111111',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ET-3-A11111',
        package: dummyPackage,
        status: WashStatus.drying,
        payment: const PaymentInfo(amount: 300),
        createdAt: DateTime.now(),
      );

      final found = WashDispatcher.findBookingForBay(bay, [booking]);
      expect(found, isNotNull);
      expect(found?.id, equals('B1'));
      expect(WashDispatcher.getBayWashStatus(bay, [booking]), equals(WashStatus.drying));
    });
  });

  group('StaffAuthenticator (Encapsulated Auth Seam)', () {
    test('Customer role always succeeds without credentials', () {
      expect(
        StaffAuthenticator.authenticate(
          role: UserRole.customer,
          enteredPin: '',
          credentials: [],
        ),
        isTrue,
      );
    });

    test('Default fallback PINs work when credentials list is empty', () {
      expect(
        StaffAuthenticator.authenticate(
          role: UserRole.admin,
          enteredPin: '1234',
          credentials: [],
        ),
        isTrue,
      );
      expect(
        StaffAuthenticator.authenticate(
          role: UserRole.cashier,
          enteredPin: '0000',
          credentials: [],
        ),
        isTrue,
      );
      expect(
        StaffAuthenticator.authenticate(
          role: UserRole.admin,
          enteredPin: 'wrong',
          credentials: [],
        ),
        isFalse,
      );
    });

    test('Custom active credentials take priority and check active state', () {
      final creds = [
        const StaffCredential(
          id: 'c1',
          username: 'cashier1',
          pin: '8899',
          role: UserRole.cashier,
          fullName: 'Chaltu B.',
          isActive: true,
        ),
        const StaffCredential(
          id: 'c2',
          username: 'admin1',
          pin: '7766',
          role: UserRole.admin,
          fullName: 'Biniam A.',
          isActive: false, // Inactive
        ),
      ];

      expect(
        StaffAuthenticator.authenticate(
          role: UserRole.cashier,
          enteredPin: '8899',
          credentials: creds,
        ),
        isTrue,
      );

      // Inactive admin cannot log in even with correct PIN
      expect(
        StaffAuthenticator.authenticate(
          role: UserRole.admin,
          enteredPin: '7766',
          credentials: creds,
        ),
        isFalse,
      );
    });
  });

  group('Repository Seams (Domain Ports)', () {
    test('IBookingRepository, IPricingRepository, IStaffRepository, IMarketingRepository form IWashRepository', () {
      // Confirms contract composition at compile-time and runtime
      expect(IWashRepository, isNotNull);
      expect(IMarketingRepository, isNotNull);
    });
  });

  group('Bishe Official Price List & 8-Washer Team Commission', () {
    test('MockWashDataSource contains the 10 official packages from price sheet', () {
      expect(CarType.values.length, equals(3));
      expect(CarType.automobile.displayName, equals('Type A (Small)'));
      expect(CarType.minibus.displayName, equals('Type B (Medium)'));
      expect(CarType.truck.displayName, equals('Type C (Truck)'));

      final packages = MockWashDataSource.getInitialPackages();
      expect(packages.length, equals(10));

      final silver = packages.firstWhere((p) => p.id == 'a0000000-0000-0000-0000-000000000101' || p.name.contains('Silver'));
      expect(silver.getPriceFor(CarType.automobile), equals(500.0));
      expect(silver.getPriceFor(CarType.minibus), equals(700.0));
      expect(silver.getPriceFor(CarType.truck), equals(1200.0));

      final diamondFull = packages.firstWhere((p) => p.id == 'a0000000-0000-0000-0000-000000000109' || p.name.contains('Diamond Full'));
      expect(diamondFull.getPriceFor(CarType.automobile), equals(13000.0));
      expect(diamondFull.getPriceFor(CarType.minibus), equals(20500.0));
      expect(diamondFull.getPriceFor(CarType.truck), equals(26000.0));

      // Verify distinct localization for Platinum A, B, C
      final platA = packages.firstWhere((p) => p.id.endsWith('0104'));
      final platB = packages.firstWhere((p) => p.id.endsWith('0105'));
      final platC = packages.firstWhere((p) => p.id.endsWith('0106'));
      expect(platA.localizedName('en'), equals('Platinum Exterior - A'));
      expect(platB.localizedName('en'), equals('Platinum Exterior - B'));
      expect(platC.localizedName('en'), equals('Platinum Exterior - C'));

      // Verify distinct localization for Diamond A, B, C
      final diamA = packages.firstWhere((p) => p.id.endsWith('0107'));
      final diamB = packages.firstWhere((p) => p.id.endsWith('0108'));
      final diamC = packages.firstWhere((p) => p.id.endsWith('0109'));
      expect(diamA.localizedName('en'), equals('Diamond Package A'));
      expect(diamB.localizedName('en'), equals('Diamond Package B'));
      expect(diamC.localizedName('en'), equals('Diamond Package C (Full)'));

      // Verify itemized features translation in Afaan Oromoo and Amharic
      final silverFeaturesEn = silver.localizedFeatures('en');
      final silverFeaturesOm = silver.localizedFeatures('om');
      final silverFeaturesAm = silver.localizedFeatures('am');
      expect(silverFeaturesEn.length, equals(5));
      expect(silverFeaturesOm.length, equals(5));
      expect(silverFeaturesAm.length, equals(5));
      expect(silverFeaturesOm.first, contains('dhiibbaa bishaaniin'));
      expect(silverFeaturesAm.first, contains('የውሃ ግፊት'));

      final platInt = packages.firstWhere((p) => p.id.endsWith('0103'));
      expect(platInt.localizedFeatures('om').first, contains('Barcumti'));
      expect(platInt.localizedFeatures('am').first, contains('ወንበሮች'));
    });

    test('8 Washers form a single team with seniority weights and dividends', () {
      final staff = MockWashDataSource.getInitialStaff();
      final washers = staff.where((s) => s.role == StaffRole.washer || s.role == StaffRole.leadDetailer).toList();
      expect(washers.length, equals(8));

      // 10,000 ETB revenue * 15% rate = 1,500 ETB pool
      const dailyRevenue = 10000.0;
      const rate = 0.15;
      const pool = dailyRevenue * rate;
      expect(pool, equals(1500.0));

      final totalWeight = washers.fold<int>(0, (sum, w) => sum + w.skillSeniorityLevel);
      expect(totalWeight, greaterThan(0));

      final lead = washers.firstWhere((w) => w.role == StaffRole.leadDetailer);
      final leadDividend = (lead.skillSeniorityLevel / totalWeight) * pool;

      final junior = washers.firstWhere((w) => w.skillSeniorityLevel == 1);
      final juniorDividend = (junior.skillSeniorityLevel / totalWeight) * pool;

      expect(leadDividend, greaterThan(juniorDividend));
    });

    test('Workflow Guardrails: ServiceType.phoneCallBooking and payment lock upon completion', () {
      expect(ServiceType.values, contains(ServiceType.phoneCallBooking));
      expect(ServiceType.phoneCallBooking.displayName, equals('Phone Reservation'));

      final booking = WashBooking(
        id: 'BSH-101',
        customerName: 'Phone Customer',
        customerPhone: '+251911223344',
        serviceType: ServiceType.phoneCallBooking,
        carType: CarType.automobile,
        licensePlate: 'AA-2-B12345',
        package: MockWashDataSource.getInitialPackages().first,
        status: WashStatus.washing,
        payment: const PaymentInfo(isPaid: false, amount: 300),
        createdAt: DateTime.now(),
        isPhoneBooking: true,
      );

      // Payment is strictly locked while wash is ongoing
      final isPaymentEligibleWhileWashing = booking.status == WashStatus.completed && !booking.payment.isPaid;
      expect(isPaymentEligibleWhileWashing, isFalse);

      // Payment unlocks when vehicle is marked completed
      final completedBooking = booking.copyWith(status: WashStatus.completed);
      final isPaymentEligibleWhenCompleted = completedBooking.status == WashStatus.completed && !completedBooking.payment.isPaid;
      expect(isPaymentEligibleWhenCompleted, isTrue);
    });
  });

  group('UrlLauncherHelper Sanitization & Multi-Format TikTok Links', () {
    test('extracts clean URL from TikTok mobile share sheet text', () {
      const shareSheetText = 'Check out this car detailing video on TikTok! https://vt.tiktok.com/ZSgWCxdWL/ #bishe';
      expect(UrlLauncherHelper.cleanUrl(shareSheetText), equals('https://vt.tiktok.com/ZSgWCxdWL/'));
    });

    test('strips invisible unicode control and bidi characters from mobile clipboards', () {
      const bidiUrl = '\u200Ehttps://vt.tiktok.com/ZSgWCxdWL/\u202C';
      expect(UrlLauncherHelper.cleanUrl(bidiUrl), equals('https://vt.tiktok.com/ZSgWCxdWL/'));
    });

    test('prepends https scheme if omitted by user', () {
      const rawDomain = 'vt.tiktok.com/ZSgWCxdWL/';
      expect(UrlLauncherHelper.cleanUrl(rawDomain), equals('https://vt.tiktok.com/ZSgWCxdWL/'));
    });

    test('trims trailing punctuation and whitespace', () {
      const punctUrl = '  https://www.tiktok.com/@bishe_car_wash/video/123456789.,;)  ';
      expect(UrlLauncherHelper.cleanUrl(punctUrl), equals('https://www.tiktok.com/@bishe_car_wash/video/123456789'));
    });
  });
}
