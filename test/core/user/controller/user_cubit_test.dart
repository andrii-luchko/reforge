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
        final updatedUser = testUser.copyWith(userName: 'newname');
        when(() => mockProfileRepository.updateUsername(any())).thenAnswer((_) async => Result.success(updatedUser));
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
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
      'updateUsername when repository fails emits error then restores',
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
        predicate<UserState>(_isError),
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
        ).thenAnswer((_) async => const Result.success(null));
        when(() => mockUserSessionService.saveUser(any())).thenAnswer((_) async {});
        return createCubit();
      },
      seed: () => UserState.loaded(testUser),
      act: (cubit) => cubit.updateEmail('new@example.com'),
      expect: () => [
        predicate<UserState>(_isLoaded),
      ],
    );

    blocTest<UserCubit, UserState>(
      'updateEmail when repository fails restores state and returns error',
      build: () {
        when(() => mockUserRepository.getCurrentUser()).thenAnswer((_) async => Result.success(testUser));
        when(
          () => mockUserRepository.updateUserEmail(
            email: any(named: 'email'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => Result.error(Exception('Email already in use')),
        );
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
        await cubit.updateEmail('new@example.com');
      },
      skip: 1,
      expect: () => [predicate<UserState>(_isLoaded)],
    );
  });
}
