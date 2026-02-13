import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/auth/controllers/forgot_password/reset_password_cubit.dart';

import '../../../helpers/test_setup.dart';
import '../mocks/mock_reset_password_repository.dart';

void main() {
  setUpAll(initTestTranslations);

  late MockResetPasswordRepository mockRepository;
  const testToken = 'test-reset-token';

  setUp(() {
    mockRepository = MockResetPasswordRepository();
  });

  group('ResetPasswordCubit', () {
    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'passwordChanged with invalid password sets newPasswordError',
      build: () => ResetPasswordCubit(testToken, mockRepository),
      act: (cubit) => cubit.passwordChanged('short'),
      expect: () => [
        isA<ResetPasswordState>()
            .having((s) => s.newPassword, 'newPassword', 'short')
            .having((s) => s.newPasswordError, 'newPasswordError', isNotNull),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'passwordChanged with valid password clears newPasswordError',
      build: () => ResetPasswordCubit(testToken, mockRepository),
      act: (cubit) => cubit.passwordChanged('password123'),
      expect: () => [
        isA<ResetPasswordState>()
            .having((s) => s.newPassword, 'newPassword', 'password123')
            .having((s) => s.newPasswordError, 'newPasswordError', isNull),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'passwordChanged updates confirmPasswordError when confirmPassword already set',
      build: () => ResetPasswordCubit(testToken, mockRepository),
      act: (cubit) {
        cubit
          ..confirmPasswordChanged('mismatch')
          ..passwordChanged('password123');
      },
      expect: () => [
        isA<ResetPasswordState>().having(
          (s) => s.confirmPassword,
          'confirmPassword',
          'mismatch',
        ),
        isA<ResetPasswordState>()
            .having((s) => s.newPassword, 'newPassword', 'password123')
            .having((s) => s.confirmPasswordError, 'confirmPasswordError', isNotNull),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'confirmPasswordChanged with mismatch sets confirmPasswordError',
      build: () => ResetPasswordCubit(testToken, mockRepository),
      act: (cubit) {
        cubit
          ..passwordChanged('password123')
          ..confirmPasswordChanged('different');
      },
      expect: () => [
        isA<ResetPasswordState>().having((s) => s.newPassword, 'newPassword', 'password123'),
        isA<ResetPasswordState>()
            .having((s) => s.confirmPassword, 'confirmPassword', 'different')
            .having((s) => s.confirmPasswordError, 'confirmPasswordError', isNotNull),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'confirmPasswordChanged with match clears confirmPasswordError',
      build: () => ResetPasswordCubit(testToken, mockRepository),
      act: (cubit) {
        cubit
          ..passwordChanged('password123')
          ..confirmPasswordChanged('password123');
      },
      expect: () => [
        isA<ResetPasswordState>().having((s) => s.newPassword, 'newPassword', 'password123'),
        isA<ResetPasswordState>()
            .having((s) => s.confirmPassword, 'confirmPassword', 'password123')
            .having((s) => s.confirmPasswordError, 'confirmPasswordError', isNull),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'submit emits success when repository succeeds',
      build: () {
        when(() => mockRepository.confirm(
              token: any(named: 'token'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => const Result.success(null));
        return ResetPasswordCubit(testToken, mockRepository);
      },
      seed: () => const ResetPasswordState(
        newPassword: 'password123',
        confirmPassword: 'password123',
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<ResetPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ResetPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.isSuccess, 'isSuccess', true),
      ],
    );

    blocTest<ResetPasswordCubit, ResetPasswordState>(
      'submit emits apiError when repository fails',
      build: () {
        when(() => mockRepository.confirm(
              token: any(named: 'token'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return ResetPasswordCubit(testToken, mockRepository);
      },
      seed: () => const ResetPasswordState(
        newPassword: 'password123',
        confirmPassword: 'password123',
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<ResetPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ResetPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.apiError, 'apiError', isNotNull),
      ],
    );
  });
}
