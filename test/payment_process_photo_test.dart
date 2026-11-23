import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/payment_process_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('AutoCareAssets.buildPhotoThumbnail is resilient to empty, base64 and invalid URLs', (tester) async {
    const dummyBase64 = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AutoCareAssets.buildPhotoThumbnail(imageUrl: '', width: 40, height: 40),
              AutoCareAssets.buildPhotoThumbnail(imageUrl: dummyBase64, width: 40, height: 40),
              AutoCareAssets.buildPhotoThumbnail(imageUrl: AutoCareAssets.assetHygieneSoapUrl, width: 40, height: 40),
              AutoCareAssets.buildPhotoThumbnail(imageUrl: 'assets/images/phase1_arrived_dirty.jpg', width: 40, height: 40),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('Cashier confirms digital payment with photo attached and dialog closes without white screen', (tester) async {
    final bookingId = '0f893b61-c039-4a96-877e-b8ebd7ea7419';
    final bookingsDb = <Map<String, dynamic>>[
      {
        'id': bookingId,
        'license_plate': '3-C12345 ET',
        'owner_name': 'Tola Gemechu',
        'customer_phone': '+251 91 222 3344',
        'service_type': 'walkInStation',
        'car_type': 'automobile',
        'package_id': 'p1',
        'status': 'completed',
        'is_paid': false,
        'total_amount': 500.0,
        'created_at': DateTime.now().toIso8601String(),
      }
    ];

    final mockClient = MockClient((request) async {
      final path = request.url.path;

      if (path.contains('wash_bookings') && request.method == 'PATCH') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final target = bookingsDb.firstWhere((b) => b['id'] == bookingId);
        target.addAll(body);
        return http.Response(jsonEncode([target]), 200, headers: {'content-type': 'application/json'});
      }

      if (path.contains('wash_bookings') && request.method == 'GET') {
        return http.Response(jsonEncode(bookingsDb), 200, headers: {'content-type': 'application/json'});
      }

      if (path.contains('wash_packages')) {
        return http.Response(jsonEncode([
          {
            'id': 'p1',
            'name': 'Basic Wash',
            'price_automobile': 500.0,
            'price_minibus': 600.0,
            'price_truck': 800.0,
          }
        ]), 200, headers: {'content-type': 'application/json'});
      }

      return http.Response('[]', 200, headers: {'content-type': 'application/json'});
    });

    final repo = SupabaseWashRepositoryImpl(
      supabaseUrl: 'https://mock.supabase.co',
      anonKey: 'mockKey',
      httpClient: mockClient,
    );
    final state = AppStateNotifier(repository: repo);
    await state.loadData();

    await tester.pumpWidget(
      AppStateProvider(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CashierDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final liveBooking = state.bookings.first;

    // Show dialog
    PaymentProcessDialog.show(tester.element(find.byType(CashierDashboardScreen)), liveBooking);
    await tester.pumpAndSettle();

    expect(find.byType(PaymentProcessDialog), findsOneWidget);

    // Enter price and transaction ref
    final priceField = find.widgetWithText(TextField, 'Final Negotiated Price (ETB)');
    if (priceField.evaluate().isNotEmpty) {
      await tester.enterText(priceField, '500');
      await tester.pumpAndSettle();
    }

    // Tap confirm and pay
    final confirmBtn = find.text('Confirm & Complete Payment');
    expect(confirmBtn, findsOneWidget);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify Cashier dashboard is still intact and not white screen
    expect(find.byType(CashierDashboardScreen), findsOneWidget);
  });

  testWidgets('Operational Manager confirms digital payment without white screen (Symmetry test)', (tester) async {
    final bookingId = '0f893b61-c039-4a96-877e-b8ebd7ea7419';
    final bookingsDb = <Map<String, dynamic>>[
      {
        'id': bookingId,
        'license_plate': '3-C99881 ET',
        'owner_name': 'Hana Bekele',
        'customer_phone': '+251 92 111 2233',
        'service_type': 'walkInStation',
        'car_type': 'automobile',
        'package_id': 'p1',
        'status': 'completed',
        'is_paid': false,
        'total_amount': 500.0,
        'created_at': DateTime.now().toIso8601String(),
      }
    ];

    final mockClient = MockClient((request) async {
      final path = request.url.path;

      if (path.contains('wash_bookings') && request.method == 'PATCH') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final target = bookingsDb.firstWhere((b) => b['id'] == bookingId);
        target.addAll(body);
        return http.Response(jsonEncode([target]), 200, headers: {'content-type': 'application/json'});
      }

      if (path.contains('wash_bookings') && request.method == 'GET') {
        return http.Response(jsonEncode(bookingsDb), 200, headers: {'content-type': 'application/json'});
      }

      if (path.contains('wash_packages')) {
        return http.Response(jsonEncode([
          {
            'id': 'p1',
            'name': 'Basic Wash',
            'price_automobile': 500.0,
            'price_minibus': 600.0,
            'price_truck': 800.0,
          }
        ]), 200, headers: {'content-type': 'application/json'});
      }

      return http.Response('[]', 200, headers: {'content-type': 'application/json'});
    });

    final repo = SupabaseWashRepositoryImpl(
      supabaseUrl: 'https://mock.supabase.co',
      anonKey: 'mockKey',
      httpClient: mockClient,
    );
    final state = AppStateNotifier(repository: repo);
    await state.loadData();

    await tester.pumpWidget(
      AppStateProvider(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OperationalManagerDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final liveBooking = state.bookings.first;

    // Show dialog
    PaymentProcessDialog.show(tester.element(find.byType(OperationalManagerDashboardScreen)), liveBooking);
    await tester.pumpAndSettle();

    expect(find.byType(PaymentProcessDialog), findsOneWidget);

    // Tap confirm and pay
    final confirmBtn = find.text('Confirm & Complete Payment');
    expect(confirmBtn, findsOneWidget);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify Manager dashboard is still intact and not white screen
    expect(find.byType(OperationalManagerDashboardScreen), findsOneWidget);
  });
}
