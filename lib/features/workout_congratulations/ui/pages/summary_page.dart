import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/congratulations_action_buttons.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/share_content_widgets.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/summary_content_widget.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutSummaryPage extends StatelessWidget {
  const WorkoutSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.select((WorkoutCongratulationsCubit c) => c.state.workoutResult);

    if (result == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Spacer(),
            SummaryContentWidget(
              xpProgress: null,
              newLevel: result.isLevelUp ? result.currentLevel : null,
              xpEarned: result.totalXpEarned,
              timeSpentSec: result.duration,
            ),
            const Spacer(),
            CongratulationsActionButtons(
              shareContent: SummaryShareContent(
                xpProgress: null,
                newLevel: result.isLevelUp ? result.currentLevel : null,
                xpEarned: result.totalXpEarned,
                timeSpentSec: result.duration,
              ),
              nextButtonText: t.common.finish_button,
              onNextPressed: () {
                const HomePageRoute().go(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
