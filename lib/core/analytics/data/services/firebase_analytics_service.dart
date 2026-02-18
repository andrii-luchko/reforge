import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';

@Singleton()
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object?>? params]) async {
    await _analytics.logEvent(
      name: name,
      parameters: params != null ? _toStringMap(params) : null,
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  @override
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  @override
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'unknown');
  }

  /// Firebase Analytics requires parameter values to be String, int, or double.
  static Map<String, Object>? _toStringMap(Map<String, Object?> params) {
    final result = <String, Object>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String || value is int || value is double) {
        result[entry.key] = value;
      } else {
        result[entry.key] = value.toString();
      }
    }
    return result.isEmpty ? null : result;
  }
}
