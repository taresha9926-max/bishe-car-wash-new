import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/admin/domain/models/daily_financial_closing.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';

DailyFinancialClosing _sampleClosing(String id) {
  final now = DateTime(2026, 11, 11, 18, 0);
  return DailyFinancialClosing(
    id: id,
    closingDate: now,
    closedAt: now,
    cashierName: 'Cashier',
    grossRevenue: 1500,
    cashRevenue: 1000,
    digitalRevenue: 500,
    providerBreakdown: const {'Cash': 1000, 'Telebirr': 500},
    carsWashedCount: 3,
    commissionPool: 225,
    netStationProfit: 1275,
    cashDeposited: 0,
    pettyCashExpenses: 0,
    cashRemaining: 1000,
    washerDividends: const {'Abebe': 225},
    shiftType: 'day',
    closedByRole: 'cashier',
    handoverTo: 'Operational Manager',
    handoverCashAmount: 1000,
    handoverMethod: 'manager_otp',
    handoverOtp: '4821',
  );
}

void main() {
  group('DailyFinancialClosing Supabase RLS-safe sync', () {
    test('New closing uses plain POST insert without on_conflict=id and clears sync error', () async {
      final calls = <String>[];
      final client = MockClient((req) async {
        calls.add('${req.method} ${req.url.path}${req.url.hasQuery ? "?${req.url.query}" : ""}');
        if (req.method == 'GET') {
          return http.Response('[]', 200);
        }
        if (req.method == 'POST') {
          expect(req.url.queryParameters.containsKey('on_conflict'), isFalse);
          return http.Response(jsonEncode([jsonDecode(req.body)]), 201);
        }
        return http.Response('[]', 400);
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://example.supabase.co',
        anonKey: 'test-key',
        httpClient: client,
      );

      await repo.saveDailyFinancialClosing(_sampleClosing('closing-2026-11-11-day'));
      expect(repo.lastClosingSyncError, isNull);
      expect(calls.length, 2);
      expect(calls[0], startsWith('GET '));
      expect(calls[1], 'POST /rest/v1/daily_closings');
    });

    test('Existing closing uses PATCH and succeeds when row is returned', () async {
      final calls = <String>[];
      final client = MockClient((req) async {
        calls.add('${req.method} ${req.url.path}');
        if (req.method == 'GET') {
          return http.Response('[{"id":"closing-2026-11-11-day"}]', 200);
        }
        if (req.method == 'PATCH') {
          return http.Response('[{"id":"closing-2026-11-11-day"}]', 200);
        }
        return http.Response('[]', 400);
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://example.supabase.co',
        anonKey: 'test-key',
        httpClient: client,
      );

      await repo.saveDailyFinancialClosing(_sampleClosing('closing-2026-11-11-day'));
      expect(repo.lastClosingSyncError, isNull);
      expect(calls, ['GET /rest/v1/daily_closings', 'PATCH /rest/v1/daily_closings']);
    });

    test('Existing closing surfaces lastClosingSyncError when Supabase UPDATE RLS returns 0 rows', () async {
      final client = MockClient((req) async {
        if (req.method == 'GET') {
          return http.Response('[{"id":"closing-2026-11-10-day"}]', 200);
        }
        if (req.method == 'PATCH') {
          // Simulates Postgres RLS UPDATE USING policy rejecting anon (0 rows updated)
          return http.Response('[]', 200);
        }
        return http.Response('[]', 401);
      });

      final repo = SupabaseWashRepositoryImpl(
        supabaseUrl: 'https://example.supabase.co',
        anonKey: 'test-key',
        httpClient: client,
      );

      await repo.saveDailyFinancialClosing(_sampleClosing('closing-2026-11-10-day'));
      expect(repo.lastClosingSyncError, isNotNull);
      expect(repo.lastClosingSyncError, contains('20261111_fix_rls_closings_and_bookings.sql'));
      final local = await repo.getDailyFinancialClosings();
      expect(local.any((c) => c.id == 'closing-2026-11-10-day'), isTrue);
    });

    test('closingCloudSyncRlsWarning translation is complete in EN, OM, AM', () {
      final en = AppStrings.get('closingCloudSyncRlsWarning', AppLanguage.en);
      final om = AppStrings.get('closingCloudSyncRlsWarning', AppLanguage.om);
      final am = AppStrings.get('closingCloudSyncRlsWarning', AppLanguage.am);
      expect(en, isNot('closingCloudSyncRlsWarning'));
      expect(om, isNot('closingCloudSyncRlsWarning'));
      expect(am, isNot('closingCloudSyncRlsWarning'));
      expect(om, isNot(en));
      expect(am, isNot(en));
    });
  });
}
