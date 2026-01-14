import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/core/root/ui/page/root_page.dart';
import 'package:reforge/features/achievements/ui/page/achievements_page.dart';
import 'package:reforge/features/auth/ui/pages/create_new_password_page.dart';
import 'package:reforge/features/auth/ui/pages/forgot_password_email_page.dart';
import 'package:reforge/features/auth/ui/pages/reset_send_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_in_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_up_page.dart';
import 'package:reforge/features/auth/ui/pages/success_password_change_page.dart';
import 'package:reforge/features/calendar/ui/page/calendar_page.dart';
import 'package:reforge/features/home/ui/page/home_page.dart';
import 'package:reforge/features/leaderboard/ui/page/leaderboard_page.dart';
import 'package:reforge/features/lore/ui/page/lore_page.dart';
import 'package:reforge/features/onboarding/page/onboarding_page.dart';
import 'package:reforge/features/quiz/ui/pages/quiz_page.dart';
import 'package:reforge/features/settings/ui/page/settings_page.dart';
import 'package:reforge/features/splash/ui/pages/splash_page.dart';
import 'package:reforge/features/training_session/ui/pages/workout_details_page.dart';
import 'package:reforge/features/training_session/ui/pages/workout_quiz_page.dart';
import 'package:reforge/features/workout_instruction/ui/page/workout_instruction_page.dart';

part 'routes.g.dart';
part 'deep_link_routes.dart';

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
      routes: [
        TypedGoRoute<SuccessPasswordChangePageRoute>(
          path: 'success-password-change',
        ),
      ],
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
      routes: [TypedGoRoute<AchievementsPageRoute>(path: '/achievements')],
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
    return const LeaderboardPage();
  }
}

class LorePageRoute extends GoRouteData with $LorePageRoute {
  const LorePageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LorePage();
  }
}

class AchievementsPageRoute extends GoRouteData with $AchievementsPageRoute {
  const AchievementsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AchievementsPage();
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

@TypedGoRoute<WorkoutDetailsPageRoute>(path: '/workout-details')
class WorkoutDetailsPageRoute extends GoRouteData with $WorkoutDetailsPageRoute {
  const WorkoutDetailsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutDetailsPage();
  }
}

@TypedGoRoute<WorkoutInstructionPageRoute>(path: '/workout-instruction')
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

@TypedGoRoute<WorkoutQuizPageRoute>(path: '/workout-quiz')
class WorkoutQuizPageRoute extends GoRouteData with $WorkoutQuizPageRoute {
  const WorkoutQuizPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutQuizPage();
  }
}
