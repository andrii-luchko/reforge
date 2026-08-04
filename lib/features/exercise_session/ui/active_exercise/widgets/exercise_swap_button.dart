import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:toastification/toastification.dart';

class ExerciseSwapButton extends StatelessWidget {
  const ExerciseSwapButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(50);

    return BlocSelector<ActiveExerciseCubit, ActiveExerciseState, bool>(
      selector: (_) => context.read<ActiveExerciseCubit>().canSwap,
      builder: (context, canSwap) {
        return Row(
          children: [
            PressableAnimation(
              onTap: canSwap
                  ? () => _openSearch(context)
                  : () {
                      toastification.showErrorToast(t.workout.swapExerciseUnavailable, context);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: canSwap ? appTheme.orange400 : appTheme.beige900,
                  border: Border.all(
                    color: canSwap ? appTheme.strokeCalendar : appTheme.beige900,
                  ),
                ),

                child: Center(
                  child: Row(
                    spacing: 8,
                    children: [
                      AppSvgIcon(
                        asset: Assets.images.icons.arrowSwapHorizontal,
                        color: canSwap ? appTheme.beige100 : appTheme.beige600,
                        size: 18,
                      ),
                      Text(
                        t.workout.swapExercise,
                        style: subheadH6Medium.copyWith(
                          color: canSwap ? appTheme.beige100 : appTheme.beige600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final activeExerciseCubit = context.read<ActiveExerciseCubit>();
    if (!activeExerciseCubit.canSwap) return;
    final flowCubit = context.read<WorkoutSessionFlowCubit>();
    final activeState = activeExerciseCubit.state;
    final result = await ExerciseSwapSearchPageRoute(
      $extra: ExerciseSwapRequestContext(
        workoutSessionId: activeState.session.workoutSessionId,
        workoutExerciseSessionId: activeState.session.id,
        currentExerciseId: activeState.effectiveExercise.id,
        measurementSystem: activeState.measureSystem,
      ),
    ).push<AppliedExerciseSwap>(context);

    if (result == null || !context.mounted) return;
    final updatedExecution = activeExerciseCubit.applySwap(result);
    if (updatedExecution != null) {
      flowCubit.updateExerciseExecutionAfterSwap(updatedExecution);
    }
  }
}
