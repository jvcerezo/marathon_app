import 'package:flutter/material.dart';

import 'section_label.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;
  final TextAlign align;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxis = switch (align) {
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.end || TextAlign.right => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: crossAxis,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        RichText(
          textAlign: align,
          text: TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: valueColor ?? cs.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            text: value,
            children: unit == null
                ? null
                : [
                    TextSpan(
                      text: ' ${unit!}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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

class StatRow extends StatelessWidget {
  final List<StatTile> tiles;
  const StatRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final children = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      children.add(Expanded(child: tiles[i]));
      if (i < tiles.length - 1) {
        children.add(
          Container(
            width: 1,
            height: 36,
            color: cs.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
