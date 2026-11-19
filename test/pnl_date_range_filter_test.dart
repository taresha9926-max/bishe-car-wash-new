import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/widgets/financial_pnl_statement_card.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/accountant_dashboard_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  group('P&L Statement Date Range Filter Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
    });

    testWidgets('Accountant P&L tab renders Date Range filter toolbar and switches periods cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
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

      // Switch to Tab 3 (P&L Statement)
      await tester.tap(find.byType(Tab).at(3), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify all 4 Date Range Filter chips are present
      expect(find.text(state.tr('filterToday')), findsOneWidget);
      expect(find.text(state.tr('filterThisWeek')), findsOneWidget);
      expect(find.text(state.tr('filterThisMonth')), findsOneWidget);
      expect(find.text(state.tr('filterCustomRange')), findsOneWidget);

      // Default is Today (1-day daily accrual)
      expect(find.text('TODAY NET OPERATING PROFIT (EBITDA)'), findsOneWidget);
      expect(find.textContaining('DAILY ACCRUED OPERATING OVERHEADS'), findsOneWidget);

      // Tap 'This Month (Monthly)'
      await tester.tap(find.text(state.tr('filterThisMonth')));
      await tester.pumpAndSettle();

      // Verify header switches to full monthly budget
      expect(find.text('THIS MONTH NET OPERATING PROFIT (EBITDA)'), findsOneWidget);
      expect(find.textContaining('FULL MONTHLY OPERATING OVERHEADS'), findsOneWidget);

      // Tap 'Today (Daily)' back
      await tester.tap(find.text(state.tr('filterToday')));
      await tester.pumpAndSettle();

      expect(find.text('TODAY NET OPERATING PROFIT (EBITDA)'), findsOneWidget);
      expect(find.textContaining('DAILY ACCRUED OPERATING OVERHEADS'), findsOneWidget);
    });

    testWidgets('FinancialPnlStatementCard correctly prorates facility rent and salary reserve by rangeDays', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Render 1-day card
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: FinancialPnlStatementCard(
                state: state,
                isMobile: false,
                totalRevenue: 5000.0,
                vatDeducted: 750.0,
                commissionPool: 750.0,
                totalPettyCash: 200.0,
                totalSupplies: 150.0,
                rangeDays: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1-day accrual for rent
      expect(find.textContaining('Daily Accrual'), findsWidgets);

      // Render 30-day card
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: FinancialPnlStatementCard(
                state: state,
                isMobile: false,
                totalRevenue: 150000.0,
                vatDeducted: 22500.0,
                commissionPool: 22500.0,
                totalPettyCash: 6000.0,
                totalSupplies: 4500.0,
                rangeDays: 30,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('30-day Accrual'), findsOneWidget);
      expect(find.text(state.tr('salaryReserveRow')), findsOneWidget);
    });
  });
}
