import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/pricing_management_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_wash_service_item.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/consumable_item.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Super Admin Master Pricing & Inventory Hub Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repository;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      state.setSuperAdminStatus(true);
      await state.loadData();
    });

    Widget createTestWidget({int initialTab = 0}) {
      return MaterialApp(
        home: AppStateProvider(
          notifier: state,
          child: PricingManagementScreen(initialTabIndex: initialTab),
        ),
      );
    }

    testWidgets('Renders 4 separated tabs for Super Admin pricing & inventory control', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialTab: 0));
      await tester.pumpAndSettle();

      // Check tab pills exist
      expect(find.textContaining('Car Wash'), findsWidgets);
      expect(find.textContaining('Carpet'), findsWidgets);
      expect(find.textContaining('Consumables'), findsWidgets);
      expect(find.textContaining('Fixed Assets'), findsWidgets);

      // Tab 0: Car Wash Detailing Services displayed
      expect(find.text('Body Hand Wash with Shampoo & Fiber Towel'), findsOneWidget);
      expect(find.text('Tire Cleaning & Tire Black Finish'), findsOneWidget);
    });

    testWidgets('Car Wash Services: Super Admin adds and deletes a custom service', (tester) async {
      final initialCount = state.serviceItems.length;

      final testItem = CarWashServiceItem(
        id: 'srv_test_ceramic_shield',
        name: 'Ceramic Coating Shield Pro',
        category: 'specialty',
        description: 'Advanced graphene coating',
        pricingByCarType: const {
          CarType.automobile: 4500.0,
          CarType.minibus: 6500.0,
          CarType.truck: 9000.0,
        },
        isActive: true,
      );

      await state.addCustomServiceItem(testItem);
      expect(state.serviceItems.length, initialCount + 1);
      expect(state.serviceItems.any((i) => i.id == 'srv_test_ceramic_shield'), isTrue);

      // Now delete it
      await state.deleteCustomServiceItem('srv_test_ceramic_shield');
      expect(state.serviceItems.length, initialCount);
      expect(state.serviceItems.any((i) => i.id == 'srv_test_ceramic_shield'), isFalse);
    });

    testWidgets('Carpet Services Tab: Displays m² rates and specialty add-ons with CRUD', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialTab: 1));
      await tester.pumpAndSettle();

      // Check Type A and Type B base prices
      expect(find.textContaining('Type A'), findsWidgets);
      expect(find.textContaining('Type B'), findsWidgets);

      // Check dynamic add-on treatments
      expect(state.carpetAddonServices.isNotEmpty, isTrue);

      // Super admin adds a new specialty treatment
      state.addCarpetAddonService({
        'id': 'cpt_wool_silk_restore',
        'name': 'Silk & Wool Fiber Restoration',
        'category': 'Specialty',
        'price': 600.0,
        'description': 'Gentle neutral pH wash for Persian carpets',
      });

      expect(state.carpetAddonServices.any((c) => c['id'] == 'cpt_wool_silk_restore'), isTrue);

      // Super admin deletes it
      state.deleteCarpetAddonService('cpt_wool_silk_restore');
      expect(state.carpetAddonServices.any((c) => c['id'] == 'cpt_wool_silk_restore'), isFalse);
    });

    testWidgets('Storekeeper Consumables Tab: Displays unit costs and supports add/edit/delete', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialTab: 2));
      await tester.pumpAndSettle();

      expect(find.text('Stock Valuation'), findsOneWidget);
      expect(find.text('Low Stock Alert'), findsOneWidget);

      final initialConsumablesCount = state.consumables.length;

      // Super admin adds a new consumable
      final newConsumable = ConsumableItem(
        id: 'CS-TEST-999',
        name: 'Graphene Wax Polish',
        nameAmharic: 'ግራፊን ፖሊሽ',
        category: 'Wax & Sealants',
        unit: 'Bottles',
        currentStock: 20.0,
        minThreshold: 5.0,
        unitCostEtb: 1450.0,
        isDailyHandoverItem: true,
      );

      await state.saveConsumable(newConsumable);
      expect(state.consumables.length, initialConsumablesCount + 1);

      // Super admin edits price/stock
      final edited = newConsumable.copyWith(unitCostEtb: 1600.0, currentStock: 25.0);
      await state.saveConsumable(edited);
      final fetched = state.consumables.firstWhere((c) => c.id == 'CS-TEST-999');
      expect(fetched.unitCostEtb, 1600.0);
      expect(fetched.currentStock, 25.0);

      // Super admin deletes consumable
      final deleted = await state.deleteConsumable('CS-TEST-999');
      expect(deleted, isTrue);
      expect(state.consumables.length, initialConsumablesCount);
    });

    testWidgets('Storekeeper Fixed Assets Tab: Tracks equipment valuation ETB and supports add/edit/delete', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialTab: 3));
      await tester.pumpAndSettle();

      expect(find.text('Asset Valuation'), findsWidgets);
      expect(find.text('Operational'), findsWidgets);

      final initialAssetsCount = state.fixedAssets.length;

      // Super admin adds a high-value industrial fixed asset
      final newAsset = FixedAsset(
        id: 'FA-TEST-888',
        name: 'Kärcher Commercial Steam Generator 180°C',
        nameAmharic: 'የእንፋሎት ማሽን',
        category: 'Wash Machinery',
        serialNumber: 'KRC-2026-X9',
        assignedLocation: 'Detailing Bay 1',
        condition: AssetCondition.operational,
        quantity: 1,
        assetValueEtb: 125000.0,
        notes: 'Heavy duty continuous steam cleaner',
      );

      await state.saveFixedAsset(newAsset);
      expect(state.fixedAssets.length, initialAssetsCount + 1);

      // Super admin updates valuation and condition
      final updatedAsset = newAsset.copyWith(
        assetValueEtb: 130000.0,
        condition: AssetCondition.needsService,
      );
      await state.saveFixedAsset(updatedAsset);
      final fetched = state.fixedAssets.firstWhere((a) => a.id == 'FA-TEST-888');
      expect(fetched.assetValueEtb, 130000.0);
      expect(fetched.condition, AssetCondition.needsService);

      // Super admin permanently deletes asset
      final deleted = await state.deleteFixedAsset('FA-TEST-888');
      expect(deleted, isTrue);
      expect(state.fixedAssets.length, initialAssetsCount);
    });
  });
}
