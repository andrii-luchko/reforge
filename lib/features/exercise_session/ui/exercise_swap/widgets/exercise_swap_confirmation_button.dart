import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/extensions/media_query_extension.dart';
import 'package:reforge/features/exercise_session/controllers/exercise_swap/exercise_swap_cubit.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class ExerciseSwapConfirmationButton extends StatelessWidget {
  const ExerciseSwapConfirmationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExerciseSwapCubit, ExerciseSwapState, ({bool hasSelection, bool isSwapping})>(
      selector: (state) => (
        hasSelection: state.selectedExerciseId != null,
        isSwapping: state.isSwapping,
      ),
      builder: (context, selectionState) {
        return AnimatedOpacity(
          opacity: selectionState.hasSelection ? 1 : 0,
          duration: const Duration(milliseconds: 100),
          child: AbsorbPointer(
            absorbing: !selectionState.hasSelection || selectionState.isSwapping,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                context.mediaQueryBottomPadding,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 20),
                    blurRadius: 30,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 30),
                    blurRadius: 30,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: PrimaryButton(
                key: const ValueKey('confirm_exercise_swap'),
                text: t.workout.swapExercise,
                onPressed: selectionState.isSwapping ? null : () => _swap(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _swap(BuildContext context) async {
    final result = await context.read<ExerciseSwapCubit>().swapSelected();
    if (result == null || !context.mounted) return;

    await WidgetsBinding.instance.endOfFrame;
    if (context.mounted) {
      Navigator.of(context).pop<AppliedExerciseSwap>(result);
    }
  }
}
