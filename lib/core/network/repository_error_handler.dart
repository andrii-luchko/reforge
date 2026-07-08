import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

mixin RepositoryErrorHandler {
  Future<T> makeRequest<T>(
    Future<T> Function() request, {
    String? label,
    AppException? Function(Object error, StackTrace stackTrace)? transformError,
  }) async {
    try {
      return await request();
    } on DioException catch (e, stackTrace) {
      if (transformError != null) {
        final transformed = transformError(e, stackTrace);
        if (transformed != null) {
          _logError(label, e, stackTrace);
          throw transformed;
        }
      }

      final statusCode = e.response?.statusCode;

      final userMessage = _toUserMessage(e);
      _logError(label, e, stackTrace);

      throw AppNetworkException(userMessage, statusCode: statusCode, originalError: e);
    } catch (e, stackTrace) {
      if (transformError != null) {
        final transformed = transformError(e, stackTrace);
        if (transformed != null) {
          _logError(label, e, stackTrace);
          throw transformed;
        }
      }
      _logError(label, e, stackTrace);
      rethrow;
    }
  }

  String _toUserMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return t.errors.connection_timeout;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final statusMessage = e.response?.statusMessage;
        if (statusCode == 401) return t.errors.unauthorized;
        final base = t.errors.server_error(statusCode: statusCode ?? 0);
        return statusMessage != null && statusMessage.isNotEmpty ? '$base. $statusMessage' : base;

      case DioExceptionType.cancel:
        return t.errors.request_cancelled;
      case DioExceptionType.connectionError:
        return t.errors.no_internet;
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return t.errors.unexpected;
    }
  }

  void _logError(String? label, Object error, StackTrace stack) {
    logger.e('ERROR [$label]: $error', error, stack);
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, reason: label).catchError((e) {
        logger.e('ERROR [$label]:Crashlytics crash', error, stack);
      }),
    );
  }
}
