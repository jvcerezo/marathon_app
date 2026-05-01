import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the Daloy brand logo. Two source assets back this widget:
///
///   - `daloy-logo.svg` — original with the white background plate.
///     Used as the canonical brand asset (e.g. press kits, splash).
///   - `daloy-mark.svg`  — mountain mark only, no plate. The right
///     choice when the logo is sitting on top of any non-white
///     surface or when you want to recolor it.
///
/// Pass `color` to recolor the mark. Pass `withPlate: true` only when
/// the white background is part of the rendering you want.
class DaloyLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool withPlate;

  const DaloyLogo({
    super.key,
    this.size = 48,
    this.color,
    this.withPlate = false,
  });

  @override
  Widget build(BuildContext context) {
    final asset = withPlate
        ? 'assets/branding/daloy-logo.svg'
        : 'assets/branding/daloy-mark.svg';
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
