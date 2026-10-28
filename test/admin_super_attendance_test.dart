import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/admin/domain/models/pending_approval_request.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';

void main() {
  group('Super Admin vs Secondary Admin & Commission Attendance Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repo;

    setUp(() async {
      repo = WashRepositoryImpl();
      state = AppStateNotifier(repository: repo);
      await state.loadData();
    });

    test('Default mode is secondary admin; sensitive changes create pending approvals', () async {
      expect(state.isSuperAdmin, isFalse);

      // Secondary admin attempts to update PIN
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '9999',
        fullName: 'Test Cashier',
      );

      // Credential in state is NOT updated directly
      final cred = state.credentials.firstWhere((c) => c.id == 'cred-cashier');
      expect(cred.pin, isNot('9999'));

      // Instead, pending approval was created
      expect(state.pendingApprovals.length, 1);
      final req = state.pendingApprovals.first;
      expect(req.actionType, ApprovalActionType.changePin);
      expect(req.payload['pin'], '9999');
    });

    test('Super Admin can approve pending requests and apply changes', () async {
      // 1. Submit pending request as secondary admin
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '8888',
        fullName: 'New Cashier Name',
      );
      expect(state.pendingApprovals.length, 1);

      // 2. Super Admin logs in
      state.setSuperAdminStatus(true);
      expect(state.isSuperAdmin, isTrue);

      // 3. Super Admin approves request
      final req = state.pendingApprovals.first;
      await state.approveRequest(req.id);

      expect(state.pendingApprovals.isEmpty, isTrue);
      final updatedCred = state.credentials.firstWhere((c) => c.id == 'cred-cashier');
      expect(updatedCred.pin, '8888');
      expect(updatedCred.fullName, 'New Cashier Name');
    });

    test('Super Admin can directly make changes without approval queue', () async {
      state.setSuperAdminStatus(true);
      expect(state.isSuperAdmin, isTrue);

      // Super Admin updates PIN directly
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '7777',
        fullName: 'Direct Super Admin Update',
      );

      expect(state.pendingApprovals.isEmpty, isTrue);
      final cred = state.credentials.firstWhere((c) => c.id == 'cred-cashier');
      expect(cred.pin, '7777');
      expect(cred.fullName, 'Direct Super Admin Update');
    });

    test('Daily Attendance & 100% Commission Pool Distribution', () {
      final washers = state.availableWashers;
      expect(washers.length, greaterThan(0));

      const double testPool = 1000.0; // 1000 ETB pool

      // All present initially
      var dividends = state.calculateWasherDividends(testPool);
      double totalPercentage = 0.0;
      double totalETB = 0.0;

      for (final div in dividends.values) {
        expect(div.isPresent, isTrue);
        expect(div.percentageShare, greaterThan(0.0));
        totalPercentage += div.percentageShare;
        totalETB += div.earnedETB;
      }

      // Sum of percentages must equal 100%
      expect((totalPercentage - 100.0).abs(), lessThan(0.01));
      expect((totalETB - testPool).abs(), lessThan(0.01));

      // Mark the first washer as ABSENT
      final absentWasher = washers.first;
      state.setWasherAttendance(absentWasher.id, false);

      expect(state.isWasherPresentToday(absentWasher.id), isFalse);
      expect(state.presentWashersCount, washers.length - 1);

      // Recalculate dividends
      dividends = state.calculateWasherDividends(testPool);

      // Absent washer gets 0% and 0 ETB
      final absentDividend = dividends[absentWasher.id]!;
      expect(absentDividend.isPresent, isFalse);
      expect(absentDividend.percentageShare, 0.0);
      expect(absentDividend.earnedETB, 0.0);

      // Present washers divide 100% of the pool
      double presentTotalPercentage = 0.0;
      double presentTotalETB = 0.0;

      for (final w in washers) {
        final div = dividends[w.id]!;
        if (div.isPresent) {
          presentTotalPercentage += div.percentageShare;
          presentTotalETB += div.earnedETB;
        }
      }

      expect((presentTotalPercentage - 100.0).abs(), lessThan(0.01));
      expect((presentTotalETB - testPool).abs(), lessThan(0.01));
    });
  });
}
