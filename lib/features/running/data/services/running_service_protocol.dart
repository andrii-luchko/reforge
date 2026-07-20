import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

/// Strict, platform-neutral readers for messages crossing the service channel.
///
/// iOS uses a JSON codec and may materialize integral values as either `int`
/// or `double`, so numeric payloads must always be decoded through [num].
abstract final class RunningServiceProtocol {
  static int requiredInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is num) return value.toInt();
    throw ServiceProtocolException(key: key, expectedType: 'num', actualValue: value);
  }

  static int? optionalInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw ServiceProtocolException(key: key, expectedType: 'num?', actualValue: value);
  }

  static double requiredDouble(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is num) return value.toDouble();
    throw ServiceProtocolException(key: key, expectedType: 'num', actualValue: value);
  }

  static double? optionalDouble(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw ServiceProtocolException(key: key, expectedType: 'num?', actualValue: value);
  }

  static String requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is String) return value;
    throw ServiceProtocolException(key: key, expectedType: 'String', actualValue: value);
  }

  static String? optionalString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null) return null;
    if (value is String) return value;
    throw ServiceProtocolException(key: key, expectedType: 'String?', actualValue: value);
  }

  static bool optionalBool(Map<String, dynamic> payload, String key, {required bool fallback}) {
    final value = payload[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    throw ServiceProtocolException(key: key, expectedType: 'bool?', actualValue: value);
  }

  static List<dynamic> optionalList(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null) return const [];
    if (value is List<dynamic>) return value;
    throw ServiceProtocolException(key: key, expectedType: 'List', actualValue: value);
  }

  static Map<String, dynamic> stringMap(Object? value, {required String key}) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ServiceProtocolException(key: key, expectedType: 'Map', actualValue: value);
  }
}
