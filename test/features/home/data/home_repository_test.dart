import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/home/data/repository/home_repository.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';

class _MockApiClient extends Mock implements ApiClient {}

DioException _dioException(int statusCode) {
  final requestOptions = RequestOptions(
    path: '/workout-sessions/results',
  );
  return DioException(
    requestOptions: requestOptions,
    response: Response<void>(
      requestOptions: requestOptions,
      statusCode: statusCode,
    ),
  );
}

void main() {
  late _MockApiClient apiClient;
  late HomeRepository repository;

  setUp(() {
    apiClient = _MockApiClient();
    repository = HomeRepositoryImpl(apiClient);
  });

  test('maps every 500 response to approved new-user stats', () async {
    when(
      () => apiClient.getUserStats(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenThrow(_dioException(500));

    final result = await repository.getUserStats(StatsPeriod.lastWeek);

    expect(result, isA<Success<UserStats>>());
    final stats = result.orNull!;
    expect(stats.level, 51);
    expect(stats.currentXp, 0);
    expect(stats.xpGoal, 1000);
    expect(stats.totalDays, 3);
  });

  test('keeps non-500 responses in the error channel', () async {
    when(
      () => apiClient.getUserStats(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenThrow(_dioException(503));

    final result = await repository.getUserStats(StatsPeriod.lastWeek);

    expect(result, isA<Failure<UserStats>>());
  });
}
