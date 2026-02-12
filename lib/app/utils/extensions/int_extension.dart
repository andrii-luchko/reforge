extension IntExtension on int {
  ({int hours, int minutes}) get durationFormatted {
    final duration = Duration(seconds: this);
    return (
      hours: duration.inHours,
      minutes: duration.inMinutes.remainder(60),
    );
  }
}
