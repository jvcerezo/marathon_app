import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/hero_number.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/status_pill.dart';
import '../../../core/format/format.dart';
import '../../../core/providers/providers.dart';
import '../../plan/models/plan_session.dart';
import '../pipeline/run_recorder.dart';
import '../providers/recording_providers.dart';
import '../service/recording_service.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  bool _starting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      final svc = ref.read(recordingServiceProvider);
      if (svc.state == RecordingState.idle) {
        await svc.start();
      }
    } on StateError catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _stop() async {
    final svc = ref.read(recordingServiceProvider);
    final adherence = ref.read(adherenceServiceProvider);
    final run = await svc.stop();
    final match = await adherence.matchRun(run);
    if (!mounted) return;
    final summary = match == null
        ? 'Run saved.'
        : 'Session ${_statusLabel(match.status)}.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(summary)),
    );
    context.pop();
  }

  String _statusLabel(SessionStatus s) => switch (s) {
        SessionStatus.hit => 'hit',
        SessionStatus.partial => 'partial',
        SessionStatus.missed => 'missed',
        _ => 'logged',
      };

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(recordingStateProvider);
    ref.watch(recordingTickProvider);
    final svc = ref.watch(recordingServiceProvider);
    final recorder = svc.recorder;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.ink,
      ),
      child: Theme(
        // Force dark for the recording surface regardless of system theme.
        data: Theme.of(context),
        child: Scaffold(
          backgroundColor: AppColors.ink,
          body: SafeArea(
            child: _error != null
                ? _ErrorView(
                    message: _error!,
                    onRetry: () {
                      setState(() => _error = null);
                      _start();
                    },
                  )
                : Column(
                    children: [
                      _TopBar(
                        state: stateAsync.value,
                        onClose: () => _confirmExit(context, svc),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SectionLabel(
                                'Distance',
                                color: AppColors.fog,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              HeroNumber(
                                recorder == null
                                    ? '0.00'
                                    : (recorder.distanceM / 1000.0)
                                        .toStringAsFixed(2),
                                size: 120,
                                color: AppColors.bone,
                                align: TextAlign.center,
                              ).animate().fadeIn(duration: AppMotion.short),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'kilometers',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.fog,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxxl),
                              _BottomStats(recorder: recorder),
                            ],
                          ),
                        ),
                      ),
                      _Controls(
                        state: stateAsync.value,
                        starting: _starting,
                        onPauseToggle: () {
                          if (stateAsync.value == RecordingState.paused) {
                            svc.resume();
                          } else {
                            svc.pause();
                          }
                        },
                        onFinish: _stop,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context, RecordingService svc) async {
    if (svc.state == RecordingState.idle) {
      context.pop();
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => Theme(
        data: Theme.of(context),
        child: AlertDialog(
          backgroundColor: AppColors.shade,
          title: const Text('Discard run?',
              style: TextStyle(color: AppColors.bone)),
          content: const Text(
            'Stop recording without saving this run?',
            style: TextStyle(color: AppColors.mist),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Keep recording'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.miss,
                foregroundColor: AppColors.bone,
              ),
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ),
    );
    if (confirm != true) return;
    await svc.stop();
    if (mounted) context.pop();
  }
}

class _TopBar extends StatelessWidget {
  final RecordingState? state;
  final VoidCallback onClose;
  const _TopBar({required this.state, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.bone),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.slate,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Spacer(),
          _StateChip(state: state),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final RecordingState? state;
  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (state) {
      RecordingState.awaitingFix =>
        (AppColors.warn, 'Acquiring GPS', Icons.satellite_alt_outlined),
      RecordingState.recording =>
        (AppColors.pulse, 'Recording', Icons.fiber_manual_record),
      RecordingState.paused =>
        (AppColors.fog, 'Paused', Icons.pause),
      _ => (AppColors.fog, 'Idle', null),
    };
    final pill = StatusPill(
      label: label,
      color: color,
      icon: icon,
    );
    if (state == RecordingState.recording) {
      return pill
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(duration: const Duration(milliseconds: 1100));
    }
    return pill;
  }
}

class _BottomStats extends StatelessWidget {
  final RunRecorder? recorder;
  const _BottomStats({required this.recorder});

  String _avgPace() {
    if (recorder == null || recorder!.distanceM < 50) return '--:--';
    final paceSecPerKm =
        recorder!.elapsed.inSeconds / (recorder!.distanceM / 1000.0);
    final mins = paceSecPerKm ~/ 60;
    final secs = (paceSecPerKm - mins * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String _elapsed() => recorder == null
      ? '00:00'
      : formatDuration(recorder!.elapsed);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.shade,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.iron),
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(label: 'Time', value: _elapsed())),
          Container(
            width: 1,
            height: 36,
            color: AppColors.iron,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          Expanded(child: _Stat(label: 'Pace', value: _avgPace())),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, color: AppColors.fog),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.bone,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final RecordingState? state;
  final bool starting;
  final VoidCallback onPauseToggle;
  final VoidCallback onFinish;

  const _Controls({
    required this.state,
    required this.starting,
    required this.onPauseToggle,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = state == RecordingState.paused;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl,
      ),
      child: Row(
        children: [
          _CircleButton(
            onTap: starting ? null : onPauseToggle,
            icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: AppColors.iron,
            iconColor: AppColors.bone,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _LongPressFinish(
              onComplete: starting ? null : onFinish,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _CircleButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(icon, color: iconColor, size: 32),
        ),
      ),
    );
  }
}

/// Long-press to finish to prevent accidental taps mid-run.
class _LongPressFinish extends StatefulWidget {
  final VoidCallback? onComplete;
  const _LongPressFinish({required this.onComplete});

  @override
  State<_LongPressFinish> createState() => _LongPressFinishState();
}

class _LongPressFinishState extends State<_LongPressFinish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && widget.onComplete != null) {
        HapticFeedback.mediumImpact();
        widget.onComplete!();
        _ctrl.reset();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDown(_) {
    if (widget.onComplete == null) return;
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _onUp(_) {
    if (_ctrl.status != AnimationStatus.completed) {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: () => _onUp(null),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.ember,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: FractionallySizedBox(
                    widthFactor: _ctrl.value,
                    child: Container(color: AppColors.bone),
                  ),
                ),
                const Center(
                  child: Text(
                    'Hold to finish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 56, color: AppColors.fog),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.bone, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
