import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/exercise_session/data/models/swap_exercise_search_item_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

void main() {
  test('maps a swap-search static target to the exercise entity', () {
    final dto = SwapExerciseSearchItemDTO.fromJson({
      'id': 40,
      'name': '3km Run',
      'description': 'Run 3km',
      'faction': {
        'id': 3,
        'name': 'Running',
        'slug': 'gyohyo',
      },
      'metrics': ['durationSec'],
      'staticData': {'distanceM': 3000},
    });

    expect(dto.toEntity().runningTarget, const ExerciseRunningTarget.distance(3000));
  });
}
