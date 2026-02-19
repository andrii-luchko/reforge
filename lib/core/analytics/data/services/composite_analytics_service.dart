import 'package:injectable/injectable.dart';
import 'package:reforge/core/analytics/data/analytics_safe_executor.dart';
import 'package:reforge/core/analytics/data/services/firebase_analytics_service.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';

@Singleton(as: AnalyticsService)
class CompositeAnalyticsService with AnalyticsSafeExecutor implements AnalyticsService {
  CompositeAnalyticsService(FirebaseAnalyticsService firebase)
      : _providers = [firebase];

  final List<AnalyticsService> _providers;

  @override
  Future<void> logEvent(String name, [Map<String, Object?>? params]) async {
    await safeExecute(
      () => Future.wait(_providers.map((p) => p.logEvent(name, params))),
      label: 'logEvent:$name',
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    await safeExecute(
      () => Future.wait(_providers.map((p) => p.setUserId(userId))),
      label: 'setUserId',
    );
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    await safeExecute(
      () => Future.wait(_providers.map((p) => p.setUserProperty(name, value))),
      label: 'setUserProperty:$name',
    );
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await safeExecute(
      () => Future.wait(
        _providers.map((p) => p.setAnalyticsCollectionEnabled(enabled)),
      ),
      label: 'setAnalyticsCollectionEnabled',
    );
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await safeExecute(
      () => Future.wait(
        _providers.map(
          (p) => p.logScreenView(screenName: screenName, screenClass: screenClass),
        ),
      ),
      label: 'logScreenView:$screenName',
    );
  }

  @override
  Future<void> logLogin({String? method}) async {
    await safeExecute(
      () => Future.wait(_providers.map((p) => p.logLogin(method: method))),
      label: 'logLogin',
    );
  }

  @override
  Future<void> logSignUp({String? method}) async {
    await safeExecute(
      () => Future.wait(_providers.map((p) => p.logSignUp(method: method))),
      label: 'logSignUp',
    );
  }
}
