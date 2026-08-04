import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/ui/pages/running_active_page.dart';
import 'package:reforge/features/running/ui/pages/running_laps_summary_page.dart';
import 'package:reforge/features/running/ui/pages/running_overview_page.dart';
import 'package:reforge/features/running/ui/pages/running_permission_denied_page.dart';

/// Phase-driven page switcher for the running exercise flow.
///
/// Listens to [RunningTrackerCubit] and renders the corresponding page with
/// a smooth animated transition. No go_router routes are created — navigation
/// is entirely internal via cubit state.
///
/// Phase → Page mapping:
/// - [RunningPhase.overview]  → [RunningOverviewPage]
/// - [RunningPhase.active]    → [RunningActivePage]
/// - [RunningPhase.finished]  → [RunningLapsSummaryPage]
class RunningExerciseHost extends StatefulWidget {
  const RunningExerciseHost({super.key});

  @override
  State<RunningExerciseHost> createState() => _RunningExerciseHostState();
}

class _RunningExerciseHostState extends State<RunningExerciseHost> {
  Future<bool>? _finishInFlight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunningTrackerCubit, RunningTrackerState>(
      buildWhen: (prev, curr) => prev.phase != curr.phase,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(state.phase),
            child: switch (state.phase) {
              RunningPhase.overview => const RunningOverviewPage(),
              RunningPhase.active => const RunningActivePage(),
              RunningPhase.finished => BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
                builder: (context, exerciseState) => RunningLapsSummaryPage(
                  exerciseDetails: exerciseState.effectiveExercise,
                  measureSystem: exerciseState.measureSystem,
                  sets: exerciseState.sets,
                  notes: exerciseState.notes,
                  isSendingSet: exerciseState.isSendingSet,
                  onNoteChanged: context.read<ActiveExerciseCubit>().setNote,
                  onExerciseFinished: _finishExercise,
                ),
              ),
              RunningPhase.permissionDenied => const RunningPermissionDeniedPage(),
            },
          ),
        );
      },
    );
  }

  Future<bool> _finishExercise() {
    final inFlight = _finishInFlight;
    if (inFlight != null) return inFlight;

    late final Future<bool> request;
    request = _finishExerciseOnce().whenComplete(() {
      if (identical(_finishInFlight, request)) _finishInFlight = null;
    });
    _finishInFlight = request;
    return request;
  }

  Future<bool> _finishExerciseOnce() async {
    final syncCubit = context.read<RunningSetSyncCubit>();
    final trackerCubit = context.read<RunningTrackerCubit>();
    final activeExerciseCubit = context.read<ActiveExerciseCubit>();

    final isSynced = await syncCubit.flush();
    if (!mounted || !isSynced) return false;

    final isTrackerClosed = await trackerCubit.finishExercise();
    if (!mounted || !isTrackerClosed) return false;

    activeExerciseCubit.replaceSetsFromExternalSource(
      sets: syncCubit.state.sets,
      isSending: syncCubit.state.isSending,
    );
    await activeExerciseCubit.finishExercise();
    return activeExerciseCubit.state.isSubmitted;
  }
}
