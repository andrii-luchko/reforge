import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:reforge/features/workout_session/data/requests/start_workout_session_request.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient apiClient;
  late WorkoutSessionRepositoryImpl repository;

  setUp(() {
    apiClient = _MockApiClient();
    repository = WorkoutSessionRepositoryImpl(apiClient);
  });

  test('starts an ad-hoc workout with an empty request body', () async {
    final request = StartWorkoutSessionRequest.adHoc();
    when(() => apiClient.starWorkoutSession(request)).thenAnswer(
      (_) async => const BaseResponse(
        data: WorkoutSession(
          id: 182,
          userId: 1,
          duration: 0,
          status: WorkoutSessionStatus.active,
          totalXpEarned: 0,
        ),
        status: 'success',
      ),
    );

    final result = await repository.startAdHocWorkoutSession();

    expect(request.toJson(), isEmpty);
    expect(result.isSuccess, isTrue);
    expect(result.orNull?.workoutProgramDayId, isNull);
    verify(() => apiClient.starWorkoutSession(request)).called(1);
  });

  test('keeps the program workout start payload unchanged', () async {
    final request = StartWorkoutSessionRequest.program(workoutProgramDayId: 25);
    when(() => apiClient.starWorkoutSession(request)).thenAnswer(
      (_) async => const BaseResponse(
        data: WorkoutSession(
          id: 183,
          userId: 1,
          workoutProgramDayId: 25,
          duration: 0,
          status: WorkoutSessionStatus.active,
          totalXpEarned: 0,
        ),
        status: 'success',
      ),
    );

    final result = await repository.startWorkoutSession(25);

    expect(request.toJson(), {'workoutProgramDayId': 25});
    expect(result.orNull?.workoutProgramDayId, 25);
    verify(() => apiClient.starWorkoutSession(request)).called(1);
  });
}
