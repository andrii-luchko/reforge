import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_candidate_repository.dart';

class RunningMilestoneTracker {
  RunningMilestoneTracker(this._repository);

  final RunningMilestoneCandidateRepository _repository;

  int? _runningSetId;
  int? _exerciseId;
  int? _workoutSessionId;
  int? _exerciseSessionId;
  Set<RunningMilestoneKey> _recordedKeys = {};
  Future<void> _writeQueue = Future.value();

  Future<void> startLap({
    required int runningSetId,
    required int exerciseId,
    required int workoutSessionId,
    required int exerciseSessionId,
    RunningMetrics? initialMetrics,
  }) async {
    await flushLap();
    _runningSetId = runningSetId;
    _exerciseId = exerciseId;
    _workoutSessionId = workoutSessionId;
    _exerciseSessionId = exerciseSessionId;
    try {
      _recordedKeys = await _repository.getRecordedKeys(runningSetId);
    } on Exception catch (error, stackTrace) {
      _recordedKeys = {};
      logger.w('RunningMilestoneTracker: failed to restore recorded keys', error, stackTrace);
    }
    if (initialMetrics != null) track(initialMetrics);
  }

  void track(RunningMetrics metrics) {
    final runningSetId = _runningSetId;
    final exerciseId = _exerciseId;
    final workoutSessionId = _workoutSessionId;
    final exerciseSessionId = _exerciseSessionId;
    if (runningSetId == null || exerciseId == null || workoutSessionId == null || exerciseSessionId == null) return;

    final reached = runningMilestoneDefinitions
        .where((definition) => !_recordedKeys.contains(definition.key) && definition.isReached(metrics))
        .toList(growable: false);
    if (reached.isEmpty) return;

    final keys = reached.map((definition) => definition.key).toSet();
    _recordedKeys.addAll(keys);
    final candidates = reached
        .map(
          (definition) => RunningMilestonePayload(
            runningSetId: runningSetId,
            exerciseId: exerciseId,
            workoutSessionId: workoutSessionId,
            exerciseSessionId: exerciseSessionId,
            durationSec: metrics.durationSeconds,
            distanceM: metrics.distanceMeters,
            milestoneKey: definition.key,
          ),
        )
        .toList(growable: false);

    _writeQueue = _writeQueue.then((_) async {
      try {
        await _repository.insertCandidates(candidates);
      } on Exception catch (error, stackTrace) {
        _recordedKeys.removeAll(keys);
        logger.w('RunningMilestoneTracker: failed to persist candidates', error, stackTrace);
      }
    });
  }

  Future<void> flushLap() => _writeQueue;

  Future<void> clear() async {
    await flushLap();
    _runningSetId = null;
    _exerciseId = null;
    _workoutSessionId = null;
    _exerciseSessionId = null;
    _recordedKeys = {};
  }
}
