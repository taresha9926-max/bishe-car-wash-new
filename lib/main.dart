import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'features/auth_roles/presentation/screens/role_shell_screen.dart';
import 'features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'features/booking_service/presentation/state/app_state_notifier.dart';
import 'features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom ErrorWidget builder to guarantee zero white screens on unexpected rendering errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Global ErrorWidget captured: ${details.exception}');
    return Material(
      color: const Color(0xFF06070B),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_car_wash_rounded, color: Color(0xFFF59E0B), size: 48),
              const SizedBox(height: 16),
              const Text(
                'BISHE Car Wash Station',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'A temporary display refresh is required.',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Soft reset
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  };

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
