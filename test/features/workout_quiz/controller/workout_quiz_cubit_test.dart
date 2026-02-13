import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/data/models/workout_quiz_answers.dart';
import 'package:reforge/features/workout_quiz/domain/enums/body_feel.dart';
import 'package:reforge/features/workout_quiz/domain/enums/energized_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/hydrated_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/sleep_quality.dart';
import 'package:reforge/features/workout_quiz/domain/enums/stress_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/work_out_quiz_steps.dart';
import 'package:reforge/features/workout_quiz/domain/repositories/workout_quiz_repository.dart';

import '../mocks/mock_workout_quiz_repository.dart';

WorkoutQuizAnswers get _fallbackWorkoutQuizAnswers => WorkoutQuizAnswers(
      sleepQuality: SleepQuality.good,
      energizedLevel: EnergizedLevel.moderate,
      stressLevel: StressLevel.neutral,
      bodyFeel: BodyFeel.mostlyFresh,
      hydratedLevel: HydratedLevel.hydrated,
      hasEatenRecently: false,
      isMorningSession: false,
    );

void main() {
  late MockWorkoutQuizRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(_fallbackWorkoutQuizAnswers);
  });

  setUp(() {
    mockRepository = MockWorkoutQuizRepository();
  });

  group('WorkoutQuizCubit', () {
    group('setters', () {
      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setSleepQuality emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setSleepQuality(SleepQuality.excellent),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.sleepQuality, 'sleepQuality', SleepQuality.excellent),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setEnergizedLevel emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setEnergizedLevel(EnergizedLevel.high),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.energizedLevel, 'energizedLevel', EnergizedLevel.high),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setStressLevel emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setStressLevel(StressLevel.calm),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.stressLevel, 'stressLevel', StressLevel.calm),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setBodyFeel emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setBodyFeel(BodyFeel.fullyFresh),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.bodyFeel, 'bodyFeel', BodyFeel.fullyFresh),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setHydratedLevel emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setHydratedLevel(HydratedLevel.wellHydrated),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.hydratedLevel, 'hydratedLevel', HydratedLevel.wellHydrated),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setHasEatenRecently emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setHasEatenRecently(true),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.hasEatenRecently, 'hasEatenRecently', true),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setIsMorningSession emits state with value',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.setIsMorningSession(true),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.isMorningSession, 'isMorningSession', true),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'onStepChanged emits state with new step index',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.onStepChanged(3),
        expect: () => [
          isA<WorkoutQuizState>()
              .having((s) => s.currentStep, 'currentStep', 3),
        ],
      );
    });

    group('isStepValid', () {
      test('sleepQualityStep valid when sleepQuality set', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setSleepQuality(SleepQuality.good);
        cubit.onStepChanged(WorkOutQuizSteps.sleepQualityStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('sleepQualityStep invalid when sleepQuality null', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.onStepChanged(WorkOutQuizSteps.sleepQualityStep.index);
        expect(cubit.isStepValid, isFalse);
      });

      test('energizedLevelStep valid when energizedLevel set', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setEnergizedLevel(EnergizedLevel.good);
        cubit.onStepChanged(WorkOutQuizSteps.energizedLevelStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('stressLevelStep valid when stressLevel set', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setStressLevel(StressLevel.neutral);
        cubit.onStepChanged(WorkOutQuizSteps.stressLevelStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('bodyFellStep valid when bodyFeel set', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setBodyFeel(BodyFeel.mostlyFresh);
        cubit.onStepChanged(WorkOutQuizSteps.bodyFellStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('hydratedLevelStep valid when hydratedLevel set', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setHydratedLevel(HydratedLevel.hydrated);
        cubit.onStepChanged(WorkOutQuizSteps.hydratedLevelStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('hasEatenRecentlyStep always valid', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.onStepChanged(WorkOutQuizSteps.hasEatenRecentlyStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('isMorningSessionStep always valid', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.onStepChanged(WorkOutQuizSteps.isMorningSessionStep.index);
        expect(cubit.isStepValid, isTrue);
      });
    });

    group('isFormComplete', () {
      test('false when fields missing', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        expect(cubit.isFormComplete, isFalse);
      });

      test('true when all 5 enum fields filled', () {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setSleepQuality(SleepQuality.good);
        cubit.setEnergizedLevel(EnergizedLevel.moderate);
        cubit.setStressLevel(StressLevel.neutral);
        cubit.setBodyFeel(BodyFeel.mostlyFresh);
        cubit.setHydratedLevel(HydratedLevel.hydrated);
        expect(cubit.isFormComplete, isTrue);
      });
    });

    group('isTodaySubmitted', () {
      test('returns true without calling repository when form complete and already submitted', () async {
        final cubit = WorkoutQuizCubit(mockRepository);
        cubit.setSleepQuality(SleepQuality.good);
        cubit.setEnergizedLevel(EnergizedLevel.moderate);
        cubit.setStressLevel(StressLevel.neutral);
        cubit.setBodyFeel(BodyFeel.mostlyFresh);
        cubit.setHydratedLevel(HydratedLevel.hydrated);
        cubit.emit(cubit.state.copyWith(isSubmitted: true));
        final result = await cubit.isTodaySubmitted();
        expect(result, isTrue);
        verifyNever(() => mockRepository.isQuizTodaySubmitted());
      });

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'emits isSubmitted from result when repository returns Success',
        build: () {
          when(() => mockRepository.isQuizTodaySubmitted())
              .thenAnswer((_) async => const Result.success(true));
          return WorkoutQuizCubit(mockRepository);
        },
        seed: () => WorkoutQuizState(
          sleepQuality: SleepQuality.good,
          energizedLevel: EnergizedLevel.moderate,
          stressLevel: StressLevel.neutral,
          bodyFeel: BodyFeel.mostlyFresh,
          hydratedLevel: HydratedLevel.hydrated,
        ),
        act: (cubit) => cubit.isTodaySubmitted(),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.isLoading, 'isLoading', true),
          isA<WorkoutQuizState>()
              .having((s) => s.isSubmitted, 'isSubmitted', true)
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'emits apiError when repository returns Error',
        build: () {
          when(() => mockRepository.isQuizTodaySubmitted()).thenAnswer(
            (_) async => Result.error(Exception('Network error')),
          );
          return WorkoutQuizCubit(mockRepository);
        },
        seed: () => WorkoutQuizState(
          sleepQuality: SleepQuality.good,
          energizedLevel: EnergizedLevel.moderate,
          stressLevel: StressLevel.neutral,
          bodyFeel: BodyFeel.mostlyFresh,
          hydratedLevel: HydratedLevel.hydrated,
        ),
        act: (cubit) => cubit.isTodaySubmitted(),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.isLoading, 'isLoading', true),
          isA<WorkoutQuizState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.apiError, 'apiError', isNotNull),
        ],
      );
    });

    group('onSubmit', () {
      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'does not call repository when form incomplete',
        build: () => WorkoutQuizCubit(mockRepository),
        act: (cubit) => cubit.onSubmit(),
        expect: () => <WorkoutQuizState>[],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'emits isSubmitted true when repository succeeds',
        build: () {
          when(() => mockRepository.submitQuiz(any()))
              .thenAnswer((_) async => const Result.success(null));
          return WorkoutQuizCubit(mockRepository);
        },
        seed: () => WorkoutQuizState(
          sleepQuality: SleepQuality.good,
          energizedLevel: EnergizedLevel.moderate,
          stressLevel: StressLevel.neutral,
          bodyFeel: BodyFeel.mostlyFresh,
          hydratedLevel: HydratedLevel.hydrated,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.isLoading, 'isLoading', true),
          isA<WorkoutQuizState>()
              .having((s) => s.isSubmitted, 'isSubmitted', true)
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'emits apiError when repository fails',
        build: () {
          when(() => mockRepository.submitQuiz(any())).thenAnswer(
            (_) async => Result.error(Exception('API error')),
          );
          return WorkoutQuizCubit(mockRepository);
        },
        seed: () => WorkoutQuizState(
          sleepQuality: SleepQuality.good,
          energizedLevel: EnergizedLevel.moderate,
          stressLevel: StressLevel.neutral,
          bodyFeel: BodyFeel.mostlyFresh,
          hydratedLevel: HydratedLevel.hydrated,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.isLoading, 'isLoading', true),
          isA<WorkoutQuizState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.apiError, 'apiError', isNotNull),
        ],
      );
    });
  });
}
