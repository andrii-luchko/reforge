// ignore_for_file: prefer_match_file_name
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/root/ui/page/root_page.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/features/achievements/ui/page/achievements_page.dart';
import 'package:reforge/features/achievements/ui/page/badges_page.dart';
import 'package:reforge/features/achievements/ui/page/ranks_page.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/active_workout/ui/pages/active_workout_page.dart';
import 'package:reforge/features/active_workout/ui/pages/active_workout_shell.dart';
import 'package:reforge/features/active_workout/ui/pages/start_running_page.dart';
import 'package:reforge/features/active_workout/ui/widgets/active_workout_page/no_workout_error_widget.dart';
import 'package:reforge/features/auth/ui/pages/create_new_password_page.dart';
import 'package:reforge/features/auth/ui/pages/forgot_password_email_page.dart';
import 'package:reforge/features/auth/ui/pages/reset_send_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_in_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_up_page.dart';
import 'package:reforge/features/auth/ui/pages/success_password_change_page.dart';
import 'package:reforge/features/calendar/ui/page/calendar_page.dart';
import 'package:reforge/features/home/ui/page/home_page.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';

import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/ui/page/leaderboard_page.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/ui/page/lore_page.dart';
import 'package:reforge/features/notifications/ui/page/notifications_page.dart';
import 'package:reforge/features/onboarding/page/onboarding_page.dart';
import 'package:reforge/features/quiz/ui/pages/quiz_page.dart';
import 'package:reforge/features/settings/ui/page/settings_page.dart';
import 'package:reforge/features/splash/ui/pages/splash_page.dart';
import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/features/workout_congratulations/ui/pages/achievement_page.dart';
import 'package:reforge/features/workout_congratulations/ui/pages/summary_page.dart';
import 'package:reforge/features/workout_congratulations/ui/pages/workout_congratulations_shell.dart';
import 'package:reforge/features/workout_details/ui/pages/workout_details_page.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_instruction/ui/page/workout_instruction_page.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/ui/pages/workout_quiz_page.dart';
import 'package:reforge/features/workout_quiz/ui/pages/workout_quiz_summary_page.dart';

part 'deep_link_routes.dart';
part 'routes.g.dart';

@TypedGoRoute<SplashPageRoute>(path: '/')
class SplashPageRoute extends GoRouteData with $SplashPageRoute {
  const SplashPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}

@TypedGoRoute<OnboardingPageRoute>(path: '/onboarding')
class OnboardingPageRoute extends GoRouteData with $OnboardingPageRoute {
  const OnboardingPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingPage();
  }
}

@TypedGoRoute<SignInPageRoute>(
  path: '/sign-in',
  routes: [
    TypedGoRoute<SignUpPageRoute>(path: 'sign-up'),
    TypedGoRoute<ForgotPasswordEmailPageRoute>(
      path: 'forgot-password',
      routes: [
        TypedGoRoute<ResetSendPageRoute>(
          path: 'reset-send',
        ),
      ],
    ),

    TypedGoRoute<CreateNewPasswordPageRoute>(
      path: 'create-new-password',
    ),
    TypedGoRoute<SuccessPasswordChangePageRoute>(
      path: 'success-password-change',
    ),
  ],
)
class SignInPageRoute extends GoRouteData with $SignInPageRoute {
  const SignInPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignInPage();
  }
}

class SignUpPageRoute extends GoRouteData with $SignUpPageRoute {
  const SignUpPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignUpPage();
  }
}

class ForgotPasswordEmailPageRoute extends GoRouteData with $ForgotPasswordEmailPageRoute {
  const ForgotPasswordEmailPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordEmailPage();
  }
}

class ResetSendPageRoute extends GoRouteData with $ResetSendPageRoute {
  const ResetSendPageRoute({required this.email});

  final String email;
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ResetSendPage(
      email: email,
    );
  }
}

class CreateNewPasswordPageRoute extends GoRouteData with $CreateNewPasswordPageRoute {
  const CreateNewPasswordPageRoute({required this.token});

  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreateNewPasswordPage(
      token: token,
    );
  }
}

class SuccessPasswordChangePageRoute extends GoRouteData with $SuccessPasswordChangePageRoute {
  const SuccessPasswordChangePageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SuccessPasswordChangePage();
  }
}

@TypedGoRoute<QuizPageRoute>(path: '/quiz')
class QuizPageRoute extends GoRouteData with $QuizPageRoute {
  const QuizPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const QuizPage();
  }
}

@TypedStatefulShellRoute<RootShellRoute>(
  branches: [
    // 1. Home
    TypedStatefulShellBranch<HomeBranch>(
      routes: [
        TypedGoRoute<HomePageRoute>(
          path: '/home',
        ),
      ],
    ),
    // 2. Chart
    TypedStatefulShellBranch<LeaderboardBranch>(
      routes: [TypedGoRoute<LeaderboardPageRoute>(path: '/leaderboard')],
    ),
    // 3. Plates
    TypedStatefulShellBranch<LoreBranch>(
      routes: [TypedGoRoute<LorePageRoute>(path: '/lore')],
    ),
    // 4. Medal
    TypedStatefulShellBranch<AchievementsBranch>(
      routes: [
        TypedGoRoute<AchievementsPageRoute>(
          path: '/achievements',
          routes: [
            TypedGoRoute<BadgesPageRoute>(path: 'badges'),
            TypedGoRoute<RanksPageRoute>(path: 'ranks'),
          ],
        ),
      ],
    ),
    // 5. Settings
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [TypedGoRoute<SettingsPageRoute>(path: '/settings')],
    ),
  ],
)
class RootShellRoute extends StatefulShellRouteData {
  const RootShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return RootPage(navigationShell: navigationShell);
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class LeaderboardBranch extends StatefulShellBranchData {
  const LeaderboardBranch();
}

class LoreBranch extends StatefulShellBranchData {
  const LoreBranch();
}

class AchievementsBranch extends StatefulShellBranchData {
  const AchievementsBranch();
}

class SettingsBranch extends StatefulShellBranchData {
  const SettingsBranch();
}

class HomePageRoute extends GoRouteData with $HomePageRoute {
  const HomePageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class LeaderboardPageRoute extends GoRouteData with $LeaderboardPageRoute {
  const LeaderboardPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.getIt<UsersLeaderboardCubit>(),
        ),
        BlocProvider(
          create: (context) => di.getIt<ImmortalForgesCubit>(),
        ),
        BlocProvider(
          create: (context) => di.getIt<FactionsLeaderboardCubit>(),
        ),
      ],
      child: const LeaderboardPage(),
    );
  }
}

class LorePageRoute extends GoRouteData with $LorePageRoute {
  const LorePageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => di.getIt<LoreCubit>(),
      child: const LorePage(),
    );
  }
}

class AchievementsPageRoute extends GoRouteData with $AchievementsPageRoute {
  const AchievementsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AchievementsPage();
  }
}

class BadgesPageRoute extends GoRouteData with $BadgesPageRoute {
  const BadgesPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BadgesPage();
  }
}

class RanksPageRoute extends GoRouteData with $RanksPageRoute {
  const RanksPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RanksPage();
  }
}

class SettingsPageRoute extends GoRouteData with $SettingsPageRoute {
  const SettingsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsPage();
  }
}

@TypedGoRoute<CalendarPageRoute>(path: '/calendar')
class CalendarPageRoute extends GoRouteData with $CalendarPageRoute {
  const CalendarPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CalendarPage();
  }
}

@TypedGoRoute<NotificationsPageRoute>(path: '/notifications')
class NotificationsPageRoute extends GoRouteData with $NotificationsPageRoute {
  const NotificationsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NotificationsPage();
  }
}

@TypedShellRoute<WorkoutShellRoute>(
  routes: [
    TypedGoRoute<WorkoutDetailsPageRoute>(path: '/workout-details'),
    TypedGoRoute<WorkoutInstructionPageRoute>(path: '/workout-instruction'),
    TypedShellRoute<WorkoutQuizShellRoute>(
      routes: [
        TypedGoRoute<WorkoutQuizPageRoute>(path: '/workout-quiz'),
        TypedGoRoute<WorkoutQuizSummaryPageRoute>(path: '/workout-quiz-summary'),
      ],
    ),
    TypedShellRoute<ActiveWorkoutsShellRoute>(
      routes: [
        TypedGoRoute<ActiveWorkoutPageRoute>(path: '/active-workout'),
      ],
    ),

    TypedGoRoute<StartRunningPageRoute>(path: '/start-running'),
    TypedShellRoute<WorkoutCongratulationsShellRoute>(
      routes: [
        TypedGoRoute<WorkoutSummaryPageRoute>(path: '/workout-summary'),
        TypedGoRoute<WorkoutAchievementPageRoute>(path: '/workout-achievements'),
      ],
    ),
  ],
)
class WorkoutShellRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: di.getIt<WorkoutFlowCubit>(),
        ),
        BlocProvider(
          create: (context) => di.getIt<WorkoutQuizCubit>(),
        ),
      ],
      child: navigator,
    );
  }
}

class WorkoutDetailsPageRoute extends GoRouteData with $WorkoutDetailsPageRoute {
  const WorkoutDetailsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutDetailsPage();
  }
}

class WorkoutInstructionPageRoute extends GoRouteData with $WorkoutInstructionPageRoute {
  const WorkoutInstructionPageRoute({required this.name, required this.workoutId});

  final String name;
  final int workoutId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WorkoutInstructionPage(
      name: name,
      workoutId: workoutId,
    );
  }
}

class WorkoutQuizShellRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return navigator;
  }
}

class WorkoutQuizPageRoute extends GoRouteData with $WorkoutQuizPageRoute {
  const WorkoutQuizPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutQuizPage();
  }
}

class WorkoutQuizSummaryPageRoute extends GoRouteData with $WorkoutQuizSummaryPageRoute {
  const WorkoutQuizSummaryPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutQuizSummaryPage();
  }
}

class ActiveWorkoutsShellRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return BlocProvider(
      create: (context) => di.getIt<TimerCubit>(),
      child: ActiveWorkoutShell(child: navigator),
    );
  }
}

class ActiveWorkoutPageRoute extends GoRouteData with $ActiveWorkoutPageRoute {
  const ActiveWorkoutPageRoute({required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocBuilder<WorkoutFlowCubit, WorkoutFlowState>(
      key: ValueKey(exerciseId),
      builder: (context, flowState) {
        final workoutSessionId = flowState.workoutSessionId;
        final programDay = flowState.programDay;

        if (workoutSessionId == null || programDay == null) {
          return const NoWorkoutErrorWidget();
        }

        final programExercise = programDay.exercises.firstWhereOrNull(
          (e) => e.exerciseDetails.id == exerciseId,
        );

        if (programExercise == null) {
          return const NoWorkoutErrorWidget();
        }

        return BlocProvider(
          create: (context) => di.getIt<ActiveExerciseCubit>(param1: workoutSessionId, param2: programExercise),
          child: const ActiveWorkoutPage(),
        );
      },
    );
  }
}

class StartRunningPageRoute extends GoRouteData with $StartRunningPageRoute {
  const StartRunningPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const StartRunningPage();
  }
}

class WorkoutCongratulationsShellRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final summary = context.read<WorkoutFlowCubit>().state.summary;
    logger.d('WorkoutCongratulationsShell - summary: $summary, isNull: ${summary == null}');

    return BlocProvider(
      create: (context) => di.getIt<WorkoutCongratulationsCubit>(
        param1: summary,
      ),
      child: WorkoutCongratulationsShell(child: navigator),
    );
  }
}

class WorkoutAchievementPageRoute extends GoRouteData with $WorkoutAchievementPageRoute {
  const WorkoutAchievementPageRoute({
    required this.milestoneIndex,
  });

  final int milestoneIndex;
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WorkoutAchievementPage(
      key: ValueKey(milestoneIndex),
      milestoneIndex: milestoneIndex,
    );
  }
}

class WorkoutSummaryPageRoute extends GoRouteData with $WorkoutSummaryPageRoute {
  const WorkoutSummaryPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutSummaryPage();
  }
}
