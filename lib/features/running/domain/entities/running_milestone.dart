import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class RunningMilestoneDefinition {
  const RunningMilestoneDefinition({
    required this.key,
    required this.triggerMetric,
    required this.threshold,
  });

  final RunningMilestoneKey key;
  final WorkoutMetric triggerMetric;
  final double threshold;

  bool isReached(RunningMetrics metrics) {
    return switch (triggerMetric) {
      WorkoutMetric.distance => metrics.distanceMeters >= threshold,
      WorkoutMetric.time => metrics.durationSeconds >= threshold,
      _ => throw StateError('Unsupported running milestone trigger metric: $triggerMetric'),
    };
  }
}

const runningMilestoneDefinitions = <RunningMilestoneDefinition>[
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.oneMile,
    triggerMetric: WorkoutMetric.distance,
    threshold: 1609.344,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.threeKm,
    triggerMetric: WorkoutMetric.distance,
    threshold: 3000,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.fiveKm,
    triggerMetric: WorkoutMetric.distance,
    threshold: 5000,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.fiveMiles,
    triggerMetric: WorkoutMetric.distance,
    threshold: 8046.72,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.tenKm,
    triggerMetric: WorkoutMetric.distance,
    threshold: 10000,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.fifteenKm,
    triggerMetric: WorkoutMetric.distance,
    threshold: 15000,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.halfMarathon,
    triggerMetric: WorkoutMetric.distance,
    threshold: 21097.5,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.marathon,
    triggerMetric: WorkoutMetric.distance,
    threshold: 42195,
  ),
  RunningMilestoneDefinition(
    key: RunningMilestoneKey.cooperTest,
    triggerMetric: WorkoutMetric.time,
    threshold: 720,
  ),
];

class RunningMilestonePayload {
  const RunningMilestonePayload({
    required this.runningSetId,
    required this.exerciseId,
    required this.workoutSessionId,
    required this.exerciseSessionId,
    required this.durationSec,
    required this.distanceM,
    required this.milestoneKey,
  });

  final int runningSetId;
  final int exerciseId;
  final int workoutSessionId;
  final int exerciseSessionId;
  final int durationSec;
  final double distanceM;
  final RunningMilestoneKey milestoneKey;
}

class PendingRunningMilestone {
  const PendingRunningMilestone({
    required this.id,
    required this.payload,
  });

  final int id;
  final RunningMilestonePayload payload;
}
