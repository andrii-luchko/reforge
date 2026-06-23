// ignore_for_file: prefer_first
import 'package:reforge/features/workout_common/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_flow/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_flow/data/models/program_exercise_dto.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';

final List<ExerciseDetailsDTO> newMockExercises = [
  // ID 1: Barbell Deadlift
  const ExerciseDetailsDTO(
    id: 1,
    name: 'Barbell Deadlift',
    description:
        'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
    key: 'deadlift',

    metrics: ['weightKg', 'reps'],
    videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),

  // ID 2: High Intensity Burpees
  const ExerciseDetailsDTO(
    id: 2,
    name: 'High Intensity Burpees',
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
      sets: 4,
      exerciseDetails: newMockExercises[0],
    ),
    ProgramExerciseDTO(
      id: 2,
      order: 2,
      sets: 3,
      exerciseDetails: newMockExercises[1],
    ),
    ProgramExerciseDTO(
      id: 3,
      order: 3,
      sets: 3,
      exerciseDetails: newMockExercises[2],
    ),
  ],
).toEntity();
