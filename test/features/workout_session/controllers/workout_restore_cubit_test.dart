import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/client_id_generator.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/exercise_catalog_repository.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';
import 'package:reforge/features/workout_session/controllers/workout_restore_cubit.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/entities/cached_workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_start_intent.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

class _MockWorkoutSessionCacheRepository extends Mock implements WorkoutSessionCacheRepository {}

class _MockWorkoutSessionRepository extends Mock implements WorkoutSessionRepository {}

class _MockWorkoutProgramRepository extends Mock implements WorkoutProgramRepository {}

class _MockExerciseCatalogRepository extends Mock implements ExerciseCatalogRepository {}

class _MockLocalWorkoutSessionRepository extends Mock implements LocalWorkoutSessionRepository {}

class _MockUserSessionService extends Mock implements UserSessionService {}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockWorkoutSessionCacheRepository sessionCache;
  late _MockWorkoutSessionRepository sessionRepository;
  late _MockWorkoutProgramRepository programRepository;
  late _MockExerciseCatalogRepository exerciseCatalogRepository;
  late _MockLocalWorkoutSessionRepository localWorkoutRepository;
  late _MockUserSessionService userSessionService;
  late _MockExerciseSessionRepository exerciseSessionRepository;
  late _MockAnalyticsService analytics;
  late WorkoutSessionFlowCubit flowCubit;
  late WorkoutRestoreCubit restoreCubit;
  late void Function({
    required WorkoutSessionDetailsDTO details,
    required ProgramDayEntity programDay,
  })
  stubRestore;

  setUp(() {
    sessionCache = _MockWorkoutSessionCacheRepository();
    sessionRepository = _MockWorkoutSessionRepository();
    programRepository = _MockWorkoutProgramRepository();
    exerciseCatalogRepository = _MockExerciseCatalogRepository();
    localWorkoutRepository = _MockLocalWorkoutSessionRepository();
    userSessionService = _MockUserSessionService();
    exerciseSessionRepository = _MockExerciseSessionRepository();
    analytics = _MockAnalyticsService();

    when(() => userSessionService.currentUser).thenReturn(_user());
    when(() => sessionCache.getActiveSession()).thenAnswer(
      (_) async => WorkoutSessionCacheData(
        id: 1,
        remoteSessionId: 172,
        programDayId: 25,
        source: CachedWorkoutSource.program.name,
        initializationPhase: WorkoutInitializationPhase.active.name,
        startedAt: DateTime(2026),
        durationSec: 120,
        lastExerciseIndex: 0,
      ),
    );
    when(
      () => localWorkoutRepository.getAnyInProgressLapForSession(172),
    ).thenAnswer((_) async => null);
    when(() => sessionCache.getExerciseSessions(172)).thenAnswer((_) async => []);
    when(() => sessionCache.clearActiveSession()).thenAnswer((_) async {});
    when(
      () => sessionCache.saveExerciseSession(
        workoutSessionId: any(named: 'workoutSessionId'),
        executionKey: any(named: 'executionKey'),
        exerciseId: any(named: 'exerciseId'),
        effectiveExerciseId: any(named: 'effectiveExerciseId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        position: any(named: 'position'),
        workoutProgramExerciseId: any(named: 'workoutProgramExerciseId'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => sessionCache.updateInitializationPhase(WorkoutInitializationPhase.active),
    ).thenAnswer((_) async {});
    when(
      () => sessionCache.updateInitializationPhase(WorkoutInitializationPhase.exerciseSessionCreated),
    ).thenAnswer((_) async {});
    when(
      () => sessionCache.getExerciseSession(
        workoutSessionId: any(named: 'workoutSessionId'),
        executionKey: any(named: 'executionKey'),
      ),
    ).thenAnswer((_) async => null);

    flowCubit = WorkoutSessionFlowCubit(
      sessionRepository,
      exerciseSessionRepository,
      analytics,
      sessionCache,
      userSessionService,
    );
    restoreCubit = WorkoutRestoreCubit(
      sessionCache,
      sessionRepository,
      programRepository,
      exerciseCatalogRepository,
      localWorkoutRepository,
      userSessionService,
      flowCubit,
    );
    stubRestore = ({required details, required programDay}) {
      when(
        () => sessionRepository.getWorkoutSessionDetails(172),
      ).thenAnswer((_) async => Result.success(details));
      when(
        () => programRepository.getWorkoutByDay(25),
      ).thenAnswer((_) async => Result.success(programDay));
    };
  });

  tearDown(() async {
    await restoreCubit.close();
    await flowCubit.close();
  });

  test('restores a regular exercise swapped to running without another POST', () async {
    final programDay = _programDay(_regularProgramExercise);
    final details = _details([
      _session(
        id: 228,
        original: _regularExerciseDto,
        swapped: _runningExerciseDto,
        notes: 'restored note',
        sets: const [
          ExerciseSetDTO(
            id: 501,
            exerciseId: 14,
            exerciseSessionId: 228,
            durationSec: 120,
            distanceM: 1000,
            setNumber: 1,
          ),
        ],
      ),
    ]);
    stubRestore(details: details, programDay: programDay);

    await restoreCubit.checkForInterrupted();
    await restoreCubit.restoreSession();

    final execution = flowCubit.exerciseExecutionFor(flowCubit.state.currentExercise!.executionKey)!;
    expect(execution.session.id, 228);
    expect(execution.session.swappedExerciseId, 14);
    expect(execution.effectiveExercise.id, 14);
    expect(execution.effectiveExercise.isRunningSwapCandidate, isTrue);
    expect(execution.session.notes, 'restored note');
    expect(flowCubit.state.restoredSets[100], hasLength(1));

    final ensured = await flowCubit.ensureExerciseSession(flowCubit.state.currentExercise!);
    expect(ensured.orNull?.session.id, 228);
    verifyNever(
      () => exerciseSessionRepository.createWorkoutExerciseSession(
        exerciseId: 33,
        workoutSessionId: 172,
        workoutProgramExerciseId: 100,
        system: MeasurementSystem.metric,
      ),
    );

    final activeCubit = ActiveExerciseCubit(
      exerciseSessionRepository,
      analytics,
      userSessionService,
      const ClientIdGenerator(),
      sessionCache,
      execution,
    );
    await activeCubit.initialize(restoredSets: flowCubit.state.restoredSets[100]);
    expect(activeCubit.isRunningExercise, isTrue);
    expect(activeCubit.state.notes, 'restored note');
    expect(activeCubit.state.previousResult, isNull);
    expect(activeCubit.state.sets, hasLength(2));
    expect(activeCubit.state.sets.first.isDone, isTrue);
    await activeCubit.close();
  });

  test('restores a running exercise swapped to regular as the regular branch', () async {
    final programDay = _programDay(_runningProgramExercise);
    final details = _details([
      _session(
        id: 229,
        programExerciseId: 101,
        original: _runningExerciseDto,
        swapped: _regularExerciseDto,
        notes: 'regular replacement',
      ),
    ]);
    stubRestore(details: details, programDay: programDay);

    await restoreCubit.checkForInterrupted();
    await restoreCubit.restoreSession();

    final execution = flowCubit.exerciseExecutionFor(flowCubit.state.currentExercise!.executionKey)!;
    expect(execution.session.id, 229);
    expect(execution.effectiveExercise.id, 33);

    final activeCubit = ActiveExerciseCubit(
      exerciseSessionRepository,
      analytics,
      userSessionService,
      const ClientIdGenerator(),
      sessionCache,
      execution,
    );
    await activeCubit.initialize();
    expect(_runningProgramExercise.isRunningExercise, isTrue);
    expect(activeCubit.isRunningExercise, isFalse);
    expect(activeCubit.state.notes, 'regular replacement');
    expect(activeCubit.state.sets, hasLength(1));
    await activeCubit.close();
  });

  test('merges sets from an unbound execution session into its swapped parent', () async {
    final programDay = _programDay(_regularProgramExercise);
    final details = _details([
      _session(
        id: 228,
        original: _regularExerciseDto,
        swapped: _runningExerciseDto,
      ),
      const WorkoutExerciseSessionDTO(
        id: 230,
        exerciseId: 14,
        workoutSessionId: 172,
        sets: [
          ExerciseSetDTO(
            id: 502,
            exerciseId: 14,
            exerciseSessionId: 230,
            durationSec: 60,
            distanceM: 500,
            setNumber: 1,
          ),
        ],
        exercise: _runningExerciseDto,
      ),
    ]);
    stubRestore(details: details, programDay: programDay);

    await restoreCubit.checkForInterrupted();
    await restoreCubit.restoreSession();

    final execution = flowCubit.exerciseExecutionFor(flowCubit.state.currentExercise!.executionKey);
    expect(execution?.session.id, 228);
    expect(execution?.session.workoutProgramExerciseId, 100);
    expect(flowCubit.state.restoredSets, hasLength(1));
    expect(flowCubit.state.restoredSets[100], hasLength(1));
  });

  test('restores Free Run from backend details and preserves dirty local notes', () async {
    final plan = WorkoutExecutionPlan.freeRun(
      details: _freeRunningExerciseDto.toEntity(),
      executionKey: 'free-run:restore',
    );
    when(() => sessionCache.getActiveSession()).thenAnswer(
      (_) async => WorkoutSessionCacheData(
        id: 1,
        remoteSessionId: 182,
        source: CachedWorkoutSource.adHoc.name,
        executionPlanJson: CachedWorkoutExecutionPlan.fromPlan(plan).encode(),
        initializationPhase: WorkoutInitializationPhase.active.name,
        startedAt: DateTime(2026),
        durationSec: 120,
        lastExerciseIndex: 0,
      ),
    );
    when(() => sessionRepository.getWorkoutSessionDetails(182)).thenAnswer(
      (_) async => const Result.success(
        WorkoutSessionDetailsDTO(
          id: 182,
          duration: 120,
          status: WorkoutSessionStatus.active,
          totalXpEarned: 0,
          exerciseSessions: [
            WorkoutExerciseSessionDTO(
              id: 246,
              exerciseId: 4,
              workoutSessionId: 182,
              notes: 'server note',
              exercise: _freeRunningExerciseDto,
            ),
          ],
        ),
      ),
    );
    when(() => sessionCache.getExerciseSessions(182)).thenAnswer(
      (_) async => [
        WorkoutExerciseSessionCacheData(
          id: 1,
          workoutSessionId: 182,
          executionKey: 'free-run:restore',
          exerciseId: 4,
          effectiveExerciseId: 4,
          exerciseSessionId: 246,
          position: 0,
          notes: 'local note',
          notesSyncStatus: CachedNotesSyncStatus.dirty.name,
          updatedAt: DateTime(2026),
        ),
      ],
    );
    when(
      () => localWorkoutRepository.getAnyInProgressLapForSession(182),
    ).thenAnswer((_) async => null);

    await restoreCubit.checkForInterrupted();
    await restoreCubit.restoreSession();

    expect(flowCubit.state.startIntent, WorkoutStartIntent.freeRun);
    expect(flowCubit.state.programDay, isNull);
    expect(flowCubit.state.currentExercise?.exerciseId, 4);
    final execution = flowCubit.exerciseExecutionFor('free-run:restore');
    expect(execution?.exerciseSessionId, 246);
    expect(execution?.session.notes, 'local note');
    verifyNever(() => exerciseCatalogRepository.getExercise(any()));
  });

  test('restores Free Run before exercise-session creation and reconciles by creating it', () async {
    final plan = WorkoutExecutionPlan.freeRun(
      details: _freeRunningExerciseDto.toEntity(),
      executionKey: 'free-run:before-exercise',
    );
    when(() => sessionCache.getActiveSession()).thenAnswer(
      (_) async => WorkoutSessionCacheData(
        id: 1,
        remoteSessionId: 182,
        source: CachedWorkoutSource.adHoc.name,
        executionPlanJson: CachedWorkoutExecutionPlan.fromPlan(plan).encode(),
        initializationPhase: WorkoutInitializationPhase.workoutCreated.name,
        startedAt: DateTime(2026),
        durationSec: 0,
        lastExerciseIndex: 0,
      ),
    );
    when(() => sessionRepository.getWorkoutSessionDetails(182)).thenAnswer(
      (_) async => const Result.success(
        WorkoutSessionDetailsDTO(
          id: 182,
          duration: 0,
          status: WorkoutSessionStatus.active,
          totalXpEarned: 0,
          exerciseSessions: [],
        ),
      ),
    );
    when(() => sessionCache.getExerciseSessions(182)).thenAnswer((_) async => []);
    when(() => exerciseCatalogRepository.getExercise(4)).thenAnswer(
      (_) async => Result.success(_freeRunningExerciseDto.toEntity()),
    );
    when(
      () => exerciseSessionRepository.createWorkoutExerciseSession(
        exerciseId: 4,
        workoutSessionId: 182,
        system: MeasurementSystem.metric,
      ),
    ).thenAnswer(
      (_) async => Result.success(
        _freeSessionEntity(id: 246),
      ),
    );

    await restoreCubit.checkForInterrupted();
    await restoreCubit.restoreSession();

    expect(flowCubit.exerciseExecutionFor('free-run:before-exercise'), isNull);
    final result = await flowCubit.ensureExerciseSession(flowCubit.state.currentExercise!);
    expect(result.orNull?.exerciseSessionId, 246);
  });

  test('clears local state when the cached workout is already terminal', () async {
    when(() => sessionRepository.getWorkoutSessionDetails(172)).thenAnswer(
      (_) async => Result.success(
        _details(const []).copyWith(status: WorkoutSessionStatus.completed),
      ),
    );

    await restoreCubit.checkForInterrupted();

    expect(restoreCubit.state, isA<WorkoutRestoreNone>());
    verify(() => sessionCache.clearActiveSession()).called(1);
    verifyNever(() => programRepository.getWorkoutByDay(any()));
  });
}

WorkoutSessionDetailsDTO _details(List<WorkoutExerciseSessionDTO> sessions) {
  return WorkoutSessionDetailsDTO(
    id: 172,
    workoutProgramDayId: 25,
    duration: 120,
    status: WorkoutSessionStatus.active,
    totalXpEarned: 0,
    exerciseSessions: sessions,
    workoutSessions: sessions,
  );
}

WorkoutExerciseSessionDTO _session({
  required int id,
  required ExerciseDetailsDTO original,
  required ExerciseDetailsDTO swapped,
  int programExerciseId = 100,
  String? notes,
  List<ExerciseSetDTO> sets = const [],
}) {
  return WorkoutExerciseSessionDTO(
    id: id,
    exerciseId: original.id,
    workoutSessionId: 172,
    workoutProgramExerciseId: programExerciseId,
    isSwapped: true,
    swappedExerciseId: swapped.id,
    notes: notes,
    sets: sets,
    exercise: original,
    swappedExercise: swapped,
  );
}

ProgramDayEntity _programDay(ProgramExerciseEntity exercise) {
  return ProgramDayEntity(
    id: 25,
    name: 'Restore day',
    dayNumber: 1,
    programExercises: [exercise],
  );
}

const _regularExerciseDto = ExerciseDetailsDTO(
  id: 33,
  name: 'Bench Press',
  description: 'Regular exercise',
  type: 1,
  key: 'bench_press',
  factionId: 1,
  metrics: ['reps'],
);

const _runningExerciseDto = ExerciseDetailsDTO(
  id: 14,
  name: '1km Run',
  description: 'Running exercise',
  type: 2,
  key: '1km_run',
  factionId: 3,
  metrics: ['durationSec', 'distanceM'],
);

const _freeRunningExerciseDto = ExerciseDetailsDTO(
  id: 4,
  name: 'Running',
  description: 'Free running exercise',
  type: 2,
  key: 'running',
  factionId: 3,
  metrics: ['durationSec', 'distanceM'],
);

WorkoutExerciseSessionEntity _freeSessionEntity({required int id}) {
  return WorkoutExerciseSessionEntity(
    id: id,
    exerciseId: 4,
    workoutSessionId: 182,
    workoutProgramExerciseId: null,
    isSwapped: false,
    swappedExerciseId: null,
    isActive: true,
    notes: null,
    lastCompletedSet: null,
    createdAt: null,
    updatedAt: null,
    sets: const [],
    exercise: _freeRunningExerciseDto.toEntity(),
    swappedExercise: null,
  );
}

final _regularProgramExercise = ProgramExerciseEntity(
  id: 100,
  programDayId: 25,
  sets: 3,
  order: 1,
  exerciseDetails: _regularExerciseDto.toEntity(),
  executionMode: ExecutionMode.standard,
  segments: const [],
);

final _runningProgramExercise = ProgramExerciseEntity(
  id: 101,
  programDayId: 25,
  sets: 1,
  order: 1,
  exerciseDetails: _runningExerciseDto.toEntity(),
  executionMode: ExecutionMode.standard,
  segments: const [],
);

User _user() {
  return User.onboarded(
    id: 67,
    measurementSystem: MeasurementSystem.metric,
    factionId: 1,
    birthDate: DateTime(1990),
    workoutsPerWeek: 3,
  );
}
