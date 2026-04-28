import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design/tokens.dart';
import '../models/plan_session.dart';

class SessionStyle {
  final IconData icon;
  final Color color;
  final String mascot;
  const SessionStyle(this.icon, this.color, this.mascot);
}

SessionStyle styleFor(SessionType type) => switch (type) {
      SessionType.rest => SessionStyle(
          PhosphorIconsDuotone.moonStars,
          AppColors.fog,
          '🌙',
        ),
      SessionType.easy => SessionStyle(
          PhosphorIconsDuotone.sneaker,
          AppColors.pulse,
          '👟',
        ),
      SessionType.long => SessionStyle(
          PhosphorIconsDuotone.mountains,
          AppColors.signal,
          '⛰️',
        ),
      SessionType.tempo => SessionStyle(
          PhosphorIconsDuotone.gauge,
          AppColors.warn,
          '🔥',
        ),
      SessionType.intervals => SessionStyle(
          PhosphorIconsDuotone.lightning,
          AppColors.ember,
          '⚡',
        ),
      SessionType.race => SessionStyle(
          PhosphorIconsDuotone.medal,
          AppColors.ember,
          '🏅',
        ),
    };
