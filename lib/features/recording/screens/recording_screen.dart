import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/status_pill.dart';
import '../../../core/format/format.dart';
import '../../../core/math/geo_math.dart';
import '../../../core/network/cached_tile_provider.dart';
import '../../../core/preferences/user_preferences.dart';
import '../../../core/providers/providers.dart';
import '../../plan/models/plan_session.dart';
import '../../plan/providers/plan_providers.dart';
import '../models/run_sample.dart';
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
      final prefs = ref.read(userPreferencesProvider);
      if (svc.state == RecordingState.idle) {
        await svc.start(
          keepScreenAwake: prefs.keepScreenAwake,
          audioCues: prefs.audioCuesEnabled,
        );
      }
    } on StateError catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _begin() async {
    final svc = ref.read(recordingServiceProvider);
    if (svc.state != RecordingState.ready) return;
    try {
      await svc.begin();
    } on StateError catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _stop() async {
    final svc = ref.read(recordingServiceProvider);
    final adherence = ref.read(adherenceServiceProvider);
    final run = await svc.stop();
    if (run == null) {
      // Was never started; nothing to save.
      if (mounted) context.pop();
      return;
    }
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

    final samples = svc.currentSamples;
    final showMap = ref.watch(userPreferencesProvider).showMapDuringRecording;
    final isRecording = stateAsync.value == RecordingState.recording;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.ink,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: _error != null
            ? SafeArea(
                child: _ErrorView(
                  message: _error!,
                  onRetry: () {
                    setState(() => _error = null);
                    _start();
                  },
                ),
              )
            : showMap
                ? _MapLayout(
                    samples: samples,
                    isRecording: isRecording,
                    state: stateAsync.value,
                    recorder: recorder,
                    starting: _starting,
                    onClose: () => _confirmExit(context, svc),
                    onPauseToggle: () {
                      if (stateAsync.value == RecordingState.paused) {
                        svc.resume();
                      } else {
                        svc.pause();
                      }
                    },
                    onFinish: _stop,
                    onBegin: _begin,
                  )
                : _NoMapLayout(
                    state: stateAsync.value,
                    recorder: recorder,
                    starting: _starting,
                    onClose: () => _confirmExit(context, svc),
                    onPauseToggle: () {
                      if (stateAsync.value == RecordingState.paused) {
                        svc.resume();
                      } else {
                        svc.pause();
                      }
                    },
                    onFinish: _stop,
                    onBegin: _begin,
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
  final PlanSession? session;
  const _BottomStats({required this.recorder, this.session});

  double? _currentPaceSecPerKm() {
    if (recorder == null || recorder!.distanceM < 50) return null;
    return recorder!.elapsed.inSeconds / (recorder!.distanceM / 1000.0);
  }

  String _avgPace() {
    final p = _currentPaceSecPerKm();
    if (p == null) return '--:--';
    final mins = p ~/ 60;
    final secs = (p - mins * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  /// Returns the current pace zone vs prescribed: -1 too slow, 0 in zone, 1 too fast.
  int? _paceZone() {
    final p = _currentPaceSecPerKm();
    final target = session?.prescribedPaceSecPerKm;
    if (p == null || target == null) return null;
    const tolerance = 20; // 20 sec/km on either side counts as "in zone"
    if (p < target - tolerance) return 1; // running faster than target
    if (p > target + tolerance) return -1; // slower than target
    return 0;
  }

  String _elapsed() => recorder == null
      ? '00:00'
      : formatDuration(recorder!.elapsed);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: _Stat(
              label: 'Pace',
              value: _avgPace(),
              accentColor: switch (_paceZone()) {
                0 => AppColors.pulse,
                1 => AppColors.signal,
                -1 => AppColors.warn,
                _ => null,
              },
              hint: switch (_paceZone()) {
                0 => 'in zone',
                1 => 'too fast',
                -1 => 'pick it up',
                _ => null,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;
  final String? hint;

  const _Stat({
    required this.label,
    required this.value,
    this.accentColor,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, color: AppColors.fog),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: accentColor ?? AppColors.bone,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: accentColor ?? AppColors.fog,
            ),
          ),
        ],
      ],
    );
  }
}

class _TargetBanner extends StatelessWidget {
  final PlanSession? session;
  const _TargetBanner({required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    if (s == null || s.type == SessionType.rest) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.iron),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flag_outlined, size: 14, color: AppColors.fog),
          const SizedBox(width: 6),
          Text(
            "Today's target: ${s.prescribedDistanceKm.toStringAsFixed(s.prescribedDistanceKm.truncateToDouble() == s.prescribedDistanceKm ? 0 : 1)} km"
            "${s.prescribedPaceSecPerKm == null ? '' : ' @ ${formatPace(s.prescribedPaceSecPerKm)}'}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.mist,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetProgress extends StatelessWidget {
  final PlanSession? session;
  final double currentKm;

  const _TargetProgress({required this.session, required this.currentKm});

  @override
  Widget build(BuildContext context) {
    final s = session;
    if (s == null ||
        s.type == SessionType.rest ||
        s.prescribedDistanceKm <= 0) {
      return const SizedBox.shrink();
    }
    final progress =
        (currentKm / s.prescribedDistanceKm).clamp(0.0, 1.0).toDouble();
    final reached = currentKm >= s.prescribedDistanceKm;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(color: AppColors.iron),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    color: reached ? AppColors.pulse : AppColors.bone,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          reached
              ? 'Target hit. Cool down or keep going.'
              : '${(progress * 100).round()}% to ${s.prescribedDistanceKm.toStringAsFixed(s.prescribedDistanceKm.truncateToDouble() == s.prescribedDistanceKm ? 0 : 1)} km',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: reached ? AppColors.pulse : AppColors.fog,
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
  final VoidCallback onBegin;

  const _Controls({
    required this.state,
    required this.starting,
    required this.onPauseToggle,
    required this.onFinish,
    required this.onBegin,
  });

  @override
  Widget build(BuildContext context) {
    // Pre-recording controls
    if (state == RecordingState.awaitingFix ||
        state == RecordingState.ready) {
      final ready = state == RecordingState.ready;
      return SizedBox(
        height: 64,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: ready ? AppColors.pulse : AppColors.iron,
            foregroundColor: ready ? AppColors.ink : AppColors.fog,
            disabledBackgroundColor: AppColors.iron,
            disabledForegroundColor: AppColors.fog,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          onPressed: ready ? onBegin : null,
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: Text(ready ? 'Start run' : 'Acquiring GPS...'),
        ),
      );
    }

    // Recording / paused controls
    final isPaused = state == RecordingState.paused;
    return Row(
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

class _MapLayout extends StatelessWidget {
  final List<RunSample> samples;
  final bool isRecording;
  final RecordingState? state;
  final RunRecorder? recorder;
  final bool starting;
  final VoidCallback onClose;
  final VoidCallback onPauseToggle;
  final VoidCallback onFinish;
  final VoidCallback onBegin;

  const _MapLayout({
    required this.samples,
    required this.isRecording,
    required this.state,
    required this.recorder,
    required this.starting,
    required this.onClose,
    required this.onPauseToggle,
    required this.onFinish,
    required this.onBegin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              Positioned.fill(
                child: _LiveMap(
                  samples: samples,
                  isRecording: isRecording,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.ink.withValues(alpha: 0),
                          AppColors.ink,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: _TopBar(state: state, onClose: onClose),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: SafeArea(
            top: false,
            child: _BottomPanel(
              recorder: recorder,
              state: state,
              starting: starting,
              onPauseToggle: onPauseToggle,
              onFinish: onFinish,
              onBegin: onBegin,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoMapLayout extends StatelessWidget {
  final RecordingState? state;
  final RunRecorder? recorder;
  final bool starting;
  final VoidCallback onClose;
  final VoidCallback onPauseToggle;
  final VoidCallback onFinish;
  final VoidCallback onBegin;

  const _NoMapLayout({
    required this.state,
    required this.recorder,
    required this.starting,
    required this.onClose,
    required this.onPauseToggle,
    required this.onFinish,
    required this.onBegin,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TopBar(state: state, onClose: onClose),
          Expanded(
            child: _BottomPanel(
              recorder: recorder,
              state: state,
              starting: starting,
              onPauseToggle: onPauseToggle,
              onFinish: onFinish,
              onBegin: onBegin,
              extraDistanceSize: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live map view that pans to follow the user as samples come in.
/// Renders the route as a polyline and a marker at the latest position.
class _LiveMap extends StatefulWidget {
  final List<RunSample> samples;
  final bool isRecording;
  const _LiveMap({required this.samples, required this.isRecording});

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap> {
  final MapController _controller = MapController();
  static const double _zoom = 16.5;
  static const double _recenterThresholdM = 10;
  static const Duration _recenterMaxInterval = Duration(seconds: 5);

  bool _initialCentered = false;
  LatLng? _lastCenteredAt;
  DateTime? _lastCenteredTime;

  @override
  void didUpdateWidget(_LiveMap old) {
    super.didUpdateWidget(old);
    final samples = widget.samples;
    if (samples.isEmpty) return;
    final last = samples.last;
    final target = LatLng(last.lat, last.lon);

    if (_initialCentered) {
      // Skip a recenter if the camera is already close to the user and
      // we centered recently — saves CPU and tile fetches on tiny GPS jitter.
      final lastCenter = _lastCenteredAt;
      final lastTime = _lastCenteredTime;
      if (lastCenter != null && lastTime != null) {
        final movedM = haversineMeters(
          lastCenter.latitude, lastCenter.longitude,
          target.latitude, target.longitude,
        );
        final elapsed = DateTime.now().difference(lastTime);
        if (movedM < _recenterThresholdM && elapsed < _recenterMaxInterval) {
          return;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (!_initialCentered) {
          _controller.move(target, _zoom);
          _initialCentered = true;
        } else {
          _controller.move(target, _controller.camera.zoom);
        }
        _lastCenteredAt = target;
        _lastCenteredTime = DateTime.now();
      } catch (_) {
        // Controller not yet attached; ignore until next tick.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.samples
        .map((s) => LatLng(s.lat, s.lon))
        .toList(growable: false);
    final initial = points.isEmpty ? const LatLng(14.5995, 120.9842) : points.first;

    return Stack(
      children: [
        // Dark backdrop so the unloaded-tile area never flashes white.
        Positioned.fill(child: Container(color: AppColors.shade)),
        Positioned.fill(
          child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: _zoom,
              minZoom: 12,
              maxZoom: 19,
              backgroundColor: AppColors.shade,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jvcerezo.daloy',
                tileProvider: CachedTileProvider(),
              ),
              if (points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 6,
                      color: AppColors.pulse,
                      borderColor: AppColors.ink,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (points.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: points.last,
                      width: 28,
                      height: 28,
                      child: _LocationDot(animated: widget.isRecording),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (points.isEmpty) const _AcquiringOverlay(),
      ],
    );
  }
}

class _LocationDot extends StatelessWidget {
  final bool animated;
  const _LocationDot({required this.animated});

  @override
  Widget build(BuildContext context) {
    final halo = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.pulse.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        if (animated)
          halo.animate(onPlay: (c) => c.repeat()).scaleXY(
                begin: 0.6,
                end: 1.6,
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOut,
              ).fadeOut(
                begin: 0.7,
                duration: const Duration(milliseconds: 1400),
              ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.pulse,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 2),
          ),
        ),
      ],
    );
  }
}

class _AcquiringOverlay extends StatelessWidget {
  const _AcquiringOverlay();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.shade,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.pulse,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Acquiring GPS...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.fog,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom panel: target capsule, distance hero, target progress, stats,
/// pause + finish controls.
class _BottomPanel extends ConsumerWidget {
  final RunRecorder? recorder;
  final RecordingState? state;
  final bool starting;
  final VoidCallback onPauseToggle;
  final VoidCallback onFinish;
  final VoidCallback onBegin;
  final bool extraDistanceSize;

  const _BottomPanel({
    required this.recorder,
    required this.state,
    required this.starting,
    required this.onPauseToggle,
    required this.onFinish,
    required this.onBegin,
    this.extraDistanceSize = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todaySessionProvider);
    final session = today.maybeWhen(data: (s) => s, orElse: () => null);
    final currentKm = (recorder?.distanceM ?? 0) / 1000.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              if (session != null && session.type != SessionType.rest)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _TargetBanner(session: session),
                ),
              SectionLabel('Distance', color: AppColors.fog),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: extraDistanceSize ? 120 : 84,
                    fontWeight: FontWeight.w900,
                    letterSpacing: extraDistanceSize ? -4 : -3,
                    height: 0.95,
                    color: AppColors.bone,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  text: currentKm.toStringAsFixed(2),
                  children: [
                    TextSpan(
                      text: ' km',
                      style: TextStyle(
                        fontSize: extraDistanceSize ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.fog,
                      ),
                    ),
                  ],
                ),
              ),
              if (session != null && session.type != SessionType.rest)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: _TargetProgress(
                    session: session,
                    currentKm: currentKm,
                  ),
                ),
            ],
          ),
          _BottomStats(recorder: recorder, session: session),
          _Controls(
            state: state,
            starting: starting,
            onPauseToggle: onPauseToggle,
            onFinish: onFinish,
            onBegin: onBegin,
          ),
        ],
      ),
    );
  }
}
