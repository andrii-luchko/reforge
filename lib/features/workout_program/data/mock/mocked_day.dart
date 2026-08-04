import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_program/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_program/data/models/program_exercise_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';

final List<ExerciseDetailsDTO> newMockExercises = [
  // ID 1: Barbell Deadlift
  const ExerciseDetailsDTO(
    id: 1,
    name: 'Barbell Deadlift',
    description:
        'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
    key: 'deadlift',
    type: 1,
    metrics: ['weightKg', 'reps'],
    videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),
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
  id: 30,
  name: 'Day 1 with Intervals',
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
      sets: 4,
      exerciseDetails: newMockExercises[1],
    ),

    const ProgramExerciseDTO(
      id: 110,
      order: 3,
      executionMode: 'segmented',
      sets: 2,
      exerciseDetails: ExerciseDetailsDTO(
        id: 4,
        name: 'Running Intervals',
        type: 2,
        key: 'running',
        metrics: ['durationSec', 'distanceM', 'speedKmH'],
        videoInstructionUrl: 'https://video.url/running',
        thumbnailInstructionUrl: 'https://thumb.url/running',
        description: 'Cardiovascular endurance exercise that improves heart health.',
      ),
      segments: [
        ExerciseSegmentDTO(
          id: 1,
          order: 4,
          activity: 'run',
          targetMetric: 'distance',
          label: 'Sprint block',
          distanceM: 100,
        ),
        ExerciseSegmentDTO(
          id: 2,
          order: 2,
          activity: 'walk',
          targetMetric: 'duration',
          label: 'Rest block',
          durationSec: 60,
        ),
      ],
    ),
    const ProgramExerciseDTO(
      id: 111,
      order: 5,
      executionMode: 'segmented',
      sets: 2,
      exerciseDetails: ExerciseDetailsDTO(
        id: 4,
        name: 'Running Intervals',
        type: 2,
        key: 'running',
        metrics: ['durationSec', 'distanceM', 'speedKmH'],
        videoInstructionUrl: 'https://video.url/running',
        thumbnailInstructionUrl: 'https://thumb.url/running',
        description: 'Cardiovascular endurance exercise that improves heart health.',
      ),
      segments: [
        ExerciseSegmentDTO(
          id: 3,
          order: 1,
          activity: 'run',
          targetMetric: 'distance',
          label: 'Sprint block',
          distanceM: 100,
        ),
        ExerciseSegmentDTO(
          id: 4,
          order: 2,
          activity: 'walk',
          targetMetric: 'duration',
          label: 'Rest block',
          durationSec: 60,
        ),
      ],
    ),
  ],
).toEntity();

// final ProgramDayEntity mockProgramDay = ProgramDayDTO(
//   id: 0,
//   name: 'Loading Workout Program...',
//   dayNumber: 1,
//   exercises: [
//     ProgramExerciseDTO(
//       id: 1,
//       order: 1,
//       executionMode: ExecutionMode.standard.name,
//       sets: 4,
//       exerciseDetails: newMockExercises[0],
//     ),
//     ProgramExerciseDTO(
//       id: 2,
//       order: 2,
//       executionMode: ExecutionMode.standard.name,
//       sets: 3,
//       exerciseDetails: newMockExercises[1],
//     ),
//     ProgramExerciseDTO(
//       id: 3,
//       order: 3,
//       executionMode: ExecutionMode.standard.name,
//       sets: 3,
//       exerciseDetails: newMockExercises[2],
//     ),
//   ],
// ).toEntity();
