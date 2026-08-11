enum RunningMilestoneKey {
  oneMile('1mile'),
  threeKm('3km'),
  fiveKm('5km'),
  fiveMiles('5mile'),
  tenKm('10km'),
  fifteenKm('15km'),
  halfMarathon('halfMarathon'),
  marathon('marathon'),
  cooperTest('cooperTest');

  const RunningMilestoneKey(this.apiValue);

  final String apiValue;

  static RunningMilestoneKey fromApiValue(String value) {
    return values.firstWhere(
      (key) => key.apiValue == value,
      orElse: () => throw ArgumentError.value(value, 'value', 'Unsupported running milestone key'),
    );
  }
}
