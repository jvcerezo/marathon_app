import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the Daloy wordmark (custom DALOY type).
///
/// Two source assets back this widget:
///   - `daloy-wordmark.svg` — original with the off-white plate; use
///     when the wordmark sits on its own (press kits, splash, etc.).
///   - `daloy-wordmark-mark.svg` — paths only, no plate, with the "O"
///     counter rendered via fill-rule="evenodd" so it's a real hole.
///     Use this when overlaying a photo or recoloring.
///
/// Provide a [height] (the natural aspect is ~3.6:1, so width is
/// inferred). Pass [color] to recolor the strokes.
class DaloyWordmark extends StatelessWidget {
  final double height;
  final Color? color;
  final bool withPlate;

  const DaloyWordmark({
    super.key,
    this.height = 24,
    this.color,
    this.withPlate = false,
  });

  @override
  Widget build(BuildContext context) {
    final asset = withPlate
        ? 'assets/branding/daloy-wordmark.svg'
        : 'assets/branding/daloy-wordmark-mark.svg';
    return SvgPicture.asset(
      asset,
      height: height,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
