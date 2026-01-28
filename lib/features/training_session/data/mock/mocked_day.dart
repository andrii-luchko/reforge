import 'package:reforge/features/training_session/data/models/exercise_details.dart';
import 'package:reforge/features/training_session/data/models/program_day.dart';
import 'package:reforge/features/training_session/data/models/program_exercise.dart';
import 'package:reforge/features/training_session/domain/enums/workout_metrics.dart';

final List<ExerciseDetails> newMockExercises = [
  // ID 1: Barbell Deadlift
  const ExerciseDetails(
    id: 1,
    name: 'Barbell Deadlift',
    description:
        'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
    key: 'deadlift',

    metrics: [WorkoutMetric.weight, WorkoutMetric.reps],
    videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),

  // ID 2: High Intensity Burpees
  const ExerciseDetails(
    id: 2,
    name: 'High Intensity Burpees',
    description:
        'A full-body exercise used in strength training and as an aerobic exercise. Great for burning calories quickly.',
    key: 'burpees',
    metrics: [WorkoutMetric.reps],
    videoInstructionUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),

  // ID 3: Weighted Twists
  const ExerciseDetails(
    id: 3,
    name: 'Weighted Twists',
    description:
        'A core exercise that targets the obliques and abdominals. Improves rotational strength and stability.',
    key: 'twists',

    metrics: [WorkoutMetric.weight, WorkoutMetric.reps, WorkoutMetric.degrees],
    videoInstructionUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    thumbnailInstructionUrl:
        'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
  ),
];

final mockProgramDay = ProgramDay(
  id: 0,
  name: 'Loading Workout Program...',
  dayNumber: 1,
  exercises: [
    ProgramExercise(
      id: 1,
      order: 1,
      sets: 4,
      exerciseDetails: newMockExercises[0],
    ),
    ProgramExercise(
      id: 2,
      order: 2,
      sets: 3,
      exerciseDetails: newMockExercises[1],
    ),
    ProgramExercise(
      id: 3,
      order: 3,
      sets: 3,
      exerciseDetails: newMockExercises[2],
    ),
  ],
);
