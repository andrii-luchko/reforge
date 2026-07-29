import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reforge/app/router/routes.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';

FutureOr<String?> appRedirect(BuildContext context, GoRouterState state, AuthState authState, UserState userState) {
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
        if (splash) {
          return const OnboardingPageRoute().location;
        }

        if (onboarding) {
          return null;
        }

        return null;
      } else {
        return const SignInPageRoute().location;
      }
    },
    authenticated: (tokens) {
      if (!onAuth) return null;

      return userState.maybeWhen(
        loaded: (user) {
          final target = user.map(
            newUser: (_) => const QuizPageRoute().location,
            //onboarded: (_) => const QuizPageRoute().location,
            onboarded: (_) => const HomePageRoute().location,
          );

          if (currentPath == target) return null;

          return target;
        },
        deleted: () => const SignInPageRoute().location,

        orElse: () => null,
      );
    },
  );
}
