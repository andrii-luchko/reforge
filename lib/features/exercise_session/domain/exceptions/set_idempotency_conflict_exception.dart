class SetIdempotencyConflictException implements Exception {
  const SetIdempotencyConflictException({required this.idempotencyKey});

  final String idempotencyKey;

  @override
  String toString() => 'Backend returned a set with different data for idempotency key $idempotencyKey.';
}
