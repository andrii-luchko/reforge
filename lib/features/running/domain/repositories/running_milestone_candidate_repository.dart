import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';

abstract interface class RunningMilestoneCandidateRepository {
  Future<Set<RunningMilestoneKey>> getRecordedKeys(int runningSetId);

  Future<void> insertCandidates(List<RunningMilestonePayload> candidates);

  Stream<List<PendingRunningMilestone>> watchPendingCandidates(int workoutSessionId);

  Future<List<PendingRunningMilestone>> getPendingCandidates(int workoutSessionId);

  Future<bool> claimAttempt(int candidateId);
}
