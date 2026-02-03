import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/lore/data/models/plates_model.dart';
import 'package:reforge/features/lore/domain/mock/lore_mock_generator.dart';

abstract interface class RemoteLoreDataSource {
  Future<bool> platesChanged();
  Future<List<PlatesModel>> getPlates();
}

@Injectable(as: RemoteLoreDataSource)
class RemoteLoreDataSourceImpl implements RemoteLoreDataSource {
  RemoteLoreDataSourceImpl(this._apiClient);

  // ignore: unused_field
  final ApiClient _apiClient;

  @override
  Future<bool> platesChanged() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Random().nextBool();
  }

  @override
  Future<List<PlatesModel>> getPlates() async {
    await Future.delayed(const Duration(seconds: 1));

    return LoreMockGenerator.generateModels(15);
  }
}
