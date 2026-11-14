import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/entrance_splash_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  testWidgets('EntranceSplashScreen renders logo, typography, and proceeds on button tap', (tester) async {
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
            autoTransitionDuration: const Duration(seconds: 10),
          ),
        ),
      ),
    );

    // Initial pump & tick animation
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('BISHE CAR WASH'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);

    final enterBtn = find.text(notifier.tr('enterStationPortal'));
    expect(enterBtn, findsOneWidget);

    await tester.ensureVisible(enterBtn);
    await tester.tap(enterBtn);
    await tester.pump();

    expect(proceeded, isTrue);
  });
}
