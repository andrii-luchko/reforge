import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:reforge/app/utils/logger/logger.dart';

mixin AnalyticsSafeExecutor {
  Future<void> safeExecute(
    Future<void> Function() operation, {
    String? label,
  }) async {
    try {
      await operation();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      logger.w('Analytics failed [$label]: $e', e, st);
      try {
        unawaited(
          FirebaseCrashlytics.instance
              .recordError(e, st, reason: 'Analytics: ${label ?? "unknown"}')
              .catchError((_) {}),
        );
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
    }
  }
}
