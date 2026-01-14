import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router_observer.dart';
import 'package:reforge/app/router/app_router_redirect.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';

final AuthCubit authCubit = di.getIt<AuthCubit>();

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: const SplashPageRoute().location,
  debugLogDiagnostics: true,
  refreshListenable: GoRouterRefreshStream(authCubit.stream),

  redirect: (context, state) => appRedirect(context, state, authCubit.state),
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
