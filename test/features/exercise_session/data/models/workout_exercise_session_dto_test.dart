import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/data/requests/create_workout_exercise_session_request.dart';
import 'package:reforge/features/exercise_session/data/requests/swap_exercise_request.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';

void main() {
  group('workout exercise session contracts', () {
    test('encodes create request and decodes the abbreviated POST response', () {
      const request = CreateWorkoutExerciseSessionRequest(
        exerciseId: 33,
        workoutSessionId: 169,
        workoutProgramExerciseId: 100,
      );

      expect(request.toJson(), {
        'exerciseId': 33,
        'workoutSessionId': 169,
        'workoutProgramExerciseId': 100,
      });

      final response = BaseResponse<WorkoutExerciseSessionDTO>.fromJson(
        _sessionResponse(isSwapped: false, swappedExerciseId: null),
        (json) => WorkoutExerciseSessionDTO.fromJson(json! as Map<String, dynamic>),
      );

      expect(response.status, 'success');
      expect(response.data.id, 222);
      expect(response.data.isSwapped, isFalse);
      expect(response.data.isActive, isTrue);
      expect(response.data.sets, isEmpty);
      expect(response.data.exercise, isNull);
    });

    test('encodes swap request and decodes the latest PATCH result', () {
      const request = SwapExerciseRequest(swappedExerciseId: 14);

      expect(request.toJson(), {'swappedExerciseId': 14});

      final response = BaseResponse<WorkoutExerciseSessionDTO>.fromJson(
        _sessionResponse(isSwapped: true, swappedExerciseId: 14),
        (json) => WorkoutExerciseSessionDTO.fromJson(json! as Map<String, dynamic>),
      );

      expect(response.data.id, 222);
      expect(response.data.isSwapped, isTrue);
      expect(response.data.swappedExerciseId, 14);
    });

    test('decodes GET session and resolves the swapped exercise as effective', () {
      final details = WorkoutSessionDetailsDTO.fromJson({
        'id': 172,
        'workoutProgramDayId': 25,
        'duration': 2567,
        'status': 'canceled',
        'totalXpEarned': 0,
        'createdAt': '2026-07-31T14:16:16.281Z',
        'exerciseSessions': [
          {
            'id': 999,
            'exerciseId': 33,
            'workoutSessionId': 172,
            'workoutProgramExerciseId': 100,
          },
        ],
        'workoutSessions': [
          {
            'id': 228,
            'exerciseId': 33,
            'workoutSessionId': 172,
            'workoutProgramExerciseId': 100,
            'isSwapped': true,
            'swappedExerciseId': 14,
            'isActive': true,
            'notes': 'keep me',
            'lastCompletedSet': null,
            'createdAt': '2026-07-31T14:43:33.058Z',
            'updatedAt': '2026-07-31T14:59:07.374Z',
            'sets': [
              {
                'id': 501,
                'exerciseId': 14,
                'exerciseSessionId': 228,
                'durationSec': 120,
                'distanceM': 1000,
                'setNumber': 1,
              },
            ],
            'exercise': _exerciseJson(id: 33, name: 'Original', key: 'original', type: 1),
            'swappedExercise': _exerciseJson(id: 14, name: '1km Run', key: '1km_run', type: 3),
          },
        ],
      });

      expect(details.workoutSessions, hasLength(1));
      final dto = details.workoutSessions!.single;
      expect(dto.id, 228);

      final entity = dto.toEntity(MeasurementSystem.metric);
      expect(entity.exercise?.id, 33);
      expect(entity.swappedExercise?.id, 14);
      expect(entity.effectiveExercise?.id, 14);
      expect(entity.effectiveExercise?.isRunningSwapCandidate, isTrue);
      expect(entity.notes, 'keep me');
      expect(entity.sets.single.distance, 1);
      expect(entity.sets.single.time, const Duration(seconds: 120));
    });

    test('resolves the original exercise when session is not swapped', () {
      final dto = WorkoutExerciseSessionDTO.fromJson({
        'id': 228,
        'exerciseId': 33,
        'workoutSessionId': 172,
        'workoutProgramExerciseId': 100,
        'isSwapped': false,
        'swappedExerciseId': null,
        'exercise': _exerciseJson(id: 33, name: 'Original', key: 'original', type: 1),
      });

      expect(dto.toEntity(MeasurementSystem.metric).effectiveExercise?.id, 33);
    });

    test('duplicate selection prefers the first session containing sets', () {
      const details = WorkoutSessionDetailsDTO(
        id: 172,
        workoutProgramDayId: 25,
        duration: 0,
        status: WorkoutSessionStatus.active,
        totalXpEarned: 0,
        workoutSessions: [
          WorkoutExerciseSessionDTO(
            id: 228,
            exerciseId: 33,
            workoutSessionId: 172,
            workoutProgramExerciseId: 100,
          ),
          WorkoutExerciseSessionDTO(
            id: 229,
            exerciseId: 33,
            workoutSessionId: 172,
            workoutProgramExerciseId: 100,
            sets: [
              ExerciseSetDTO(
                id: 501,
                exerciseId: 33,
                exerciseSessionId: 229,
              ),
            ],
          ),
          WorkoutExerciseSessionDTO(
            id: 230,
            exerciseId: 33,
            workoutSessionId: 172,
            workoutProgramExerciseId: 100,
            sets: [
              ExerciseSetDTO(
                id: 502,
                exerciseId: 33,
                exerciseSessionId: 230,
              ),
            ],
          ),
        ],
      );

      expect(details.exerciseSessionsByProgramExerciseId[100]?.id, 229);
    });
  });
}

Map<String, dynamic> _sessionResponse({required bool isSwapped, required int? swappedExerciseId}) {
  return {
    'data': {
      'id': 222,
      'exerciseId': 33,
      'workoutSessionId': 169,
      'workoutProgramExerciseId': 100,
      'isSwapped': isSwapped,
      'swappedExerciseId': swappedExerciseId,
      'notes': '',
      'createdAt': '2026-07-31T14:43:33.058Z',
      'updatedAt': '2026-07-31T14:43:33.058Z',
    },
    'status': 'success',
  };
}

Map<String, dynamic> _exerciseJson({
  required int id,
  required String name,
  required String key,
  required int type,
}) {
  return {
    'id': id,
    'name': name,
    'description': '$name description',
    'type': type,
    'factionId': type,
    'key': key,
    'metrics': type == 3 ? ['durationSec', 'distanceM'] : ['reps'],
    'staticData': <String, dynamic>{},
    'isPoseDetectionEnabled': false,
    'poseDetectionPreset': null,
    'videoInstructionUrl': null,
    'thumbnailInstructionUrl': null,
  };
}
