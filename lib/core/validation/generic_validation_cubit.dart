import 'package:flutter_bloc/flutter_bloc.dart';

class GenericValidationCubit<T> extends Cubit<GenericValidationState<T>> {
  GenericValidationCubit({
    required T initialValue,
    required this.onSave,
    this.validator,
  }) : super(GenericValidationInitial(initialValue));

  final Future<void> Function(T newValue) onSave;
  final String? Function(T value)? validator;

  void onChanged(T newValue) {
    final error = validator?.call(newValue);
    if (error == null) {
      emit(GenericValidationInitial(newValue));
    } else {
      emit(GenericValidationError(newValue, error));
    }
  }

  Future<void> save() async {
    final error = validator?.call(state.value);
    if (error != null) {
      emit(GenericValidationError(state.value, error));
      return;
    }

    emit(GenericValidationLoading(state.value));
    try {
      await onSave(state.value);
      emit(GenericValidationSuccess(state.value));
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      emit(GenericValidationError(state.value, e.toString()));
    }
  }
}

sealed class GenericValidationState<T> {
  const GenericValidationState({required this.value, this.error, this.isLoading = false});

  final T value;
  final String? error;
  final bool isLoading;
}

class GenericValidationInitial<T> extends GenericValidationState<T> {
  const GenericValidationInitial(T value) : super(value: value);
}

class GenericValidationLoading<T> extends GenericValidationState<T> {
  const GenericValidationLoading(T value) : super(value: value, isLoading: true);
}

class GenericValidationSuccess<T> extends GenericValidationState<T> {
  const GenericValidationSuccess(T value) : super(value: value);
}

class GenericValidationError<T> extends GenericValidationState<T> {
  const GenericValidationError(T value, String message) : super(value: value, error: message);
}
