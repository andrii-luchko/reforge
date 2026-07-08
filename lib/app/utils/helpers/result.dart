import 'package:flutter/foundation.dart' show immutable;

@immutable
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.success(T value) = Success;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error, [StackTrace stackTrace]) = Failure;

  /// Functional handling of the result.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception error, StackTrace? stackTrace) onError,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final error, :final stackTrace) => onError(error, stackTrace),
    };
  }

  /// Transforms the value if this is a [Success].
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Success<R>(transform(value)),
      Failure<T>(:final error, :final stackTrace) => Failure<R>(error, stackTrace),
    };
  }

  /// Asynchronously transforms the value if this is a [Success].
  Future<Result<R>> asyncMap<R>(Future<R> Function(T value) transform) async {
    return switch (this) {
      Success<T>(:final value) => Success<R>(await transform(value)),
      Failure<T>(:final error, :final stackTrace) => Failure<R>(error, stackTrace),
    };
  }

  /// Transforms the error if this is an [Failure].
  Result<T> mapError(Exception Function(Exception error) transform) {
    return switch (this) {
      Success<T>() => this,
      Failure<T>(:final error, :final stackTrace) => Failure<T>(transform(error), stackTrace),
    };
  }

  /// Returns the value if [Success], or throws the error if [Failure].
  T getOrThrow() {
    return switch (this) {
      Success<T>(:final value) => value,
      Failure<T>(:final error) => throw error,
    };
  }

  /// Returns the value if [Success], otherwise returns [defaultValue].
  T getOrElse(T defaultValue) => this is Success<T> ? (this as Success<T>).value : defaultValue;

  /// Returns the value if [Success], otherwise returns null.
  T? get orNull => this is Success<T> ? (this as Success<T>).value : null;

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Failure<T>;
}

/// A successful [Result] with a returned [value].
@immutable
final class Success<T> extends Result<T> {
  const Success(this.value);

  /// The returned value of this result.
  final T value;

  @override
  String toString() => 'Result<$T>.success($value)';
}

/// An error [Result] with a resulting [error].
@immutable
final class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);

  /// The resulting error of this result.
  final Exception error;

  final StackTrace? stackTrace;

  @override
  String toString() => 'Result<$T>.error($error)';
}
