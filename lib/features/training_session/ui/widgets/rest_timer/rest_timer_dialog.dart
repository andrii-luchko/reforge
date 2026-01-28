import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/training_session/controllers/rest_timer/rest_timer_cubit.dart';
import 'package:reforge/features/training_session/ui/widgets/rest_timer/circular_timer.dart';
import 'package:reforge/features/training_session/ui/widgets/uikit/workout_done_button.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class RestTimerDialog extends StatelessWidget {
  const RestTimerDialog({super.key});

  void onClosePressed(BuildContext context, RestTimerCubit cubit) {
    final elapsedTime = cubit.stopTimerAndGetResult();

    Navigator.of(context).pop<int?>(elapsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RestTimerCubit>(
      create: (context) => di.getIt<RestTimerCubit>()
        ..initTimer(defaultRestDuration)
        ..startTimer(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<RestTimerCubit, RestTimerState>(
          builder: (context, state) {
            final cubit = context.read<RestTimerCubit>();

            return Column(
              spacing: 32,
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              children: [
                DefaultDialogHeader(
                  title: t.training_session.rest_timer_dialog_title,
                  onClosePressed: () => onClosePressed(context, cubit),
                ),
                Builder(
                  builder: (context) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: .stretch,
                        spacing: 16,
                        children: [
                          BlocSelector<RestTimerCubit, RestTimerState, ({int current, int total, double progress})>(
                            selector: (state) {
                              return (
                                current: state.remainingSeconds,
                                total: state.targetSeconds,
                                progress: state.remainingSeconds < 0 ? 0 : cubit.progress,
                              );
                            },
                            builder: (context, state) {
                              return AspectRatio(
                                aspectRatio: 1,
                                child: CircularTimer(
                                  progress: state.progress,
                                  mainTime: state.current,
                                  totalTime: state.total,
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Column(
                              spacing: 16,
                              children: [
                                SizedBox(
                                  height: context.appTheme.workoutContainerConstrains.maxHeight,
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Expanded(
                                        child: WorkoutDoneButton.text(
                                          onTap: () => cubit.adjustTime(adjustValue),
                                          isDone: true,
                                          text: '+$adjustValue',
                                        ),
                                      ),

                                      Expanded(
                                        child: WorkoutDoneButton.text(
                                          onTap: () => cubit.adjustTime(-adjustValue),
                                          isDone: true,
                                          text: '-$adjustValue',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SecondaryButton(
                                  text: t.common.skip_button,
                                  onPressed: () => onClosePressed(context, cubit),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
