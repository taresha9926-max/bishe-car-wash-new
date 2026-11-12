import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';

void main() {
  group('Delivery Fees, 15% VAT Commission, Assigned Tips, SMS Link & Alerts', () {
    late AppStateNotifier state;

    setUp(() async {
      state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
      await state.clearAllBookings();
    });

    test('Admin delivery add-on fees are flat once-per-order and persist in config', () async {
      await state.updateDeliveryAddonFee(
        isCarpet: false,
        mode: ServiceType.valetPickUp,
        fee: 250.0,
      );
      await state.updateDeliveryAddonFee(
        isCarpet: true,
        mode: ServiceType.atHomeMobile,
        fee: 175.0,
      );

      expect(state.getDeliveryAddonFee(ServiceType.walkInStation, isCarpet: false), 0.0);
      expect(state.getDeliveryAddonFee(ServiceType.valetPickUp, isCarpet: false), 250.0);
      expect(state.getDeliveryAddonFee(ServiceType.atHomeMobile, isCarpet: true), 175.0);
      // Carpet base rate stays uniform per m² across delivery modes
      expect(
        state.getCarpetPricePerSqM('type_a', ServiceType.atHomeMobile),
        state.getCarpetPricePerSqM('type_a', ServiceType.walkInStation),
      );
    });

    test('15% VAT deducted before commission; shower & tips exempt; tip goes 100% to assigned washer', () async {
      final washers = state.availableWashers;
      expect(washers.length, greaterThanOrEqualTo(2));
      final assignedWasher = washers[0];
      final otherWasher = washers[1];

      // Register & collect 10,000 ETB wash + 300 ETB tip assigned strictly to washers[0]
      final b = await state.registerWalkIn(
        licensePlate: 'VAT-10K',
        customerPhone: '+251911000111',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedWasherId: assignedWasher.id,
        assignedWasherName: assignedWasher.name,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 10000.0,
      );
      await state.updateWashStatus(b.id, WashStatus.completed);
      await state.processPayment(
        bookingId: b.id,
        method: PaymentMethod.cash,
        amount: 10000.0,
        tipAmount: 300.0,
      );

      // Shower revenue is 100% VAT & commission exempt
      await state.recordShowerEntry(
        userCount: 4,
        paymentMethod: PaymentMethod.cash,
        cashierName: 'Cashier',
      );

      expect(state.vatDeductedTodayETB, closeTo(1500.0, 0.01));
      expect(state.netServiceRevenueTodayETB, closeTo(8500.0, 0.01));
      expect(state.teamWashCommissionTodayETB, closeTo(1275.0, 0.01));
      expect(state.todayCustomerTipsETB, closeTo(300.0, 0.01));
      expect(state.teamCommissionPoolTodayETB, closeTo(1575.0, 0.01));

      // Verify assigned washer gets share of 1275 + full 300 tip; other washer gets only share of 1275
      final dividends = state.washerDividendsToday;
      final assignedDiv = dividends[assignedWasher.id]!;
      final otherDiv = dividends[otherWasher.id]!;
      final assignedExpectedWashShare = (assignedDiv.percentageShare / 100.0) * 1275.0;
      final otherExpectedWashShare = (otherDiv.percentageShare / 100.0) * 1275.0;

      expect(assignedDiv.earnedETB, closeTo(assignedExpectedWashShare + 300.0, 0.01));
      expect(otherDiv.earnedETB, closeTo(otherExpectedWashShare, 0.01));
      expect(state.getTodayDirectTipsForWasher(assignedWasher.id), closeTo(300.0, 0.01));
      expect(state.getTodayDirectTipsForWasher(otherWasher.id), 0.0);
    });

    test('SMS templates across EN/OM/AM include https://bishecarwash.vercel.app', () async {
      final b = await state.bookNewWash(
        customerName: 'Tare',
        customerPhone: '+251911223344',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: '3333',
        package: state.packages.first,
        customTotalPrice: 1100.0,
      );

      for (final lang in ['EN', 'OM', 'AM']) {
        state.setLanguage(lang);
        expect(state.getCustomerCompletionSmsText(b), endsWith('\nhttps://bishecarwash.vercel.app'));
        expect(state.getCarpetRegistrationSmsText(b), endsWith('\nhttps://bishecarwash.vercel.app'));
      }
    });

    test('Online booking alerts trigger notification epoch bump and dismiss cleanly', () async {
      final initialEpoch = state.onlineBookingAlertEpoch;
      expect(state.pendingOnlineAlerts, isEmpty);

      await state.bookNewWash(
        customerName: 'Online Guest',
        customerPhone: '+251911998877',
        serviceType: ServiceType.valetPickUp,
        carType: CarType.automobile,
        licensePlate: 'ONL-901',
        package: state.packages.first,
        isPhoneBooking: false,
      );

      expect(state.onlineBookingAlertEpoch, greaterThan(initialEpoch));
      expect(state.pendingOnlineAlerts.length, 1);

      state.acknowledgeOnlineAlerts();
      expect(state.pendingOnlineAlerts, isEmpty);
    });

    testWidgets('Customer dashboard hides history buttons and NewBookingScreen adds delivery fee', (tester) async {
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: const MaterialApp(home: CustomerHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(state.tr('myCarWashes')), findsNothing);
      expect(find.text(state.tr('myCarpetCleanings')), findsNothing);

      // Verify NewBookingScreen automatically adds delivery fee for VIP Driver
      await state.updateDeliveryAddonFee(isCarpet: false, mode: ServiceType.valetPickUp, fee: 250.0);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: const MaterialApp(
            home: NewBookingScreen(
              initialServiceType: ServiceType.valetPickUp,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('250'), findsWidgets);
    });
  });
}
