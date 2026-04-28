import 'package:flutter/material.dart';

/// Uppercase, tracked label used to introduce a section. Sits above titles.
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: color ?? cs.onSurfaceVariant,
      ),
    );
  }
}
