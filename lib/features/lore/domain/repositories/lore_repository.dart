import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';

typedef PaginatedPlates = ({
  List<PlatesEntity> items,
  int total,
  bool hasMore,
});

abstract interface class LoreRepository {
  Future<Result<PaginatedPlates>> getPlates({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<Result<PlatesEntity>> getPlateById(int id);
}
