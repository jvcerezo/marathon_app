import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/plan/screens/plan_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/recording/screens/recording_screen.dart';
import '../../features/runs/screens/run_detail_screen.dart';
import '../../features/runs/screens/runs_history_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shell/shell_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/recording',
      builder: (_, __) => const RecordingScreen(),
    ),
    GoRoute(
      path: '/runs/:id',
      builder: (_, state) =>
          RunDetailScreen(runId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    ShellRoute(
      builder: (_, __, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/plan',
          pageBuilder: (_, __) => const NoTransitionPage(child: PlanScreen()),
        ),
        GoRoute(
          path: '/runs',
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: RunsHistoryScreen()),
        ),
        GoRoute(
          path: '/progress',
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: ProgressScreen()),
        ),
      ],
    ),
  ],
);
