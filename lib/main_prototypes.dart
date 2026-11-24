import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'features/booking_service/presentation/state/app_state_notifier.dart';
import 'features/booking_service/presentation/state/app_state_provider.dart';
import 'features/prototypes/data/mock_prototype_wash_repository.dart';
import 'features/prototypes/presentation/screens/prototype_evaluator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hermetic in-memory mock repository (Rule 10: Zero live DB hits)
  final mockRepo = MockPrototypeWashRepository();
  final appStateNotifier = AppStateNotifier(repository: mockRepo);
  await appStateNotifier.loadData();

  runApp(PrototypeAppHarness(appStateNotifier: appStateNotifier));
}

class PrototypeAppHarness extends StatelessWidget {
  final AppStateNotifier appStateNotifier;

  const PrototypeAppHarness({
    super.key,
    required this.appStateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: appStateNotifier,
      child: AnimatedBuilder(
        animation: appStateNotifier,
        builder: (context, _) {
          return MaterialApp(
            title: 'BISHE Prototype Evaluator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const PrototypeEvaluatorScreen(),
          );
        },
      ),
    );
  }
}
