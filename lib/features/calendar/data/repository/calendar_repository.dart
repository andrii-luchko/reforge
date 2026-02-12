import 'package:injectable/injectable.dart';

import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';

abstract interface class CalendarRepository {
  Future<Result<CalendarEntity>> getMonthCalendarData(DateTime month);

  Future<Result<TrainingDetailsEntity>> getWorkoutDetails(int sessionId);
}

@Injectable(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._apiClient, this._userSessionService);

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
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

  @override
  Future<Result<TrainingDetailsEntity>> getWorkoutDetails(int sessionId) async {
    try {
      final system =
          _userSessionService.currentUser?.map(
            newUser: (_) => null,
            onboarded: (u) => u.measurementSystem,
          ) ??
          MeasurementSystem.metric;

      final response = await _apiClient.getWorkoutDetails(sessionId);

      logger.d(response.data);

      return Result.success(response.data.toEntity(system));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
