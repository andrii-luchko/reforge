part of 'routes.dart';

@TypedGoRoute<DeepLinCreateNewPasswordRoute>(
  path: '/create-new-password',
)
class DeepLinCreateNewPasswordRoute extends GoRouteData with $DeepLinCreateNewPasswordRoute {
  const DeepLinCreateNewPasswordRoute({required this.token});

  final String token;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return CreateNewPasswordPageRoute(token: token).location;
  }
}
