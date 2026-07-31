import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/exercise_session/data/requests/swap_exercise_search_request.dart';
import 'package:reforge/features/exercise_session/data/responses/swap_exercise_search_response.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  group('swap exercise search contract', () {
    test('encodes optional filters and pagination', () {
      const request = SwapExerciseSearchRequest(search: 'run', factionId: 3, page: 2);

      expect(request.toJson(), {
        'search': 'run',
        'factionId': 3,
        'page': 2,
        'limit': 20,
      });
      expect(const SwapExerciseSearchRequest().toJson(), {'page': 1, 'limit': 20});
    });

    test('decodes data and pagination without requiring type or key', () {
      final response = SwapExerciseSearchResponse.fromJson({
        'data': [
          {
            'id': 14,
            'name': '1km Run',
            'description': 'Fixed distance sprint or time trial.',
            'isPoseDetectionEnabled': false,
            'poseDetectionPreset': null,
            'videoInstructionUrl': null,
            'thumbnailInstructionUrl': null,
            'metrics': ['durationSec'],
            'staticData': <String, dynamic>{},
            'createdAt': '2025-12-25T11:49:48.397Z',
            'updatedAt': '2025-12-25T11:49:48.397Z',
            'faction': {
              'id': 3,
              'name': 'Running',
              'slug': 'gyohyo',
            },
            'bodyParts': [
              {'id': 7, 'name': 'Legs'},
            ],
          },
        ],
        'meta': {
          'pagination': {'page': 1, 'total': 45, 'limit': 20, 'pages': 3},
        },
        'status': 'success',
      });

      expect(response.status, 'success');
      expect(response.meta.pagination.total, 45);
      expect(response.meta.pagination.pages, 3);
      expect(response.data.single.bodyParts.single['name'], 'Legs');

      final exercise = response.data.single.toEntity();
      expect(exercise.id, 14);
      expect(exercise.key, isNull);
      expect(exercise.type, isNull);
      expect(exercise.metrics, [WorkoutMetric.time]);
      expect(exercise.isRunningSwapCandidate, isTrue);
    });

    test('does not classify duration-only non-running faction as running', () {
      final item = SwapExerciseSearchResponse.fromJson({
        'data': [
          {
            'id': 12,
            'name': 'Frog Stretch',
            'description': 'Passive stretch.',
            'metrics': ['durationSec'],
            'staticData': <String, dynamic>{},
            'faction': {'id': 2, 'name': 'Flexibility', 'slug': 'seiren'},
          },
        ],
        'meta': {
          'pagination': {'page': 1, 'total': 1, 'limit': 20, 'pages': 1},
        },
        'status': 'success',
      }).data.single;

      expect(item.toEntity().isRunningSwapCandidate, isFalse);
    });

    test('classifies distance metric as running without running faction', () {
      final item = SwapExerciseSearchResponse.fromJson({
        'data': [
          {
            'id': 4,
            'name': 'Distance exercise',
            'description': '',
            'metrics': ['distanceM'],
            'staticData': <String, dynamic>{},
            'faction': {'id': 1, 'name': 'Strength', 'slug': 'gakki'},
          },
        ],
        'meta': {
          'pagination': {'page': 1, 'total': 1, 'limit': 20, 'pages': 1},
        },
        'status': 'success',
      }).data.single;

      expect(item.toEntity().isRunningSwapCandidate, isTrue);
    });
  });
}
