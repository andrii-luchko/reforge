import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router_redirect.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/core/analytics/data/observers/analytics_route_observer.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';

final AuthCubit authCubit = di.getIt<AuthCubit>();
final UserCubit userCubit = di.getIt<UserCubit>();
final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  routes: $appRoutes,
  navigatorKey: rootNavigatorKey,
  initialLocation: const SplashPageRoute().location,
  debugLogDiagnostics: true,
  refreshListenable: GoRouterRefreshStream([
    authCubit.stream,
    userCubit.stream,
  ]),

  redirect: (context, state) => appRedirect(context, state, authCubit.state, userCubit.state),
  observers: [
    di.getIt<RouteObserver<ModalRoute<void>>>(),
    di.getIt<AnalyticsRouteObserver>(),
  ],
);

// ignore: prefer_match_file_name
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    _subscriptions = streams.map((stream) {
      return stream.listen((_) => notifyListeners());
    }).toList();
  }

  // ignore: avoid_late_keyword
  late final List<StreamSubscription<dynamic>> _subscriptions;

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    super.dispose();
  }
}
