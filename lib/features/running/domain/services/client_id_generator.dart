import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class ClientIdGenerator {
  const ClientIdGenerator();

  static const _uuid = Uuid();

  String nextSetId() => _uuid.v7();
}
