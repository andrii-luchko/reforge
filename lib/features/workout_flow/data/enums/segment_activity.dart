enum SegmentActivity {
  run,
  walk,
  unknown;

  static SegmentActivity fromJson(String json) {
    switch (json) {
      case 'run':
        return .run;
      case 'walk':
        return .walk;

      default:
        return .unknown;
    }
  }
}

extension SegmentActivityX on SegmentActivity {
  String get title {
    switch (this) {
      case .run:
        return 'Run';
      case .walk:
        return 'Walk';
      case .unknown:
        return 'Unknown';
    }
  }
}
