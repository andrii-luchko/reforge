import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/features/auth/ui/pages/create_new_password_page.dart';
import 'package:reforge/features/auth/ui/pages/forgot_password_email_page.dart';
import 'package:reforge/features/auth/ui/pages/reset_send_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_in_page.dart';
import 'package:reforge/features/auth/ui/pages/sign_up_page.dart';
import 'package:reforge/features/auth/ui/pages/success_password_change_page.dart';
import 'package:reforge/features/onboarding/page/onboarding_page.dart';
import 'package:reforge/features/quiz/ui/pages/quiz_page.dart';
import 'package:reforge/features/splash/ui/pages/splash_page.dart';

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
