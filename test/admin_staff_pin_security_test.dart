import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';

void main() {
  group('Admin Staff PIN Security & Multi-PIN Prevention Tests', () {
    late WashRepositoryImpl localRepo;
    late AppStateNotifier state;

    setUp(() async {
      localRepo = WashRepositoryImpl();
      state = AppStateNotifier(repository: localRepo);
      await state.loadData();
    });

    test('Initial system default PINs authenticate successfully', () async {
      expect(await state.authenticateRoleAsync(UserRole.admin, '4450'), isTrue);
      expect(await state.authenticateRoleAsync(UserRole.cashier, '2233'), isTrue);
      expect(await state.authenticateRoleAsync(UserRole.manager, '7788'), isTrue);
      expect(await state.authenticateRoleAsync(UserRole.accountant, '3344'), isTrue);
      expect(await state.authenticateRoleAsync(UserRole.storekeeper, '3344'), isTrue);

      // Wrong PINs are rejected
      expect(await state.authenticateRoleAsync(UserRole.cashier, '0000'), isFalse);
      expect(await state.authenticateRoleAsync(UserRole.cashier, '1234'), isFalse);
    });

    test('Cashier PIN change from 2233 to 1234 strictly invalidates 2233', () async {
      state.setSuperAdminStatus(true);

      // Change cashier PIN to 1234
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '1234',
        fullName: 'Station Gate Cashier',
      );

      // Default PIN 2233 must now be strictly rejected
      final oldAuth = await state.authenticateRoleAsync(UserRole.cashier, '2233');
      expect(oldAuth, isFalse, reason: 'Default PIN 2233 must be rejected once custom PIN is set');

      // New PIN 1234 must be accepted
      final newAuth = await state.authenticateRoleAsync(UserRole.cashier, '1234');
      expect(newAuth, isTrue, reason: 'New PIN 1234 must be accepted');

      // Admin credentials view reflects 1234
      final cashierCred = state.credentials.firstWhere((c) => c.role == UserRole.cashier);
      expect(cashierCred.pin, equals('1234'));
    });

    test('All 5 staff roles strictly reject default PINs once customized', () async {
      state.setSuperAdminStatus(true);

      // 1. Manager: 7788 -> 5566
      await state.updateStaffCredential(
        id: 'cred-manager',
        pin: '5566',
        fullName: 'Lead Operations Manager',
      );
      expect(await state.authenticateRoleAsync(UserRole.manager, '7788'), isFalse);
      expect(await state.authenticateRoleAsync(UserRole.manager, '5566'), isTrue);

      // 2. Accountant: 3344 -> 7711
      await state.updateStaffCredential(
        id: 'cred-accountant',
        pin: '7711',
        fullName: 'Head Accountant',
      );
      expect(await state.authenticateRoleAsync(UserRole.accountant, '3344'), isFalse);
      expect(await state.authenticateRoleAsync(UserRole.accountant, '7711'), isTrue);

      // 3. Storekeeper: 3344 -> 8822
      await state.updateStaffCredential(
        id: 'cred-storekeeper',
        pin: '8822',
        fullName: 'Senior Storekeeper',
      );
      expect(await state.authenticateRoleAsync(UserRole.storekeeper, '3344'), isFalse);
      expect(await state.authenticateRoleAsync(UserRole.storekeeper, '8822'), isTrue);

      // 4. Admin: 4450 -> 9988
      await state.updateStaffCredential(
        id: 'cred-admin',
        pin: '9988',
        fullName: 'Super Admin',
      );
      expect(await state.authenticateRoleAsync(UserRole.admin, '4450'), isFalse);
      expect(await state.authenticateRoleAsync(UserRole.admin, '9988'), isTrue);
    });

    test('SupabaseWashRepositoryImpl fail-closed: rejects false server response without fallback bypass', () async {
      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.contains('rpc/verify_staff_pin')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final role = body['p_role'];
          final pin = body['p_pin'];

          // Server has cashier = 1234. It returns false for 2233.
          if (role == 'cashier' && pin == '1234') {
            return http.Response('true', 200);
          } else {
            return http.Response('false', 200);
          }
        }

        if (path.contains('staff_credentials')) {
          // Return empty list to simulate RLS-restricted SELECT
          return http.Response('[]', 200);
        }

        return http.Response('[]', 200);
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://siioobajphmwzwwarlrr.supabase.co',
        anonKey: 'dummy_anon_key',
        httpClient: mockClient,
      );

      // When server returns false for cashier 2233, repo must return false (not fall through to default 2233)
      final verifyOld = await repo.verifyStaffPin(UserRole.cashier, '2233');
      expect(verifyOld, isFalse, reason: 'Fail-closed: authoritative false from server must never be overridden');

      // When server returns true for cashier 1234, repo returns true
      final verifyNew = await repo.verifyStaffPin(UserRole.cashier, '1234');
      expect(verifyNew, isTrue, reason: 'Authoritative true from server must authenticate');
    });

    test('SupabaseWashRepositoryImpl getStaffCredentials retains fallback edits when Supabase SELECT returns empty', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200); // RLS hides rows
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://siioobajphmwzwwarlrr.supabase.co',
        anonKey: 'dummy_anon_key',
        httpClient: mockClient,
      );

      // Update cashier PIN through repo
      await repo.updateStaffCredential('cred-cashier', '1234', 'Station Gate Cashier');

      // getStaffCredentials must retain 1234 from fallback repo instead of regenerating 2233
      final creds = await repo.getStaffCredentials();
      final cashier = creds.firstWhere((c) => c.role == UserRole.cashier);
      expect(cashier.pin, equals('1234'));
    });
  });
}
