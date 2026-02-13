import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/repositories/auth_repository.dart';
import '../mocks/mock_auth_repository.dart';

bool _isAuthenticated(AuthState s) =>
    s.maybeMap(authenticated: (_) => true, orElse: () => false);
bool _isUnauthenticated(AuthState s) =>
    s.maybeMap(unauthenticated: (_) => true, orElse: () => false);
bool _isError(AuthState s) =>
    s.maybeMap(error: (_) => true, orElse: () => false);

void main() {
  late MockAuthRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const AuthTokens(accessToken: '', refreshToken: ''));
  });

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  const testTokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'signIn emits authenticated when repository succeeds',
      build: () {
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signin(any(), any()))
            .thenAnswer((_) async => Result.success(testTokens));
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signin(any(), any())).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signup(any(), any()))
            .thenAnswer((_) async => Result.success(testTokens));
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signup(any(), any())).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithGoogle())
            .thenAnswer((_) async => Result.success(testTokens));
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithGoogle()).thenAnswer(
          (_) async => const Result.error(AuthCanceledException()),
        );
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithGoogle()).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithApple())
            .thenAnswer((_) async => Result.success(testTokens));
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => const Result.success(null));
        when(() => mockRepository.signWithApple()).thenAnswer(
          (_) async => const Result.error(AuthCanceledException()),
        );
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => Result.success(testTokens));
        when(() => mockRepository.signOut())
            .thenAnswer((_) async => const Result.success(null));
        return AuthCubit(mockRepository);
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
        when(() => mockRepository.getTokens())
            .thenAnswer((_) async => Result.success(testTokens));
        when(() => mockRepository.signOut()).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return AuthCubit(mockRepository);
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
