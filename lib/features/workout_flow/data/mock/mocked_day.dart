// ignore_for_file: prefer_first
import 'dart:convert';

import 'package:reforge/features/workout_common/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_flow/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_flow/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_flow/data/models/program_exercise_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';

final List<ExerciseDetailsDTO> newMockExercises = [
  // ID 1: Barbell Deadlift
  // const ExerciseDetailsDTO(
  //   id: 1,
  //   name: 'Barbell Deadlift',
  //   description:
  //       'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
  //   key: 'deadlift',

  //   metrics: ['weightKg', 'reps'],
  //   videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  //   thumbnailInstructionUrl:
  //       'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  // ),
  const ExerciseDetailsDTO(
    id: 1,
    name: 'Some angle exercise',
    description:
        'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
    key: 'angle',
    type: 3,
    metrics: ['angleDeg'],
    poseDetectionPreset: 'spine',
    videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),

  // const ExerciseDetailsDTO(
  //   id: 1,
  //   name: 'Run 5 km',
  //   description:
  //       'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
  //   key: 'deadlift',

  //   metrics: ['durationSec', 'distanceM', 'speedKmH'],
  //   videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  //   thumbnailInstructionUrl:
  //       'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  // ),

  // ID 2: High Intensity Burpees
  const ExerciseDetailsDTO(
    id: 2,
    name: 'High Intensity Burpees',
    type: 1,
    description:
        'A full-body exercise used in strength training and as an aerobic exercise. Great for burning calories quickly.',
    key: 'burpees',
    metrics: ['reps'],
    videoInstructionUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),

  // ID 3: Weighted Twists
  const ExerciseDetailsDTO(
    id: 3,
    name: 'Weighted Twists',
    type: 1,
    description:
        'A core exercise that targets the obliques and abdominals. Improves rotational strength and stability.',
    key: 'twists',

    metrics: ['weightKg', 'reps', 'angleDeg'],
    videoInstructionUrl: 'https://www.youtube.com/watch?v=3mDny9XAgic',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),
];

final ProgramDayEntity mockProgramDay = ProgramDayDTO(
  id: 0,
  name: 'Loading Workout Program...',
  dayNumber: 1,
  exercises: [
    ProgramExerciseDTO(
      id: 1,
      order: 1,
      executionMode: ExecutionMode.standard.name,
      sets: 4,
      exerciseDetails: newMockExercises[0],
    ),
    ProgramExerciseDTO(
      id: 2,
      order: 2,
      executionMode: ExecutionMode.standard.name,
      sets: 3,
      exerciseDetails: newMockExercises[1],
    ),
    ProgramExerciseDTO(
      id: 3,
      order: 3,
      executionMode: ExecutionMode.standard.name,
      sets: 3,
      exerciseDetails: newMockExercises[2],
    ),
  ],
).toEntity();

final parsedMockedDay = ProgramDayDTO.fromJson(
  jsonDecode('''
{

"id": 30,

"programId": 15,

"exerciseTypeId": 2,

"dayNumber": 1,

"name": "Day 1",

"createdAt": "2026-06-25T14:00:53.983Z",

"updatedAt": "2026-06-25T14:00:53.983Z",

"exercises": [

{

"id": 110,

"programDayId": 30,

"exerciseId": 4,

"order": 1,

"sets": 2,

"executionMode": "segmented",

"tier": null,

"reps": null,

"durationSec": null,

"weightKg": null,

"angleDeg": null,

"speedKmH": null,

"distanceM": null,

"createdAt": "2026-06-25T14:00:53.983Z",

"updatedAt": "2026-06-25T14:00:53.983Z",

"exercise": {

"id": 4,

"factionId": 3,

"type": 2,

"fileUploadType": null,

"isTiered": false,

"isPoseDetectionEnabled": false,

"poseDetectionPreset": null,

"name": "Running",

"description": "Cardiovascular endurance exercise that improves heart health and stamina.",

"key": "running",

"metrics": [

"durationSec",

"distanceM",

"speedKmH"

],

"staticData": {},

"videoInstructionUrl": "https://video.url/running",

"thumbnailInstructionUrl": "https://thumb.url/running",

"createdAt": "2025-12-22T16:03:19.119Z",

"updatedAt": "2025-12-22T16:03:19.119Z"

},

"segments": [

{

"id": 1,

"workoutProgramExerciseId": 110,

"order": 1,

"activity": "run",

"targetMetric": "distance",

"role": "work",

"distanceM": 100,

"durationSec": null,

"label": "1231231dsa",

"createdAt": "2026-06-25T14:00:53.983Z",

"updatedAt": "2026-06-25T14:00:54.819Z"

},

{

"id": 2,

"workoutProgramExerciseId": 110,

"order": 2,

"activity": "walk",

"targetMetric": "duration",

"role": "work",

"distanceM": null,

"durationSec": 60,

"label": "dsadsadas",

"createdAt": "2026-06-25T14:00:53.983Z",

"updatedAt": "2026-06-25T14:00:54.927Z"

}

]

}

]

}
''')
      as Map<String, dynamic>,
);
