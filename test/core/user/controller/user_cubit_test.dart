import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../../analytics/mocks/mock_analytics_service.dart';
import '../mocks/mock_auth_cubit.dart';
import '../mocks/mock_profile_repository.dart';
import '../mocks/mock_user_repository.dart';
import '../mocks/mock_user_session_service.dart';

OnboardedUser get testUser => OnboardedUser(
  id: 1,
  email: 'test@example.com',
  measurementSystem: MeasurementSystem.metric,
  factionId: 1,
  birthDate: DateTime(1990, 1, 15),
  workoutsPerWeek: 3,
  userName: 'testuser',
  bodyWeight: 75,
);

bool _isLoaded(UserState s) => s.maybeMap(loaded: (_) => true, orElse: () => false);
bool _isDeleted(UserState s) => s.maybeMap(deleted: (_) => true, orElse: () => false);
bool _isError(UserState s) => s.maybeMap(error: (_) => true, orElse: () => false);

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockUserRepository mockUserRepository;
  late MockProfileRepository mockProfileRepository;
  late MockUserSessionService mockUserSessionService;
  late MockAnalyticsService mockAnalytics;
  late StreamController<AuthState> authStreamController;

  setUpAll(() {
    registerFallbackValue(testUser);
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockUserRepository = MockUserRepository();
    mockProfileRepository = MockProfileRepository();
    mockUserSessionService = MockUserSessionService();
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.setUserId(any())).thenAnswer((_) async {});
    when(() => mockAnalytics.setUserProperty(any(), any())).thenAnswer((_) async {});
    when(() => mockUserSessionService.clearUser()).thenAnswer((_) async {});
    authStreamController = StreamController<AuthState>.broadcast();
    // Use stream that never emits to avoid _onAuthStateChanged overwriting seeded state
    when(() => mockAuthCubit.stream).thenAnswer((_) => authStreamController.stream);
    when(() => mockAuthCubit.state).thenReturn(const AuthState.unauthenticated());
  });

  tearDown(() {
    unawaited(authStreamController.close());
  });

  UserCubit createCubit() => UserCubit(
    mockAuthCubit,
    mockUserRepository,
    mockProfileRepository,
    mockUserSessionService,
    mockAnalytics,
  );

  group('UserCubit', () {
    blocTest<UserCubit, UserState>(
      'authenticated startup waits for the server and never emits a cached user',
      build: () {
        final serverUser = testUser.copyWith(email: 'server@example.com');
        when(() => mockUserSessionService.currentUser).thenReturn(testUser);
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
        when(() => mockUserRepository.getCurrentUser()).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return Result.success(serverUser);
        });
        return createCubit();
      },
      act: (cubit) async {
        authStreamController.add(
          const AuthState.authenticated(
            tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
      },
      expect: () => [
        isA<Loading>(),
        isA<Loaded>().having((state) => state.user.email, 'email', 'server@example.com'),
      ],
      verify: (_) {
        verifyNever(() => mockUserSessionService.currentUser);
      },
    );

    blocTest<UserCubit, UserState>(
      'refreshUser emits loaded when repository succeeds',
      build: () {
        when(() => mockUserRepository.getCurrentUser()).thenAnswer((_) async => Result.success(testUser));
        when(() => mockUserRepository.refreshUser()).thenAnswer((_) async => Result.success(testUser));
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
        when(() => mockUserSessionService.currentUser).thenReturn(null);
        return createCubit();
      },
      act: (cubit) async {
        authStreamController.add(
          const AuthState.authenticated(
            tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 200));
        await cubit.refreshUser();
      },
      skip: 1,
      expect: () => [predicate<UserState>(_isLoaded)],
    );

    blocTest<UserCubit, UserState>(
      'refreshUser emits error then restores state when repository fails',
      build: () {
        when(() => mockUserRepository.refreshUser()).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.refreshUser(),
      expect: () => [
        predicate<UserState>(_isError),
        predicate<UserState>(_isLoaded),
      ],
    );

    blocTest<UserCubit, UserState>(
      'deleteUser emits deleted when repository succeeds',
      build: () {
        when(() => mockUserRepository.deleteUser()).thenAnswer((_) async => const Result.success(null));
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.deleteUser(),
      expect: () => [
        isA<UserState>().having((s) => s.maybeMap(updating: (_) => true, orElse: () => false), 'updating', true),
        predicate<UserState>(_isDeleted),
      ],
    );

    blocTest<UserCubit, UserState>(
      'deleteUser restores state when repository fails',
      build: () {
        when(() => mockUserRepository.deleteUser()).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.deleteUser(),
      expect: () => [
        isA<UserState>().having((s) => s.maybeMap(updating: (_) => true, orElse: () => false), 'updating', true),
        predicate<UserState>(_isError),
        predicate<UserState>(_isLoaded),
      ],
    );

    blocTest<UserCubit, UserState>(
      'updateUsername emits loaded with updated user',
      build: () {
        when(() => mockProfileRepository.updateUsername(any())).thenAnswer(
          (_) async => const Result.success('server-name'),
        );
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.updateUsername('newname'),
      expect: () => [
        isA<UserState>().having((s) => s.maybeMap(updating: (_) => true, orElse: () => false), 'updating', true),
        isA<Loaded>()
            .having((state) => state.user, 'user type', isA<OnboardedUser>())
            .having((state) => (state.user as OnboardedUser).userName, 'username', 'server-name')
            .having((state) => (state.user as OnboardedUser).factionId, 'faction', testUser.factionId),
      ],
    );

    blocTest<UserCubit, UserState>(
      'updateUsername when repository fails restores the loaded user',
      build: () {
        when(() => mockProfileRepository.updateUsername(any())).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.updateUsername('newname'),
      expect: () => [
        isA<UserState>().having((s) => s.maybeMap(updating: (_) => true, orElse: () => false), 'updating', true),
        predicate<UserState>(_isLoaded),
      ],
    );

    blocTest<UserCubit, UserState>(
      'updateEmail success emits loaded with new email',
      build: () {
        when(
          () => mockUserRepository.updateUserEmail(
            email: any(named: 'email'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => const Result.success('new@example.com'));
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.updateEmail('new@example.com'),
      expect: () => [
        isA<UserState>().having((s) => s.maybeMap(updating: (_) => true, orElse: () => false), 'updating', true),
        isA<Loaded>().having((state) => state.user.email, 'email', 'new@example.com'),
      ],
      verify: (_) {
        final savedUser = verify(() => mockUserSessionService.saveUser(captureAny())).captured.single as User;
        expect(savedUser, isA<OnboardedUser>());
        expect(savedUser.id, testUser.id);
        expect((savedUser as OnboardedUser).factionId, testUser.factionId);
        expect(savedUser.email, 'new@example.com');
      },
    );

    blocTest<UserCubit, UserState>(
      'updateEmail trims input and skips the request when email is unchanged',
      build: createCubit,
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.updateEmail('  test@example.com  '),
      expect: () => <UserState>[],
      verify: (_) {
        verifyNever(
          () => mockUserRepository.updateUserEmail(
            email: any(named: 'email'),
            userId: any(named: 'userId'),
          ),
        );
        verifyNever(() => mockUserSessionService.saveUser(any()));
      },
    );

    blocTest<UserCubit, UserState>(
      'updateEmail when repository fails restores state and returns error',
      build: () {
        when(
          () => mockUserRepository.updateUserEmail(
            email: any(named: 'email'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => Result.error(Exception('Email already in use')),
        );
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.updateEmail('new@example.com'),
      expect: () => [
        isA<UserState>().having((s) => s.maybeMap(updating: (_) => true, orElse: () => false), 'updating', true),
        predicate<UserState>(_isLoaded),
      ],
    );
  });
}
