import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router_observer.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';

final AuthCubit authCubit = di.getIt<AuthCubit>();

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: const SplashPageRoute().location,
  debugLogDiagnostics: true,
  refreshListenable: GoRouterRefreshStream(authCubit.stream),

  redirect: (context, state) {
    final currentPath = state.matchedLocation;
    final authState = authCubit.state;
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
      authenticated: (user, tokens) {
        if (onAuth) {
          return const HomePageRoute().location;
        }
        return null;
      },
    );
  },
  observers: [
    AppRouterObserver(),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
