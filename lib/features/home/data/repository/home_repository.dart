import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';

// ignore: one_member_abstracts
abstract interface class HomeRepository {
  Future<Result<UserStats>> getUserStats(StatsPeriod period);
}

@Injectable(as: HomeRepository)
class HomeRepositoryImpl with RepositoryErrorHandler implements HomeRepository {
  HomeRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<UserStats>> getUserStats(StatsPeriod period) async {
    try {
      final startDate = period.range.start.toUtc().toIso8601String();
      final endDate = period.range.end.toUtc().toIso8601String();
      final result = await _apiClient.getUserStats(startDate: startDate, endDate: endDate);

      final stats = result.data.toDomain();
      return Result.success(stats);
    } on DioException catch (error, stackTrace) {
      if (error.response?.statusCode == 500) {
        // TODO(reforge): Remove this workaround when the backend returns an explicit
        // no-stats response for new users instead of a generic 500.
        return Result.success(UserStats.newUser());
      }

      return Result.error(error, stackTrace);

      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      final exception = error is Exception ? error : AppException(error.toString());
      return Result.error(exception, stackTrace);
    }
  }
}
