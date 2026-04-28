import 'package:flutter/material.dart';

import '../tokens.dart';

/// Flat surface with a 1px outline. Used as a card alternative when we want
/// even less visual weight than a filled card.
class BorderedSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  const BorderedSurface({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.radius = AppRadius.lg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radiusGeo = BorderRadius.circular(radius);
    return Material(
      color: color ?? cs.surfaceContainerLow,
      borderRadius: radiusGeo,
      child: InkWell(
        onTap: onTap,
        borderRadius: radiusGeo,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radiusGeo,
            border: Border.all(
              color: borderColor ?? cs.outlineVariant,
              width: 1,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
