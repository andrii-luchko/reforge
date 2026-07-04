import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';

/// Wraps [child] and listens for lap/segment completion events from
/// [RunningTrackerCubit]. When [RunningTrackerState.lapJustCompleted] fires,
/// it calls [onLapCompleted] with the index of the newly started segment.
///
/// Usage: wrap [RunningActivePage] (or its scaffold body) with this widget,
/// then show your popup inside [onLapCompleted].
///
/// Example:
/// ```dart
/// LapCompletedListener(
///   onLapCompleted: (newSegmentIndex) {
///     showDialog(context: context, builder: (_) => LapCompleteDialog(...));
///   },
///   child: RunningActivePage(),
/// )
/// ```
class LapCompletedListener extends StatelessWidget {
  const LapCompletedListener({
    required this.onLapCompleted,
    required this.child,
    super.key,
  });

  /// Called with the index of the segment that is NOW active (after the lap).
  final void Function(int newSegmentIndex) onLapCompleted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RunningTrackerCubit, RunningTrackerState>(
      listenWhen: (prev, curr) => curr.lapJustCompleted && !prev.lapJustCompleted,
      listener: (context, state) {
        // state.currentSegmentIndex is already the NEW active segment index.
        // The segment that just finished = currentSegmentIndex - 1.
        onLapCompleted(state.currentSegmentIndex);
        context.read<RunningTrackerCubit>().clearLapCompleted();
      },
      child: child,
    );
  }
}
