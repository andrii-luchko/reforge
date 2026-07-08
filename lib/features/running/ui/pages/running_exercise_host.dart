import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
class RunningExerciseHost extends StatelessWidget {
  const RunningExerciseHost({super.key});

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
              RunningPhase.finished => const RunningLapsSummaryPage(),
              RunningPhase.permissionDenied => const RunningPermissionDeniedPage(),
            },
          ),
        );
      },
    );
  }
}
