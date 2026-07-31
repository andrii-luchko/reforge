import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class ActiveExerciseLoader extends StatelessWidget {
  const ActiveExerciseLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ActiveExerciseCubit, ActiveExerciseState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
        return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
