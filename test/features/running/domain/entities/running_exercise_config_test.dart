import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/domain/entities/running_exercise_config.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  test('repeats a static target for the configured regular set count', () {
    final config = _config(
      target: const ExerciseRunningTarget.distance(3000),
      staticTargetSetCount: 3,
    );

    expect(config.limits, hasLength(3));
    expect(config.limits.map((limit) => limit.metric), everyElement(WorkoutMetric.distance));
    expect(config.limits.map((limit) => limit.limitValue), everyElement(3000));
    expect(config.isFreeRun, isFalse);
  });

  test('uses one static target when the configured swap count is one', () {
    final config = _config(
      target: const ExerciseRunningTarget.duration(720),
    );

    expect(config.limits, hasLength(1));
    expect(config.limits.single.metric, WorkoutMetric.time);
    expect(config.limits.single.limitValue, 720);
  });

  test('segments take precedence over a static target', () {
    final config = _config(
      target: const ExerciseRunningTarget.distance(3000),
      staticTargetSetCount: 3,
      segments: [
        ExerciseSegmentEntity(
          id: 10,
          order: 1,
          activity: SegmentActivity.walk,
          targetMetric: WorkoutMetric.time,
          distanceM: 0,
          durationSec: 60,
        ),
      ],
    );

    expect(config.limits, hasLength(1));
    expect(config.limits.single.metric, WorkoutMetric.time);
    expect(config.limits.single.limitValue, 60);
    expect(config.limits.single.segmentId, 10);
    expect(config.limits.single.activityType, SegmentActivity.walk);
  });

  test('has no limits without segments or a static target', () {
    final config = _config();

    expect(config.limits, isEmpty);
    expect(config.isFreeRun, isTrue);
  });
}

RunningExerciseConfig _config({
  ExerciseRunningTarget? target,
  int staticTargetSetCount = 1,
  List<ExerciseSegmentEntity> segments = const [],
}) {
  return RunningExerciseConfig(
    workoutSessionId: 1,
    exerciseSessionId: 10,
    workoutProgramExerciseId: 2,
    exercise: ExerciseDetailsEntity(
      id: 3,
      name: 'Run',
      description: 'Run',
      key: 'run',
      metrics: const [WorkoutMetric.time, WorkoutMetric.distance],
      poseDetectionPreset: null,
      runningTarget: target,
      isTiered: false,
      tiers: const [],
      videoInstructionUrl: null,
      thumbnailInstructionUrl: null,
      instructionsSteps: const {},
    ),
    segments: segments,
    staticTargetSetCount: staticTargetSetCount,
  );
}
