import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_data.freezed.dart';
part 'calendar_data.g.dart';

@freezed
sealed class CalendarData with _$CalendarData {
  const factory CalendarData({
    required CalendarSummary summary,
    required List<CalendarDayDto> calendar,
  }) = _CalendarData;

  factory CalendarData.fromJson(Map<String, dynamic> json) => _$CalendarDataFromJson(json);
}

@freezed
sealed class CalendarSummary with _$CalendarSummary {
  const factory CalendarSummary({
    required int totalPlannedInMonth,
    required int totalCompletedInMonth,
    required int complianceRate,
  }) = _CalendarSummary;

  factory CalendarSummary.fromJson(Map<String, dynamic> json) => _$CalendarSummaryFromJson(json);
}

@freezed
sealed class CalendarDayDto with _$CalendarDayDto {
  const factory CalendarDayDto({
    required String date,
    required int dayOfWeek,
    required bool isSpecificDay,
    required bool isCompleted,
    required bool isCanceled,
    required int sessionsCount,
    required List<int> sessionIds,
  }) = _CalendarDayDto;

  factory CalendarDayDto.fromJson(Map<String, dynamic> json) => _$CalendarDayDtoFromJson(json);
}
