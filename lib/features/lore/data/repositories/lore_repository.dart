import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/lore/data/datasource/local_lore.dart';
import 'package:reforge/features/lore/data/datasource/remote_lore.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/domain/repositories/lore_repository.dart';

@Injectable(as: LoreRepository)
class LoreRepositoryImpl with RepositoryErrorHandler implements LoreRepository {
  LoreRepositoryImpl(this._localLoreDataSource, this._remoteLoreDataSource);

  final LocalLoreDataSource _localLoreDataSource;
  final RemoteLoreDataSource _remoteLoreDataSource;

  @override
  Future<Result<List<PlatesEntity>>> getPlates() async {
    try {
      return await makeRequest(
        () async {
          final isPlatesChanged = await _remoteLoreDataSource.platesChanged();
          final localPlates = await _localLoreDataSource.getPlates();

          if (isPlatesChanged || localPlates.isEmpty) {
            final remotePlates = await _remoteLoreDataSource.getPlates();
            await _localLoreDataSource.storePlates(remotePlates);
            return Result.success(remotePlates.map((m) => m.toEntity()).toList());
          }

          return Result.success(localPlates.map((m) => m.toEntity()).toList());
        },
        label: 'getPlates',
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
