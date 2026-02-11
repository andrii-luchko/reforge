import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';

// ignore: one_member_abstracts
abstract interface class LoreRepository {
  Future<Result<List<PlatesEntity>>> getPlates();
}
