import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: DaloyApp()));
}

class DaloyApp extends ConsumerStatefulWidget {
  const DaloyApp({super.key});

  @override
  ConsumerState<DaloyApp> createState() => _DaloyAppState();
}

class _DaloyAppState extends ConsumerState<DaloyApp> {
  @override
  void initState() {
    super.initState();
    // Recover any runs whose recording session was killed mid-session
    // (most often by aggressive Android OEM background killing). Reads
    // back the samples that did get flushed to disk and rebuilds the
    // distance / polyline / splits so the user still has a summary.
    // Fires once per app start; safely a no-op if there are no orphans.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(runsRepositoryProvider).recoverOrphans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daloy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
