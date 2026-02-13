import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';

void main() {
  group('GenericValidationCubit', () {
    blocTest<GenericValidationCubit<String>, GenericValidationState<String>>(
      'onChanged with valid value emits GenericValidationInitial',
      build: () => GenericValidationCubit<String>(
        initialValue: 'initial',
        onSave: (_) async {},
        validator: (v) => v.isEmpty ? 'required' : null,
      ),
      act: (cubit) => cubit.onChanged('valid'),
      expect: () => [
        isA<GenericValidationInitial<String>>()
            .having((s) => s.value, 'value', 'valid'),
      ],
    );

    blocTest<GenericValidationCubit<String>, GenericValidationState<String>>(
      'onChanged with invalid value emits GenericValidationError',
      build: () => GenericValidationCubit<String>(
        initialValue: 'initial',
        onSave: (_) async {},
        validator: (v) => v.isEmpty ? 'required' : null,
      ),
      act: (cubit) => cubit.onChanged(''),
      expect: () => [
        isA<GenericValidationError<String>>()
            .having((s) => s.value, 'value', '')
            .having((s) => s.error, 'error', 'required'),
      ],
    );

    blocTest<GenericValidationCubit<String>, GenericValidationState<String>>(
      'onChanged without validator emits GenericValidationInitial',
      build: () => GenericValidationCubit<String>(
        initialValue: 'initial',
        onSave: (_) async {},
      ),
      act: (cubit) => cubit.onChanged('any'),
      expect: () => [
        isA<GenericValidationInitial<String>>()
            .having((s) => s.value, 'value', 'any'),
      ],
    );

    blocTest<GenericValidationCubit<String>, GenericValidationState<String>>(
      'save with valid value emits Loading then Success',
      build: () => GenericValidationCubit<String>(
        initialValue: 'valid',
        onSave: (_) async {},
        validator: (v) => v.isEmpty ? 'required' : null,
      ),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<GenericValidationLoading<String>>()
            .having((s) => s.value, 'value', 'valid'),
        isA<GenericValidationSuccess<String>>()
            .having((s) => s.value, 'value', 'valid'),
      ],
    );

    blocTest<GenericValidationCubit<String>, GenericValidationState<String>>(
      'save with invalid value emits GenericValidationError and does not call onSave',
      build: () => GenericValidationCubit<String>(
        initialValue: '',
        onSave: (_) async {},
        validator: (v) => v.isEmpty ? 'required' : null,
      ),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<GenericValidationError<String>>()
            .having((s) => s.value, 'value', '')
            .having((s) => s.error, 'error', 'required'),
      ],
    );

    blocTest<GenericValidationCubit<String>, GenericValidationState<String>>(
      'save when onSave throws emits GenericExternalError',
      build: () => GenericValidationCubit<String>(
        initialValue: 'valid',
        onSave: (_) async {
          throw Exception('Network error');
        },
        validator: (v) => v.isEmpty ? 'required' : null,
      ),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<GenericValidationLoading<String>>()
            .having((s) => s.value, 'value', 'valid'),
        isA<GenericExternalError<String>>()
            .having((s) => s.value, 'value', 'valid')
            .having((s) => s.error, 'error', contains('Network error')),
      ],
    );
  });
}
