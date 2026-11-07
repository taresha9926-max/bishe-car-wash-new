import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';

void main() {
  group('Carpet Cashier Separation & Dual SMS Pipeline Tests', () {
    late WashRepositoryImpl repository;
    late AppStateNotifier state;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      await state.loadData();
    });

    test('Cashier registers carpet walk-in with CPT tag and no vehicle bay', () async {
      final carpetBooking = await state.registerWalkIn(
        customerName: 'Kenenisa Bekele',
        customerPhone: '+251 91 122 3344',
        licensePlate: 'CPT-7721',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedBay: null,
        paymentMethod: PaymentMethod.cash,
        isCarpet: true,
        carpetType: 'type_a',
        carpetAreaSqMeters: 12.0,
        carpetDimensions: '3.0m x 4.0m',
        customTotalPrice: 1800.0,
      );

      expect(carpetBooking.isCarpet, isTrue);
      expect(carpetBooking.licensePlate, 'CPT-7721');
      expect(carpetBooking.carpetType, 'type_a');
      expect(carpetBooking.carpetAreaSqMeters, 12.0);
      expect(carpetBooking.carpetDimensions, '3.0m x 4.0m');
      expect(carpetBooking.totalPrice, 1800.0);
      expect(carpetBooking.assignedBay, isNull);

      // Verify strict separation
      expect(state.carpetWashBookings.any((b) => b.id == carpetBooking.id), isTrue);
      expect(state.carWashBookings.any((b) => b.id == carpetBooking.id), isFalse);
    });

    test('Zero cross-contamination: vehicle wash vs carpet wash queues', () async {
      // 1. Create a car wash booking
      final carBooking = await state.registerWalkIn(
        customerName: 'Abebe Bikila',
        customerPhone: '+251 92 233 4455',
        licensePlate: 'ET-3-B12345',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedBay: null,
        paymentMethod: PaymentMethod.cash,
        isCarpet: false,
      );

      // 2. Create a carpet cleaning booking
      final carpetBooking = await state.registerWalkIn(
        customerName: 'Derartu Tulu',
        customerPhone: '+251 93 344 5566',
        licensePlate: 'CPT-8832',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedBay: null,
        paymentMethod: PaymentMethod.cash,
        isCarpet: true,
        carpetType: 'type_b',
        carpetAreaSqMeters: 15.0,
        carpetDimensions: '3.0m x 5.0m',
        customTotalPrice: 3000.0,
      );

      // Verify car wash queue has ONLY car booking
      final carQueue = state.carWashBookings;
      expect(carQueue.any((b) => b.id == carBooking.id), isTrue);
      expect(carQueue.any((b) => b.isCarpet), isFalse);

      // Verify carpet queue has ONLY carpet booking
      final carpetQueue = state.carpetWashBookings;
      expect(carpetQueue.any((b) => b.id == carpetBooking.id), isTrue);
      expect(carpetQueue.any((b) => !b.isCarpet), isFalse);
    });

    test('Dual SMS dispatch: SMS 1 (Intake with Tag) and SMS 2 (Completion Notice) with trilingual support', () async {
      final carpetBooking = WashBooking(
        id: 'CPT-9901',
        customerName: 'Fatuma Roba',
        customerPhone: '+251 94 455 6677',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'CPT-9901',
        package: state.packages.first,
        status: WashStatus.pending,
        payment: const PaymentInfo(isPaid: false, method: PaymentMethod.cash, amount: 2400.0),
        createdAt: DateTime.now(),
        isCarpet: true,
        carpetType: 'type_b',
        carpetAreaSqMeters: 12.0,
        carpetDimensions: '3.0m x 4.0m',
        customTotalPrice: 2400.0,
      );

      // 1. Verify SMS 1 (Intake with Tag) across EN, OM, AM
      state.setLanguage('EN');
      final sms1En = state.getCarpetRegistrationSmsText(carpetBooking);
      expect(sms1En, contains('CPT-9901'));
      expect(sms1En, contains('Fatuma Roba'));
      expect(sms1En, contains('Deep Clean (Type B)'));
      expect(sms1En, contains('3.0m x 4.0m'));
      expect(sms1En, contains('2400.00'));

      state.setLanguage('OM');
      final sms1Om = state.getCarpetRegistrationSmsText(carpetBooking);
      expect(sms1Om, contains('CPT-9901'));
      expect(sms1Om, contains('Fatuma Roba'));
      expect(sms1Om, contains('kiliimii'));

      state.setLanguage('AM');
      final sms1Am = state.getCarpetRegistrationSmsText(carpetBooking);
      expect(sms1Am, contains('CPT-9901'));
      expect(sms1Am, contains('Fatuma Roba'));
      expect(sms1Am, contains('የካርፔት'));

      // 2. Verify SMS 2 (Completion Notice) across EN, OM, AM
      final completedCarpet = carpetBooking.copyWith(status: WashStatus.completed);

      state.setLanguage('EN');
      final sms2En = state.getCustomerCompletionSmsText(completedCarpet);
      expect(sms2En, contains('CPT-9901'));
      expect(sms2En, contains('completed and ready'));
      expect(sms2En, contains('2400.00'));

      state.setLanguage('OM');
      final sms2Om = state.getCustomerCompletionSmsText(completedCarpet);
      expect(sms2Om, contains('CPT-9901'));
      expect(sms2Om, contains('guutummaatti xumuramee'));

      state.setLanguage('AM');
      final sms2Am = state.getCustomerCompletionSmsText(completedCarpet);
      expect(sms2Am, contains('CPT-9901'));
      expect(sms2Am, contains('ተጠናቆ ዝግጁ ሆኗል'));
    });

    test('Operational Manager full operational parity: status advancement and completion SMS', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Register an active carpet booking
      final carpetBooking = await state.registerWalkIn(
        customerName: 'Haile Gebrselassie',
        customerPhone: '+251 91 777 8899',
        licensePlate: 'CPT-1122',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedBay: null,
        paymentMethod: PaymentMethod.cash,
        isCarpet: true,
        carpetType: 'type_a',
        carpetAreaSqMeters: 6.0,
        carpetDimensions: '2.0m x 3.0m',
        customTotalPrice: 720.0,
      );

      expect(carpetBooking.status, WashStatus.pending);

      // Operational manager advances status: pending -> washing -> drying -> completed
      await state.updateWashStatus(carpetBooking.id, WashStatus.washing);
      var current = state.bookings.firstWhere((b) => b.id == carpetBooking.id);
      expect(current.status, WashStatus.washing);

      await state.updateWashStatus(carpetBooking.id, WashStatus.drying);
      current = state.bookings.firstWhere((b) => b.id == carpetBooking.id);
      expect(current.status, WashStatus.drying);

      await state.updateWashStatus(carpetBooking.id, WashStatus.completed);
      current = state.bookings.firstWhere((b) => b.id == carpetBooking.id);
      expect(current.status, WashStatus.completed);

      // Verify completion SMS dispatch succeeds
      final smsSent = await state.sendCustomerCompletionSms(current);
      expect(smsSent, isTrue);
    });

    test('Daily financial closing multiple saves and night closing persist without duplicate error', () async {
      final closing1 = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'day',
        closedByRole: 'operational_manager',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );

      expect(closing1.id, contains('day'));
      expect(state.dailyFinancialClosings.first.id, closing1.id);

      // Second save (updating closing on same date & shift)
      final closing2 = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'day',
        notes: 'Updated daily closing numbers',
        closedByRole: 'operational_manager',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );

      expect(closing2.id, closing1.id);
      expect(state.dailyFinancialClosings.first.notes, 'Updated daily closing numbers');

      // Night shift closing
      final nightClosing = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'night',
        closedByRole: 'operational_manager',
        handoverTo: 'Admin',
        handoverMethod: 'admin_otp',
      );

      expect(nightClosing.id, contains('night'));
      expect(state.dailyFinancialClosings.any((c) => c.shiftType == 'night'), isTrue);
    });
  });
}
