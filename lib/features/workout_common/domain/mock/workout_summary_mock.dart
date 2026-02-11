import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';

const mockWorkoutResult = WorkoutSessionSummaryEntity(
  id: 771823,
  duration: 5400,
  totalXpEarned: 1250,

  isLevelUp: true,
  currentLevel: 15,
  earnedMilestones: [
    UserWorkoutMilestoneEntity(
      id: 101,
      name: 'Peak of Might',
      tier: 3,
      iconUrl: 'https://my-cdn.com/icons/endurance_gold.png',
    ),

    UserWorkoutMilestoneEntity(
      id: 204,
      name: 'Peak of Might',
      tier: 1,
      iconUrl: null,
    ),
  ],
);
