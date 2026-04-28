import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/format/format.dart';
import '../../../core/providers/providers.dart';
import '../../profile/models/user_profile.dart';
import '../providers/plan_providers.dart';

/// Slim "what's next?" flow used after a race ends. Doesn't ask for
/// demographics again — just the three knobs that change between cycles:
/// goal distance, race date, days per week.
Future<bool> showNewGoalSheet(BuildContext context, UserProfile profile) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (c) => _NewGoalSheet(profile: profile),
  );
  return result ?? false;
}

class _NewGoalSheet extends ConsumerStatefulWidget {
  final UserProfile profile;
  const _NewGoalSheet({required this.profile});

  @override
  ConsumerState<_NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends ConsumerState<_NewGoalSheet> {
  late GoalDistance _goalDistance;
  late int _daysPerWeek;
  late DateTime _raceDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _goalDistance = widget.profile.goalDistance;
    _daysPerWeek = widget.profile.daysPerWeek;
    _raceDate = DateTime.now()
        .add(Duration(days: _defaultWeeks(_goalDistance) * 7));
  }

  int _defaultWeeks(GoalDistance g) => switch (g) {
        GoalDistance.fiveK => 12,
        GoalDistance.tenK => 16,
        GoalDistance.halfMarathon => 20,
        GoalDistance.marathon => 52,
      };

  Future<void> _submit() async {
    setState(() => _saving = true);
    final updated = widget.profile.copyWith(
      goalDistance: _goalDistance,
      daysPerWeek: _daysPerWeek,
      targetMarathonDate: _raceDate,
    );
    await ref.read(profileRepositoryProvider).save(updated);
    final engine = ref.read(planEngineProvider);
    final plan = engine.generate(updated);
    await ref.read(planRepositoryProvider).save(plan);
    ref.invalidate(activePlanProvider);
    ref.invalidate(todaySessionProvider);
    ref.invalidate(upcomingSessionsProvider);
    ref.invalidate(planStateProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final weeksToRace =
        (_raceDate.difference(DateTime.now()).inDays / 7).round();
    final tooShort = weeksToRace < _goalDistance.minWeeks;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + inset,
      ),
      child: SingleChildScrollView(
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
            Text('Plan another race',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "We'll use your current fitness to set the new starting line.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('Goal distance'),
            const SizedBox(height: AppSpacing.sm),
            ...GoalDistance.values.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _OptionRow(
                  label: g.label,
                  selected: _goalDistance == g,
                  onTap: () => setState(() {
                    _goalDistance = g;
                    _raceDate = DateTime.now()
                        .add(Duration(days: _defaultWeeks(g) * 7));
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Days per week'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [3, 4, 5, 6]
                  .map((d) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: d == 6 ? 0 : AppSpacing.sm),
                          child: _DaysSegment(
                            label: '$d',
                            selected: _daysPerWeek == d,
                            onTap: () =>
                                setState(() => _daysPerWeek = d),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Race date'),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _raceDate,
                    firstDate: DateTime.now()
                        .add(Duration(days: _goalDistance.minWeeks * 7)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) setState(() => _raceDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: cs.onSurfaceVariant, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${monthDay(_raceDate)}, ${_raceDate.year}',
                              style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$weeksToRace weeks from today',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
            if (tooShort) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${_goalDistance.label} really wants ≥${_goalDistance.minWeeks} weeks. The plan will pad to that minimum.',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warn,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Generate new plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? cs.primary.withValues(alpha: 0.10)
          : cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: cs.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaysSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DaysSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary : cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: selected ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
