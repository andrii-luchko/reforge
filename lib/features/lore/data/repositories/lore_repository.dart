import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/lore/data/datasource/remote_lore.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/domain/repositories/lore_repository.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@Injectable(as: LoreRepository)
class LoreRepositoryImpl with RepositoryErrorHandler implements LoreRepository {
  LoreRepositoryImpl(this._remoteLoreDataSource);

  final RemoteLoreDataSource _remoteLoreDataSource;

  @override
  Future<Result<PaginatedPlates>> getPlates({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final data = await makeRequest(
        () async {
          final result = await _remoteLoreDataSource.getPlates(
            page: page,
            limit: limit,
            search: search,
          );
          return (
            items: result.items.map((m) => m.toEntity()).toList(),
            total: result.total,
            hasMore: result.hasMore,
          );
        },
        label: 'getPlates',
      );
      return Result.success(data);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<PlatesEntity>> getPlateById(int id) async {
    try {
      final model = await makeRequest(
        () => _remoteLoreDataSource.getPlateById(id),
        label: 'getPlateById',
        transformError: (error, stackTrace) {
          if (error is DioException && error.response?.statusCode == 403) {
            return AppException(t.lore.unlockAtRequiredLevel);
          }
          return null;
        },
      );
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
