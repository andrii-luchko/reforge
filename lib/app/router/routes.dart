// ignore_for_file: prefer_match_file_name
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/root/ui/page/root_page.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/achievements/ui/page/achievements_page.dart';
import 'package:reforge/features/achievements/ui/page/badges_page.dart';
import 'package:reforge/features/achievements/ui/page/ranks_page.dart';
import 'package:reforge/features/auth/ui/pages/create_new_password_page.dart';
import 'package:reforge/features/auth/ui/pages/forgot_password_email_page.dart';
import 'package:reforge/features/auth/ui/pages/reset_send_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_in_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_up_page.dart';
import 'package:reforge/features/auth/ui/pages/success_password_change_page.dart';
import 'package:reforge/features/calendar/controllers/training_details/training_details_cubit.dart';
import 'package:reforge/features/calendar/ui/page/calendar_page.dart';
import 'package:reforge/features/calendar/ui/page/training_details_page.dart';
import 'package:reforge/features/camera_detection/controller/camera_detection_cubit.dart';
import 'package:reforge/features/camera_detection/ui/pages/camera_detection_page.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/pages/regular_exercise_page.dart';
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
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/ui/pages/running_exercise_host.dart';
import 'package:reforge/features/running/ui/pages/start_running_page.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/helpers/settings_navigation.dart';
import 'package:reforge/features/settings/ui/page/settings_content/change_faction_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/date_of_birth_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/email_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/height_and_weight_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/measurement_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/name_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/notification_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/workout_days_content.dart';
import 'package:reforge/features/settings/ui/page/settings_page.dart';
import 'package:reforge/features/splash/ui/pages/splash_page.dart';
import 'package:reforge/features/subscription/ui/pages/change_plan_page.dart';
import 'package:reforge/features/subscription/ui/pages/paywall_page.dart';
import 'package:reforge/features/subscription/ui/pages/subscription_page.dart';
import 'package:reforge/features/workout_congratulations/ui/pages/workout_congratulations_page.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/pages/exercise_instruction_page.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/pages/scheduled_workout_details_page.dart';
import 'package:reforge/features/workout_program/ui/workout_day_details/pages/workout_details_page.dart';
import 'package:reforge/features/workout_quiz/controller/workout_quiz_cubit.dart';
import 'package:reforge/features/workout_quiz/ui/pages/workout_quiz_page.dart';
import 'package:reforge/features/workout_quiz/ui/pages/workout_quiz_summary_page.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/ui/active_workout/pages/active_workout_shell.dart';
import 'package:reforge/features/workout_session/ui/navigation/workout_navigation_mixin.dart';
import 'package:reforge/shared/uikit/states/no_workout_error_widget.dart';

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
      routes: [
        TypedGoRoute<SettingsPageRoute>(
          path: '/settings',
          routes: [
            TypedGoRoute<SettingsNamePageRoute>(path: 'name'),
            TypedGoRoute<SettingsEmailPageRoute>(path: 'email'),
            TypedGoRoute<SettingsDateOfBirthPageRoute>(path: 'date-of-birth'),
            TypedGoRoute<SettingsHeightAndWeightPageRoute>(path: 'height-and-weight'),
            TypedGoRoute<SettingsWorkoutDaysPageRoute>(path: 'workout-days'),
            TypedGoRoute<SettingsFactionPageRoute>(path: 'faction'),
            TypedGoRoute<SettingsMeasurementPageRoute>(path: 'measurement'),
            TypedGoRoute<SettingsNotificationPageRoute>(path: 'notifications'),
            TypedGoRoute<SettingsSubscriptionPageRoute>(
              path: 'subscription',
              routes: [
                TypedGoRoute<ChangePlanPageRoute>(path: 'change-plan'),
              ],
            ),
          ],
        ),
      ],
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

class SettingsNamePageRoute extends GoRouteData with $SettingsNamePageRoute {
  const SettingsNamePageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(ProfileSettings.name),
      child: NamePage(name: onboarded.userName),
    );
  }
}

class SettingsEmailPageRoute extends GoRouteData with $SettingsEmailPageRoute {
  const SettingsEmailPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(ProfileSettings.email),
      child: EmailPage(initialEmail: onboarded.email),
    );
  }
}

class SettingsDateOfBirthPageRoute extends GoRouteData with $SettingsDateOfBirthPageRoute {
  const SettingsDateOfBirthPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(ProfileSettings.dateOfBirth),
      child: DateOfBirthPage(dateOfBirth: onboarded.birthDate),
    );
  }
}

class SettingsHeightAndWeightPageRoute extends GoRouteData with $SettingsHeightAndWeightPageRoute {
  const SettingsHeightAndWeightPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(ProfileSettings.heightAndWeight),
      child: HeightAndWeightPage(
        weight: onboarded.bodyWeight,
        system: onboarded.measurementSystem,
      ),
    );
  }
}

class SettingsWorkoutDaysPageRoute extends GoRouteData with $SettingsWorkoutDaysPageRoute {
  const SettingsWorkoutDaysPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(WorkoutSettings.workoutDays),
      child: WorkoutDaysPage(
        workoutsPerWeek: onboarded.workoutsPerWeek,
        specificWeekDays: onboarded.specificWeekDays,
      ),
    );
  }
}

class SettingsFactionPageRoute extends GoRouteData with $SettingsFactionPageRoute {
  const SettingsFactionPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(WorkoutSettings.faction),
      child: ChangeFactionPage(initialFactions: onboarded.factionsList),
    );
  }
}

class SettingsMeasurementPageRoute extends GoRouteData with $SettingsMeasurementPageRoute {
  const SettingsMeasurementPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final user = context.read<UserCubit>().state.userOrNull;
    final onboarded = user is OnboardedUser ? user : null;
    if (onboarded == null) {
      return const _SettingsRedirectToSettings();
    }
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(WorkoutSettings.measureSystem),
      child: MeasurementPage(system: onboarded.measurementSystem),
    );
  }
}

class SettingsNotificationPageRoute extends GoRouteData with $SettingsNotificationPageRoute {
  const SettingsNotificationPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(WorkoutSettings.notification),
      child: const SettingsNotificationPage(),
    );
  }
}

class SettingsSubscriptionPageRoute extends GoRouteData with $SettingsSubscriptionPageRoute {
  const SettingsSubscriptionPageRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsScreenWithAnalytics(
      event: SettingsNavigation.eventFor(WorkoutSettings.subscription),
      child: const SubscriptionPage(),
    );
  }
}

class ChangePlanPageRoute extends GoRouteData with $ChangePlanPageRoute {
  const ChangePlanPageRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChangePlanPage();
  }
}

class _SettingsRedirectToSettings extends StatefulWidget {
  const _SettingsRedirectToSettings();

  @override
  State<_SettingsRedirectToSettings> createState() => _SettingsRedirectToSettingsState();
}

class _SettingsRedirectToSettingsState extends State<_SettingsRedirectToSettings> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(const SettingsPageRoute().location);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

@TypedGoRoute<CalendarPageRoute>(path: '/calendar')
class CalendarPageRoute extends GoRouteData with $CalendarPageRoute {
  const CalendarPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CalendarPage();
  }
}

@TypedGoRoute<TrainingDetailsPageRoute>(path: '/training-details')
class TrainingDetailsPageRoute extends GoRouteData with $TrainingDetailsPageRoute {
  const TrainingDetailsPageRoute({
    required this.date,
    required this.workoutSessionID,
  });

  final DateTime date;
  final int workoutSessionID;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => di.getIt<TrainingDetailsCubit>(param1: workoutSessionID),
      child: const TrainingDetailsPage(),
    );
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
    TypedGoRoute<ScheduledWorkoutDetailsPageRoute>(path: '/scheduled-workout-details'),
    TypedGoRoute<ExerciseInstructionPageRoute>(path: '/workout-instruction'),
    TypedShellRoute<WorkoutQuizShellRoute>(
      routes: [
        TypedGoRoute<WorkoutQuizPageRoute>(path: '/workout-quiz'),
        TypedGoRoute<WorkoutQuizSummaryPageRoute>(path: '/workout-quiz-summary'),
      ],
    ),
    TypedShellRoute<ActiveWorkoutShellRoute>(
      routes: [
        TypedGoRoute<ActiveExercisePageRoute>(
          path: '/active-workout',
        ),
      ],
    ),
    TypedGoRoute<CameraDetectionPageRoute>(path: '/camera-detection'),
    TypedGoRoute<StartRunningPageRoute>(path: '/start-running'),
    TypedGoRoute<WorkoutCongratulationsPageRoute>(path: '/workout-congratulations'),
  ],
)
class WorkoutShellRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.getIt<WorkoutQuizCubit>(),
        ),
      ],
      child: navigator,
    );
  }
}

class WorkoutDetailsPageRoute extends GoRouteData with $WorkoutDetailsPageRoute, WorkoutNavigationMixin {
  const WorkoutDetailsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WorkoutDetailsPage(
      onStartWorkout: () => handleStartWorkout(context),
    );
  }
}

class ScheduledWorkoutDetailsPageRoute extends GoRouteData
    with $ScheduledWorkoutDetailsPageRoute, WorkoutNavigationMixin {
  const ScheduledWorkoutDetailsPageRoute({required this.date, required this.scheduledWorkoutDayId});

  final DateTime date;
  final int scheduledWorkoutDayId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ScheduledWorkoutDetailsPage(
      scheduledWorkoutDayId: scheduledWorkoutDayId,
      date: date,
      onStartWorkout: () => handleStartWorkout(context),
    );
  }
}

class ExerciseInstructionPageRoute extends GoRouteData with $ExerciseInstructionPageRoute {
  const ExerciseInstructionPageRoute({required this.name, required this.workoutId});

  final String name;
  final int workoutId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExerciseInstructionPage(
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

class ActiveWorkoutShellRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return BlocProvider(
      create: (context) => di.getIt<TimerCubit>(),
      child: ActiveWorkoutShell(child: navigator),
    );
  }
}

class ActiveExercisePageRoute extends GoRouteData with $ActiveExercisePageRoute {
  const ActiveExercisePageRoute({required this.programExerciseId});

  final int programExerciseId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocBuilder<WorkoutSessionFlowCubit, WorkoutSessionFlowState>(
      key: ValueKey(programExerciseId),
      builder: (context, flowState) {
        final workoutSessionId = flowState.workoutSessionId;
        final programDay = flowState.programDay;

        if (workoutSessionId == null || programDay == null) {
          return const NoWorkoutErrorWidget();
        }

        final programExercise = programDay.programExercises.firstWhereOrNull(
          (pExercise) => pExercise.id == programExerciseId,
        );

        if (programExercise == null) {
          return const NoWorkoutErrorWidget();
        }

        // ── Running exercise ─────────────────────────────────────────────
        if (programExercise.isRunningExercise) {
          final restoredSets = flowState.isRestoredSession ? flowState.restoredSets[programExercise.id] : null;

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => di.getIt<ActiveExerciseCubit>(
                  param1: workoutSessionId,
                  param2: programExercise,
                )..setRestoredSets(restoredSets),
              ),
              BlocProvider(
                create: (_) {
                  final cubit = di.getIt<RunningTrackerCubit>(
                    param1: workoutSessionId,
                    param2: programExercise,
                  );
                  unawaited(cubit.init());
                  return cubit;
                },
              ),
              BlocProvider(
                create: (_) => di.getIt<RunningSetSyncCubit>(
                  param1: workoutSessionId,
                  param2: programExercise,
                )..init(),
              ),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
                  listenWhen: (previous, current) => previous.isLoading && !current.isLoading,
                  listener: (context, state) {
                    final syncState = context.read<RunningSetSyncCubit>().state;
                    context.read<ActiveExerciseCubit>().replaceSetsFromExternalSource(
                      sets: syncState.sets,
                      isSending: syncState.isSending,
                    );
                  },
                ),
                BlocListener<RunningSetSyncCubit, RunningSetSyncState>(
                  listener: (context, syncState) {
                    final activeExerciseCubit = context.read<ActiveExerciseCubit>();
                    if (activeExerciseCubit.state.isLoading) return;
                    activeExerciseCubit.replaceSetsFromExternalSource(
                      sets: syncState.sets,
                      isSending: syncState.isSending,
                    );
                  },
                ),
              ],
              child: RunningExerciseHost(
                onExerciseFinished: () async {
                  final timerDuration = context.read<TimerCubit>().state.duration;
                  await context.read<WorkoutSessionFlowCubit>().nextExercise(timerDuration);
                },
              ),
            ),
          );
        }

        // ── Regular exercise ─────────────────────────────────────────────
        final restoredSets = flowState.isRestoredSession ? flowState.restoredSets[programExercise.id] : null;

        return BlocProvider(
          create: (context) => di.getIt<ActiveExerciseCubit>(
            param1: workoutSessionId,
            param2: programExercise,
          )..setRestoredSets(restoredSets),
          child: const RegularExercisePage(),
        );
      },
    );
  }
}

class CameraDetectionPageRoute extends GoRouteData with $CameraDetectionPageRoute {
  const CameraDetectionPageRoute({required this.$extra});

  final ActiveExerciseCubit $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: $extra),
        BlocProvider(
          create: (context) => di.getIt<CameraDetectionCubit>(),
        ),
      ],
      child: const CameraDetectionPage(),
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

class WorkoutCongratulationsPageRoute extends GoRouteData with $WorkoutCongratulationsPageRoute {
  const WorkoutCongratulationsPageRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return context.read<WorkoutSessionFlowCubit>().state.summary == null ? const HomePageRoute().location : null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutCongratulationsPage();
  }
}

@TypedGoRoute<PayWallPageRoute>(path: '/paywall')
class PayWallPageRoute extends GoRouteData with $PayWallPageRoute {
  const PayWallPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PaywallPage();
  }
}

// Extension: setting → route (nullable) and push; used from settings_page.
extension ProfileSettingsRouteX on ProfileSettings {
  GoRouteData? get route => switch (this) {
    ProfileSettings.name => const SettingsNamePageRoute(),
    ProfileSettings.email => const SettingsEmailPageRoute(),
    ProfileSettings.dateOfBirth => const SettingsDateOfBirthPageRoute(),
    ProfileSettings.heightAndWeight => const SettingsHeightAndWeightPageRoute(),
    ProfileSettings.image => null,
  };

  void push(BuildContext context) {
    final r = route;
    if (r != null) unawaited(context.push(r.location));
  }
}

extension WorkoutSettingsRouteX on WorkoutSettings {
  GoRouteData? get route => switch (this) {
    WorkoutSettings.workoutDays => const SettingsWorkoutDaysPageRoute(),
    WorkoutSettings.faction => const SettingsFactionPageRoute(),
    WorkoutSettings.measureSystem => const SettingsMeasurementPageRoute(),
    WorkoutSettings.notification => const SettingsNotificationPageRoute(),
    WorkoutSettings.subscription => const SettingsSubscriptionPageRoute(),
    WorkoutSettings.privacy => null,
    WorkoutSettings.termsAndConditions => null,
  };

  void push(BuildContext context) {
    final r = route;
    if (r != null) unawaited(context.push(r.location));
  }
}
