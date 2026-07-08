import 'package:reforge/app/utils/formatters/second_formatter.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

extension DigitalDurationWithUnit on Duration {
  /// Converts Duration to a digital string with a descriptive highest unit:
  /// e.g. "01:05:00 hours" or "15:15 minutes" or "0:30 seconds"
  String toDigitalWithUnit(Translations t) {
    final digitalString = formatSeconds(inSeconds);

    String unitName;
    if (inHours > 0) {
      unitName = t.common.unit_hour(n: inHours);
    } else if (inMinutes > 0) {
      unitName = t.common.unit_minute(n: inMinutes);
    } else {
      unitName = t.common.unit_second(n: inSeconds);
    }

    return '$digitalString $unitName';
  }

  String toDigital() {
    return formatSeconds(inSeconds);
  }
}
