import 'package:flutter/material.dart';

/// Massive display number paired with an optional unit suffix.
/// Use for the centerpiece of a screen — distance during a run, days
/// remaining, predicted time.
class HeroNumber extends StatelessWidget {
  final String value;
  final String? unit;
  final double size;
  final Color? color;
  final TextAlign align;

  const HeroNumber(
    this.value, {
    super.key,
    this.unit,
    this.size = 96,
    this.color,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurface;
    return RichText(
      textAlign: align,
      text: TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: -size * 0.03,
          height: 0.95,
          color: c,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        text: value,
        children: unit == null
            ? null
            : [
                TextSpan(
                  text: '  ${unit!}',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: c.withValues(alpha: 0.55),
                  ),
                ),
              ],
      ),
    );
  }
}
