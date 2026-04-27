String formatPace(double? secPerKm) {
  if (secPerKm == null || secPerKm <= 0) return '--:--';
  final mins = secPerKm ~/ 60;
  final secs = (secPerKm - mins * 60).round();
  return '$mins:${secs.toString().padLeft(2, '0')}/km';
}

String formatDistanceKm(double km, {int decimals = 2}) =>
    '${km.toStringAsFixed(decimals)} km';

String formatDistanceM(double meters, {int decimals = 2}) =>
    formatDistanceKm(meters / 1000.0, decimals: decimals);

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String formatDurationSec(int seconds) =>
    formatDuration(Duration(seconds: seconds));
