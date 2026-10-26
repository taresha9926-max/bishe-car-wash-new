import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'features/auth_roles/presentation/screens/role_shell_screen.dart';
import 'features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'features/booking_service/presentation/state/app_state_notifier.dart';
import 'features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean Architecture Dependency Injection (Live Supabase + Offline Fallback)
  final washRepository = SupabaseWashRepositoryImpl(
    supabaseUrl: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  final appStateNotifier = AppStateNotifier(repository: washRepository);

  runApp(BisheCarWashApp(appStateNotifier: appStateNotifier));
}

class BisheCarWashApp extends StatelessWidget {
  final AppStateNotifier appStateNotifier;

  const BisheCarWashApp({
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
            title: 'BISHE Car Wash',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const RoleShellScreen(),
          );
        },
      ),
    );
  }
}
