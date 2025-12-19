import 'package:flutter/material.dart';
import 'package:reforge/app/utils/logger/logger.dart';

class AppRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.d('📍 PUSH: ${_routeName(previousRoute)} → ${_routeName(route)}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.d('📍 POP: ${_routeName(route)} → ${_routeName(previousRoute)}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.d('📍 REPLACE: ${_routeName(oldRoute)} → ${_routeName(newRoute)}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.d('📍 REMOVE: ${_routeName(route)}');
  }

  String _routeName(Route<dynamic>? route) {
    return route?.settings.name ?? 'unknown';
  }
}
