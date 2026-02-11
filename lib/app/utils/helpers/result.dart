sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.success(T value) = Success._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error, [StackTrace stackTrace]) = ErrorR._;
}

/// A successful [Result] with a returned [value].
final class Success<T> extends Result<T> {
  const Success._(this.value);

  /// The returned value of this result.
  final T value;

  @override
  String toString() => 'Result<$T>.success($value)';
}

/// An error [Result] with a resulting [error].
final class ErrorR<T> extends Result<T> {
  const ErrorR._(this.error, [this.stackTrace]);

  /// The resulting error of this result.
  final Exception error;

  final StackTrace? stackTrace;

  @override
  String toString() => 'Result<$T>.error($error)';
}
