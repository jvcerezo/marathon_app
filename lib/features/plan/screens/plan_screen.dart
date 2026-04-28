import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/view_mode_selector.dart';
import '../../../core/format/format.dart';
import '../models/plan_session.dart';
import '../providers/plan_providers.dart';
import '../widgets/session_card.dart';
import '../widgets/session_type_style.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  ViewMode _mode = ViewMode.week;
  DateTime _focused = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(activePlanProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('No plan yet.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.fabSafe,
            ),
            children: [
              const SizedBox(height: AppSpacing.sm),
              ViewModeSelector(
                value: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: AppSpacing.lg),
              switch (_mode) {
                ViewMode.day => _DayView(
                    focused: _focused,
                    sessions: plan.sessions,
                    onChangeFocus: (d) => setState(() => _focused = d),
                  ),
                ViewMode.week => _WeekView(
                    focused: _focused,
                    sessions: plan.sessions,
                    onChangeFocus: (d) => setState(() => _focused = d),
                  ),
                ViewMode.month => _MonthView(
                    focused: _focused,
                    sessions: plan.sessions,
                    onChangeFocus: (d) => setState(() => _focused = d),
                    onPickDay: (d) => setState(() {
                      _focused = d;
                      _mode = ViewMode.day;
                    }),
                  ),
              },
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String eyebrow;
  final String title;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _Header({
    required this.eyebrow,
    required this.title,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(eyebrow),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        if (onPrev != null)
          IconButton.filledTonal(
            onPressed: onPrev,
            icon: Icon(PhosphorIconsRegular.caretLeft, color: cs.onSurface),
          ),
        const SizedBox(width: 4),
        if (onNext != null)
          IconButton.filledTonal(
            onPressed: onNext,
            icon: Icon(PhosphorIconsRegular.caretRight, color: cs.onSurface),
          ),
      ],
    );
  }
}

// =================== DAY VIEW ===================

class _DayView extends StatelessWidget {
  final DateTime focused;
  final List<PlanSession> sessions;
  final ValueChanged<DateTime> onChangeFocus;

  const _DayView({
    required this.focused,
    required this.sessions,
    required this.onChangeFocus,
  });

  @override
  Widget build(BuildContext context) {
    final dayKey = DateTime(focused.year, focused.month, focused.day);
    final session = sessions.firstWhere(
      (s) =>
          DateTime(s.scheduledDate.year, s.scheduledDate.month,
                  s.scheduledDate.day) ==
          dayKey,
      orElse: () => sessions.first,
    );
    final style = styleFor(session.type);
    final isRest = session.type == SessionType.rest;
    final today = DateTime.now();
    final isToday = DateTime(today.year, today.month, today.day) == dayKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          eyebrow: isToday ? 'TODAY' : shortDayName(focused.weekday),
          title: '${monthDay(focused)}, ${focused.year}',
          onPrev: () =>
              onChangeFocus(focused.subtract(const Duration(days: 1))),
          onNext: () => onChangeFocus(focused.add(const Duration(days: 1))),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                style.color.withValues(alpha: 0.18),
                style.color.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: style.color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(style.icon, color: style.color, size: 36),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(
                          session.type.label.toUpperCase(),
                          color: style.color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRest ? 'Rest day' : _heroLabel(session),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isRest) ...[
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Chip(
                      icon: PhosphorIconsRegular.ruler,
                      label: formatDistanceKm(session.prescribedDistanceKm,
                          decimals: 1),
                    ),
                    if (session.prescribedPaceSecPerKm != null)
                      _Chip(
                        icon: PhosphorIconsRegular.gauge,
                        label: formatPace(session.prescribedPaceSecPerKm),
                      ),
                    _Chip(
                      icon: PhosphorIconsRegular.flag,
                      label: _statusLabel(session.status),
                    ),
                  ],
                ),
              ],
              if (session.notes != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PhosphorIconsRegular.lightbulb,
                          size: 16, color: style.color),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          session.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _heroLabel(PlanSession s) {
    final km = s.prescribedDistanceKm;
    final kmStr = km.truncateToDouble() == km
        ? km.toStringAsFixed(0)
        : km.toStringAsFixed(1);
    return '$kmStr km';
  }

  String _statusLabel(SessionStatus s) => switch (s) {
        SessionStatus.hit => 'Hit',
        SessionStatus.partial => 'Partial',
        SessionStatus.missed => 'Missed',
        SessionStatus.scheduled => 'Scheduled',
        SessionStatus.rest => 'Rest',
      };
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurface),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// =================== WEEK VIEW ===================

class _WeekView extends StatelessWidget {
  final DateTime focused;
  final List<PlanSession> sessions;
  final ValueChanged<DateTime> onChangeFocus;

  const _WeekView({
    required this.focused,
    required this.sessions,
    required this.onChangeFocus,
  });

  @override
  Widget build(BuildContext context) {
    final monday = focused.subtract(
      Duration(days: (focused.weekday - DateTime.monday) % 7),
    );
    final sunday = monday.add(const Duration(days: 6));
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final weekSessions = <PlanSession>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      final found = sessions.firstWhere(
        (s) =>
            DateTime(s.scheduledDate.year, s.scheduledDate.month,
                    s.scheduledDate.day) ==
            dayKey,
        orElse: () => _placeholder(day),
      );
      weekSessions.add(found);
    }
    final totalKm = weekSessions.fold<double>(
        0, (sum, s) => sum + s.prescribedDistanceKm);
    final running = weekSessions
        .where((s) =>
            s.type != SessionType.rest && s.type != SessionType.race)
        .length;
    final hits =
        weekSessions.where((s) => s.status == SessionStatus.hit).length;
    final weekNum = weekSessions.first.weekNumber;
    final phase = _phaseFor(weekNum);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          eyebrow: '$phase · WEEK $weekNum',
          title: '${monthDay(monday)} – ${monthDay(sunday)}',
          onPrev: () =>
              onChangeFocus(focused.subtract(const Duration(days: 7))),
          onNext: () => onChangeFocus(focused.add(const Duration(days: 7))),
        ),
        const SizedBox(height: AppSpacing.lg),
        _StatStrip(totalKm: totalKm, running: running, hits: hits),
        const SizedBox(height: AppSpacing.lg),
        ...weekSessions.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SessionCard(
              session: s,
              isToday: DateTime(s.scheduledDate.year, s.scheduledDate.month,
                      s.scheduledDate.day) ==
                  todayKey,
            ),
          ),
        ),
      ],
    );
  }

  String _phaseFor(int week) {
    if (week <= 12) return 'Foundation';
    if (week <= 24) return 'Base';
    if (week <= 36) return 'Build';
    if (week <= 48) return 'Peak';
    return 'Taper';
  }

  PlanSession _placeholder(DateTime day) {
    return PlanSession(
      id: 'placeholder-${day.toIso8601String()}',
      planId: '',
      scheduledDate: day,
      weekNumber: 1,
      dayOfWeek: day.weekday,
      type: SessionType.rest,
      prescribedDistanceKm: 0,
      status: SessionStatus.rest,
    );
  }
}

class _StatStrip extends StatelessWidget {
  final double totalKm;
  final int running;
  final int hits;

  const _StatStrip({
    required this.totalKm,
    required this.running,
    required this.hits,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg, vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCol(
              label: 'TOTAL',
              value: totalKm.toStringAsFixed(0),
              unit: 'km',
            ),
          ),
          Container(width: 1, height: 28, color: cs.outlineVariant),
          Expanded(
            child: _StatCol(
              label: 'RUN DAYS',
              value: '$running',
              unit: '',
            ),
          ),
          Container(width: 1, height: 28, color: cs.outlineVariant),
          Expanded(
            child: _StatCol(
              label: 'COMPLETED',
              value: '$hits / $running',
              unit: '',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _StatCol(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            text: value,
            children: unit.isEmpty
                ? null
                : [
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

// =================== MONTH VIEW ===================

class _MonthView extends StatelessWidget {
  final DateTime focused;
  final List<PlanSession> sessions;
  final ValueChanged<DateTime> onChangeFocus;
  final ValueChanged<DateTime> onPickDay;

  const _MonthView({
    required this.focused,
    required this.sessions,
    required this.onChangeFocus,
    required this.onPickDay,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focused.year, focused.month, 1);
    // Start grid on the Monday on/before the 1st.
    final startOffset = (firstOfMonth.weekday - DateTime.monday) % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: startOffset));
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final byDay = <DateTime, PlanSession>{};
    for (final s in sessions) {
      final k =
          DateTime(s.scheduledDate.year, s.scheduledDate.month,
              s.scheduledDate.day);
      byDay[k] = s;
    }

    // Render 6 rows of 7 cells = 42 days. Always covers a month.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          eyebrow: '${focused.year}',
          title: _monthName(focused.month),
          onPrev: () => onChangeFocus(
              DateTime(focused.year, focused.month - 1, 1)),
          onNext: () => onChangeFocus(
              DateTime(focused.year, focused.month + 1, 1)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (int row = 0; row < 6; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _DayCell(
                        date: gridStart
                            .add(Duration(days: row * 7 + col)),
                        currentMonth: focused.month,
                        session: byDay[DateTime(
                          gridStart.year,
                          gridStart.month,
                          gridStart.day +
                              row * 7 +
                              col,
                        )],
                        todayKey: todayKey,
                        onTap: onPickDay,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        _MonthLegend(),
      ],
    );
  }

  String _monthName(int m) => switch (m) {
        1 => 'January',
        2 => 'February',
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December',
        _ => '',
      };
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final int currentMonth;
  final PlanSession? session;
  final DateTime todayKey;
  final ValueChanged<DateTime> onTap;

  const _DayCell({
    required this.date,
    required this.currentMonth,
    required this.session,
    required this.todayKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dayKey = DateTime(date.year, date.month, date.day);
    final isToday = dayKey == todayKey;
    final inMonth = date.month == currentMonth;
    final s = session;
    final color = s == null ? cs.surfaceContainerHigh : styleFor(s.type).color;
    final isRest = s?.type == SessionType.rest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () => onTap(date),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isToday
                ? color.withValues(alpha: 0.30)
                : isRest
                    ? cs.surfaceContainerLow
                    : color.withValues(alpha: inMonth ? 0.15 : 0.06),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isToday ? color : Colors.transparent,
              width: isToday ? 1.5 : 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: inMonth
                      ? cs.onSurface
                      : cs.onSurface.withValues(alpha: 0.35),
                ),
              ),
              if (s != null && !isRest)
                Text(
                  s.prescribedDistanceKm.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _LegendItem(color: AppColors.pulse, label: 'Easy'),
        _LegendItem(color: AppColors.signal, label: 'Long'),
        _LegendItem(color: AppColors.warn, label: 'Tempo'),
        _LegendItem(color: AppColors.ember, label: 'Intervals'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
