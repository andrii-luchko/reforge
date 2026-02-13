import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/calendar/controllers/training_details/training_details_cubit.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../mocks/mock_calendar_repository.dart';

TrainingDetailsEntity createTestTrainingDetailsEntity() {
  return TrainingDetailsEntity(
    id: 1,
    date: DateTime(2025, 1, 15),
    duration: 3600,
    totalXpEarned: 100,
    exercises: [],
    measurementSystem: MeasurementSystem.metric,
  );
}

void main() {
  late MockCalendarRepository mockRepository;

  setUp(() {
    mockRepository = MockCalendarRepository();
  });

  group('TrainingDetailsCubit', () {
    test('loadWorkoutDetails emits Loaded when repository succeeds', () async {
      when(() => mockRepository.getWorkoutDetails(1))
          .thenAnswer((_) async => Result.success(createTestTrainingDetailsEntity()));
      final cubit = TrainingDetailsCubit(mockRepository, 1);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.maybeWhen(loaded: (_) => true, orElse: () => false), isTrue);
      expect(cubit.state.maybeWhen(loaded: (d) => d.id, orElse: () => 0), 1);
    });

    test('loadWorkoutDetails emits Error when repository fails', () async {
      when(() => mockRepository.getWorkoutDetails(1))
          .thenAnswer((_) async => Result.error(Exception('Network error')));
      final cubit = TrainingDetailsCubit(mockRepository, 1);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.maybeWhen(error: (_) => true, orElse: () => false), isTrue);
    });

    test('refresh calls loadWorkoutDetails with forceRefresh true', () async {
      when(() => mockRepository.getWorkoutDetails(1))
          .thenAnswer((_) async => Result.success(createTestTrainingDetailsEntity()));
      when(() => mockRepository.getWorkoutDetails(1, forceRefresh: true))
          .thenAnswer((_) async => Result.success(createTestTrainingDetailsEntity()));
      final cubit = TrainingDetailsCubit(mockRepository, 1);
      await Future.delayed(const Duration(milliseconds: 50));
      await cubit.refresh();
      verify(() => mockRepository.getWorkoutDetails(1, forceRefresh: true)).called(1);
    });
  });
}
