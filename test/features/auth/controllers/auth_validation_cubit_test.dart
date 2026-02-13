import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/auth/controllers/validation/auth_validation_cubit.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  group('AuthValidationCubit', () {
    blocTest<AuthValidationCubit, AuthValidationState>(
      'setMode switches to signUp and updates canSubmit',
      build: AuthValidationCubit.new,
      act: (cubit) => cubit.setMode(AuthMode.signUp),
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.mode, 'mode', AuthMode.signUp)
            .having((s) => s.canSubmit, 'canSubmit', false),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'setMode switches to signIn',
      build: AuthValidationCubit.new,
      act: (cubit) {
        cubit.setMode(AuthMode.signUp);
        cubit.setMode(AuthMode.signIn);
      },
      expect: () => [
        isA<AuthValidationState>().having((s) => s.mode, 'mode', AuthMode.signUp),
        isA<AuthValidationState>().having((s) => s.mode, 'mode', AuthMode.signIn),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'emailChanged with invalid email sets emailError',
      build: AuthValidationCubit.new,
      act: (cubit) => cubit.emailChanged('invalid'),
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.email, 'email', 'invalid')
            .having((s) => s.emailError, 'emailError', isNotNull),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'emailChanged with valid email clears emailError',
      build: AuthValidationCubit.new,
      act: (cubit) => cubit.emailChanged('user@example.com'),
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.email, 'email', 'user@example.com')
            .having((s) => s.emailError, 'emailError', isNull),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'passwordChanged with invalid password sets passwordError',
      build: AuthValidationCubit.new,
      act: (cubit) => cubit.passwordChanged('short'),
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.password, 'password', 'short')
            .having((s) => s.passwordError, 'passwordError', isNotNull),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'passwordChanged with valid password clears passwordError',
      build: AuthValidationCubit.new,
      act: (cubit) => cubit.passwordChanged('password123'),
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.password, 'password', 'password123')
            .having((s) => s.passwordError, 'passwordError', isNull),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'confirmPasswordChanged in signUp with mismatch sets confirmPasswordError',
      build: AuthValidationCubit.new,
      act: (cubit) {
        cubit.setMode(AuthMode.signUp);
        cubit.passwordChanged('password123');
        cubit.confirmPasswordChanged('different');
      },
      expect: () => [
        isA<AuthValidationState>().having((s) => s.mode, 'mode', AuthMode.signUp),
        isA<AuthValidationState>().having((s) => s.password, 'password', 'password123'),
        isA<AuthValidationState>()
            .having((s) => s.confirmPassword, 'confirmPassword', 'different')
            .having((s) => s.confirmPasswordError, 'confirmPasswordError', isNotNull),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'termsAcceptanceChanged in signUp affects canSubmit',
      build: AuthValidationCubit.new,
      act: (cubit) {
        cubit.setMode(AuthMode.signUp);
        cubit.emailChanged('user@example.com');
        cubit.passwordChanged('password123');
        cubit.confirmPasswordChanged('password123');
        cubit.termsAcceptanceChanged(true);
      },
      skip: 5,
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.termsAccepted, 'termsAccepted', true)
            .having((s) => s.canSubmit, 'canSubmit', true),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'signUp mode: canSubmit false without terms accepted',
      build: AuthValidationCubit.new,
      act: (cubit) {
        cubit.setMode(AuthMode.signUp);
        cubit.emailChanged('user@example.com');
        cubit.passwordChanged('password123');
        cubit.confirmPasswordChanged('password123');
      },
      expect: () => [
        isA<AuthValidationState>().having((s) => s.mode, 'mode', AuthMode.signUp),
        isA<AuthValidationState>().having((s) => s.email, 'email', 'user@example.com'),
        isA<AuthValidationState>().having((s) => s.password, 'password', 'password123'),
        isA<AuthValidationState>()
            .having((s) => s.confirmPassword, 'confirmPassword', 'password123')
            .having((s) => s.canSubmit, 'canSubmit', false),
      ],
    );

    blocTest<AuthValidationCubit, AuthValidationState>(
      'signIn mode: valid email and password sets canSubmit true',
      build: AuthValidationCubit.new,
      act: (cubit) {
        cubit.emailChanged('user@example.com');
        cubit.passwordChanged('password123');
      },
      skip: 2,
      expect: () => [
        isA<AuthValidationState>()
            .having((s) => s.password, 'password', 'password123')
            .having((s) => s.canSubmit, 'canSubmit', true),
      ],
    );
  });
}
