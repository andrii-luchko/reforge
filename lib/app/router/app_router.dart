import 'package:go_router/go_router.dart';
import 'package:reforge/app/router/routes.dart';

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: const OnboardingPageRoute().location,
  debugLogDiagnostics: true,
);
