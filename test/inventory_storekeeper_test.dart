import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/inventory/data/datasources/initial_inventory_seed.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/daily_handover.dart';
import 'package:bishe_car_wash/features/inventory/domain/models/fixed_asset.dart';

void main() {
  group('Bishe Storekeeper Inventory & Option B Safeguards', () {
    late WashRepositoryImpl repository;
    late AppStateNotifier notifier;

    setUp(() {
      repository = WashRepositoryImpl();
      notifier = AppStateNotifier(repository: repository);
    });

    test('Initial Seed contains all 25 fixed assets and 20 consumables', () {
      final assets = InitialInventorySeed.getFixedAssets();
      final consumables = InitialInventorySeed.getConsumables();

      expect(assets.length, 25);
      expect(consumables.length, 22); // 20 numbered items with 10a, 10b, 10c sub-sprays

      // Verify specific sample items
      expect(assets.any((a) => a.name.contains('Polish Grinder')), isTrue);
      expect(assets.any((a) => a.name.contains('Pressure Pump')), isTrue);
      expect(assets.any((a) => a.name.contains('Sewing Machines')), isTrue);
      expect(assets.any((a) => a.name.contains('Cash Register Machine')), isTrue);

      expect(consumables.any((c) => c.name.contains('Car Shampoo')), isTrue);
      expect(consumables.any((c) => c.name.contains('Microfiber Towels')), isTrue);
      expect(consumables.any((c) => c.name.contains('Abro Polish')), isTrue);
    });

    test('Storekeeper receives incoming stock and increments inventory', () async {
      final initialShampoo = notifier.consumables.firstWhere((c) => c.id == 'CS-009');
      final initialStock = initialShampoo.currentStock;

      await notifier.receiveStock(
        itemId: 'CS-009',
        quantity: 20.0,
        unitCostEtb: 220.0,
        supplier: 'Oromia Chemical Wholesale',
        notes: 'Monthly batch delivery',
      );

      final updatedShampoo = notifier.consumables.firstWhere((c) => c.id == 'CS-009');
      expect(updatedShampoo.currentStock, initialStock + 20.0);

      // Stock transaction recorded for accountant
      expect(notifier.stockTransactions.isNotEmpty, isTrue);
      final latestTx = notifier.stockTransactions.first;
      expect(latestTx.itemId, 'CS-009');
      expect(latestTx.quantity, 20.0);
      expect(latestTx.totalCostEtb, 20.0 * 220.0);
    });

    test('Option B Safeguard: Non-super-admin cannot delete, but can decommission', () async {
      // By default, not super admin
      expect(notifier.isSuperAdmin, isFalse);

      // 1. Decommissioning is permitted
      await notifier.decommissionFixedAsset('FA-005', 'Motor damaged beyond repair');
      final asset = notifier.fixedAssets.firstWhere((a) => a.id == 'FA-005');
      expect(asset.condition, AssetCondition.decommissioned);
      expect(asset.decommissionReason, 'Motor damaged beyond repair');

      // 2. Permanent deletion is rejected for non-super-admin
      final deleteSuccess = await notifier.deleteFixedAsset('FA-005');
      expect(deleteSuccess, isFalse);
      expect(notifier.fixedAssets.any((a) => a.id == 'FA-005'), isTrue);

      // 3. Super admin can permanently delete
      notifier.setSuperAdminStatus(true);
      final adminDeleteSuccess = await notifier.deleteFixedAsset('FA-005');
      expect(adminDeleteSuccess, isTrue);
      expect(notifier.fixedAssets.any((a) => a.id == 'FA-005'), isFalse);
    });

    test('Daily Handover Loop: Morning checkout and Evening return reconcile', () async {
      // Starting stock
      final shampooBefore = notifier.consumables.firstWhere((c) => c.id == 'CS-009').currentStock;

      // 1. Morning Shift: Storekeeper issues supplies to Team Leader
      await notifier.startDailyHandover(
        washerTeamLeaderName: 'Dawit Abebe',
        issuedQuantities: {
          'CS-009': 5.0, // 5 Liters shampoo
          'CS-013': 20.0, // 20 Microfiber towels
        },
        notes: 'Bay 1 & Bay 2 shift batch',
      );

      expect(notifier.activeHandover, isNotNull);
      final active = notifier.activeHandover!;
      expect(active.washerTeamLeaderName, 'Dawit Abebe');
      expect(active.status, HandoverStatus.active);
      expect(active.issuedQuantities['CS-009'], 5.0);

      // 2. Evening Shift: Team Leader returns 1.5L shampoo and all 20 towels
      await notifier.completeDailyHandover(
        handoverId: active.id,
        returnedQuantities: {
          'CS-009': 1.5, // 1.5L remaining
          'CS-013': 20.0, // 20 towels returned (for laundry)
        },
        notes: 'Shift complete, no towels missing',
      );

      // Handover closed
      expect(notifier.activeHandover, isNull);
      final completed = notifier.dailyHandovers.firstWhere((h) => h.id == active.id);
      expect(completed.status, HandoverStatus.completed);

      // Consumed: 5.0 - 1.5 = 3.5 Liters shampoo
      expect(completed.consumedQuantities['CS-009'], 3.5);
      // Consumed: 20 - 20 = 0 towels lost
      expect(completed.consumedQuantities['CS-013'], 0.0);

      // Stock was decremented by net consumption
      final shampooAfter = notifier.consumables.firstWhere((c) => c.id == 'CS-009').currentStock;
      expect(shampooAfter, shampooBefore - 3.5);
    });

    test('UserRole authentication supports Storekeeper (3344) and Accountant (5566)', () {
      expect(notifier.authenticateRole(UserRole.storekeeper, '3344'), isTrue);
      expect(notifier.authenticateRole(UserRole.storekeeper, 'wrong'), isFalse);

      expect(notifier.authenticateRole(UserRole.accountant, '5566'), isTrue);
      expect(notifier.authenticateRole(UserRole.accountant, 'wrong'), isFalse);
    });

    test('Accountant screen getters: bankDeposits and bankDepositRecords alias are available and non-null', () {
      expect(notifier.bankDeposits, isNotNull);
      expect(notifier.bankDepositRecords, isNotNull);
      expect(notifier.bankDepositRecords.length, equals(notifier.bankDeposits.length));
      expect(notifier.dailyFinancialClosings, isNotNull);
      expect(notifier.weeklyCommissionReports, isNotNull);
      expect(notifier.stockTransactions, isNotNull);
    });
  });
}
