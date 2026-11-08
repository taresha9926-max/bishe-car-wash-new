import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_wash_service_item.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Car Wash Dynamic Detailing Services & Negotiated Pricing Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repository;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      await state.loadData();
    });

    test('Loads initial 14 detailing services matching official service menu', () {
      expect(state.serviceItems.length, greaterThanOrEqualTo(14));
      final names = state.serviceItems.map((e) => e.name).toList();
      expect(names.any((n) => n.contains('Body Hand Wash')), isTrue);
      expect(names.any((n) => n.contains('Tire Cleaning')), isTrue);
      expect(names.any((n) => n.contains('Machine Body Polish')), isTrue);
      expect(names.any((n) => n.contains('Engine Bay Chemical Degreasing')), isTrue);
    });

    test('Pricing by CarType calculates correctly across automobile, minibus, truck', () {
      final bodyWash = state.serviceItems.firstWhere((s) => s.id == 'srv_body_wash');
      expect(bodyWash.getPriceFor(CarType.automobile), 500.0);
      expect(bodyWash.getPriceFor(CarType.minibus), 700.0);
      expect(bodyWash.getPriceFor(CarType.truck), 1200.0);
    });

    test('Cashier registers walk-in with custom selected services and negotiated price override', () async {
      final selectedServices = [
        'Body Hand Wash with Shampoo',
        'Tire Cleaning & Tire Black Finish',
        'Machine Body Polish (High-Gloss)',
      ];
      const agreedNegotiatedPrice = 1899.0;

      final booking = await state.registerWalkIn(
        customerName: 'Ato Girma Benti',
        customerPhone: '+251 91 123 4567',
        licensePlate: '3-A44556 ET',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.telebirr,
        selectedServices: selectedServices,
        customTotalPrice: agreedNegotiatedPrice,
      );

      expect(booking.totalPrice, 1899.0);
      expect(booking.selectedServices, isNotNull);
      expect(booking.selectedServices!.length, 3);
      expect(booking.serviceDisplayName, contains('Body Hand Wash with Shampoo (+2 services)'));
    });

    test('Phone reservation records custom services and custom negotiated price', () async {
      final selectedServices = [
        'Body Hand Wash with Shampoo',
        'Window Polish & Exterior Glass',
      ];
      const negotiatedPrice = 650.0;

      final booking = await state.bookNewWash(
        customerName: 'W/ro Selam [Phone]',
        customerPhone: '+251 92 987 6543',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: '3-B11223 ET',
        package: state.packages.first,
        selectedServices: selectedServices,
        customTotalPrice: negotiatedPrice,
      );

      expect(booking.totalPrice, 650.0);
      expect(booking.selectedServices, equals(selectedServices));
      expect(booking.serviceDisplayName, 'Body Hand Wash with Shampoo + Window Polish & Exterior Glass');
    });

    test('Admin adds a new detailing service dynamically and updates prices', () async {
      final initialCount = state.serviceItems.length;
      final newService = const CarWashServiceItem(
        id: 'srv_ceramic_nano_shield',
        name: 'Ceramic Nano-Shield 9H',
        category: 'specialty',
        description: 'Advanced 12-month ceramic paint protection',
        pricingByCarType: {
          CarType.automobile: 3500.0,
          CarType.minibus: 4800.0,
          CarType.truck: 7000.0,
        },
        isActive: true,
      );

      await state.addCustomServiceItem(newService);
      expect(state.serviceItems.length, initialCount + 1);
      expect(state.serviceItems.any((s) => s.id == 'srv_ceramic_nano_shield'), isTrue);

      // Toggle active
      await state.toggleServiceItemActive('srv_ceramic_nano_shield');
      final toggled = state.serviceItems.firstWhere((s) => s.id == 'srv_ceramic_nano_shield');
      expect(toggled.isActive, isFalse);
    });

    test('Customer completion SMS uses serviceDisplayName for custom negotiated services in trilingual formats', () {
      final booking = WashBooking(
        id: 'BSH-777',
        customerName: 'Abebe Bikila',
        customerPhone: '0911223344',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: '3-A99887 ET',
        package: state.packages.first,
        payment: const PaymentInfo(isPaid: false, amount: 1500.0),
        createdAt: DateTime.now(),
        customTotalPrice: 1500.0,
        selectedServices: const [
          'Touchless Snow Foam & Hand Wash',
          'Machine High-Gloss Polish',
        ],
      );

      // English
      state.setLanguage('EN');
      final enSms = state.getCustomerCompletionSmsText(booking);
      expect(enSms, contains('Touchless Snow Foam & Hand Wash + Machine High-Gloss Polish'));
      expect(enSms, contains('1500.00'));

      // Afaan Oromoo
      state.setLanguage('OM');
      final omSms = state.getCustomerCompletionSmsText(booking);
      expect(omSms, contains('Touchless Snow Foam & Hand Wash + Machine High-Gloss Polish'));
      expect(omSms, contains('Kabajamaa Abebe Bikila'));

      // Amharic
      state.setLanguage('AM');
      final amSms = state.getCustomerCompletionSmsText(booking);
      expect(amSms, contains('Touchless Snow Foam & Hand Wash + Machine High-Gloss Polish'));
      expect(amSms, contains('ውድ Abebe Bikila'));
    });

    test('Customer creates online booking with custom selected services checklist and gratuity tip', () async {
      final selectedServices = [
        'Body Hand Wash with Shampoo',
        'Tire Cleaning & Tire Black Finish',
        'Headlight Restoration',
      ];
      // Automobile prices: 500 + 200 + 1000 = 1700
      const totalCustomServicesPrice = 1700.0;
      const tipAmount = 100.0;

      final booking = await state.bookNewWash(
        customerName: 'Dawit Tolessa',
        customerPhone: '+251 93 111 2233',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: '3-B99887 ET',
        package: state.packages.first,
        selectedServices: selectedServices,
        customTotalPrice: totalCustomServicesPrice,
        tipAmount: tipAmount,
      );

      expect(booking.totalPrice, 1700.0);
      expect(booking.selectedServices, equals(selectedServices));
      expect(booking.serviceDisplayName, 'Body Hand Wash with Shampoo (+2 services)');
    });
  });
}
