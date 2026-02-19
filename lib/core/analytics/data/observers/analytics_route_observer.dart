import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';

@lazySingleton
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final screenName = _screenName(route);
    unawaited(_analytics.logScreenView(screenName: screenName));
  }

  String _screenName(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;

    final args = route.settings.arguments;
    if (args is Map && args.containsKey('path')) {
      return args['path'] as String? ?? 'unknown';
    }

    return 'unknown';
  }
}
