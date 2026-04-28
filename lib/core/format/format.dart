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

/// "Morning", "Afternoon", "Evening", "Late night" based on local time.
String greetingFor(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return 'Morning';
  if (h >= 12 && h < 17) return 'Afternoon';
  if (h >= 17 && h < 22) return 'Evening';
  return 'Late night';
}

String shortDayName(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[weekday - 1];
}

String shortMonthName(int month) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return names[month - 1];
}

String monthDay(DateTime d) => '${shortMonthName(d.month)} ${d.day}';
