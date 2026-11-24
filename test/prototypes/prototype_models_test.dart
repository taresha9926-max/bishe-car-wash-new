import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/prototypes/data/mock_prototype_wash_repository.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/screens/prototype_evaluator_screen.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/screens/prototype_station_lounge_screen.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_1_stepper_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_2_saas_portal_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_3_express_kiosk_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_served_unified_clone_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_live_ticket_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prototype Sandbox Seam Tests (TDD)', () {
    late MockPrototypeWashRepository mockRepo;
    late AppStateNotifier state;

    setUp(() async {
      mockRepo = MockPrototypeWashRepository();
      state = AppStateNotifier(repository: mockRepo);
      await state.loadData();
    });

    test('MockPrototypeWashRepository initializes hermetically in-memory', () async {
      expect(mockRepo.isHermeticSandbox, isTrue);
      final packages = await mockRepo.getPackages();
      expect(packages.isNotEmpty, isTrue);
      final telemetry = mockRepo.getStationTelemetrySnapshot();
      expect(telemetry.totalBays, equals(2));
      expect(telemetry.availableBays, inInclusiveRange(0, 2));
    });

    testWidgets('PrototypeEvaluatorScreen renders top control bar and switches models cleanly', (tester) async {
      tester.view.physicalSize = const Size(1300, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PrototypeEvaluatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top control bar exists
      expect(find.text('Prototype Evaluator'), findsOneWidget);
      expect(find.text('Flagship: Served Clone'), findsOneWidget);
      expect(find.text('Model 1: Stepper'), findsOneWidget);
      expect(find.text('Model 2: SaaS Portal'), findsOneWidget);
      expect(find.text('Model 3: Express Kiosk'), findsOneWidget);

      // Default active view is Flagship Served Clone
      expect(find.byType(PrototypeServedUnifiedCloneView), findsOneWidget);

      // Switch to Model 1
      final model1Btn = find.text('Model 1: Stepper');
      await tester.ensureVisible(model1Btn);
      await tester.tap(model1Btn);
      await tester.pumpAndSettle();
      expect(find.byType(Prototype1StepperView), findsOneWidget);

      // Switch to Model 2
      final model2Btn = find.text('Model 2: SaaS Portal');
      await tester.ensureVisible(model2Btn);
      await tester.tap(model2Btn);
      await tester.pumpAndSettle();
      expect(find.byType(Prototype2SaasPortalView), findsOneWidget);

      // Switch to Model 3
      final model3Btn = find.text('Model 3: Express Kiosk');
      await tester.ensureVisible(model3Btn);
      await tester.tap(model3Btn);
      await tester.pumpAndSettle();
      expect(find.byType(Prototype3ExpressKioskView), findsOneWidget);
    });

    testWidgets('PrototypeServedUnifiedCloneView provides 1-screen booking and collapsible accordions', (tester) async {
      tester.view.physicalSize = const Size(700, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: PrototypeServedUnifiedCloneView(
                onBookingComplete: (booking) {},
                onOpenLounge: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Renders Car vs Carpet slider
      expect(find.text('Car Washing Service'), findsOneWidget);
      expect(find.text('Carpet Washing Service'), findsOneWidget);

      // Renders Vehicle category and package selection
      expect(find.text('Vehicle Category'), findsOneWidget);
      expect(find.text('Service Package'), findsOneWidget);

      // Renders collapsible sections
      expect(find.text('Car Care & Detailing Reels'), findsOneWidget);
      expect(find.text('Station Amenities'), findsOneWidget);
      expect(find.text('Station Location & Hours'), findsOneWidget);
      expect(find.text('Track Past or Active Wash'), findsOneWidget);

      // Enter details and confirm booking directly in 1 screen
      await tester.enterText(find.byKey(const Key('unified_plate_input')), 'ET-44321');
      await tester.enterText(find.byKey(const Key('unified_phone_input')), '0912345678');
      await tester.pumpAndSettle();

      final confirmBtn = find.byType(ElevatedButton).first;
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Immediately renders live ticket without extra page hops
      expect(find.byType(PrototypeLiveTicketView), findsOneWidget);
    });

    testWidgets('Prototype1StepperView completes 3-step booking and renders live ticket', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Prototype1StepperView(
                onBookingComplete: (booking) {},
                onOpenLounge: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Select vehicle
      expect(find.text('Choose Vehicle'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.directions_car_rounded).first);
      await tester.pumpAndSettle();

      // Advance to Step 2
      await tester.tap(find.text('Next: Wash Package'));
      await tester.pumpAndSettle();

      // Step 2: Choose package
      expect(find.text('Wash Package'), findsOneWidget);
      final nextContactBtn = find.text('Next: Contact Details');
      await tester.ensureVisible(nextContactBtn);
      await tester.tap(nextContactBtn);
      await tester.pumpAndSettle();

      // Step 3: Enter contact info
      expect(find.text('Contact Details'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('stepper_plate_input')), 'A12345');
      await tester.enterText(find.byKey(const Key('stepper_phone_input')), '0911223344');
      await tester.pumpAndSettle();

      // Confirm & Drive In
      final confirmBtn = find.text('Confirm & Drive In');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Renders digital ticket
      expect(find.byType(PrototypeLiveTicketView), findsOneWidget);
    });

    testWidgets('Prototype3ExpressKioskView submits in one single screen', (tester) async {
      tester.view.physicalSize = const Size(600, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Prototype3ExpressKioskView(
                onBookingComplete: (booking) {},
                onOpenLounge: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Express Wash Intake'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('kiosk_plate_input')), 'B99887');
      await tester.enterText(find.byKey(const Key('kiosk_phone_input')), '0922334455');
      await tester.pumpAndSettle();

      final instantBtn = find.text('Instant Book & Drive In');
      await tester.ensureVisible(instantBtn);
      await tester.tap(instantBtn);
      await tester.pumpAndSettle();

      expect(find.byType(PrototypeLiveTicketView), findsOneWidget);
    });

    testWidgets('PrototypeStationLoungeScreen renders video showcase and amenities cleanly', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PrototypeStationLoungeScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Station Lounge & Media'), findsOneWidget);
      expect(find.text('Car Care & Detailing Reels'), findsOneWidget);
      expect(find.text('Station Amenities'), findsOneWidget);
    });
  });
}
