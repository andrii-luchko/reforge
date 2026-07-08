import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/core/timer/ui/app_timer.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class ActiveWorkoutAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ActiveWorkoutAppBar({
    this.onClosePressed,
    this.onRestTimerPressed,
    super.key,
  });

  final VoidCallback? onClosePressed;
  final VoidCallback? onRestTimerPressed;

  static const verticalPadding = 32.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 16, right: 16, bottom: verticalPadding),

      child: SafeArea(
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            AppIconButton.icon(
              iconData: Icons.close,
              onPressed: onClosePressed,
            ),

            BlocBuilder<TimerCubit, TimerState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: state.isRunning
                      ? context.read<TimerCubit>().pauseTimer
                      : context.read<TimerCubit>().startTimer,
                  child: AppTimer(
                    isPaused: !state.isRunning,
                    totalSeconds: state.duration,
                  ),
                );
              },
            ),
            AppIconButton(
              iconAsset: Assets.images.icons.timer,
              onPressed: onRestTimerPressed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const .fromHeight(kToolbarHeight + verticalPadding);

  static Size get preferredSizeStatic => const .fromHeight(kToolbarHeight + verticalPadding);
}
