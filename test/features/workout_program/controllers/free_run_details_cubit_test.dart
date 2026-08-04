import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_program/controllers/free_run_details_cubit.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_program/domain/repositories/exercise_catalog_repository.dart';

void main() {
  test('loads Running id 4 and builds an unbound Free Run plan', () async {
    final repository = _FakeExerciseCatalogRepository();
    final cubit = FreeRunDetailsCubit(repository);

    await cubit.load();

    expect(repository.requestedIds, [4]);
    expect(cubit.state.exercise, _running);
    expect(cubit.state.executionPlan?.exercises.single.exerciseId, 4);
    expect(cubit.state.executionPlan?.exercises.single.workoutProgramExerciseId, isNull);
    expect(cubit.state.executionPlan?.exercises.single.executionKey, FreeRunDetailsCubit.executionKey);
    await cubit.close();
  });

  test('keeps a retryable error and loads Running on retry', () async {
    final repository = _FakeExerciseCatalogRepository(failFirst: true);
    final cubit = FreeRunDetailsCubit(repository);

    await cubit.load();
    expect(cubit.state.error, contains('catalog failed'));
    expect(cubit.state.isLoading, isFalse);

    await cubit.retry();
    expect(repository.requestedIds, [4, 4]);
    expect(cubit.state.executionPlan?.exercises.single.exerciseId, 4);
    await cubit.close();
  });
}

class _FakeExerciseCatalogRepository implements ExerciseCatalogRepository {
  _FakeExerciseCatalogRepository({this.failFirst = false});

  final bool failFirst;
  final List<int> requestedIds = [];

  @override
  Future<Result<ExerciseDetailsEntity>> getExercise(int exerciseId) async {
    requestedIds.add(exerciseId);
    if (failFirst && requestedIds.length == 1) {
      return Result.error(Exception('catalog failed'));
    }
    return const Result.success(_running);
  }
}

const _running = ExerciseDetailsEntity(
  id: 4,
  name: 'Running',
  description: 'Free run',
  key: 'running',
  metrics: [WorkoutMetric.time, WorkoutMetric.distance],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);
