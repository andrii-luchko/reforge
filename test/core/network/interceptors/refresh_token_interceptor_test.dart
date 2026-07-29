import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/session/auth_session_controller.dart';
import 'package:reforge/core/auth/session/token_refresh_service.dart';
import 'package:reforge/core/network/dio_factory.dart';
import 'package:reforge/core/network/interceptors/auth_interceptor.dart';
import 'package:reforge/core/network/interceptors/refresh_token_interceptor.dart';

const _oldTokens = AuthTokens(
  accessToken: 'old-access-token',
  refreshToken: 'old-refresh-token',
);
const _newTokens = AuthTokens(
  accessToken: 'new-access-token',
  refreshToken: 'new-refresh-token',
);
const _watchdog = Duration(milliseconds: 500);

void main() {
  group('RefreshTokenInterceptor', () {
    test('refreshes an expired token and retries the request', () async {
      late final _NetworkHarness harness;
      var mainRequestCount = 0;

      harness = _NetworkHarness(
        mainHandler: (options) async {
          mainRequestCount++;
          final authorization = options.headers['Authorization'];

          if (authorization == 'Bearer ${_oldTokens.accessToken}') {
            return _jsonResponse(401, const {'message': 'Unauthorized'});
          }

          expect(authorization, 'Bearer ${_newTokens.accessToken}');
          return _jsonResponse(200, const {'ok': true});
        },
      );

      final response = await harness.dio.get<Map<String, dynamic>>('/resource').timeout(_watchdog);

      expect(response.statusCode, 200);
      expect(response.data, const {'ok': true});
      expect(mainRequestCount, 2);
      expect(harness.refreshRequestCount, 1);
      expect(harness.localDataSource.tokens, _newTokens);
      expect(harness.localDataSource.saveCount, 1);
    });

    test('coalesces concurrent refreshes and retries both requests', () async {
      final bothInitialRequestsArrived = Completer<void>();
      var initialRequestCount = 0;
      var retryRequestCount = 0;

      final harness = _NetworkHarness(
        mainHandler: (options) async {
          final authorization = options.headers['Authorization'];

          if (authorization == 'Bearer ${_oldTokens.accessToken}') {
            initialRequestCount++;
            if (initialRequestCount == 2) {
              bothInitialRequestsArrived.complete();
            }
            return _jsonResponse(401, const {'message': 'Unauthorized'});
          }

          expect(authorization, 'Bearer ${_newTokens.accessToken}');
          retryRequestCount++;
          return _jsonResponse(200, const {'ok': true});
        },
        beforeRefreshResponse: () => bothInitialRequestsArrived.future,
      );

      final responses = await Future.wait([
        harness.dio.get<Map<String, dynamic>>('/first'),
        harness.dio.get<Map<String, dynamic>>('/second'),
      ]).timeout(_watchdog);

      expect(responses.map((response) => response.statusCode), everyElement(200));
      expect(initialRequestCount, 2);
      expect(retryRequestCount, 2);
      expect(harness.refreshRequestCount, 1);
      expect(harness.localDataSource.tokens, _newTokens);
    });

    test('returns a repeated 401 without refreshing again or hanging', () async {
      var mainRequestCount = 0;
      final harness = _NetworkHarness(
        mainHandler: (options) async {
          mainRequestCount++;
          return _jsonResponse(401, const {'message': 'Unauthorized'});
        },
      );

      final error = await _captureDioException(
        harness.dio.get<Map<String, dynamic>>('/resource'),
      );

      expect(error.response?.statusCode, 401);
      expect(mainRequestCount, 2);
      expect(harness.refreshRequestCount, 1);
    });

    test('returns a retry receive timeout without hanging', () async {
      var mainRequestCount = 0;
      final harness = _NetworkHarness(
        mainHandler: (options) async {
          mainRequestCount++;
          if (options.headers['Authorization'] == 'Bearer ${_oldTokens.accessToken}') {
            return _jsonResponse(401, const {'message': 'Unauthorized'});
          }

          throw DioException.receiveTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: options,
          );
        },
      );

      final error = await _captureDioException(
        harness.dio.get<Map<String, dynamic>>('/resource'),
      );

      expect(error.type, DioExceptionType.receiveTimeout);
      expect(mainRequestCount, 2);
      expect(harness.refreshRequestCount, 1);
    });

    for (final statusCode in [401, 403]) {
      test('invalidates the session when refresh returns $statusCode', () async {
        var mainRequestCount = 0;
        final harness = _NetworkHarness(
          mainHandler: (options) async {
            mainRequestCount++;
            return _jsonResponse(401, const {'message': 'Unauthorized'});
          },
          refreshStatusCode: statusCode,
        );

        final error = await _captureDioException(
          harness.dio.get<Map<String, dynamic>>('/resource'),
        );

        expect(error.response?.statusCode, statusCode);
        expect(mainRequestCount, 1);
        expect(harness.refreshRequestCount, 1);
        expect(harness.sessionController.reasons, [SessionEndReason.refreshTokenInvalid]);
        expect(harness.localDataSource.tokens, isNull);
        expect(harness.localDataSource.clearCount, 1);
      });
    }

    test('passes through a non-authentication error without refreshing', () async {
      var mainRequestCount = 0;
      final harness = _NetworkHarness(
        mainHandler: (options) async {
          mainRequestCount++;
          return _jsonResponse(500, const {'message': 'Server error'});
        },
      );

      final error = await _captureDioException(
        harness.dio.get<Map<String, dynamic>>('/resource'),
      );

      expect(error.response?.statusCode, 500);
      expect(mainRequestCount, 1);
      expect(harness.refreshRequestCount, 0);
      expect(harness.localDataSource.tokens, _oldTokens);
    });
  });

  test('DioFactory debug logger does not print sensitive request data', () {
    if (!kDebugMode) return;

    final localDataSource = _InMemoryAuthLocalDataSource(_oldTokens);
    final dio = DioFactory.create(
      baseUrl: 'https://example.test',
      localDataSource: localDataSource,
      sessionController: _RecordingSessionController(localDataSource),
    );
    final logInterceptor = dio.interceptors.whereType<LogInterceptor>().single;

    expect(logInterceptor.request, isFalse);
    expect(logInterceptor.requestHeader, isFalse);
    expect(logInterceptor.requestBody, isFalse);
    expect(logInterceptor.responseHeader, isFalse);
    expect(logInterceptor.responseBody, isFalse);
    expect(logInterceptor.requestUrl, isTrue);
    expect(logInterceptor.responseUrl, isTrue);
    expect(logInterceptor.error, isTrue);
  });
}

Future<DioException> _captureDioException(Future<Object?> request) async {
  try {
    await request.timeout(_watchdog);
  } on DioException catch (error) {
    return error;
  }

  fail('Expected the request to throw a DioException');
}

ResponseBody _jsonResponse(int statusCode, Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _NetworkHarness {
  _NetworkHarness({
    required Future<ResponseBody> Function(RequestOptions options) mainHandler,
    this.refreshStatusCode = 200,
    this.beforeRefreshResponse,
  }) : localDataSource = _InMemoryAuthLocalDataSource(_oldTokens) {
    final mainAdapter = _CallbackHttpClientAdapter(mainHandler);
    final refreshAdapter = _CallbackHttpClientAdapter((options) async {
      refreshRequestCount++;
      expect(options.path, '/auth/refresh');
      expect(options.data, {'refreshToken': _oldTokens.refreshToken});
      await beforeRefreshResponse?.call();

      if (refreshStatusCode != 200) {
        return _jsonResponse(refreshStatusCode, const {'message': 'Invalid refresh token'});
      }

      return _jsonResponse(200, {
        'data': _newTokens.toJson(),
        'status': 'success',
      });
    });

    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = mainAdapter;

    final refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test'))..httpClientAdapter = refreshAdapter;

    sessionController = _RecordingSessionController(localDataSource);
    dio.interceptors.addAll([
      AuthInterceptor(localDataSource),
      RefreshTokenInterceptor(
        dio: dio,
        localDataSource: localDataSource,
        tokenRefreshService: TokenRefreshService(refreshDio, localDataSource),
        sessionController: sessionController,
      ),
    ]);
  }

  late final Dio dio;
  final _InMemoryAuthLocalDataSource localDataSource;
  late final _RecordingSessionController sessionController;
  final int refreshStatusCode;
  final Future<void> Function()? beforeRefreshResponse;
  int refreshRequestCount = 0;
}

class _CallbackHttpClientAdapter implements HttpClientAdapter {
  _CallbackHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  _InMemoryAuthLocalDataSource(this.tokens);

  AuthTokens? tokens;
  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    saveCount++;
    this.tokens = tokens;
  }

  @override
  Future<AuthTokens?> getTokens() async => tokens;

  @override
  Future<void> clearTokens() async {
    clearCount++;
    tokens = null;
  }

  @override
  Future<bool> hasAccessToken() async => tokens != null;

  @override
  Future<void> writeAccessToken(String accessToken) async {
    final currentTokens = tokens;
    if (currentTokens != null) {
      tokens = currentTokens.copyWith(accessToken: accessToken);
    }
  }
}

class _RecordingSessionController implements AuthSessionController {
  _RecordingSessionController(this._localDataSource);

  final AuthLocalDataSource _localDataSource;
  final reasons = <SessionEndReason>[];

  @override
  Stream<SessionEndReason> get invalidations => const Stream.empty();

  @override
  Future<void> invalidate(SessionEndReason reason) async {
    reasons.add(reason);
    await _localDataSource.clearTokens();
  }
}
