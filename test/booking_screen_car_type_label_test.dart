import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/walk_in_registration_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/edit_booking_dialog.dart';

void main() {
  late AppStateNotifier notifier;

  setUp(() async {
    notifier = AppStateNotifier(repository: WashRepositoryImpl());
    await notifier.loadData();
  });

  testWidgets('Customer booking screen renders "Full Name or Car Type" label and trilingual translations', (tester) async {
    notifier.switchRole(UserRole.customer);
    notifier.setLanguage('EN');

    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: NewBookingScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Single booking screen shows Customer Details inline immediately (no Next Step wizard)

    // Verify English label
    expect(find.text('Full Name or Car Type'), findsOneWidget);

    // Switch to Amharic
    notifier.setLanguage('AM');
    await tester.pumpAndSettle();
    expect(find.text('ሙሉ ስም ወይም የመኪና ዓይነት'), findsOneWidget);

    // Switch to Afaan Oromoo
    notifier.setLanguage('OM');
    await tester.pumpAndSettle();
    expect(find.text('Maqaa Guutuu ykn Gosa Konkolaataa'), findsOneWidget);
  });

  testWidgets('Cashier & Operational Manager walk-in screen renders "Full Name or Car Type" label and trilingual translations', (tester) async {
    notifier.switchRole(UserRole.cashier);
    notifier.setLanguage('EN');

    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: WalkInRegistrationScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify English label
    expect(find.text('Full Name or Car Type'), findsOneWidget);

    // Switch to Amharic
    notifier.setLanguage('AM');
    await tester.pumpAndSettle();
    expect(find.text('ሙሉ ስም ወይም የመኪና ዓይነት'), findsOneWidget);

    // Switch to Afaan Oromoo
    notifier.setLanguage('OM');
    await tester.pumpAndSettle();
    expect(find.text('Maqaa Guutuu ykn Gosa Konkolaataa'), findsOneWidget);
  });

  testWidgets('Edit booking dialog renders "Full Name or Car Type" label and trilingual translations', (tester) async {
    notifier.switchRole(UserRole.manager);
    notifier.setLanguage('EN');

    final testPkg = WashPackage(
      id: 'pkg-silver',
      name: 'Silver Wash',
      description: 'Standard wash',
      durationMinutes: 20,
      pricingByCarType: const {
        CarType.automobile: 350.0,
        CarType.minibus: 450.0,
        CarType.truck: 650.0,
      },
      features: const ['Foam wash', 'Rinse', 'Tire shine'],
    );

    final dummyBooking = WashBooking(
      id: 'test-edit-label',
      customerName: 'Abebe Kebede',
      customerPhone: '+251911223344',
      licensePlate: 'ET-3-12345',
      serviceType: ServiceType.walkInStation,
      carType: CarType.automobile,
      package: testPkg,
      payment: const PaymentInfo(
        isPaid: false,
        amount: 350,
        method: PaymentMethod.cash,
      ),
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: EditBookingDialog(booking: dummyBooking),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify English label
    expect(find.text('Full Name or Car Type'), findsOneWidget);

    // Switch to Amharic
    notifier.setLanguage('AM');
    await tester.pumpAndSettle();
    expect(find.text('ሙሉ ስም ወይም የመኪና ዓይነት'), findsOneWidget);

    // Switch to Afaan Oromoo
    notifier.setLanguage('OM');
    await tester.pumpAndSettle();
    expect(find.text('Maqaa Guutuu ykn Gosa Konkolaataa'), findsOneWidget);
  });
}
