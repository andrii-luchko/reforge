import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/features/exercise_session/data/models/complete_set_request.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/data/requests/create_workout_exercise_session_request.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_session/data/models/workout_session.dart';
import 'package:reforge/features/workout_session/data/models/workout_session_details_dto.dart';
import 'package:reforge/features/workout_session/data/requests/start_workout_session_request.dart';

void main() {
  group('Free Run API contract', () {
    test('parses a workout session without a program day', () {
      final response = BaseResponse<WorkoutSession>.fromJson(
        _fixture('free_run_workout_session.json'),
        (json) => WorkoutSession.fromJson(json! as Map<String, dynamic>),
      );

      expect(response.data.id, 182);
      expect(response.data.workoutProgramDayId, isNull);
      expect(response.data.status, WorkoutSessionStatus.active);
    });

    test('serializes program and ad-hoc start payloads explicitly', () {
      expect(
        StartWorkoutSessionRequest.program(workoutProgramDayId: 25).toJson(),
        {'workoutProgramDayId': 25},
      );
      expect(StartWorkoutSessionRequest.adHoc().toJson(), isEmpty);
    });

    test('serializes program and ad-hoc exercise session payloads', () {
      expect(
        CreateWorkoutExerciseSessionRequest.program(
          exerciseId: 4,
          workoutSessionId: 182,
          workoutProgramExerciseId: 100,
        ).toJson(),
        {
          'exerciseId': 4,
          'workoutSessionId': 182,
          'workoutProgramExerciseId': 100,
        },
      );
      expect(
        CreateWorkoutExerciseSessionRequest.adHoc(
          exerciseId: 4,
          workoutSessionId: 182,
        ).toJson(),
        {'exerciseId': 4, 'workoutSessionId': 182},
      );
    });

    test('serializes a Free Run set without program bindings', () {
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: WorkoutSet(
          id: 1,
          clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
          time: const Duration(seconds: 60),
          distance: 1,
          speed: 10.5,
          pace: 60 / 10.5,
        ),
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );

      expect(request.toJson(), {
        'exerciseId': 4,
        'workoutSessionId': 182,
        'exerciseSessionId': 246,
        'idempotencyKey': '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
        'durationSec': 60,
        'speedKmH': 10.5,
        'distanceM': 1000.0,
      });
    });

    test('omits zero running speed while preserving a manually completed set', () {
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: WorkoutSet(
          id: 1,
          time: const Duration(seconds: 2),
          distance: 0,
          speed: 0,
          pace: 0,
        ),
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.metric,
      );

      expect(request.speedKmH, isNull);
      expect(request.toJson(), {
        'exerciseId': 4,
        'workoutSessionId': 182,
        'exerciseSessionId': 246,
        'durationSec': 2,
        'distanceM': 0.0,
      });
    });

    test('keeps the legacy program set payload and adds runtime identity', () {
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: WorkoutSet(id: 1, reps: 10, weight: 80),
        exerciseId: 8,
        workoutSessionId: 182,
        exerciseSessionId: 247,
        workoutProgramExerciseId: 100,
        system: MeasurementSystem.metric,
      );

      expect(request.toJson(), {
        'exerciseId': 8,
        'workoutSessionId': 182,
        'exerciseSessionId': 247,
        'workoutProgramExerciseId': 100,
        'reps': 10,
        'weightKg': 80.0,
      });
    });

    test('serializes imperial speed as km/h without sending derived pace', () {
      final request = CreateSetSessionRequest.fromWorkoutSet(
        set: WorkoutSet(
          id: 1,
          speed: 5.1,
          pace: 60 / 5.1,
        ),
        exerciseId: 4,
        workoutSessionId: 182,
        exerciseSessionId: 246,
        system: MeasurementSystem.imperial,
      );

      expect(request.speedKmH, closeTo(8.2076544, 0.000001));
      final json = request.toJson();
      expect(json, {
        'exerciseId': 4,
        'workoutSessionId': 182,
        'exerciseSessionId': 246,
        'speedKmH': request.speedKmH,
      });
    });

    test('parses active and completed unbound exercise sessions', () {
      final active = _detailsFixture('free_run_active_details.json');
      final completed = _detailsFixture('free_run_completed_details.json');

      expect(active.workoutProgramDayId, isNull);
      expect(active.normalizedExerciseSessions.single.toEntity(MeasurementSystem.metric).id, 246);

      final session = completed.normalizedExerciseSessions.single;
      final set = session.sets.single;
      expect(completed.status, WorkoutSessionStatus.completed);
      expect(session.workoutProgramExerciseId, isNull);
      expect(set.id, 368);
      expect(set.clientSetId, '019893a2-7078-76f9-8e8f-bf8e3b16bf93');
      expect(set.programSegmentId, isNull);

      final history = completed.toEntity(MeasurementSystem.metric);
      expect(history.exercises, hasLength(1));
      expect(history.exercises.single.name, 'Running');
      expect(history.exercises.single.sets.single.distance, 1);
      expect(history.exercises.single.sets.single.speed, 10.5);
      expect(history.exercises.single.sets.single.pace, closeTo(60 / 10.5, 0.000001));
    });

    test('maps backend idempotencyKey to the local client set identity', () {
      final response = BaseResponse<ExerciseSetDTO>.fromJson(
        {
          'data': {
            'id': 368,
            'exerciseId': 4,
            'exerciseSessionId': 246,
            'idempotencyKey': '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
            'durationSec': 60,
            'distanceM': 1000,
            'setNumber': 1,
          },
          'status': 'success',
        },
        (json) => ExerciseSetDTO.fromJson(json! as Map<String, dynamic>),
      );

      expect(response.data.id, 368);
      expect(response.data.clientSetId, '019893a2-7078-76f9-8e8f-bf8e3b16bf93');
    });
  });
}

WorkoutSessionDetailsDTO _detailsFixture(String name) {
  return BaseResponse<WorkoutSessionDetailsDTO>.fromJson(
    _fixture(name),
    (json) => WorkoutSessionDetailsDTO.fromJson(json! as Map<String, dynamic>),
  ).data;
}

Map<String, dynamic> _fixture(String name) {
  final file = File('test/features/workout_session/data/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}
