import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
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
      final model = await _remoteLoreDataSource.getPlateById(id);
      return Result.success(model.toEntity());
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 403) {
        return Result.error(Exception(t.lore.unlockAtRequiredLevel));
      }
      final userMessage = _toUserMessage(e);
      logger.e('ERROR [getPlateById]: $e', e, stackTrace);
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'getPlateById'));
      return Result.error(Exception(userMessage));
    } on Exception catch (e, stackTrace) {
      logger.e('ERROR [getPlateById]: $e', e, stackTrace);
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'getPlateById'));
      return Result.error(Exception(e.toString()));
    }
  }

  String _toUserMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return t.errors.connection_timeout;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return t.errors.unauthorized;
        return t.errors.server_error(statusCode: statusCode ?? 0);
      case DioExceptionType.cancel:
        return t.errors.request_cancelled;
      case DioExceptionType.connectionError:
        return t.errors.no_internet;
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return t.errors.unexpected;
    }
  }
}
