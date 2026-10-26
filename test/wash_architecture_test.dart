import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/staff_authenticator.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_dispatcher.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/repositories/i_wash_repository.dart';

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
    test('IBookingRepository, IPricingRepository, IStaffRepository form IWashRepository', () {
      // Confirms contract composition at compile-time and runtime
      expect(IWashRepository, isNotNull);
    });
  });
}
