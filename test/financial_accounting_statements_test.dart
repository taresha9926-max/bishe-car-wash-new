import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/widgets/financial_balance_sheet_card.dart';
import 'package:bishe_car_wash/core/widgets/financial_cash_flow_card.dart';
import 'package:bishe_car_wash/core/widgets/storekeeper_chemical_reconciliation_card.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/accountant_dashboard_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  group('Comprehensive Financial Accounting Statements Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
    });

    testWidgets('FinancialBalanceSheetCard balances Assets = Liabilities + Equity with 0.00 discrepancy', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialBalanceSheetCard(
                  state: state,
                  isMobile: false,
                  cashOnHand: 24500.0,
                  bankBalance: 12000.0,
                  vatPayable: 3675.0,
                  commissionPayable: 4200.0,
                  netRetainedProfit: 18500.0,
                  rangeDays: 30,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Balance Sheet sections
      expect(find.text(state.tr('balanceSheetTitle')), findsOneWidget);
      expect(find.text(state.tr('assetsHeader')), findsOneWidget);
      expect(find.text(state.tr('liabilitiesHeader')), findsOneWidget);
      expect(find.text(state.tr('equityHeader')), findsOneWidget);

      // Verify GAAP balanced accounting equation badge
      expect(find.text(state.tr('balancedAccountingEquation')), findsOneWidget);
      expect(find.text('TOTAL LIABILITIES & EQUITY (L + E)'), findsOneWidget);
    });

    testWidgets('FinancialCashFlowCard correctly computes Net CFO, CFI, CFF and reconciles Closing Cash', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialCashFlowCard(
                  state: state,
                  isMobile: false,
                  cashFromCarWash: 35000.0,
                  cashFromCarpet: 8500.0,
                  cashFromShower: 3200.0,
                  digitalCollections: 14000.0,
                  suppliesPaid: 6500.0,
                  commissionsPaid: 7200.0,
                  pettyCashPaid: 2100.0,
                  rentPaid: 25000.0,
                  rangeDays: 30,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Cash Flow sections
      expect(find.text(state.tr('cashFlowTitle')), findsOneWidget);
      expect(find.text(state.tr('cfoHeader')), findsOneWidget);
      expect(find.text(state.tr('cfiHeader')), findsOneWidget);
      expect(find.text(state.tr('cffHeader')), findsOneWidget);
      expect(find.text(state.tr('netChangeInCash')), findsOneWidget);
      expect(find.text(state.tr('closingCash')), findsOneWidget);
    });

    testWidgets('StorekeeperChemicalReconciliationCard compares expected formula usage vs actual store issues', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime.now();
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: StorekeeperChemicalReconciliationCard(
                  state: state,
                  isMobile: false,
                  carsWashedCount: 50,
                  carpetsWashedCount: 15,
                  rangeDays: 1,
                  rangeStart: DateTime(now.year, now.month, now.day),
                  rangeEnd: DateTime(now.year, now.month, now.day, 23, 59, 59),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(state.tr('reconciliationTitle')), findsOneWidget);
      expect(find.textContaining('50 Cars'), findsOneWidget);
      expect(find.textContaining('15 Carpets'), findsOneWidget);
      expect(find.textContaining('Active Snow Foam'), findsOneWidget);
      expect(find.textContaining('TOTAL CHEMICAL VALUATION & VARIANCE'), findsOneWidget);
    });

    testWidgets('AccountantDashboardScreen Tab 3 switches between all 4 financial statement views smoothly', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AccountantDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Tab 3 (Financial Statements)
      await tester.tap(find.byType(Tab).at(3), warnIfMissed: false);
      await tester.pumpAndSettle();

      // View 0: P&L Statement is default
      expect(find.text(state.tr('statementBalanceSheetTab')), findsOneWidget);
      expect(find.text(state.tr('statementCashFlowTab')), findsOneWidget);
      expect(find.text(state.tr('statementReconciliationTab')), findsOneWidget);
      expect(find.textContaining('TODAY NET OPERATING PROFIT'), findsOneWidget);

      // Tap View 1: Balance Sheet
      await tester.tap(find.text(state.tr('statementBalanceSheetTab')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('balanceSheetTitle')), findsOneWidget);
      expect(find.text(state.tr('balancedAccountingEquation')), findsOneWidget);

      // Tap View 2: Cash Flow
      await tester.tap(find.text(state.tr('statementCashFlowTab')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('cashFlowTitle')), findsOneWidget);
      expect(find.text(state.tr('cfoHeader')), findsOneWidget);

      // Tap View 3: Chemical Reconciliation Audit
      await tester.tap(find.text(state.tr('statementReconciliationTab')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('reconciliationTitle')), findsOneWidget);
      expect(find.textContaining('Cars Washed Count'), findsOneWidget);
    });
  });
}
