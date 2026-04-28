import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/tokens.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  static const _tabs = [
    (path: '/', icon: Icons.today_outlined, selected: Icons.today, label: 'Today'),
    (path: '/plan', icon: Icons.calendar_month_outlined, selected: Icons.calendar_month, label: 'Plan'),
    (path: '/runs', icon: Icons.directions_run_outlined, selected: Icons.directions_run, label: 'Runs'),
    (path: '/progress', icon: Icons.insights_outlined, selected: Icons.insights, label: 'Progress'),
  ];

  int _indexFor(String location) {
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location == _tabs[i].path || location.startsWith('${_tabs[i].path}/')) {
        if (_tabs[i].path == '/' && location != '/') continue;
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFor(location);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'shellStartRun',
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        onPressed: () => context.push('/recording'),
        icon: const Icon(Icons.play_arrow_rounded, size: 26),
        label: const Text(
          'Start run',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selected),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
