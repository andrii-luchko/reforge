import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/workout_program/data/models/exercise_catalog_item_dto.dart';
import 'package:reforge/features/workout_program/data/repositories/exercise_catalog_repository.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  test('loads an exercise from the global catalog', () async {
    final apiClient = _MockApiClient();
    final repository = ExerciseCatalogRepositoryImpl(apiClient);
    when(() => apiClient.getExercise(4)).thenAnswer(
      (_) async => const BaseResponse(
        data: ExerciseCatalogItemDTO(
          id: 4,
          name: 'Running',
          description: 'Run',
          faction: ExerciseFactionDTO(id: 3, name: 'Running', slug: 'gyohyo'),
          metrics: ['durationSec', 'distanceM'],
        ),
        status: 'success',
      ),
    );

    final result = await repository.getExercise(4);

    expect(result.isSuccess, isTrue);
    expect(result.orNull?.id, 4);
    expect(result.orNull?.key, isNull);
    verify(() => apiClient.getExercise(4)).called(1);
  });
}
