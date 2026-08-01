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
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';
import 'package:reforge/features/workout_session/controllers/workout_restore_cubit.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

class _MockWorkoutSessionCacheRepository extends Mock implements WorkoutSessionCacheRepository {}

class _MockWorkoutSessionRepository extends Mock implements WorkoutSessionRepository {}

class _MockWorkoutProgramRepository extends Mock implements WorkoutProgramRepository {}

class _MockLocalWorkoutSessionRepository extends Mock implements LocalWorkoutSessionRepository {}

class _MockUserSessionService extends Mock implements UserSessionService {}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockWorkoutSessionCacheRepository sessionCache;
  late _MockWorkoutSessionRepository sessionRepository;
  late _MockWorkoutProgramRepository programRepository;
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
        startedAt: DateTime(2026),
        durationSec: 120,
        lastExerciseIndex: 0,
      ),
    );
    when(
      () => localWorkoutRepository.getAnyInProgressLapForSession(172),
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

    final context = flowCubit.exerciseContextFor(100)!;
    expect(context.session.id, 228);
    expect(context.session.swappedExerciseId, 14);
    expect(context.effectiveExercise.id, 14);
    expect(context.effectiveExercise.isRunningSwapCandidate, isTrue);
    expect(context.session.notes, 'restored note');
    expect(flowCubit.state.restoredSets[100], hasLength(1));

    final ensured = await flowCubit.ensureExerciseSession(_regularProgramExercise);
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
      context,
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

    final context = flowCubit.exerciseContextFor(101)!;
    expect(context.session.id, 229);
    expect(context.effectiveExercise.id, 33);

    final activeCubit = ActiveExerciseCubit(
      exerciseSessionRepository,
      analytics,
      userSessionService,
      context,
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

    expect(flowCubit.exerciseContextFor(100)?.session.id, 228);
    expect(flowCubit.exerciseContextFor(100)?.session.workoutProgramExerciseId, 100);
    expect(flowCubit.state.restoredSets, hasLength(1));
    expect(flowCubit.state.restoredSets[100], hasLength(1));
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
