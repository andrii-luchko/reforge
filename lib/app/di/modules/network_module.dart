import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/dio_factory.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthLocalDataSource localDataSource,
  ) {
    return DioFactory.create(
      baseUrl: Env.apiBaseUrl,
      localDataSource: localDataSource,
    );
  }

  @lazySingleton
  ApiClient apiClient(Dio dio) => ApiClient(dio);
}
