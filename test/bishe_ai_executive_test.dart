import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/services/bishe_ai_executive_service.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
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
      state.switchRole(UserRole.admin);
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
      expect(response, contains('Type A (Small'));
      expect(response, contains('Type B (Medium'));
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

    test('Blind Spot 1: Ingests showers and reports 0% VAT statutory exemption', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'How many showers were used today and what is the VAT?',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains("Today's Shower Service & 0% VAT Statutory Audit"));
      expect(response, contains('0% VAT EXEMPT'));
      expect(response, contains('Total Shower Guests Today'));
    });

    test('Blind Spot 2: Reports Bay 1, Bay 2, Mobile Van turnaround and queue', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'What is the bay turnaround speed and active queue?',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Live Bay Distribution, Queue & Turnaround Speed'));
      expect(response, contains('Bay 1 (Concrete)'));
      expect(response, contains('Bay 2 (Concrete)'));
      expect(response, contains('Mobile Van Unit'));
    });

    test('Blind Spot 3: Audits fixed asset machinery health and maintenance conditions', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Check fixed assets and machinery equipment health',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Station Fixed Assets & Machinery Health Audit'));
      expect(response, contains('Operational'));
      expect(response, contains('Needs Preventative Service'));
    });

    test('Blind Spot 4: Reconciles bank deposit slips against cashier drawer collections', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Audit bank deposit slips and cashier collections',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Bank Deposit Slips & Cash Drawer Reconciliation'));
      expect(response, contains('Total Deposited to Bank Today'));
    });

    test('Blind Spot 5: Reports 6-digit OTP shift handover custody status', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'What is the status of the cashier 6-digit OTP shift handover?',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Shift Custody & 6-Digit OTP Handover Status'));
      expect(response, contains('Day Shift Handover'));
    });

    test('Blind Spot 6: Reports customer feedback sentiment and satisfaction ratings', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Show customer feedback ratings and sentiment',
        state: state,
        currentLang: AppLanguage.en,
      );

      expect(response, contains('Customer Satisfaction & Feedback Sentiment'));
      expect(response, contains('Average Star Rating'));
    });

    test('Storekeeper: Audits empty container exchange (ዕቃ በዕቃ)', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Check empty container return balance',
        state: state,
        currentLang: AppLanguage.en,
        callerRole: UserRole.storekeeper,
      );

      expect(response, contains('Storekeeper Empty-for-Full Container Exchange (ዕቃ በዕቃ)'));
      expect(response, contains('Snow Foam Shampoo'));
    });

    test('Customer Concierge: Gives package pricing and EV safety guidance', () async {
      final packageResponse = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'What wash packages do you offer and how much are they?',
        state: state,
        currentLang: AppLanguage.en,
        callerRole: UserRole.customer,
      );
      expect(packageResponse, contains('Service Packages & Pricing'));
      expect(packageResponse, contains('Silver / Basic'));
      expect(packageResponse, contains('Gold Polish'));

      final evResponse = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'Is high pressure wash safe for electric vehicles?',
        state: state,
        currentLang: AppLanguage.en,
        callerRole: UserRole.customer,
      );
      expect(evResponse, contains('Electric Vehicle (EV) Safety Guarantee'));
      expect(evResponse, contains('BYD'));
    });

    test('Customer Concierge: Strictly enforces privacy guardrails on profit and payroll', () async {
      final response = await BisheAiExecutiveService.askExecutive(
        userQuestion: 'What is your net profit margin and how much commission do washers get?',
        state: state,
        currentLang: AppLanguage.en,
        callerRole: UserRole.customer,
      );

      expect(response, contains('Customer Privacy Notice'));
      expect(response, contains('cannot be disclosed'));
    });
  });

  group('BISHE AI Executive Sheet UI Widget Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repository;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      state.setSuperAdminStatus(true);
      state.switchRole(UserRole.admin);
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

    testWidgets('Renders structured mobile tables with horizontal scroll and export actions', (tester) async {
      tester.view.physicalSize = const Size(390, 844); // Standard mobile phone viewport
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open AI Co-Pilot'));
      await tester.pumpAndSettle();

      // Tap on P&L Statement chip (first visible chip)
      await tester.tap(find.text(state.tr('aiPromptPnL')));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsWidgets);
      // Verify Export CSV and Copy Table buttons are present
      expect(find.text(state.tr('aiExportCsv')), findsWidgets);
      expect(find.text(state.tr('aiCopyTable')), findsWidgets);
    });

    testWidgets('Adapts to Customer Concierge mode: displays concierge title and hides API key config', (tester) async {
      state.switchRole(UserRole.customer);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open AI Co-Pilot'));
      await tester.pumpAndSettle();

      // Verify Concierge header
      expect(find.textContaining('BISHE AI Concierge'), findsWidgets);
      // Verify API key config button is hidden for customers
      expect(find.byIcon(Icons.key_rounded), findsNothing);
      // Verify customer package prompt chip is visible
      expect(find.text(state.tr('aiPromptCustomerPackages')), findsOneWidget);
    });
  });
}
