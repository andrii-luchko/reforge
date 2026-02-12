// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:injectable/injectable.dart';

import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';

// ignore: one_member_abstracts
abstract interface class CalendarRepository {
  Future<Result<CalendarEntity>> getMonthCalendarData(DateTime month);
}

@Injectable(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<CalendarEntity>> getMonthCalendarData(DateTime month) async {
    try {
      final validMonth = month.toYearMonth();

      final response = await _apiClient.geMonthCalendar(month: validMonth);

      return Result.success(CalendarEntity.fromDto(response.data));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
