import 'package:drift/drift.dart' as drift;
import 'package:injectable/injectable.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_candidate_status.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_candidate_repository.dart';

@LazySingleton(as: RunningMilestoneCandidateRepository)
class RunningMilestoneCandidateRepositoryImpl implements RunningMilestoneCandidateRepository {
  RunningMilestoneCandidateRepositoryImpl(this._db);

  final WorkoutDatabase _db;

  @override
  Future<Set<RunningMilestoneKey>> getRecordedKeys(int runningSetId) async {
    final rows = await (_db.select(
      _db.runningMilestoneCandidates,
    )..where((candidate) => candidate.runningSetId.equals(runningSetId))).get();
    return rows.map((row) => RunningMilestoneKey.fromApiValue(row.milestoneKey)).toSet();
  }

  @override
  Future<void> insertCandidates(List<RunningMilestonePayload> candidates) async {
    if (candidates.isEmpty) return;
    final now = DateTime.now().toUtc();
    await _db.batch((batch) {
      batch.insertAll(
        _db.runningMilestoneCandidates,
        candidates
            .map(
              (candidate) => RunningMilestoneCandidatesCompanion.insert(
                runningSetId: candidate.runningSetId,
                exerciseId: candidate.exerciseId,
                workoutSessionId: candidate.workoutSessionId,
                exerciseSessionId: candidate.exerciseSessionId,
                durationSec: candidate.durationSec,
                distanceM: candidate.distanceM,
                milestoneKey: candidate.milestoneKey.apiValue,
                createdAt: now,
              ),
            )
            .toList(),
        mode: drift.InsertMode.insertOrIgnore,
      );
    });
  }

  @override
  Stream<List<PendingRunningMilestone>> watchPendingCandidates(int workoutSessionId) {
    return (_db.select(_db.runningMilestoneCandidates)
          ..where(
            (candidate) =>
                candidate.workoutSessionId.equals(workoutSessionId) &
                candidate.status.equals(RunningMilestoneCandidateStatus.pending.name),
          )
          ..orderBy([(candidate) => drift.OrderingTerm.asc(candidate.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toPending).toList(growable: false));
  }

  @override
  Future<List<PendingRunningMilestone>> getPendingCandidates(int workoutSessionId) async {
    final rows =
        await (_db.select(_db.runningMilestoneCandidates)
              ..where(
                (candidate) =>
                    candidate.workoutSessionId.equals(workoutSessionId) &
                    candidate.status.equals(RunningMilestoneCandidateStatus.pending.name),
              )
              ..orderBy([(candidate) => drift.OrderingTerm.asc(candidate.createdAt)]))
            .get();
    return rows.map(_toPending).toList(growable: false);
  }

  @override
  Future<bool> claimAttempt(int candidateId) async {
    final updated =
        await (_db.update(_db.runningMilestoneCandidates)..where(
              (candidate) =>
                  candidate.id.equals(candidateId) &
                  candidate.status.equals(RunningMilestoneCandidateStatus.pending.name),
            ))
            .write(
              RunningMilestoneCandidatesCompanion(
                status: drift.Value(RunningMilestoneCandidateStatus.attempted.name),
                attemptedAt: drift.Value(DateTime.now().toUtc()),
              ),
            );
    return updated == 1;
  }

  PendingRunningMilestone _toPending(RunningMilestoneCandidate row) {
    return PendingRunningMilestone(
      id: row.id,
      payload: RunningMilestonePayload(
        runningSetId: row.runningSetId,
        exerciseId: row.exerciseId,
        workoutSessionId: row.workoutSessionId,
        exerciseSessionId: row.exerciseSessionId,
        durationSec: row.durationSec,
        distanceM: row.distanceM,
        milestoneKey: RunningMilestoneKey.fromApiValue(row.milestoneKey),
      ),
    );
  }
}
