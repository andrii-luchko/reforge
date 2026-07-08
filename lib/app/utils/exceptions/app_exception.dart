class AppException implements Exception {
  AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AppNetworkException implements AppException {
  AppNetworkException(this.message, {this.statusCode, this.originalError});

  @override
  final String message;
  final int? statusCode;

  final Object? originalError;

  @override
  String toString() => message;
}
