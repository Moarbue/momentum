String formatDuration(int seconds) {
  if (seconds < 0) return "0s";

  int h = seconds ~/ 3600;
  int m = (seconds % 3600) ~/ 60;
  int s = seconds % 60;

  List<String> parts = [];
  if (h > 0) parts.add('${h}h');
  if (m > 0) parts.add('${m}m');
  if (s > 0 || parts.isEmpty) parts.add('${s}s');

  return parts.join(' ');
}
