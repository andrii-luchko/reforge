import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/exercise_session/data/models/complete_set_request.dart';
import 'package:reforge/features/exercise_session/data/models/swap_exercise_search_item_dto.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/data/repositories/exercise_session_repository.dart';
import 'package:reforge/features/exercise_session/data/requests/create_workout_exercise_session_request.dart';
import 'package:reforge/features/exercise_session/data/requests/swap_exercise_request.dart';
import 'package:reforge/features/exercise_session/data/requests/swap_exercise_search_request.dart';
import 'package:reforge/features/exercise_session/data/responses/swap_exercise_search_response.dart';
import 'package:reforge/features/exercise_session/domain/entities/completed_set_identity.dart';
import 'package:reforge/features/exercise_session/domain/exceptions/set_idempotency_conflict_exception.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient apiClient;
  late ExerciseSessionRepositoryImpl repository;

  setUp(() {
    apiClient = _MockApiClient();
    repository = ExerciseSessionRepositoryImpl(apiClient);
  });

  group('ExerciseSessionRepositoryImpl', () {
    test('creates a workout exercise session and maps its response', () async {
      const request = CreateWorkoutExerciseSessionRequest(
        exerciseId: 33,
        workoutSessionId: 169,
        workoutProgramExerciseId: 100,
      );
      when(
        () => apiClient.createWorkoutExerciseSession(request),
      ).thenAnswer(
        (_) async => const BaseResponse(
          data: WorkoutExerciseSessionDTO(
            id: 222,
            exerciseId: 33,
            workoutSessionId: 169,
            workoutProgramExerciseId: 100,
          ),
          status: 'success',
        ),
      );

      final result = await repository.createWorkoutExerciseSession(
        exerciseId: 33,
        workoutSessionId: 169,
        workoutProgramExerciseId: 100,
        system: MeasurementSystem.metric,
      );

      expect(result.isSuccess, isTrue);
      expect(result.orNull?.id, 222);
      expect(result.orNull?.exerciseId, 33);
      expect(result.orNull?.isSwapped, isFalse);
      verify(() => apiClient.createWorkoutExerciseSession(request)).called(1);
    });

    test('creates and maps an unbound ad-hoc exercise session', () async {
      final request = CreateWorkoutExerciseSessionRequest.adHoc(
        exerciseId: 4,
        workoutSessionId: 182,
      );
      when(() => apiClient.createWorkoutExerciseSession(request)).thenAnswer(
        (_) async => const BaseResponse(
          data: WorkoutExerciseSessionDTO(
            id: 246,
            exerciseId: 4,
            workoutSessionId: 182,
          ),
          status: 'success',
        ),
      );

      final result = await repository.createWorkoutExerciseSession(
        exerciseId: 4,
        workoutSessionId: 182,
        system: MeasurementSystem.metric,
      );

      expect(result.isSuccess, isTrue);
      expect(result.orNull?.id, 246);
      expect(result.orNull?.workoutProgramExerciseId, isNull);
      verify(() => apiClient.createWorkoutExerciseSession(request)).called(1);
    });

    test('returns server and client identities from create-set response', () async {
      const clientSetId = '019893a2-7078-76f9-8e8f-bf8e3b16bf93';
      final set = WorkoutSet(
        id: 1,
        clientSetId: clientSetId,
        time: const Duration(seconds: 60),
        distance: 1,
      );
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: set,
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );
      when(() => apiClient.completeSet(request)).thenAnswer(
        (_) async => const BaseResponse(
          data: ExerciseSetDTO(
            id: 368,
            exerciseId: 4,
            exerciseSessionId: 246,
            clientSetId: clientSetId,
            durationSec: 60,
            distanceM: 1000,
          ),
          status: 'success',
        ),
      );

      final result = await repository.completeSet(
        set: set,
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );

      expect(result.isSuccess, isTrue);
      expect(result.orNull?.remoteSetId, 368);
      expect(result.orNull?.clientSetId, clientSetId);
      verify(() => apiClient.completeSet(request)).called(1);
    });

    test('treats omitted and zero running speed as the same payload', () async {
      const clientSetId = '019893a2-7078-76f9-8e8f-bf8e3b16bf94';
      final set = WorkoutSet(
        id: 1,
        clientSetId: clientSetId,
        time: const Duration(seconds: 2),
        distance: 0,
        speed: 0,
        pace: 0,
      );
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: set,
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );
      when(() => apiClient.completeSet(request)).thenAnswer(
        (_) async => const BaseResponse(
          data: ExerciseSetDTO(
            id: 369,
            exerciseId: 4,
            exerciseSessionId: 246,
            clientSetId: clientSetId,
            durationSec: 2,
            distanceM: 0,
            speedKmH: 0,
          ),
          status: 'success',
        ),
      );

      final result = await repository.completeSet(
        set: set,
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );

      expect(request.speedKmH, isNull);
      expect(result.isSuccess, isTrue);
      expect(result.orNull?.remoteSetId, 369);
    });

    test('rejects a successful duplicate response with a different immutable payload', () async {
      const clientSetId = '019893a2-7078-76f9-8e8f-bf8e3b16bf93';
      final set = WorkoutSet(
        id: 1,
        clientSetId: clientSetId,
        time: const Duration(seconds: 60),
        distance: 1,
      );
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: set,
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );
      when(() => apiClient.completeSet(request)).thenAnswer(
        (_) async => const BaseResponse(
          data: ExerciseSetDTO(
            id: 368,
            exerciseId: 4,
            exerciseSessionId: 246,
            clientSetId: clientSetId,
            durationSec: 61,
            distanceM: 1000,
          ),
          status: 'success',
        ),
      );

      final result = await repository.completeSet(
        set: set,
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );

      expect(result.isError, isTrue);
      expect(result, isA<Failure<CompletedSetIdentity>>());
      expect((result as Failure<CompletedSetIdentity>).error, isA<SetIdempotencyConflictException>());
    });

    test('saves notes through the exercise-session endpoint', () async {
      when(() => apiClient.saveExerciseSessionNotes(246, 'outdoor intervals')).thenAnswer((_) async {});

      final result = await repository.saveWorkoutNote(
        exerciseSessionId: 246,
        note: 'outdoor intervals',
      );

      expect(result.isSuccess, isTrue);
      verify(() => apiClient.saveExerciseSessionNotes(246, 'outdoor intervals')).called(1);
    });

    test('searches with filters and maps exercises plus pagination', () async {
      const request = SwapExerciseSearchRequest(
        search: 'run',
        factionId: 3,
        page: 2,
        limit: 10,
      );
      when(
        () => apiClient.searchSwapExercises(request),
      ).thenAnswer(
        (_) async => const SwapExerciseSearchResponse(
          data: [
            SwapExerciseSearchItemDTO(
              id: 14,
              name: '1km Run',
              description: 'Fixed distance sprint or time trial.',
              faction: ExerciseFactionDTO(id: 3, name: 'Running', slug: 'gyohyo'),
              metrics: ['durationSec'],
            ),
          ],
          meta: MetaData(
            pagination: PaginationInfo(page: 2, total: 45, limit: 10, pages: 5),
          ),
          status: 'success',
        ),
      );

      final result = await repository.searchSwapExercises(
        search: 'run',
        factionId: 3,
        page: 2,
        limit: 10,
      );

      expect(result.isSuccess, isTrue);
      final page = result.orNull!;
      expect(page.exercises.single.id, 14);
      expect(page.exercises.single.isRunningSwapCandidate, isTrue);
      expect(page.pagination.page, 2);
      expect(page.pagination.total, 45);
      expect(page.pagination.pages, 5);
      verify(() => apiClient.searchSwapExercises(request)).called(1);
    });

    test('swaps through the current session id and maps the PATCH response', () async {
      const request = SwapExerciseRequest(swappedExerciseId: 14);
      when(
        () => apiClient.swapWorkoutExercise(228, request),
      ).thenAnswer(
        (_) async => const BaseResponse(
          data: WorkoutExerciseSessionDTO(
            id: 228,
            exerciseId: 33,
            workoutSessionId: 172,
            workoutProgramExerciseId: 100,
            isSwapped: true,
            swappedExerciseId: 14,
            notes: 'keep me',
          ),
          status: 'success',
        ),
      );

      final result = await repository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 14,
        system: MeasurementSystem.metric,
      );

      expect(result.isSuccess, isTrue);
      expect(result.orNull?.id, 228);
      expect(result.orNull?.swappedExerciseId, 14);
      expect(result.orNull?.notes, 'keep me');
      verify(() => apiClient.swapWorkoutExercise(228, request)).called(1);
    });

    test('keeps API exceptions in the Result error channel', () async {
      const request = CreateWorkoutExerciseSessionRequest(
        exerciseId: 33,
        workoutSessionId: 169,
        workoutProgramExerciseId: 100,
      );
      when(
        () => apiClient.createWorkoutExerciseSession(request),
      ).thenThrow(Exception('create failed'));

      final result = await repository.createWorkoutExerciseSession(
        exerciseId: 33,
        workoutSessionId: 169,
        workoutProgramExerciseId: 100,
        system: MeasurementSystem.metric,
      );

      expect(result.isError, isTrue);
      expect(result.orNull, isNull);
    });
  });
}
