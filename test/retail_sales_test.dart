import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/pricing_management_screen.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/inventory/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';

void main() {
  late AppStateNotifier state;

  setUp(() async {
    state = AppStateNotifier(repository: WashRepositoryImpl());
    await state.loadData();
  });

  group('Bishe Retail Merchandise Sales End-to-End Tests', () {
    test('Seeds exact 7 official retail items and starts with 0 fake sales', () {
      expect(state.retailSales, isEmpty);
      expect(state.retailItems.length, equals(7));

      final byName = {for (final i in state.retailItems) i.name: i};
      expect(byName['Dash board cream']?.sellingPriceEtb, equals(1800.0));
      expect(byName['Dash board cream']?.nameAmharic, equals('ዳሽ ቦርድ ክሬም'));
      expect(byName['Car Perfume Gold Infusion']?.sellingPriceEtb, equals(1000.0));
      expect(byName['Foaming Tire Cleaner Darkener spray']?.sellingPriceEtb, equals(1200.0));
      expect(byName['Dog skin (Wsha koda)']?.sellingPriceEtb, equals(1000.0));
      expect(byName['Microfiber towel/dryer big']?.sellingPriceEtb, equals(1200.0));
      expect(byName['Microfiber towel medium']?.sellingPriceEtb, equals(1100.0));
      expect(byName['Microfiber towel small']?.sellingPriceEtb, equals(900.0));
    });

    test('Storekeeper restock & Cashier/Manager retail sales update drawer, custody, closing & exclude wash commission', () async {
      final perfume = state.retailItems.firstWhere((i) => i.id == 'RTL-002');
      await state.restockRetailItem(
        itemId: perfume.id,
        addedQuantity: 10,
        unitCostEtb: 450.0,
        supplier: 'Addis Auto Supply',
      );
      expect(state.retailItems.firstWhere((i) => i.id == 'RTL-002').currentStock, equals(10));

      // Day Shift Cashier sells 2x Perfume for Cash (2,000 ETB)
      state.switchRole(UserRole.cashier);
      final cashSale = await state.recordRetailSale(
        item: state.retailItems.firstWhere((i) => i.id == 'RTL-002'),
        quantity: 2,
        paymentMethod: PaymentMethod.cash,
        cashierName: 'Chaltu Cashier',
      );
      expect(cashSale.totalAmount, equals(2000.0));
      expect(cashSale.totalCost, equals(900.0));
      expect(state.retailItems.firstWhere((i) => i.id == 'RTL-002').currentStock, equals(8));
      expect(state.cashierTodayCashETB, equals(2000.0));
      expect(state.cashierDrawerBalanceETB, equals(2000.0));
      // 0% washer wash commission & 0% VAT on retail merchandise
      expect(state.teamCommissionPoolTodayETB, equals(0.0));
      expect(state.vatDeductedTodayETB, equals(0.0));

      final dayClosing = await state.confirmDailyClosing(
        cashierName: 'Chaltu Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );
      expect(dayClosing.retailSalesCount, equals(2));
      expect(dayClosing.retailRevenue, equals(2000.0));
      expect(dayClosing.retailCogs, equals(900.0));
      expect(dayClosing.grossRevenue, equals(2000.0));
      expect(dayClosing.netStationProfit, equals(1100.0));

      // Manager accepts custody OTP and makes a Night Shift Telebirr sale of Dash board cream (1,800 ETB)
      await state.acceptCashierHandover(managerName: 'Gedion Manager', enteredOtp: dayClosing.handoverOtp);
      state.switchRole(UserRole.manager);
      final cream = state.retailItems.firstWhere((i) => i.id == 'RTL-001');
      await state.recordRetailSale(
        item: cream,
        quantity: 1,
        paymentMethod: PaymentMethod.telebirr,
        cashierName: 'Gedion Manager',
        role: 'operationalManager',
      );
      expect(state.managerTodayDigitalETB, equals(1800.0));
      expect(state.managerCustodyCashETB, equals(2000.0));
      expect(state.todayRetailRevenueETB, equals(3800.0));
      expect(state.todayRetailSalesCount, equals(3));
    });

    testWidgets('Cashier and Operational Manager desks symmetrically record retail sales inside Money tab without mobile overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Cashier Desk test
      state.switchRole(UserRole.cashier);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('station_bottom_tab_1')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(state.tr('retailSalesTitle')));
      await tester.tap(find.text(state.tr('retailSalesTitle')));
      await tester.pumpAndSettle();
      expect(find.text('Dash board cream'), findsAtLeastNWidgets(1));
      await tester.ensureVisible(find.text('Car Perfume Gold Infusion'));
      await tester.tap(find.text('Car Perfume Gold Infusion'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byIcon(Icons.add_circle_outline).first);
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining(state.tr('recordRetailSale')));
      await tester.tap(find.textContaining(state.tr('recordRetailSale')));
      await tester.pumpAndSettle();
      expect(state.cashierDrawerBalanceETB, equals(2000.0));
      expect(find.textContaining('2× Car Perfume Gold Infusion'), findsOneWidget);

      // Operational Manager symmetry check
      state.switchRole(UserRole.manager);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('station_bottom_tab_1')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(state.tr('retailSalesTitle')));
      await tester.tap(find.text(state.tr('retailSalesTitle')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Microfiber towel small'));
      await tester.tap(find.text('Microfiber towel small'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining(state.tr('recordRetailSale')));
      await tester.tap(find.textContaining(state.tr('recordRetailSale')));
      await tester.pumpAndSettle();
      expect(state.todayRetailRevenueETB, equals(2900.0));
    });

    testWidgets('Super Admin Pricing Hub Tab 6 & Customer Station Shop display official items', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      state.setSuperAdminStatus(true);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const PricingManagementScreen(initialTabIndex: 5)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dash board cream'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(1800.0)), findsOneWidget);
      expect(find.text('Microfiber towel small'), findsOneWidget);

      // Customer Portal Station Tab (Tab 2)
      state.switchRole(UserRole.customer);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CustomerHomeScreen(initialTabIndex: 2)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(state.tr('stationShopTitle')));
      expect(find.text(state.tr('stationShopTitle')), findsOneWidget);
      expect(find.text('Dog skin (Wsha koda)'), findsOneWidget);

      // Storekeeper Retail Shop Stock section (desktop layout ensures Tab 1 renders unclipped)
      tester.view.physicalSize = const Size(900, 900);
      await tester.pumpAndSettle();
      state.switchRole(UserRole.storekeeper);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const StorekeeperDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining(state.tr('retailStockSection')));
      await tester.tap(find.textContaining(state.tr('retailStockSection')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('restockRetailItem')), findsNWidgets(7));
    });

    test('All new retail localization keys have distinct EN / OM / AM translations', () {
      const keys = [
        'retailSalesTitle',
        'retailSalesSub',
        'retailSalesSubtotal',
        'retailUnitsLabel',
        'recordRetailSale',
        'retailSaleRecordedToast',
        'recentRetailSales',
        'retailSalesTab',
        'addRetailItem',
        'retailStockSection',
        'restockRetailItem',
        'sellingPriceLabel',
        'stationShopTitle',
        'availableAtCashierDesk',
        'buyerOptionalHint',
        'qtyLabel',
        'inStockLabel',
        'retailTxRefHint',
        'noRetailItemsAvailable',
      ];
      for (final key in keys) {
        final en = AppStrings.get(key, AppLanguage.en);
        final om = AppStrings.get(key, AppLanguage.om);
        final am = AppStrings.get(key, AppLanguage.am);
        expect(en, isNot(equals(key)), reason: 'Missing EN for $key');
        expect(om, isNot(equals(key)), reason: 'Missing OM for $key');
        expect(om, isNot(equals(en)), reason: 'Untranslated OM for $key');
        expect(am, isNot(equals(key)), reason: 'Missing AM for $key');
        expect(am, isNot(equals(en)), reason: 'Untranslated AM for $key');
      }
    });
  });
}
