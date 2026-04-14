String formatDuration(int seconds) {
  if (seconds < 0) return "0s";

  int h = seconds ~/ 3600;
  int m = (seconds % 3600) ~/ 60;
  int s = seconds % 60;

  if (h > 0) {
    return '${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  } else if (m > 0) {
    return '${m}:${s.toString().padLeft(2, '0')}';
  } else {
    return '${s}';
  }
}
