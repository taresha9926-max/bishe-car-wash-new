import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/customer_feedback.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/customer_feedback_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Feedback & Admin Moderation Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repository;

    setUp(() async {
      repository = WashRepositoryImpl();
      state = AppStateNotifier(repository: repository);
      await state.loadData();
    });

    test('Pending feedback is hidden until Admin approves; ignored comments stay hidden', () async {
      // 1. Submit rating-only (optional comment left empty)
      final err1 = await state.submitCustomerFeedback(stars: 4);
      expect(err1, isNull);
      expect(state.pendingCustomerFeedback.length, equals(1));
      expect(state.approvedCustomerFeedback, isEmpty);

      // Admin approves it
      final firstId = state.pendingCustomerFeedback.first.id;
      await state.moderateCustomerFeedback(firstId, FeedbackStatus.approved);
      expect(state.pendingCustomerFeedback, isEmpty);
      expect(state.approvedCustomerFeedback.length, equals(1));
      expect(state.averageApprovedRating, equals(4.0));

      // 2. Directly save a scam/spam pending item via repository to test Ignore path without cooldown wait
      final spam = CustomerFeedback(
        id: 'FDB-SPAM',
        stars: 1,
        comment: 'Inappropriate scammer message',
        createdAt: DateTime.now(),
        status: FeedbackStatus.pending,
      );
      await repository.saveCustomerFeedback([state.approvedCustomerFeedback.first, spam]);
      await state.loadData();
      expect(state.pendingCustomerFeedback.length, equals(1));

      await state.moderateCustomerFeedback('FDB-SPAM', FeedbackStatus.ignored);
      expect(state.pendingCustomerFeedback, isEmpty);
      expect(state.ignoredCustomerFeedback.length, equals(1));
      expect(state.approvedCustomerFeedback.length, equals(1));
    });

    test('Anti-spam validator blocks links and rapid cooldown submissions', () async {
      final linkErr = await state.submitCustomerFeedback(
        stars: 2,
        comment: 'Visit https://scam-site.com for free money',
      );
      expect(linkErr, equals('feedbackLinksBlocked'));
      expect(state.pendingCustomerFeedback, isEmpty);

      final okErr = await state.submitCustomerFeedback(stars: 3, comment: 'Great foam wash!');
      expect(okErr, isNull);

      final cooldownErr = await state.submitCustomerFeedback(stars: 4, comment: 'Second rapid submit');
      expect(cooldownErr, equals('feedbackCooldownError'));
      expect(state.pendingCustomerFeedback.length, equals(1));
    });

    test('Trilingual translations include approved Amharic 4-star wording', () {
      state.setLanguage('EN');
      expect(state.tr('feedbackTab'), equals('Feedback'));
      expect(state.tr('star4SuperSatisfied'), equals('4 Stars — Super Satisfied'));

      state.setLanguage('OM');
      expect(state.tr('feedbackTab'), equals('Yaada Maamilaa'));
      expect(state.tr('star4SuperSatisfied'), equals('Urjii 4 — Hedduu Gammadeera'));

      state.setLanguage('AM');
      expect(state.tr('feedbackTab'), equals('አስተያየት'));
      expect(state.tr('star4SuperSatisfied'), equals('4 ኮከብ — እጅግ በጣም አርኪ'));
    });

    testWidgets('WelcomeScreen shows Feedback beside Enter Customer Portal and opens expanded suggestions list', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Enter Customer Portal'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);

      await tester.tap(find.text('Feedback'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CustomerFeedbackSheet), findsOneWidget);
      expect(find.text('1 Star — Good'), findsOneWidget);
      expect(find.text('4 Stars — Super Satisfied'), findsOneWidget);
      // Expanded by default
      expect(find.text('Show Customers Suggestions (0)'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
