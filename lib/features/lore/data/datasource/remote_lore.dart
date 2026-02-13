import 'package:injectable/injectable.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/lore/data/models/plates_model.dart';

typedef PaginatedPlatesResult = ({
  List<PlatesModel> items,
  int total,
  bool hasMore,
});

abstract interface class RemoteLoreDataSource {
  Future<PaginatedPlatesResult> getPlates({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<PlatesModel> getPlateById(int id);
}

@Injectable(as: RemoteLoreDataSource)
class RemoteLoreDataSourceImpl implements RemoteLoreDataSource {
  RemoteLoreDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedPlatesResult> getPlates({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final response = await _apiClient.getJikuPlates(page, limit, search);
    final items = response.data.map(PlatesModel.fromListDto).toList();
    final pagination = response.meta.pagination;
    final hasMore = pagination.page < pagination.pages;

    return (
      items: items,
      total: pagination.total,
      hasMore: hasMore,
    );
  }

  @override
  Future<PlatesModel> getPlateById(int id) async {
    final response = await _apiClient.getJikuPlateById(id);
    return PlatesModel.fromDetailDto(response.data);
  }
}
