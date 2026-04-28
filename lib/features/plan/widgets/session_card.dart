import 'package:flutter/material.dart';

import '../../../core/design/tokens.dart';
import '../../../core/format/format.dart';
import '../models/plan_session.dart';
import 'session_type_style.dart';

/// Big session card. Used everywhere session detail is shown — Plan day
/// view, Plan week list, Progress day view.
class SessionCard extends StatelessWidget {
  final PlanSession session;
  final bool isToday;
  final bool dense;

  const SessionCard({
    super.key,
    required this.session,
    this.isToday = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = styleFor(session.type);
    final isRest = session.type == SessionType.rest;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: dense ? AppSpacing.md : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isToday
            ? style.color.withValues(alpha: 0.10)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isToday ? style.color : cs.outlineVariant,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          _IconBadge(style: style, isRest: isRest, dense: dense),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      shortDayName(session.scheduledDate.weekday).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: style.color,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: style.color == Colors.white
                                ? Colors.black
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isRest
                      ? 'Rest day'
                      : '${session.type.label} · '
                          '${formatDistanceKm(session.prescribedDistanceKm, decimals: 1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (!isRest && session.prescribedPaceSecPerKm != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'at ${formatPace(session.prescribedPaceSecPerKm)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _StatusGlyph(status: session.status),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final SessionStyle style;
  final bool isRest;
  final bool dense;

  const _IconBadge({
    required this.style,
    required this.isRest,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    final size = dense ? 40.0 : 48.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        style.icon,
        color: style.color,
        size: size * 0.55,
      ),
    );
  }
}

class _StatusGlyph extends StatelessWidget {
  final SessionStatus status;
  const _StatusGlyph({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = switch (status) {
      SessionStatus.hit => (Icons.check_circle_rounded, AppColors.pulse),
      SessionStatus.partial => (Icons.adjust_rounded, AppColors.warn),
      SessionStatus.missed => (Icons.cancel_rounded, AppColors.miss),
      _ => (null as IconData?, cs.onSurfaceVariant),
    };
    if (icon == null) return const SizedBox.shrink();
    return Icon(icon, color: color, size: 22);
  }
}
