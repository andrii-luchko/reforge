import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/repositories/auth_repository.dart';
import 'package:reforge/core/auth/session/auth_session_controller.dart';
import '../../../core/analytics/mocks/mock_analytics_service.dart';
import '../mocks/mock_auth_repository.dart';

bool _isAuthenticated(AuthState s) => s.maybeMap(authenticated: (_) => true, orElse: () => false);
bool _isUnauthenticated(AuthState s) => s.maybeMap(unauthenticated: (_) => true, orElse: () => false);
bool _isError(AuthState s) => s.maybeMap(error: (_) => true, orElse: () => false);

class _TestAuthSessionController implements AuthSessionController {
  final _invalidations = StreamController<SessionEndReason>.broadcast();

  @override
  Stream<SessionEndReason> get invalidations => _invalidations.stream;

  @override
  Future<void> invalidate(SessionEndReason reason) async {
    _invalidations.add(reason);
  }

  Future<void> close() => _invalidations.close();
}

void main() {
  late MockAuthRepository mockRepository;
  late MockAnalyticsService mockAnalytics;
  late _TestAuthSessionController sessionController;

  setUpAll(() {
    registerFallbackValue(const AuthTokens(accessToken: '', refreshToken: ''));
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    mockAnalytics = MockAnalyticsService();
    sessionController = _TestAuthSessionController();
    when(() => mockRepository.clearTokens()).thenAnswer((_) async => const Result.success(null));
    when(() => mockAnalytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.setUserId(any())).thenAnswer((_) async {});
    when(() => mockAnalytics.setUserProperty(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.setAnalyticsCollectionEnabled(any())).thenAnswer((_) async {});
    when(
      () => mockAnalytics.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockAnalytics.logLogin(method: any(named: 'method'))).thenAnswer((_) async {});
    when(() => mockAnalytics.logSignUp(method: any(named: 'method'))).thenAnswer((_) async {});
  });

  tearDown(() => sessionController.close());

  const testTokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated when the active session is invalidated',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(testTokens));
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await sessionController.invalidate(SessionEndReason.refreshTokenInvalid);
        await Future<void>.delayed(Duration.zero);
      },
      skip: 1,
      expect: () => [predicate<AuthState>(_isUnauthenticated)],
    );

    blocTest<AuthCubit, AuthState>(
      'signIn emits authenticated when repository succeeds',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signin(any(), any())).thenAnswer((_) async => const Result.success(testTokens));
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signIn(email: 'user@example.com', password: 'password123');
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isAuthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signIn emits error when repository fails',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signin(any(), any())).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signIn(email: 'user@example.com', password: 'password123');
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isError),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signUp emits authenticated when repository succeeds',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signup(any(), any())).thenAnswer((_) async => const Result.success(testTokens));
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signUp(email: 'user@example.com', password: 'password123');
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isAuthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signUp emits error when repository fails',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signup(any(), any())).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signUp(email: 'user@example.com', password: 'password123');
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isError),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signWithGoogle emits authenticated when repository succeeds',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithGoogle()).thenAnswer((_) async => const Result.success(testTokens));
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signWithGoogle();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isAuthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signWithGoogle emits unauthenticated when AuthCanceledException',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithGoogle()).thenAnswer(
          (_) async => const Result.error(AuthCanceledException()),
        );
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signWithGoogle();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isUnauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signWithGoogle emits error when other exception',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithGoogle()).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signWithGoogle();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isError),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signWithApple emits authenticated when repository succeeds',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithApple()).thenAnswer((_) async => const Result.success(testTokens));
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signWithApple();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isAuthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signWithApple emits unauthenticated when AuthCanceledException',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithApple()).thenAnswer(
          (_) async => const Result.error(AuthCanceledException()),
        );
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signWithApple();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isUnauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits unauthenticated when from authenticated state',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(testTokens));
        when(() => mockRepository.signOut()).thenAnswer((_) async => const Result.success(null));
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signOut();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isUnauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut restores state when repository fails',
      build: () {
        when(() => mockRepository.getTokens()).thenAnswer((_) async => const Result.success(testTokens));
        when(() => mockRepository.signOut()).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository, mockAnalytics, sessionController);
      },
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        await cubit.signOut();
      },
      skip: 2,
      expect: () => [
        predicate<AuthState>(_isError),
        predicate<AuthState>(_isAuthenticated),
      ],
    );
  });
}
