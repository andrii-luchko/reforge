import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';

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
}
