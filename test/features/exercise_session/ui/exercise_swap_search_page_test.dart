// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/controllers/exercise_swap/exercise_swap_cubit.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/exercise_session/ui/exercise_swap/pages/exercise_swap_search_page.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  testWidgets('blocks Back during PATCH and pops only after the swap is confirmed', (tester) async {
    final exerciseRepository = _MockExerciseSessionRepository();
    final swapResponse = Completer<Result<WorkoutExerciseSessionEntity>>();
    when(
      () => exerciseRepository.searchSwapExercises(
        search: null,
        factionId: null,
        page: 1,
        limit: 20,
      ),
    ).thenAnswer(
      (_) async => const Result.success((
        exercises: [_exercise],
        pagination: PaginationInfo(page: 1, total: 1, limit: 20, pages: 1),
      )),
    );
    when(
      () => exerciseRepository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 12,
        system: MeasurementSystem.metric,
      ),
    ).thenAnswer((_) => swapResponse.future);
    final cubit = ExerciseSwapCubit(
      exerciseRepository,
      _MockWorkoutSessionRepository(),
      _requestContext,
    );
    await cubit.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const ExerciseSwapSearchPage(),
                      ),
                    ),
                  );
                },
                child: const Text('Open swap'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open swap'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('confirm_exercise_swap')), findsOneWidget);
    final hiddenConfirmation = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('confirm_exercise_swap')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(hiddenConfirmation.opacity, 0);

    await tester.tap(find.text('Frog Stretch'));
    await tester.pump();

    final confirmation = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('confirm_exercise_swap')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(confirmation.opacity, 1);
    verifyNever(
      () => exerciseRepository.swapExercise(
        workoutExerciseSessionId: 228,
        swappedExerciseId: 12,
        system: MeasurementSystem.metric,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('confirm_exercise_swap')));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('Frog Stretch'), findsOneWidget);

    swapResponse.complete(const Result.success(_session));
    await tester.pumpAndSettle();

    expect(find.text('Open swap'), findsOneWidget);
    expect(find.text('Frog Stretch'), findsNothing);

    await cubit.close();
  });
}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

class _MockWorkoutSessionRepository extends Mock implements WorkoutSessionRepository {}

const _requestContext = ExerciseSwapRequestContext(
  workoutSessionId: 172,
  workoutExerciseSessionId: 228,
  currentExerciseId: 33,
  measurementSystem: MeasurementSystem.metric,
);

const _exercise = ExerciseDetailsEntity(
  id: 12,
  name: 'Frog Stretch',
  description: 'Stretch',
  key: null,
  metrics: [],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _session = WorkoutExerciseSessionEntity(
  id: 228,
  exerciseId: 33,
  workoutSessionId: 172,
  workoutProgramExerciseId: 100,
  isSwapped: true,
  swappedExerciseId: 12,
  isActive: true,
  notes: '',
  lastCompletedSet: null,
  createdAt: null,
  updatedAt: null,
  sets: [],
  exercise: null,
  swappedExercise: null,
);
