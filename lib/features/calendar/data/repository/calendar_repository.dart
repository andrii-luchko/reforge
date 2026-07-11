import 'package:injectable/injectable.dart';

import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/calendar/data/datasources/workout_details_local_datasource.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';

abstract interface class CalendarRepository {
  Future<Result<CalendarEntity>> getMonthCalendarData(DateTime month);

  Future<Result<TrainingDetailsEntity?>> getWorkoutDetails(
    int sessionId, {
    bool forceRefresh = false,
  });
}

@Injectable(as: CalendarRepository)
class CalendarRepositoryImpl with RepositoryErrorHandler implements CalendarRepository {
  CalendarRepositoryImpl(
    this._apiClient,
    this._userSessionService,
    this._localDataSource,
  );

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final WorkoutDetailsLocalDataSource _localDataSource;

  @override
  Future<Result<CalendarEntity>> getMonthCalendarData(DateTime month) async {
    try {
      final validMonth = month.toYearMonth();
      final response = await makeRequest(
        () => _apiClient.geMonthCalendar(month: validMonth),
        label: 'getMonthCalendarData',
      );
      return Result.success(CalendarEntity.fromDto(response.data));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<TrainingDetailsEntity?>> getWorkoutDetails(
    int sessionId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _localDataSource.get(sessionId);
      if (cached != null) return Result.success(cached);
    }

    try {
      final system =
          _userSessionService.currentUser?.map(
            newUser: (_) => null,
            onboarded: (u) => u.measurementSystem,
          ) ??
          MeasurementSystem.metric;

      final response = await makeRequest(
        () => _apiClient.getWorkoutDetails(sessionId),
        label: 'getWorkoutDetails',
      );
      final entity = response.data?.toEntity(system);

      _localDataSource.put(sessionId, entity);

      return Result.success(entity);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
