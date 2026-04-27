import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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

  int? _age;
  Gender? _gender;
  double? _heightCm;
  double? _weightKg;
  FitnessLevel _fitness = FitnessLevel.beginner;
  double? _recentDistanceKm;
  Duration? _recentDuration;
  int _daysPerWeek = 4;
  DateTime _raceDate = DateTime.now().add(const Duration(days: 365));

  bool _saving = false;

  static const _pages = 5;

  void _next() {
    if (_page < _pages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
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
        return _age != null && _gender != null;
      case 2:
        return _heightCm != null && _weightKg != null;
      case 3:
        return true;
      case 4:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: LinearProgressIndicator(
                value: (_page + 1) / _pages,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(),
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
                    daysPerWeek: _daysPerWeek,
                    raceDate: _raceDate,
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
                    onRaceDate: (v) => setState(() => _raceDate = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _canProceed && !_saving ? _next : null,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_page == _pages - 1
                              ? 'Generate my plan'
                              : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'First marathon\nin 365 days.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            "Tell us a bit about yourself and we'll build a 52-week plan tailored to your starting point. Each session gets recorded with GPS and matched to your schedule.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text('A little about you',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age (years)'),
            onChanged: (v) => onAge(int.tryParse(v)),
          ),
          const SizedBox(height: 16),
          Text('Gender', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Gender.values
                .map(
                  (g) => ChoiceChip(
                    label: Text(g.name[0].toUpperCase() + g.name.substring(1)),
                    selected: gender == g,
                    onSelected: (_) => onGender(g),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Used only to estimate your starting fitness. Stays on your phone.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text('Height & weight',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
            onChanged: (v) => onHeight(double.tryParse(v)),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            onChanged: (v) => onWeight(double.tryParse(v)),
          ),
        ],
      ),
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
        FitnessLevel.none => "Couch",
        FitnessLevel.beginner => "Just starting",
        FitnessLevel.recreational => "Run sometimes",
        FitnessLevel.intermediate => "Run regularly",
      };

  String _description(FitnessLevel l) => switch (l) {
        FitnessLevel.none => "Cannot run a continuous mile right now.",
        FitnessLevel.beginner => "Run occasionally, no real structure.",
        FitnessLevel.recreational => "Comfortable with a 5 km.",
        FitnessLevel.intermediate => "Have completed a 10 km or longer.",
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text('Where are you starting?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ...FitnessLevel.values.map(
            (l) => Card(
              child: RadioListTile<FitnessLevel>(
                value: l,
                groupValue: fitness,
                onChanged: (v) => v == null ? null : onFitness(v),
                title: Text(_label(l)),
                subtitle: Text(_description(l)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Optional: a recent run for a sharper estimate",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Distance (km)',
              hintText: 'e.g. 5',
            ),
            onChanged: (v) => onRecentDistance(double.tryParse(v)),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Time (minutes)',
              hintText: 'e.g. 32',
            ),
            onChanged: (v) {
              final m = double.tryParse(v);
              onRecentDuration(m == null
                  ? null
                  : Duration(seconds: (m * 60).round()));
            },
          ),
        ],
      ),
    );
  }
}

class _PlanPage extends StatelessWidget {
  final int daysPerWeek;
  final DateTime raceDate;
  final int? age;
  final Gender? gender;
  final double? heightCm;
  final double? weightKg;
  final FitnessLevel fitness;
  final double? recentRunDistanceM;
  final Duration? recentRunDuration;
  final ValueChanged<int> onDays;
  final ValueChanged<DateTime> onRaceDate;

  const _PlanPage({
    required this.daysPerWeek,
    required this.raceDate,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitness,
    required this.recentRunDistanceM,
    required this.recentRunDuration,
    required this.onDays,
    required this.onRaceDate,
  });

  @override
  Widget build(BuildContext context) {
    final canPredict = age != null &&
        gender != null &&
        heightCm != null &&
        weightKg != null;

    Duration? predicted;
    if (canPredict) {
      final tempProfile = UserProfile(
        id: 'preview',
        ageYears: age!,
        gender: gender!,
        heightCm: heightCm!,
        weightKg: weightKg!,
        fitnessLevel: fitness,
        recentRunDistanceM: recentRunDistanceM,
        recentRunDuration: recentRunDuration,
        daysPerWeek: daysPerWeek,
        targetMarathonDate: raceDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final targetVdot = estimateTargetVdot(tempProfile);
      predicted = predictRaceTime(targetVdot, kMarathon);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text('Your plan',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Days you can run per week',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [3, 4, 5, 6]
                .map(
                  (d) => ChoiceChip(
                    label: Text('$d'),
                    selected: daysPerWeek == d,
                    onSelected: (_) => onDays(d),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('Target race date',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '${raceDate.year}-${raceDate.month.toString().padLeft(2, '0')}-${raceDate.day.toString().padLeft(2, '0')}',
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: raceDate,
                firstDate: DateTime.now().add(const Duration(days: 90)),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked != null) onRaceDate(picked);
            },
          ),
          if (predicted != null) ...[
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your projected marathon time',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDuration(predicted),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Achievable if you stay consistent. Recalculated as you log runs.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
