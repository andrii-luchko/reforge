import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/data/models/quiz_answers.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/quiz_steps.dart';
import 'package:reforge/features/quiz/domain/enums/training_level.dart';

import '../../../helpers/test_setup.dart';
import '../mocks/mock_quiz_repository.dart';

QuizAnswers get _fallbackQuizAnswers => QuizAnswers(
  dateOfBirth: DateTime(1990, 1, 15),
  measurementSystem: MeasurementSystem.metric,
  bodyWeight: 70,
  mainGoal: MainGoal.buildStrength,
  trainingLevel: TrainingLevel.beginner,
  workoutDaysPerWeek: 3,
  specificWorkoutDays: [1, 2, 3],
  mainFaction: Faction.gakki,
  secondFaction: null,
);

void main() {
  late MockQuizRepository mockRepository;

  setUpAll(() {
    initTestTranslations();
    registerFallbackValue(_fallbackQuizAnswers);
  });

  setUp(() {
    mockRepository = MockQuizRepository();
  });

  group('QuizCubit', () {
    group('setters', () {
      blocTest<QuizCubit, QuizState>(
        'setDateOfBirth with valid date emits state with date and no error',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setDateOfBirth(DateTime(1990, 1, 15)),
        expect: () => [
          isA<QuizState>()
              .having((s) => s.dateOfBirth, 'dateOfBirth', DateTime(1990, 1, 15))
              .having((s) => s.dateOfBirthError, 'dateOfBirthError', isNull),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setDateOfBirth with null emits state with error',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setDateOfBirth(null),
        expect: () => [
          isA<QuizState>()
              .having((s) => s.dateOfBirth, 'dateOfBirth', isNull)
              .having((s) => s.dateOfBirthError, 'dateOfBirthError', isNotNull),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setMeasurementSystem emits state with system',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setMeasurementSystem(MeasurementSystem.imperial),
        expect: () => [
          isA<QuizState>().having(
            (s) => s.measurementSystem,
            'measurementSystem',
            MeasurementSystem.imperial,
          ),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setBodyWeight emits state with weight',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setBodyWeight(75),
        expect: () => [
          isA<QuizState>().having((s) => s.bodyWeight, 'bodyWeight', 75),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setMainGoal emits state with goal and faction',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setMainGoal(MainGoal.improveEndurance),
        expect: () => [
          isA<QuizState>()
              .having((s) => s.mainGoal, 'mainGoal', MainGoal.improveEndurance)
              .having((s) => s.mainFaction, 'mainFaction', Faction.gyohyo),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setTrainingLevel emits state with level',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setTrainingLevel(TrainingLevel.intermediate),
        expect: () => [
          isA<QuizState>().having(
            (s) => s.trainingLevel,
            'trainingLevel',
            TrainingLevel.intermediate,
          ),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setWorkoutDays emits state with days count',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setWorkoutDays(4),
        expect: () => [
          isA<QuizState>().having(
            (s) => s.workoutDaysPerWeek,
            'workoutDaysPerWeek',
            4,
          ),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setSpecificDays emits state with days',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setSpecificDays([WeekDay.monday, WeekDay.wednesday]),
        expect: () => [
          isA<QuizState>().having(
            (s) => s.specificWorkoutDays,
            'specificWorkoutDays',
            [WeekDay.monday, WeekDay.wednesday],
          ),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'setMainFaction emits state with faction',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.setMainFaction(Faction.seiren),
        expect: () => [
          isA<QuizState>().having((s) => s.mainFaction, 'mainFaction', Faction.seiren),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'toggleSecondFaction adds faction when not in list',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.toggleSecondFaction(Faction.gyohyo),
        expect: () => [
          isA<QuizState>().having((s) => s.secondFactions, 'secondFactions', [Faction.gyohyo]),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'toggleSecondFaction removes faction when in list',
        build: () => QuizCubit(mockRepository),
        seed: () => QuizState(secondFactions: [Faction.gyohyo]),
        act: (cubit) => cubit.toggleSecondFaction(Faction.gyohyo),
        expect: () => [
          isA<QuizState>().having((s) => s.secondFactions, 'secondFactions', isEmpty),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'onStepChanged emits state with new step index',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.onStepChanged(2),
        expect: () => [
          isA<QuizState>().having((s) => s.currentStep, 'currentStep', 2),
        ],
      );
    });

    group('isStepValid', () {
      test('dateBirthStep valid when date set and no error', () {
        final cubit = QuizCubit(mockRepository);
        cubit.setDateOfBirth(DateTime(1990, 1, 15));
        cubit.onStepChanged(QuizSteps.dateBirthStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('dateBirthStep invalid when date is null', () {
        final cubit = QuizCubit(mockRepository);
        cubit.onStepChanged(QuizSteps.dateBirthStep.index);
        expect(cubit.isStepValid, isFalse);
      });

      test('measurementSystemStep always valid', () {
        final cubit = QuizCubit(mockRepository);
        cubit.onStepChanged(QuizSteps.measurementSystemStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('bodyWeightStep valid when bodyWeight set', () {
        final cubit = QuizCubit(mockRepository);
        cubit.setBodyWeight(70);
        cubit.onStepChanged(QuizSteps.bodyWeightStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('bodyWeightStep invalid when bodyWeight null', () {
        final cubit = QuizCubit(mockRepository);
        cubit.onStepChanged(QuizSteps.bodyWeightStep.index);
        expect(cubit.isStepValid, isFalse);
      });

      test('mainGoalStep valid when mainGoal set', () {
        final cubit = QuizCubit(mockRepository)
          ..setMainGoal(MainGoal.buildStrength)
          ..onStepChanged(QuizSteps.mainGoalStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('trainingLevelStep valid when trainingLevel set', () {
        final cubit = QuizCubit(mockRepository)
          ..setTrainingLevel(TrainingLevel.beginner)
          ..onStepChanged(QuizSteps.trainingLevelStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('workoutFrequencyStep valid when days match count', () {
        final cubit = QuizCubit(mockRepository)
          ..setWorkoutDays(2)
          ..setSpecificDays([WeekDay.monday, WeekDay.tuesday])
          ..onStepChanged(QuizSteps.workoutFrequencyStep.index);
        expect(cubit.isStepValid, isTrue);
      });

      test('workoutFrequencyStep invalid when days count mismatch', () {
        final cubit = QuizCubit(mockRepository)
          ..setWorkoutDays(3)
          ..setSpecificDays([WeekDay.monday, WeekDay.tuesday])
          ..onStepChanged(QuizSteps.workoutFrequencyStep.index);
        expect(cubit.isStepValid, isFalse);
      });

      test('selectSecondFactionStep always valid', () {
        final cubit = QuizCubit(mockRepository)..onStepChanged(QuizSteps.selectSecondFactionStep.index);
        expect(cubit.isStepValid, isTrue);
      });
    });

    group('isFormComplete', () {
      test('false when fields missing', () {
        final cubit = QuizCubit(mockRepository);
        expect(cubit.isFormComplete, isFalse);
      });

      test('true when all required fields filled', () {
        final cubit = QuizCubit(mockRepository)
          ..setDateOfBirth(DateTime(1990, 1, 15))
          ..setBodyWeight(70)
          ..setMainGoal(MainGoal.buildStrength)
          ..setTrainingLevel(TrainingLevel.beginner)
          ..setWorkoutDays(3)
          ..setSpecificDays([
            WeekDay.monday,
            WeekDay.tuesday,
            WeekDay.wednesday,
          ])
          ..setMainFaction(Faction.gakki);
        expect(cubit.isFormComplete, isTrue);
      });
    });

    group('onSubmit', () {
      blocTest<QuizCubit, QuizState>(
        'does not call repository when form incomplete',
        build: () => QuizCubit(mockRepository),
        act: (cubit) => cubit.onSubmit(),
        expect: () => <QuizState>[],
      );

      blocTest<QuizCubit, QuizState>(
        'emits isSubmitted true when repository succeeds',
        build: () {
          when(() => mockRepository.submitQuiz(any())).thenAnswer((_) async => const Result.success(null));
          return QuizCubit(mockRepository);
        },
        seed: () => QuizState(
          dateOfBirth: DateTime(1990, 1, 15),
          bodyWeight: 70,
          mainGoal: MainGoal.buildStrength,
          trainingLevel: TrainingLevel.beginner,
          workoutDaysPerWeek: 3,
          specificWorkoutDays: [
            WeekDay.monday,
            WeekDay.tuesday,
            WeekDay.wednesday,
          ],
          mainFaction: Faction.gakki,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<QuizState>().having((s) => s.isLoading, 'isLoading', true),
          isA<QuizState>()
              .having((s) => s.isSubmitted, 'isSubmitted', true)
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<QuizCubit, QuizState>(
        'emits apiError when repository fails',
        build: () {
          when(() => mockRepository.submitQuiz(any())).thenAnswer(
            (_) async => Result.error(Exception('API error')),
          );
          return QuizCubit(mockRepository);
        },
        seed: () => QuizState(
          dateOfBirth: DateTime(1990, 1, 15),
          bodyWeight: 70,
          mainGoal: MainGoal.buildStrength,
          trainingLevel: TrainingLevel.beginner,
          workoutDaysPerWeek: 3,
          specificWorkoutDays: [
            WeekDay.monday,
            WeekDay.tuesday,
            WeekDay.wednesday,
          ],
          mainFaction: Faction.gakki,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          isA<QuizState>().having((s) => s.isLoading, 'isLoading', true),
          isA<QuizState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.apiError, 'apiError', isNotNull),
        ],
      );
    });
  });
}
