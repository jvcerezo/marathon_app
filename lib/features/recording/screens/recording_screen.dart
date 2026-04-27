import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/format.dart';
import '../../../core/providers/providers.dart';
import '../../plan/models/plan_session.dart';
import '../providers/recording_providers.dart';
import '../pipeline/run_recorder.dart';
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
        : 'Session ${_statusLabel(match.status)}!';
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
    ref.watch(recordingTickProvider); // tick for live UI refresh
    final svc = ref.watch(recordingServiceProvider);
    final recorder = svc.recorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            if (svc.state != RecordingState.idle) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Discard run?'),
                  content: const Text(
                    'Stop recording without saving this run?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(false),
                      child: const Text('Keep recording'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(c).pop(true),
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              await svc.stop();
            }
            if (mounted) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => _error = null);
                          _start();
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _StateBanner(state: stateAsync.value),
                    const Spacer(),
                    _BigStat(
                      value: recorder == null
                          ? '0.00'
                          : (recorder.distanceM / 1000.0).toStringAsFixed(2),
                      label: 'kilometers',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallStat(
                            value: recorder == null
                                ? '00:00'
                                : formatDuration(recorder.elapsed),
                            label: 'time',
                          ),
                        ),
                        Expanded(
                          child: _SmallStat(
                            value: _avgPace(recorder),
                            label: 'pace',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(stateAsync.value == RecordingState.paused
                                ? Icons.play_arrow
                                : Icons.pause),
                            label: Text(stateAsync.value == RecordingState.paused
                                ? 'Resume'
                                : 'Pause'),
                            onPressed: _starting
                                ? null
                                : () {
                                    if (stateAsync.value ==
                                        RecordingState.paused) {
                                      svc.resume();
                                    } else {
                                      svc.pause();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.stop),
                            label: const Text('Finish'),
                            onPressed: _starting ? null : _stop,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _avgPace(RunRecorder? recorder) {
    if (recorder == null || recorder.distanceM < 50) return '--:--';
    final paceSecPerKm =
        recorder.elapsed.inSeconds / (recorder.distanceM / 1000.0);
    return formatPace(paceSecPerKm);
  }
}

class _StateBanner extends StatelessWidget {
  final RecordingState? state;
  const _StateBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      RecordingState.awaitingFix => (Colors.orange, 'Acquiring GPS...'),
      RecordingState.recording => (Colors.green, 'Recording'),
      RecordingState.paused => (Colors.amber, 'Paused'),
      _ => (Colors.grey, 'Idle'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  const _BigStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 96,
                height: 1,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String value;
  final String label;
  const _SmallStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
