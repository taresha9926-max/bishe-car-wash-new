import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/entrance_splash_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  testWidgets('EntranceSplashScreen renders logo, social pills, tap prompt, and proceeds on tap anywhere', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final notifier = AppStateNotifier(repository: WashRepositoryImpl());
    bool proceeded = false;

    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: EntranceSplashScreen(
            onProceed: () => proceeded = true,
          ),
        ),
      ),
    );

    // Initial pump & tick animation
    await tester.pump(const Duration(milliseconds: 300));

    // Logo image is present
    expect(find.byType(Image), findsOneWidget);

    // Social media pills are present
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);

    // Tap anywhere to continue prompt is present
    expect(find.text(notifier.tr('tapToContinue')), findsOneWidget);

    // Tap anywhere on the splash screen
    await tester.tap(find.byType(EntranceSplashScreen));
    await tester.pump();

    expect(proceeded, isTrue);
  });

  testWidgets('EntranceSplashScreen automatically proceeds after 10 seconds fallback timer', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final notifier = AppStateNotifier(repository: WashRepositoryImpl());
    bool autoProceeded = false;

    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: EntranceSplashScreen(
            onProceed: () => autoProceeded = true,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(autoProceeded, isFalse);

    // After 5 seconds, should not have auto-proceeded yet
    await tester.pump(const Duration(seconds: 5));
    expect(autoProceeded, isFalse);

    // After full 10 seconds, it proceeds
    await tester.pump(const Duration(seconds: 5));
    expect(autoProceeded, isTrue);
  });
}
