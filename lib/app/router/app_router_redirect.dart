import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reforge/app/router/routes.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';

FutureOr<String?> appRedirect(BuildContext context, GoRouterState state, AuthState authState) {
  final currentPath = state.matchedLocation;

  final splash = currentPath == const SplashPageRoute().location;
  final onboarding = currentPath == const OnboardingPageRoute().location;
  final signingIn = currentPath.contains(const SignInPageRoute().location);
  final signingUp = currentPath.contains(const SignUpPageRoute().location);

  final resetPassword = currentPath.contains('/create-new-password');

  final onAuth = splash || onboarding || signingIn || signingUp || resetPassword;

  return authState.when(
    loading: () => null,
    error: (_) => null,
    unauthenticated: () {
      if (onAuth) {
        if (onboarding) {
          return null;
        }
        if (splash) {
          return const OnboardingPageRoute().location;
        }

        return null;
      }

      return const SignInPageRoute().location;
    },
    authenticated: (tokens, user) {
      if (onAuth) {
        // if (user == null) {
        //   return const QuizPageRoute().location;
        // }
        return const HomePageRoute().location;
      }
      return null;
    },
  );
}
