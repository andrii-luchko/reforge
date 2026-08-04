import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

void main() {
  group('ExerciseDetailsDTO instructions', () {
    test('maps the API instructions list to instructionsSteps', () {
      final dto = ExerciseDetailsDTO.fromJson({
        'id': 1,
        'name': 'Exercise',
        'description': 'Description',
        'type': 1,
        'key': 'exercise',
        'instructions': [
          {'step12132131': 'dsadasdasdas'},
          {'step2': 'some desc of step 2'},
          {'step333': 'line 1\n\nline 2'},
        ],
      });

      expect(dto.instructionsSteps, {
        'step12132131': 'dsadasdasdas',
        'step2': 'some desc of step 2',
        'step333': 'line 1\n\nline 2',
      });
    });

    test('maps instructionsSteps back to the API instructions list', () {
      const dto = ExerciseDetailsDTO(
        id: 1,
        name: 'Exercise',
        description: 'Description',
        type: 1,
        key: 'exercise',
        instructionsSteps: {
          'step1': 'First step',
          'step2': 'Second step',
        },
      );

      expect(dto.toJson()['instructions'], [
        {'step1': 'First step'},
        {'step2': 'Second step'},
      ]);
      expect(dto.toJson(), isNot(contains('instructionsSteps')));
    });
  });

  group('ExerciseDetailsDTO static running target', () {
    test('maps distanceM to a distance target', () {
      final entity = _dtoWithStaticData(const StaticDataDTO(distanceM: 3000)).toEntity();

      expect(entity.runningTarget, const ExerciseRunningTarget.distance(3000));
    });

    test('maps durationSec to a duration target', () {
      final entity = _dtoWithStaticData(const StaticDataDTO(durationSec: 720)).toEntity();

      expect(entity.runningTarget, const ExerciseRunningTarget.duration(720));
    });

    test('ignores conflicting targets', () {
      final entity = _dtoWithStaticData(
        const StaticDataDTO(distanceM: 3000, durationSec: 720),
      ).toEntity();

      expect(entity.runningTarget, isNull);
    });

    test('ignores a non-positive target', () {
      final entity = _dtoWithStaticData(const StaticDataDTO(distanceM: 0)).toEntity();

      expect(entity.runningTarget, isNull);
    });
  });
}

ExerciseDetailsDTO _dtoWithStaticData(StaticDataDTO staticData) {
  return ExerciseDetailsDTO(
    id: 1,
    name: 'Exercise',
    description: 'Description',
    type: 2,
    key: 'exercise',
    staticData: staticData,
  );
}
