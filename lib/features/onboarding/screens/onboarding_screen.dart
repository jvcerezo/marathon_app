import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/bordered_surface.dart';
import '../../../core/design/widgets/hero_number.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/format/format.dart';
import '../../../core/providers/providers.dart';
import '../../fitness/predictor.dart';
import '../../plan/providers/plan_providers.dart';
import '../../profile/models/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  String _name = '';
  int? _age;
  Gender? _gender;
  double? _heightCm;
  double? _weightKg;
  FitnessLevel _fitness = FitnessLevel.beginner;
  double? _recentDistanceKm;
  Duration? _recentDuration;
  int _daysPerWeek = 4;
  GoalDistance _goalDistance = GoalDistance.marathon;
  DateTime _raceDate = DateTime.now().add(const Duration(days: 365));
  bool _userPickedRaceDate = false;

  void _onGoalDistanceChange(GoalDistance g) {
    setState(() {
      _goalDistance = g;
      if (!_userPickedRaceDate) {
        final defaultWeeks = switch (g) {
          GoalDistance.fiveK => 12,
          GoalDistance.tenK => 16,
          GoalDistance.halfMarathon => 20,
          GoalDistance.marathon => 52,
        };
        _raceDate = DateTime.now().add(Duration(days: defaultWeeks * 7));
      }
    });
  }

  void _onRaceDatePicked(DateTime d) {
    setState(() {
      _raceDate = d;
      _userPickedRaceDate = true;
    });
  }

  bool _saving = false;

  static const _pages = 6;

  void _next() {
    FocusScope.of(context).unfocus();
    if (_page < _pages - 1) {
      _pageController.nextPage(
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page == 0) return;
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: AppMotion.medium,
      curve: AppMotion.emphasized,
    );
  }

  Future<void> _finish() async {
    if (_age == null ||
        _gender == null ||
        _heightCm == null ||
        _weightKg == null) {
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final profile = UserProfile(
      id: const Uuid().v4(),
      name: _name.trim(),
      ageYears: _age!,
      gender: _gender!,
      heightCm: _heightCm!,
      weightKg: _weightKg!,
      fitnessLevel: _fitness,
      recentRunDistanceM: _recentDistanceKm == null
          ? null
          : _recentDistanceKm! * 1000,
      recentRunDuration: _recentDuration,
      daysPerWeek: _daysPerWeek,
      goalDistance: _goalDistance,
      targetMarathonDate: _raceDate,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(profileRepositoryProvider).save(profile);
    final engine = ref.read(planEngineProvider);
    final plan = engine.generate(profile);
    await ref.read(planRepositoryProvider).save(plan);
    ref.invalidate(activePlanProvider);
    ref.invalidate(todaySessionProvider);
    if (!mounted) return;
    context.go('/');
  }

  bool get _canProceed {
    switch (_page) {
      case 0:
        return true;
      case 1:
        return _name.trim().length >= 2;
      case 2:
        return _age != null && _gender != null;
      case 3:
        return _heightCm != null && _weightKg != null;
      case 4:
        return true;
      case 5:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: cs.surface,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _ProgressBar(value: (_page + 1) / _pages),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    const _WelcomePage(),
                    _NamePage(
                      name: _name,
                      onChanged: (v) => setState(() => _name = v),
                    ),
                    _AgeGenderPage(
                      age: _age,
                      gender: _gender,
                      onAge: (v) => setState(() => _age = v),
                      onGender: (v) => setState(() => _gender = v),
                    ),
                    _BodyPage(
                      heightCm: _heightCm,
                      weightKg: _weightKg,
                      onHeight: (v) => setState(() => _heightCm = v),
                      onWeight: (v) => setState(() => _weightKg = v),
                    ),
                    _FitnessPage(
                      fitness: _fitness,
                      recentDistanceKm: _recentDistanceKm,
                      recentDuration: _recentDuration,
                      onFitness: (v) => setState(() => _fitness = v),
                      onRecentDistance: (v) =>
                          setState(() => _recentDistanceKm = v),
                      onRecentDuration: (v) =>
                          setState(() => _recentDuration = v),
                    ),
                    _PlanPage(
                      name: _name,
                      daysPerWeek: _daysPerWeek,
                      raceDate: _raceDate,
                      goalDistance: _goalDistance,
                      age: _age,
                      gender: _gender,
                      heightCm: _heightCm,
                      weightKg: _weightKg,
                      fitness: _fitness,
                      recentRunDistanceM: _recentDistanceKm == null
                          ? null
                          : _recentDistanceKm! * 1000,
                      recentRunDuration: _recentDuration,
                      onDays: (v) => setState(() => _daysPerWeek = v),
                      onRaceDate: _onRaceDatePicked,
                      onGoalDistance: _onGoalDistanceChange,
                    ),
                  ],
                ),
              ),
              _Footer(
                page: _page,
                pages: _pages,
                canProceed: _canProceed,
                saving: _saving,
                onBack: _back,
                onNext: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm,
      ),
      child: Stack(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AnimatedFractionallySizedBox(
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            widthFactor: value,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int page;
  final int pages;
  final bool canProceed;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _Footer({
    required this.page,
    required this.pages,
    required this.canProceed,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page == pages - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg,
      ),
      child: Row(
        children: [
          if (page > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : onBack,
                child: const Text('Back'),
              ),
            ),
          if (page > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: canProceed && !saving ? onNext : null,
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(isLast ? 'Generate my plan' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const _PageScaffold({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            SectionLabel(eyebrow!),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(title, style: tt.headlineLarge),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle!, style: tt.bodyLarge),
          ],
          const SizedBox(height: AppSpacing.xl),
          ...children,
        ],
      ).animate().fadeIn(duration: AppMotion.short).moveY(
            begin: 8,
            end: 0,
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
          ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.huge, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SectionLabel('Couch to 42.2 km', color: cs.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your first',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 56,
                  height: 1,
                ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'marathon',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 56,
                      height: 1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'in ',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 56,
                      height: 1,
                      color: cs.onSurfaceVariant,
                    ),
              ),
              HeroNumber('365', size: 80, color: cs.primary),
              Text(
                ' days',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 56,
                      height: 1,
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'A personalized 52-week plan calibrated to where you are right now. Every session recorded by GPS.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final String name;
  final ValueChanged<String> onChanged;

  const _NamePage({required this.name, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      eyebrow: 'Step 1 of 5',
      title: 'What should we\ncall you?',
      subtitle: 'A first name is plenty.',
      children: [
        TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'e.g. Jeff',
          ),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AgeGenderPage extends StatelessWidget {
  final int? age;
  final Gender? gender;
  final ValueChanged<int?> onAge;
  final ValueChanged<Gender?> onGender;

  const _AgeGenderPage({
    required this.age,
    required this.gender,
    required this.onAge,
    required this.onGender,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      eyebrow: 'Step 2 of 5',
      title: 'A bit about you',
      subtitle: 'Used to estimate your baseline. Stays on your phone.',
      children: [
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Age (years)'),
          onChanged: (v) => onAge(int.tryParse(v)),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Gender'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: Gender.values
              .map(
                (g) => ChoiceChip(
                  label: Text(_genderLabel(g)),
                  selected: gender == g,
                  onSelected: (_) => onGender(g),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _genderLabel(Gender g) => switch (g) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };
}

class _BodyPage extends StatelessWidget {
  final double? heightCm;
  final double? weightKg;
  final ValueChanged<double?> onHeight;
  final ValueChanged<double?> onWeight;

  const _BodyPage({
    required this.heightCm,
    required this.weightKg,
    required this.onHeight,
    required this.onWeight,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      eyebrow: 'Step 3 of 5',
      title: 'Height and weight',
      subtitle: 'BMI and frame factor into your starting fitness estimate.',
      children: [
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Height',
            suffixText: 'cm',
          ),
          onChanged: (v) => onHeight(double.tryParse(v)),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight',
            suffixText: 'kg',
          ),
          onChanged: (v) => onWeight(double.tryParse(v)),
        ),
      ],
    );
  }
}

class _FitnessPage extends StatelessWidget {
  final FitnessLevel fitness;
  final double? recentDistanceKm;
  final Duration? recentDuration;
  final ValueChanged<FitnessLevel> onFitness;
  final ValueChanged<double?> onRecentDistance;
  final ValueChanged<Duration?> onRecentDuration;

  const _FitnessPage({
    required this.fitness,
    required this.recentDistanceKm,
    required this.recentDuration,
    required this.onFitness,
    required this.onRecentDistance,
    required this.onRecentDuration,
  });

  String _label(FitnessLevel l) => switch (l) {
        FitnessLevel.none => 'Couch',
        FitnessLevel.beginner => 'Just starting',
        FitnessLevel.recreational => 'Run sometimes',
        FitnessLevel.intermediate => 'Run regularly',
      };

  String _description(FitnessLevel l) => switch (l) {
        FitnessLevel.none => "Cannot run a continuous mile right now.",
        FitnessLevel.beginner => "Run occasionally, no real structure.",
        FitnessLevel.recreational => "Comfortable with a 5 km.",
        FitnessLevel.intermediate => "Have completed a 10 km or longer.",
      };

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      eyebrow: 'Step 4 of 5',
      title: 'Where you are\nstarting',
      children: [
        ...FitnessLevel.values.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _FitnessTile(
              label: _label(l),
              description: _description(l),
              selected: fitness == l,
              onTap: () => onFitness(l),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionLabel('Recent run (optional)'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sharper estimate if you can give us one.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance',
                  suffixText: 'km',
                ),
                onChanged: (v) => onRecentDistance(double.tryParse(v)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixText: 'min',
                ),
                onChanged: (v) {
                  final m = double.tryParse(v);
                  onRecentDuration(m == null
                      ? null
                      : Duration(seconds: (m * 60).round()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FitnessTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _FitnessTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.short,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: selected
            ? cs.primary.withValues(alpha: 0.10)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: AppMotion.short,
                  scale: selected ? 1.0 : 0.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanPage extends StatelessWidget {
  final String name;
  final int daysPerWeek;
  final DateTime raceDate;
  final GoalDistance goalDistance;
  final int? age;
  final Gender? gender;
  final double? heightCm;
  final double? weightKg;
  final FitnessLevel fitness;
  final double? recentRunDistanceM;
  final Duration? recentRunDuration;
  final ValueChanged<int> onDays;
  final ValueChanged<DateTime> onRaceDate;
  final ValueChanged<GoalDistance> onGoalDistance;

  const _PlanPage({
    required this.name,
    required this.daysPerWeek,
    required this.raceDate,
    required this.goalDistance,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitness,
    required this.recentRunDistanceM,
    required this.recentRunDuration,
    required this.onDays,
    required this.onRaceDate,
    required this.onGoalDistance,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canPredict = age != null &&
        gender != null &&
        heightCm != null &&
        weightKg != null;
    Duration? predicted;
    if (canPredict) {
      final tempProfile = UserProfile(
        id: 'preview',
        name: name,
        ageYears: age!,
        gender: gender!,
        heightCm: heightCm!,
        weightKg: weightKg!,
        fitnessLevel: fitness,
        recentRunDistanceM: recentRunDistanceM,
        recentRunDuration: recentRunDuration,
        daysPerWeek: daysPerWeek,
        goalDistance: goalDistance,
        targetMarathonDate: raceDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      predicted = predictRaceTime(
          estimateTargetVdot(tempProfile), goalDistance.meters);
    }
    final daysToRace = raceDate.difference(DateTime.now()).inDays;
    final weeksToRace = (daysToRace / 7).round();
    final tooShort = weeksToRace < goalDistance.minWeeks;

    return _PageScaffold(
      eyebrow: 'Step 5 of 5',
      title: 'Build the plan',
      children: [
        const SectionLabel('What are you training for?'),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: GoalDistance.values
              .map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _GoalDistanceTile(
                    distance: g,
                    selected: g == goalDistance,
                    onTap: () => onGoalDistance(g),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionLabel('Days you can run per week'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [3, 4, 5, 6]
              .map(
                (d) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: d == 6 ? 0 : AppSpacing.sm,
                    ),
                    child: _SegmentTile(
                      label: '$d',
                      sublabel: d == 6 ? 'days' : '',
                      selected: daysPerWeek == d,
                      onTap: () => onDays(d),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionLabel('Target race date'),
        const SizedBox(height: AppSpacing.md),
        BorderedSurface(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: raceDate,
              firstDate: DateTime.now()
                  .add(Duration(days: goalDistance.minWeeks * 7)),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) onRaceDate(picked);
          },
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${monthDay(raceDate)}, ${raceDate.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$weeksToRace weeks from today',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
        if (tooShort) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${goalDistance.label} training really needs ≥${goalDistance.minWeeks} weeks. The plan will pad to that minimum.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warn,
            ),
          ),
        ],
        if (predicted != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          _PredictionHero(
              predicted: predicted, goalLabel: goalDistance.label),
        ],
      ],
    );
  }
}

class _GoalDistanceTile extends StatelessWidget {
  final GoalDistance distance;
  final bool selected;
  final VoidCallback onTap;

  const _GoalDistanceTile({
    required this.distance,
    required this.selected,
    required this.onTap,
  });

  String _description(GoalDistance d) => switch (d) {
        GoalDistance.fiveK =>
          '6-12 weeks. Great first goal if you can already run a bit.',
        GoalDistance.tenK => '8-16 weeks. The classic step-up race.',
        GoalDistance.halfMarathon =>
          '10-20 weeks. Serious commitment, achievable for most.',
        GoalDistance.marathon => '16-52 weeks. The full distance.',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.short,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: selected
            ? cs.primary.withValues(alpha: 0.10)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(distance.label,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        _description(distance),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: AppMotion.short,
                  scale: selected ? 1.0 : 0.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check,
                        size: 16, color: cs.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTile({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.short,
      curve: AppMotion.standard,
      height: 64,
      decoration: BoxDecoration(
        color: selected ? cs.primary : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: selected ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PredictionHero extends StatelessWidget {
  final Duration predicted;
  final String goalLabel;
  const _PredictionHero({
    required this.predicted,
    required this.goalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Your projected $goalLabel time', color: cs.primary),
          const SizedBox(height: AppSpacing.md),
          HeroNumber(
            formatDuration(predicted),
            size: 64,
            color: cs.onPrimaryContainer,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'If you stay consistent. Recalculated as you log runs.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}
