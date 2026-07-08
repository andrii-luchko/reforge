import 'dart:developer' as developer;

import 'package:talker/talker.dart';

//
// ignore: specify_nonobvious_property_types
final logger = _AppLogger.instance;

class _AppLogger {
  _AppLogger._();

  static final instance = _AppLogger._();

  final talker = Talker(
    settings: TalkerSettings(
      useHistory: false,
      maxHistoryItems: 0,
    ),
    logger: TalkerLogger(
      settings: TalkerLoggerSettings(),
      output: (message) => developer.log(message, name: 'Talker'),
    ),
  );

  void e(dynamic message, [Object? exception, StackTrace? stackTrace]) =>
      talker.error(message ?? exception.runtimeType, exception, stackTrace);

  void w(Object message, [Object? exception, StackTrace? stackTrace]) => talker.warning(message, exception, stackTrace);

  void i(Object message, [Object? exception, StackTrace? stackTrace]) => talker.info(message, exception, stackTrace);

  void d(Object? message, [Object? exception, StackTrace? stackTrace]) => talker.debug(message, exception, stackTrace);
}
