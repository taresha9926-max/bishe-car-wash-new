import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/services/bishe_ai_executive_service.dart';
import 'package:bishe_car_wash/features/admin/presentation/widgets/bishe_ai_executive_sheet.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BISHE AI Executive Service & Analytics Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repository;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      state.setSuperAdminStatus(true);
      await state.loadData();
    });

    test('Local analytics engine outputs P&L statement without API key', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Show me the P&L statement and net station profit',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Executive Financial & P&L Statement'));
      expect(response, contains('Gross Revenue'));
      expect(response, contains('NET OPERATING PROFIT'));
    });

    test('Local analytics engine breaks down vehicles washed by category', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'How many cars were washed today?',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Vehicle & Carpet Wash Activity'));
      expect(response, contains('Sedans / Small Cars'));
      expect(response, contains('SUVs / Pickups'));
    });

    test('Local analytics engine reports washer attendance and commissions', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'List active washers and their commissions',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Active Washers & Commission Performance'));
      expect(response, contains('Active On-Duty Washers'));
      expect(response, contains('Washer Name'));
    });

    test('Local analytics engine reports chemical yield and 5L shampoo benchmarks', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'What is our chemical consumption yield for shampoo and perfume?',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Chemical Yield & Average Consumption Analysis'));
      expect(response, contains('5L Dilution Can'));
      expect(response, contains('Air Freshener'));
    });

    test('Local analytics engine reports stock discrepancy and low stock alerts', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Any low stock alerts or discrepancies?',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Station Discrepancies & Stock Alerts'));
      expect(response, contains('Low Inventory Re-Order Alerts'));
    });

    test('Local analytics engine generates executive overview for general query', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Give me a general overview of station health',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('BISHE Executive AI Operations Desk'));
      expect(response, contains("Today's Bookings"));
      expect(response, contains('Lifetime Completed'));
    });
  });

  group('BISHE AI Executive Sheet UI Widget Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repository;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      state.setSuperAdminStatus(true);
      await state.loadData();
    });

    Widget createTestWidget() {
      return AppStateProvider(
        notifier: state,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () => BisheAiExecutiveSheet.show(ctx),
                  child: const Text('Open AI Co-Pilot'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Opens AI Executive modal sheet, displays chips, and asks local query', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open AI Co-Pilot'));
      await tester.pumpAndSettle();

      // Verify header and initial message
      expect(find.textContaining('BISHE AI Executive'), findsWidgets);
      expect(find.textContaining('Local Station Analytics'), findsOneWidget);

      // Verify quick action chips
      expect(find.text(state.tr('aiPromptPnL')), findsOneWidget);
      expect(find.text(state.tr('aiPromptCars')), findsOneWidget);
      expect(find.text(state.tr('aiPromptWashers')), findsOneWidget);
      expect(find.text(state.tr('aiPromptYield')), findsOneWidget);
      expect(find.text(state.tr('aiPromptAlerts')), findsOneWidget);

      // Tap on P&L Statement chip
      await tester.tap(find.text(state.tr('aiPromptPnL')));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify response generated in chat list
      expect(find.textContaining('Executive Financial & P&L Statement'), findsOneWidget);
      expect(find.textContaining('NET OPERATING PROFIT'), findsOneWidget);
    });

    testWidgets('Opens Gemini API Key configuration dialog and saves key', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open AI Co-Pilot'));
      await tester.pumpAndSettle();

      // Tap API Key settings button (key icon)
      final keyBtn = find.byIcon(Icons.key_rounded);
      expect(keyBtn, findsOneWidget);
      await tester.tap(keyBtn);
      await tester.pumpAndSettle();

      // Verify dialog opened
      expect(find.text('Configure Gemini API Key'), findsWidgets);

      // Enter test API key
      final inputField = find.byType(TextField).last;
      await tester.enterText(inputField, 'AIzaSyTestApiKey123456');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(state.geminiApiKey, equals('AIzaSyTestApiKey123456'));
      expect(find.textContaining('Gemini AI Cloud'), findsOneWidget);
    });
  });
}
