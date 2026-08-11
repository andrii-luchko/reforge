import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/data/repositories/running_milestone_candidate_repository_impl.dart';
import 'package:reforge/features/running/data/services/running_milestone_sender.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_candidate_status.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_candidate_repository.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_repository.dart';

void main() {
  late WorkoutDatabase database;
  late RunningMilestoneCandidateRepository repository;
  late int runningSetId;

  setUpAll(() {
    registerFallbackValue(
      const RunningMilestonePayload(
        runningSetId: 0,
        exerciseId: 0,
        workoutSessionId: 0,
        exerciseSessionId: 0,
        durationSec: 0,
        distanceM: 0,
        milestoneKey: RunningMilestoneKey.oneMile,
      ),
    );
  });

  setUp(() async {
    database = WorkoutDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON;');
    await database
        .into(database.workoutSessionCache)
        .insert(
          WorkoutSessionCacheCompanion.insert(
            remoteSessionId: 42,
            startedAt: DateTime.now().toUtc(),
          ),
        );
    runningSetId = await database
        .into(database.activeRunningSets)
        .insert(
          ActiveRunningSetsCompanion.insert(
            sessionId: 42,
            exerciseSessionId: const Value(101),
            clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
            setNumber: 1,
          ),
        );
    repository = RunningMilestoneCandidateRepositoryImpl(database);
  });

  tearDown(() => database.close());

  test('deduplicates by lap and key and atomically claims the first attempt', () async {
    final candidate = _payload(runningSetId);
    await repository.insertCandidates([candidate, candidate]);

    expect(await repository.getRecordedKeys(runningSetId), {RunningMilestoneKey.oneMile});
    final pending = await repository.getPendingCandidates(42);
    expect(pending, hasLength(1));
    expect(pending.single.payload.distanceM, 1612.7);

    expect(await repository.claimAttempt(pending.single.id), true);
    expect(await repository.claimAttempt(pending.single.id), false);
    expect(await repository.getPendingCandidates(42), isEmpty);

    final stored = await database.select(database.runningMilestoneCandidates).getSingle();
    expect(stored.status, RunningMilestoneCandidateStatus.attempted.name);
    expect(stored.attemptedAt, isNotNull);
  });

  test('workout cache cleanup cascades through the lap to candidates', () async {
    await repository.insertCandidates([_payload(runningSetId)]);

    await database.delete(database.workoutSessionCache).go();

    expect(await database.select(database.activeRunningSets).get(), isEmpty);
    expect(await database.select(database.runningMilestoneCandidates).get(), isEmpty);
  });

  test('sender never retries an attempted candidate after a network failure', () async {
    final milestoneRepository = _MockRunningMilestoneRepository();
    when(() => milestoneRepository.calculateRunningMilestone(any())).thenThrow(Exception('offline'));
    await repository.insertCandidates([_payload(runningSetId)]);
    final sender = RunningMilestoneSender(repository, milestoneRepository);

    await sender.drain(42);
    await sender.stop(42);
    await sender.drain(42);

    verify(() => milestoneRepository.calculateRunningMilestone(any())).called(1);
    expect(await repository.getPendingCandidates(42), isEmpty);
    await sender.stop(42);
  });
}

RunningMilestonePayload _payload(int runningSetId) {
  return RunningMilestonePayload(
    runningSetId: runningSetId,
    exerciseId: 4,
    workoutSessionId: 42,
    exerciseSessionId: 101,
    durationSec: 560,
    distanceM: 1612.7,
    milestoneKey: RunningMilestoneKey.oneMile,
  );
}

class _MockRunningMilestoneRepository extends Mock implements RunningMilestoneRepository {}
