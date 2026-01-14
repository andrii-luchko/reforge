import 'package:reforge/features/workout_instruction/data/models/exercise_details.dart';

final List<ExerciseDetails> mockExercises = [
  // ID 1: Для "Full Body Blast"
  const ExerciseDetails(
    id: 1,
    name: 'Barbell Deadlift',
    description:
        'The ultimate full-body compound movement. Targets the posterior chain, including hamstrings, glutes, and lower back.',
    videoUrl: null,
    imageUrl: 'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
    instructionSteps: {
      'Setup':
          'Stand with feet hip-width apart, toes pointing forward. The barbell should be over the middle of your feet.',
      'Grip':
          'Bend at the hips and knees to grasp the bar. Hands should be shoulder-width apart, just outside your legs.',
      'Brace':
          'Straighten your back, drop your hips slightly, and engage your core. Keep your chest up and shoulders back.',
      'Lift': 'Drive through your heels to lift the bar. Keep the bar close to your shins and thighs as you rise.',
      'Lockout': 'Stand tall at the top, fully extending your hips. Do not lean back excessively. Squeeze your glutes.',
    },
  ),

  // ID 2: Для "Cardio Burnout"
  const ExerciseDetails(
    id: 2,
    name: 'High Intensity Burpees',
    description:
        'A full-body exercise used in strength training and as an aerobic exercise. Great for burning calories quickly.',
    videoUrl: 'https://www.youtube.com/watch?v=TU8QYXL8gJk',
    imageUrl: 'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
    instructionSteps: {
      'Start Position': 'Stand with your feet shoulder-width apart and arms at your sides.',
      'The Drop': 'Lower your body into a squat and place your hands on the floor in front of you.',
      'Kick Back': 'Jump your feet back so that you land in a plank position. Keep your body in a straight line.',
      'Push Up': 'Optional: Perform a push-up, keeping your elbows tucked close to your body.',
      'Return': 'Jump your feet back towards your hands to return to the squat position.',
      'Explode': 'Jump up into the air, reaching your arms overhead.',
    },
  ),

  // ID 3: Для "Core Crusher"
  const ExerciseDetails(
    id: 3,
    name: 'Weighted Russian Twists',
    description:
        'A core exercise that targets the obliques and abdominals. Improves rotational strength and stability.',
    videoUrl: null,
    imageUrl: 'https://hardtokillfitness.co/cdn/shop/articles/deadlifts-9728886.png?v=1755466823&width=1500',
    instructionSteps: {
      'Sit Down': 'Sit on the floor with your knees bent and feet lifted slightly off the ground.',
      'Lean Back':
          'Lean back so your torso is at a 45-degree angle to the floor. Engage your core to keep your back straight.',
      'Hold Weight': 'Hold a weight plate or dumbbell with both hands in front of your chest.',
      'Twist Right': 'Rotate your torso to the right, bringing the weight beside your right hip.',
      'Twist Left': 'Rotate your torso to the left, bringing the weight beside your left hip.',
      'Repeat': 'Continue alternating sides in a controlled motion.',
    },
  ),
];
