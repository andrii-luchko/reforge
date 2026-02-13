import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/auth/controllers/forgot_password/forgot_password_cubit.dart';

import '../../../helpers/test_setup.dart';
import '../mocks/mock_reset_password_repository.dart';

void main() {
  setUpAll(initTestTranslations);

  late MockResetPasswordRepository mockRepository;

  setUp(() {
    mockRepository = MockResetPasswordRepository();
  });

  group('ForgotPasswordCubit', () {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'resetState resets to initial state',
      build: () => ForgotPasswordCubit(mockRepository),
      seed: () => const ForgotPasswordState(
        email: 'user@example.com',
        emailError: 'error',
        apiError: 'api error',
      ),
      act: (cubit) => cubit.resetState(),
      expect: () => [
        const ForgotPasswordState(),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'emailChanged with invalid email sets emailError',
      build: () => ForgotPasswordCubit(mockRepository),
      act: (cubit) => cubit.emailChanged('invalid'),
      expect: () => [
        isA<ForgotPasswordState>()
            .having((s) => s.email, 'email', 'invalid')
            .having((s) => s.emailError, 'emailError', isNotNull)
            .having((s) => s.apiError, 'apiError', isNull),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'emailChanged with valid email clears errors',
      build: () => ForgotPasswordCubit(mockRepository),
      act: (cubit) => cubit.emailChanged('user@example.com'),
      expect: () => [
        isA<ForgotPasswordState>()
            .having((s) => s.email, 'email', 'user@example.com')
            .having((s) => s.emailError, 'emailError', isNull)
            .having((s) => s.apiError, 'apiError', isNull),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'submit emits success when repository succeeds',
      build: () {
        when(() => mockRepository.initiate(any()))
            .thenAnswer((_) async => const Result.success(null));
        return ForgotPasswordCubit(mockRepository);
      },
      seed: () => const ForgotPasswordState(email: 'user@example.com'),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<ForgotPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ForgotPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.isSuccess, 'isSuccess', true),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'submit emits apiError when repository fails',
      build: () {
        when(() => mockRepository.initiate(any())).thenAnswer(
          (_) async => Result.error(Exception('Network error')),
        );
        return ForgotPasswordCubit(mockRepository);
      },
      seed: () => const ForgotPasswordState(email: 'user@example.com'),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<ForgotPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<ForgotPasswordState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.apiError, 'apiError', isNotNull),
      ],
    );
  });
}
