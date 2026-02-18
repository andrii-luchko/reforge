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

import '../../../core/analytics/mocks/mock_analytics_service.dart';
import '../mocks/mock_workout_quiz_repository.dart';

WorkoutQuizAnswers get _fallbackWorkoutQuizAnswers => const WorkoutQuizAnswers(
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
  late MockAnalyticsService mockAnalytics;

  setUpAll(() {
    registerFallbackValue(_fallbackWorkoutQuizAnswers);
  });

  setUp(() {
    mockRepository = MockWorkoutQuizRepository();
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logEvent(any())).thenAnswer((_) async {});
  });

  WorkoutQuizCubit createCubit() => WorkoutQuizCubit(mockRepository, mockAnalytics);

  group('WorkoutQuizCubit', () {
    group('setters', () {
      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setSleepQuality emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setSleepQuality(SleepQuality.excellent),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.sleepQuality, 'sleepQuality', SleepQuality.excellent),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setEnergizedLevel emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setEnergizedLevel(EnergizedLevel.high),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.energizedLevel, 'energizedLevel', EnergizedLevel.high),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setStressLevel emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setStressLevel(StressLevel.calm),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.stressLevel, 'stressLevel', StressLevel.calm),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setBodyFeel emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setBodyFeel(BodyFeel.fullyFresh),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.bodyFeel, 'bodyFeel', BodyFeel.fullyFresh),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setHydratedLevel emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setHydratedLevel(HydratedLevel.wellHydrated),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.hydratedLevel, 'hydratedLevel', HydratedLevel.wellHydrated),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setHasEatenRecently emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setHasEatenRecently(true),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.hasEatenRecently, 'hasEatenRecently', true),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'setIsMorningSession emits state with value',
        build: createCubit,
        act: (cubit) => cubit.setIsMorningSession(true),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.isMorningSession, 'isMorningSession', true),
        ],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'onStepChanged emits state with new step index',
        build: createCubit,
        act: (cubit) => cubit.onStepChanged(3),
        expect: () => [
          isA<WorkoutQuizState>().having((s) => s.currentStep, 'currentStep', 3),
        ],
      );
    });

    group('isStepValid', () {
      test('sleepQualityStep valid when sleepQuality set', () {
        final cubit = createCubit();
        expect(
          (cubit
                ..setSleepQuality(SleepQuality.good)
                ..onStepChanged(WorkOutQuizSteps.sleepQualityStep.index))
              .isStepValid,
          isTrue,
        );
      });

      test('sleepQualityStep invalid when sleepQuality null', () {
        final cubit = createCubit();
        expect(
          (cubit..onStepChanged(WorkOutQuizSteps.sleepQualityStep.index)).isStepValid,
          isFalse,
        );
      });

      test('energizedLevelStep valid when energizedLevel set', () {
        final cubit = createCubit();
        expect(
          (cubit
                ..setEnergizedLevel(EnergizedLevel.good)
                ..onStepChanged(WorkOutQuizSteps.energizedLevelStep.index))
              .isStepValid,
          isTrue,
        );
      });

      test('stressLevelStep valid when stressLevel set', () {
        final cubit = createCubit();
        expect(
          (cubit
                ..setStressLevel(StressLevel.neutral)
                ..onStepChanged(WorkOutQuizSteps.stressLevelStep.index))
              .isStepValid,
          isTrue,
        );
      });

      test('bodyFellStep valid when bodyFeel set', () {
        final cubit = createCubit();
        expect(
          (cubit
                ..setBodyFeel(BodyFeel.mostlyFresh)
                ..onStepChanged(WorkOutQuizSteps.bodyFellStep.index))
              .isStepValid,
          isTrue,
        );
      });

      test('hydratedLevelStep valid when hydratedLevel set', () {
        final cubit = createCubit();
        expect(
          (cubit
                ..setHydratedLevel(HydratedLevel.hydrated)
                ..onStepChanged(WorkOutQuizSteps.hydratedLevelStep.index))
              .isStepValid,
          isTrue,
        );
      });

      test('hasEatenRecentlyStep always valid', () {
        final cubit = createCubit();
        expect(
          (cubit..onStepChanged(WorkOutQuizSteps.hasEatenRecentlyStep.index)).isStepValid,
          isTrue,
        );
      });

      test('isMorningSessionStep always valid', () {
        final cubit = createCubit();
        expect(
          (cubit..onStepChanged(WorkOutQuizSteps.isMorningSessionStep.index)).isStepValid,
          isTrue,
        );
      });
    });

    group('isFormComplete', () {
      test('false when fields missing', () {
        final cubit = createCubit();
        expect(cubit.isFormComplete, isFalse);
      });

      test('true when all 5 enum fields filled', () {
        final cubit = createCubit();
        expect(
          (cubit
                ..setSleepQuality(SleepQuality.good)
                ..setEnergizedLevel(EnergizedLevel.moderate)
                ..setStressLevel(StressLevel.neutral)
                ..setBodyFeel(BodyFeel.mostlyFresh)
                ..setHydratedLevel(HydratedLevel.hydrated))
              .isFormComplete,
          isTrue,
        );
      });
    });

    group('isTodaySubmitted', () {
      test('returns true without calling repository when form complete and already submitted', () async {
        final cubit = createCubit();
        cubit
          ..setSleepQuality(SleepQuality.good)
          ..setEnergizedLevel(EnergizedLevel.moderate)
          ..setStressLevel(StressLevel.neutral)
          ..setBodyFeel(BodyFeel.mostlyFresh)
          ..setHydratedLevel(HydratedLevel.hydrated)
          ..emit(cubit.state.copyWith(isSubmitted: true));
        final result = await cubit.isTodaySubmitted();
        expect(result, isTrue);
        verifyNever(() => mockRepository.isQuizTodaySubmitted());
      });

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'emits isSubmitted from result when repository returns Success',
        build: () {
          when(() => mockRepository.isQuizTodaySubmitted()).thenAnswer((_) async => const Result.success(true));
          return createCubit();
        },
        seed: () => const WorkoutQuizState(
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
          return createCubit();
        },
        seed: () => const WorkoutQuizState(
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
        build: createCubit,
        act: (cubit) => cubit.onSubmit(),
        expect: () => <WorkoutQuizState>[],
      );

      blocTest<WorkoutQuizCubit, WorkoutQuizState>(
        'emits isSubmitted true when repository succeeds',
        build: () {
          when(() => mockRepository.submitQuiz(any())).thenAnswer((_) async => const Result.success(null));
          return createCubit();
        },
        seed: () => const WorkoutQuizState(
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
          return createCubit();
        },
        seed: () => const WorkoutQuizState(
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
