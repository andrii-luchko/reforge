import 'package:go_router/go_router.dart';
import 'package:reforge/app/router/routes.dart';

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: const SplashPageRoute().location,
  debugLogDiagnostics: true,
  observers: [],
);
