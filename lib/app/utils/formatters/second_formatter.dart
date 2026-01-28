String formatSeconds(int totalSeconds, {bool alwaysShowHours = false}) {
  final isOvertime = totalSeconds < 0;
  final absSeconds = totalSeconds.abs();

  final hours = absSeconds ~/ 3600;
  final minutes = (absSeconds % 3600) ~/ 60;
  final seconds = absSeconds % 60;

  final hStr = hours.toString().padLeft(2, '0');
  final mStr = minutes.toString().padLeft(2, '0');
  final sStr = seconds.toString().padLeft(2, '0');
  final sign = isOvertime ? '+' : '';

  if (hours > 0 || alwaysShowHours) {
    return '$sign$hStr:$mStr:$sStr';
  }

  return '$sign$mStr:$sStr';
}
