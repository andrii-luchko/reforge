import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_candidate_repository.dart';
import 'package:reforge/features/running/domain/services/running_milestone_tracker.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  test('catalog uses typed WorkoutMetric triggers and exact backend thresholds', () {
    expect(
      runningMilestoneDefinitions.map((definition) => definition.triggerMetric).toSet(),
      {WorkoutMetric.distance, WorkoutMetric.time},
    );
    expect(
      {
        for (final definition in runningMilestoneDefinitions) definition.key.apiValue: definition.threshold,
      },
      {
        '1mile': 1609.344,
        '3km': 3000,
        '5km': 5000,
        '5mile': 8046.72,
        '10km': 10000,
        '15km': 15000,
        'halfMarathon': 21097.5,
        'marathon': 42195,
        'cooperTest': 720,
      },
    );
  });

  test('persists every crossed key once with the first actual snapshot values', () async {
    final repository = _FakeCandidateRepository();
    final tracker = RunningMilestoneTracker(repository);
    await tracker.startLap(
      runningSetId: 7,
      exerciseId: 4,
      workoutSessionId: 42,
      exerciseSessionId: 101,
    );

    tracker
      ..track(_metrics(distanceM: 8100, durationSec: 721))
      ..track(_metrics(distanceM: 9000, durationSec: 800));
    await tracker.flushLap();

    expect(
      repository.inserted.map((candidate) => candidate.milestoneKey).toSet(),
      {
        RunningMilestoneKey.oneMile,
        RunningMilestoneKey.threeKm,
        RunningMilestoneKey.fiveKm,
        RunningMilestoneKey.fiveMiles,
        RunningMilestoneKey.cooperTest,
      },
    );
    expect(repository.inserted, everyElement(isA<RunningMilestonePayload>()));
    expect(repository.inserted.map((candidate) => candidate.distanceM), everyElement(8100));
    expect(repository.inserted.map((candidate) => candidate.durationSec), everyElement(721));
  });

  test('restore skips recorded keys and evaluates the persisted initial snapshot', () async {
    final repository = _FakeCandidateRepository()..recordedKeys[8] = {RunningMilestoneKey.oneMile};
    final tracker = RunningMilestoneTracker(repository);

    await tracker.startLap(
      runningSetId: 8,
      exerciseId: 4,
      workoutSessionId: 42,
      exerciseSessionId: 101,
      initialMetrics: _metrics(distanceM: 3100, durationSec: 500),
    );
    await tracker.flushLap();

    expect(repository.inserted.map((candidate) => candidate.milestoneKey), [RunningMilestoneKey.threeKm]);
  });

  test('the same milestone can be recorded again in a new lap', () async {
    final repository = _FakeCandidateRepository();
    final tracker = RunningMilestoneTracker(repository);

    await tracker.startLap(
      runningSetId: 1,
      exerciseId: 4,
      workoutSessionId: 42,
      exerciseSessionId: 101,
    );
    tracker.track(_metrics(distanceM: 1700, durationSec: 500));
    await tracker.startLap(
      runningSetId: 2,
      exerciseId: 4,
      workoutSessionId: 42,
      exerciseSessionId: 101,
    );
    tracker.track(_metrics(distanceM: 1700, durationSec: 480));
    await tracker.flushLap();

    final oneMile = repository.inserted.where(
      (candidate) => candidate.milestoneKey == RunningMilestoneKey.oneMile,
    );
    expect(oneMile.map((candidate) => candidate.runningSetId), [1, 2]);
  });
}

RunningMetrics _metrics({required double distanceM, required int durationSec}) {
  return RunningMetrics(
    distanceMeters: distanceM,
    durationSeconds: durationSec,
    avgSpeedKmH: 10,
    currentSpeedKmH: 10,
    avgPaceMinKm: 6,
    currentPaceMinKm: 6,
    stepCount: 0,
  );
}

class _FakeCandidateRepository implements RunningMilestoneCandidateRepository {
  final Map<int, Set<RunningMilestoneKey>> recordedKeys = {};
  final List<RunningMilestonePayload> inserted = [];

  @override
  Future<Set<RunningMilestoneKey>> getRecordedKeys(int runningSetId) async {
    return {...?recordedKeys[runningSetId]};
  }

  @override
  Future<void> insertCandidates(List<RunningMilestonePayload> candidates) async {
    inserted.addAll(candidates);
    for (final candidate in candidates) {
      recordedKeys.putIfAbsent(candidate.runningSetId, () => {}).add(candidate.milestoneKey);
    }
  }

  @override
  Future<bool> claimAttempt(int candidateId) => throw UnimplementedError();

  @override
  Future<List<PendingRunningMilestone>> getPendingCandidates(int workoutSessionId) => throw UnimplementedError();

  @override
  Stream<List<PendingRunningMilestone>> watchPendingCandidates(int workoutSessionId) => throw UnimplementedError();
}
