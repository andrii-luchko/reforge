import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/features/auth_page.dart';
import 'package:reforge/features/onboarding/page/onboarding_page.dart';
import 'package:reforge/features/splash/ui/pages/splash_page.dart';

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

@TypedGoRoute<AuthPageRoute>(path: '/auth')
class AuthPageRoute extends GoRouteData with $AuthPageRoute {
  const AuthPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthPage();
  }
}

@TypedGoRoute<SignPageRoute>(path: '/signin')
class SignPageRoute extends GoRouteData with $SignPageRoute {
  const SignPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthPage();
  }
}
