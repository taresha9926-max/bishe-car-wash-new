import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';

void main() {
  group('Supabase Egress Optimization & Alert Poller Tests', () {
    late WashRepositoryImpl repository;

    setUp(() {
      repository = WashRepositoryImpl();
    });

    test('getPendingOnlineAlerts filters exclusively for pending online bookings', () async {
      final packages = await repository.getPackages();
      final pkg = packages.first;

      // Seed walk-in pending booking
      final walkIn = WashBooking(
        id: 'b-walkin-1',
        customerName: 'Walk In Customer',
        customerPhone: '0911000001',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'AA-11111',
        package: pkg,
        status: WashStatus.pending,
        payment: const PaymentInfo(isPaid: false, method: PaymentMethod.cash, amount: 300),
        createdAt: DateTime.now(),
        isOnlineBooking: false,
      );
      await repository.createBooking(walkIn);

      // Seed completed online booking
      final completedOnline = WashBooking(
        id: 'b-online-completed',
        customerName: 'Completed Customer',
        customerPhone: '0911000002',
        serviceType: ServiceType.atHomeMobile,
        carType: CarType.automobile,
        licensePlate: 'AA-22222',
        package: pkg,
        status: WashStatus.completed,
        payment: const PaymentInfo(isPaid: true, method: PaymentMethod.telebirr, amount: 300),
        createdAt: DateTime.now(),
        isOnlineBooking: true,
      );
      await repository.createBooking(completedOnline);

      // Seed pending online booking (the target)
      final pendingOnline = WashBooking(
        id: 'b-online-pending-1',
        customerName: 'Pending Online Customer',
        customerPhone: '0911000003',
        serviceType: ServiceType.atHomeMobile,
        carType: CarType.automobile,
        licensePlate: 'AA-33333',
        package: pkg,
        status: WashStatus.pending,
        payment: const PaymentInfo(isPaid: false, method: PaymentMethod.telebirr, amount: 300),
        createdAt: DateTime.now(),
        isOnlineBooking: true,
      );
      await repository.createBooking(pendingOnline);

      final alerts = await repository.getPendingOnlineAlerts();

      expect(alerts.isNotEmpty, isTrue);
      expect(alerts.any((b) => b.id == 'b-online-pending-1'), isTrue);
      // Ensure walk-in and completed online bookings are excluded from alerts
      expect(alerts.any((b) => b.id == 'b-walkin-1'), isFalse);
      expect(alerts.any((b) => b.id == 'b-online-completed'), isFalse);
    });

    test('getPendingOnlineAlerts caps result to at most 5 items for minimal egress', () async {
      final packages = await repository.getPackages();
      final pkg = packages.first;

      for (int i = 0; i < 10; i++) {
        await repository.createBooking(
          WashBooking(
            id: 'b-bulk-online-$i',
            customerName: 'Customer $i',
            customerPhone: '09110000$i',
            serviceType: ServiceType.atHomeMobile,
            carType: CarType.automobile,
            licensePlate: 'AA-0000$i',
            package: pkg,
            status: WashStatus.pending,
            payment: const PaymentInfo(isPaid: false, method: PaymentMethod.telebirr, amount: 300),
            createdAt: DateTime.now(),
            isOnlineBooking: true,
          ),
        );
      }

      final alerts = await repository.getPendingOnlineAlerts();
      expect(alerts.length, lessThanOrEqualTo(5));
    });
  });
}
