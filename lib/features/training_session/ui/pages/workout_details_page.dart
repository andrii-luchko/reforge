import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_info_chip_list_view.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_list_tile.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutDetailsPage extends StatelessWidget {
  const WorkoutDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: AppAppBar(
        onPressed: Navigator.of(context).pop,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Power Builder Routine',
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(body: WorkoutDetailsBody()),
    );
  }
}

class WorkoutDetailsBody extends StatelessWidget {
  const WorkoutDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.5 - 32; //minus padding
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Skeletonizer(
          enabled: false,
          child: Column(
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Yamakata',
                          style: subheadH2Medium.copyWith(color: appTheme.beige100),
                        ),
                      ),

                      const WorkoutInfoChipListView(
                        chips: ['xp 3000', 'duration: 45 mins', 'Equipment: Dumbbells'],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 16),
                        child: Text(
                          '3 Exercises',
                          style: subheadH2Medium.copyWith(color: appTheme.beige100),
                        ),
                      ),

                      WorkoutListTile(
                        title: 'Full Body Blast',
                        description: 'A comprehensive full-body workout to build strength and endurance.',
                        imageUrl: 'https://example.com/workout1.jpg',
                        tags: const ['10 reps', 'xp 1500'],
                        onTap: () async {
                          // ignore: inference_failure_on_function_invocation
                          await const WorkoutInstructionPageRoute(name: 'Full Body Blast', workoutId: 1).push(context);
                        },
                      ),

                      const SizedBox(height: 8),
                      WorkoutListTile(
                        title: 'Cardio Burnout',
                        description: 'An intense cardio session to boost your heart rate and burn calories.',
                        imageUrl: 'https://example.com/workout2.jpg',
                        tags: const ['10 reps', 'xp 1500'],
                        onTap: () async {
                          // ignore: inference_failure_on_function_invocation
                          await const WorkoutInstructionPageRoute(name: 'Cardio Burnout', workoutId: 2).push(context);
                        },
                      ),
                      const SizedBox(height: 8),
                      WorkoutListTile(
                        title: 'Core Crusher',
                        description: 'A focused core workout to strengthen your abs and lower back.',
                        imageUrl: 'https://example.com/workout3.jpg',
                        tags: const ['10 reps', 'xp 1500'],
                        onTap: () async {
                          // ignore: inference_failure_on_function_invocation
                          await const WorkoutInstructionPageRoute(name: 'Core Crusher', workoutId: 3).push(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Skeleton.leaf(
                  child: SizedBox(
                    width: buttonWidth,
                    child: PrimaryButton(text: 'Start Workout', onPressed: () {}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
