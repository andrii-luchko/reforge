import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/app/utils/helpers/keyboard_visibility_provider.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/entities/running_exercise_config.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/enums/running_session_status.dart';
import 'package:reforge/features/running/ui/pages/running_exercise_host.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

import '../../../helpers/test_setup.dart';

class _MockRunningTrackerCubit extends MockCubit<RunningTrackerState> implements RunningTrackerCubit {}

class _MockRunningSetSyncCubit extends MockCubit<RunningSetSyncState> implements RunningSetSyncCubit {}

class _MockActiveExerciseCubit extends MockCubit<ActiveExerciseState> implements ActiveExerciseCubit {}

void main() {
  setUpAll(initTestTranslations);

  for (final programExerciseId in <int?>[null, 20]) {
    final source = programExerciseId == null ? 'Free Run' : 'program Running';

    testWidgets('$source finishes inside the running provider scope and stops tracking before submit', (tester) async {
      final tracker = _MockRunningTrackerCubit();
      final sync = _MockRunningSetSyncCubit();
      final active = _MockActiveExerciseCubit();
      final order = <String>[];
      final config = _config(programExerciseId);
      var activeState = _activeState(programExerciseId);

      when(() => tracker.state).thenReturn(_trackerState);
      when(() => tracker.config).thenReturn(config);
      when(() => sync.state).thenReturn(_syncState);
      when(() => active.state).thenAnswer((_) => activeState);
      when(sync.flush).thenAnswer((_) async {
        order.add('flush');
        return true;
      });
      when(tracker.finishExercise).thenAnswer((_) async {
        order.add('tracker');
        return true;
      });
      when(
        () => active.replaceSetsFromExternalSource(
          sets: any(named: 'sets'),
          isSending: any(named: 'isSending'),
        ),
      ).thenAnswer((_) {
        order.add('replace');
      });
      when(active.finishExercise).thenAnswer((_) async {
        order.add('submit');
        activeState = activeState.copyWith(isSubmitted: true);
      });

      await _pumpHost(tester, tracker: tracker, sync: sync, active: active);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(order, ['flush', 'tracker', 'replace', 'submit']);
      verify(sync.flush).called(1);
      verify(tracker.finishExercise).called(1);
      verify(active.finishExercise).called(1);
      await _disposeHost(tester);
    });
  }

  testWidgets('failed flush neither stops tracking nor submits the exercise', (tester) async {
    final tracker = _MockRunningTrackerCubit();
    final sync = _MockRunningSetSyncCubit();
    final active = _MockActiveExerciseCubit();

    when(() => tracker.state).thenReturn(_trackerState);
    when(() => tracker.config).thenReturn(_config(null));
    when(() => sync.state).thenReturn(_syncState);
    when(() => active.state).thenReturn(_activeState(null));
    when(sync.flush).thenAnswer((_) async => false);

    await _pumpHost(tester, tracker: tracker, sync: sync, active: active);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    verify(sync.flush).called(1);
    verifyNever(tracker.finishExercise);
    verifyNever(active.finishExercise);
    await _disposeHost(tester);
  });

  testWidgets('double Finish tap shares one in-flight pipeline', (tester) async {
    final tracker = _MockRunningTrackerCubit();
    final sync = _MockRunningSetSyncCubit();
    final active = _MockActiveExerciseCubit();
    final flush = Completer<bool>();

    when(() => tracker.state).thenReturn(_trackerState);
    when(() => tracker.config).thenReturn(_config(null));
    when(() => sync.state).thenReturn(_syncState);
    when(() => active.state).thenReturn(_activeState(null));
    when(sync.flush).thenAnswer((_) => flush.future);

    await _pumpHost(tester, tracker: tracker, sync: sync, active: active);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    verify(sync.flush).called(1);

    flush.complete(false);
    await tester.pump();
    await _disposeHost(tester);
  });
}

Future<void> _disposeHost(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required RunningTrackerCubit tracker,
  required RunningSetSyncCubit sync,
  required ActiveExerciseCubit active,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeDataValues.darkThemeData,
      home: KeyboardVisibilityProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<RunningTrackerCubit>.value(value: tracker),
            BlocProvider<RunningSetSyncCubit>.value(value: sync),
            BlocProvider<ActiveExerciseCubit>.value(value: active),
          ],
          child: const Scaffold(body: RunningExerciseHost()),
        ),
      ),
    ),
  );
}

RunningExerciseConfig _config(int? programExerciseId) {
  return RunningExerciseConfig(
    workoutSessionId: 182,
    exerciseSessionId: 246,
    workoutProgramExerciseId: programExerciseId,
    exercise: _runningExercise,
    segments: const [],
    staticTargetSetCount: 1,
  );
}

ActiveExerciseState _activeState(int? programExerciseId) {
  return ActiveExerciseState(
    session: WorkoutExerciseSessionEntity(
      id: 246,
      exerciseId: 4,
      workoutSessionId: 182,
      workoutProgramExerciseId: programExerciseId,
      isSwapped: false,
      swappedExerciseId: null,
      isActive: true,
      notes: null,
      lastCompletedSet: null,
      createdAt: null,
      updatedAt: null,
      sets: const [],
      exercise: _runningExercise,
      swappedExercise: null,
    ),
    effectiveExercise: _runningExercise,
    sets: [_syncedSet],
  );
}

const _trackerState = RunningTrackerState(
  phase: RunningPhase.finished,
  sessionStatus: RunningSessionStatus.suspended,
  isPaused: true,
);

final _syncState = RunningSetSyncState(
  sets: [_syncedSet],
  canFinish: true,
);

final _syncedSet = WorkoutSet(
  id: 368,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
  setNumber: 1,
  time: const Duration(seconds: 60),
  distance: 1,
  pace: 10,
  isLocallyCompleted: true,
  isDone: true,
);

const _runningExercise = ExerciseDetailsEntity(
  id: 4,
  name: 'Running',
  description: 'Run',
  key: 'running',
  metrics: [WorkoutMetric.time, WorkoutMetric.distance],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);
