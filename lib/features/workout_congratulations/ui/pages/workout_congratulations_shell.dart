import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class WorkoutCongratulationsShell extends StatelessWidget {
  const WorkoutCongratulationsShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.beige900,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: BlocListener<WorkoutCongratulationsCubit, WorkoutCongratulationsState>(
        listenWhen: (previous, current) => previous.navigationTarget != current.navigationTarget,
        listener: (context, state) {
          final target = state.navigationTarget;
          if (target == null) return;

          context.read<WorkoutCongratulationsCubit>().onNavigationConsumed();

          target.when(
            achievement: (index) {
              WorkoutAchievementPageRoute(milestoneIndex: index).go(context);
            },
            summary: () {
              const WorkoutSummaryPageRoute().go(context);
            },
            home: () {
              const HomePageRoute().go(context);
            },
          );
        },
        child: DefaultBackground(
          body: child,
          additionalAnimationsOnTop: const [
            Positioned.fill(child: ParticlesWidget()),
          ],
        ),
      ),
    );
  }
}
