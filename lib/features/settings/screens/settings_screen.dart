import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/format/format.dart';
import '../../../core/preferences/user_preferences.dart';
import '../../../core/providers/providers.dart';
import '../../plan/providers/plan_providers.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge,
            ),
            children: [
              const _SectionHeader('Profile'),
              _SettingsTile(
                label: 'Name',
                value: profile.name.isEmpty ? 'Add your name' : profile.name,
                onTap: () => _editText(
                  context: context,
                  title: 'Name',
                  initial: profile.name,
                  onSave: (v) async {
                    await _saveProfile(
                      ref,
                      profile.copyWith(name: v.trim()),
                    );
                  },
                ),
              ),
              _SettingsTile(
                label: 'Age',
                value: '${profile.ageYears}',
                onTap: () => _editNumber(
                  context: context,
                  title: 'Age',
                  initial: profile.ageYears.toDouble(),
                  suffix: 'years',
                  onSave: (v) async {
                    await _saveProfile(
                      ref,
                      profile.copyWith(ageYears: v.round()),
                    );
                  },
                ),
              ),
              _SettingsTile(
                label: 'Height',
                value: '${profile.heightCm.toStringAsFixed(0)} cm',
                onTap: () => _editNumber(
                  context: context,
                  title: 'Height',
                  initial: profile.heightCm,
                  suffix: 'cm',
                  onSave: (v) async {
                    await _saveProfile(
                      ref,
                      profile.copyWith(heightCm: v),
                    );
                  },
                ),
              ),
              _SettingsTile(
                label: 'Weight',
                value: '${profile.weightKg.toStringAsFixed(1)} kg',
                onTap: () => _editNumber(
                  context: context,
                  title: 'Weight',
                  initial: profile.weightKg,
                  suffix: 'kg',
                  onSave: (v) async {
                    await _saveProfile(
                      ref,
                      profile.copyWith(weightKg: v),
                    );
                  },
                ),
              ),
              _SettingsTile(
                label: 'Gender',
                value: _genderLabel(profile.gender),
                onTap: () => _editGender(context, ref, profile),
              ),
              _SettingsTile(
                label: 'Fitness level',
                value: _fitnessLabel(profile.fitnessLevel),
                onTap: () => _editFitness(context, ref, profile),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader('Training'),
              _SettingsTile(
                label: 'Days per week',
                value: '${profile.daysPerWeek}',
                onTap: () => _editDaysPerWeek(context, ref, profile),
              ),
              _SettingsTile(
                label: 'Race date',
                value:
                    '${monthDay(profile.targetMarathonDate)}, ${profile.targetMarathonDate.year}',
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: profile.targetMarathonDate,
                    firstDate: DateTime.now().add(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) {
                    await _saveProfile(
                      ref,
                      profile.copyWith(targetMarathonDate: picked),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _DangerTile(
                label: 'Regenerate plan',
                description:
                    'Rebuilds the 52-week plan from current settings. Completed sessions become unmatched.',
                onTap: () => _regeneratePlan(context, ref, profile),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader('Preferences'),
              _ToggleTile(
                label: 'Show map during recording',
                description:
                    'Disable to save battery on long runs. Route is still recorded.',
                value: ref.watch(userPreferencesProvider)
                    .showMapDuringRecording,
                onChanged: (v) => ref
                    .read(userPreferencesProvider.notifier)
                    .setShowMap(v),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionHeader('About'),
              _SettingsTile(
                label: 'Version',
                value: '0.1.0',
                onTap: null,
              ),
            ],
          );
        },
      ),
    );
  }

  String _genderLabel(Gender g) => switch (g) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };

  String _fitnessLabel(FitnessLevel f) => switch (f) {
        FitnessLevel.none => 'Couch',
        FitnessLevel.beginner => 'Just starting',
        FitnessLevel.recreational => 'Run sometimes',
        FitnessLevel.intermediate => 'Run regularly',
      };

  Future<void> _saveProfile(WidgetRef ref, UserProfile p) async {
    await ref.read(profileRepositoryProvider).save(p);
  }

  Future<void> _editText({
    required BuildContext context,
    required String title,
    required String initial,
    required Future<void> Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (c) => _EditSheet(
        title: title,
        child: TextField(
          autofocus: true,
          controller: controller,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.of(c).pop(v),
        ),
        onSave: () => Navigator.of(c).pop(controller.text),
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await onSave(result);
    }
  }

  Future<void> _editNumber({
    required BuildContext context,
    required String title,
    required double initial,
    required String suffix,
    required Future<void> Function(double) onSave,
  }) async {
    final controller =
        TextEditingController(text: initial.toStringAsFixed(0).replaceAll(RegExp(r'\.0+$'), ''));
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (c) => _EditSheet(
        title: title,
        child: TextField(
          autofocus: true,
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: suffix),
          onSubmitted: (v) {
            final parsed = double.tryParse(v);
            if (parsed != null) Navigator.of(c).pop(parsed);
          },
        ),
        onSave: () {
          final parsed = double.tryParse(controller.text);
          if (parsed != null) Navigator.of(c).pop(parsed);
        },
      ),
    );
    if (result != null) {
      await onSave(result);
    }
  }

  Future<void> _editGender(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final result = await showModalBottomSheet<Gender>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (c) => _OptionSheet<Gender>(
        title: 'Gender',
        options: Gender.values
            .map((g) => (value: g, label: _genderLabel(g)))
            .toList(),
        selected: profile.gender,
      ),
    );
    if (result != null) {
      await _saveProfile(ref, profile.copyWith(gender: result));
    }
  }

  Future<void> _editFitness(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final result = await showModalBottomSheet<FitnessLevel>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (c) => _OptionSheet<FitnessLevel>(
        title: 'Fitness level',
        options: FitnessLevel.values
            .map((f) => (value: f, label: _fitnessLabel(f)))
            .toList(),
        selected: profile.fitnessLevel,
      ),
    );
    if (result != null) {
      await _saveProfile(ref, profile.copyWith(fitnessLevel: result));
    }
  }

  Future<void> _editDaysPerWeek(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (c) => _OptionSheet<int>(
        title: 'Days per week',
        options: [3, 4, 5, 6]
            .map((d) => (value: d, label: '$d days'))
            .toList(),
        selected: profile.daysPerWeek,
      ),
    );
    if (result != null) {
      await _saveProfile(ref, profile.copyWith(daysPerWeek: result));
    }
  }

  Future<void> _regeneratePlan(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Regenerate plan?'),
        content: const Text(
          'Your current plan will be replaced with a fresh 52-week plan based on your latest settings. Completed runs stay, but session matches reset.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Regenerate')),
        ],
      ),
    );
    if (confirm != true) return;
    final engine = ref.read(planEngineProvider);
    final plan = engine.generate(profile);
    await ref.read(planRepositoryProvider).save(plan);
    ref.invalidate(activePlanProvider);
    ref.invalidate(todaySessionProvider);
    ref.invalidate(upcomingSessionsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan regenerated.')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs, AppSpacing.md, AppSpacing.xs, AppSpacing.sm,
      ),
      child: SectionLabel(label),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.chevron_right,
                      color: cs.onSurfaceVariant, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => onChanged(!value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Switch(
                  value: value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback onTap;

  const _DangerTile({
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.miss.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.miss.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh, color: AppColors.miss),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.miss,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;

  const _EditSheet({
    required this.title,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + inset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          child,
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onSave,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _OptionSheet<T> extends StatelessWidget {
  final String title;
  final List<({T value, String label})> options;
  final T selected;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...options.map(
            (o) => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => Navigator.of(context).pop(o.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          o.label,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (o.value == selected)
                        Icon(Icons.check, color: cs.primary, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
