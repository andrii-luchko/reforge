import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';

abstract interface class HomeRepository {
  OnboardedUser? getUserData();
  Future<Result<UserStats?>> getUserStats(StatsPeriod period);
}

@Injectable(as: HomeRepository)
class HomeRepositoryImpl with RepositoryErrorHandler implements HomeRepository {
  HomeRepositoryImpl(this._apiClient, this._userSessionService);

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  @override
  OnboardedUser? getUserData() {
    return _userSessionService.currentUser?.map(
      newUser: (_) => null,
      onboarded: (u) => u,
    );
  }

  @override
  Future<Result<UserStats?>> getUserStats(StatsPeriod period) async {
    try {
      final startDate = period.range.start.toUtc().toIso8601String();
      final endDate = period.range.end.toUtc().toIso8601String();
      final result = await makeRequest(
        () => _apiClient.getUserStats(startDate: startDate, endDate: endDate),
        label: 'getUserStats',
      );

      final stats = result.data.toDomain();
      return Result.success(stats);
    } on AppNetworkException catch (error, stackTrace) {
      if (error.statusCode == 500) {
        //typical problem from backend for a new user. just return null;

        return const Result.success(null);
      }

      return Result.error(error, stackTrace);

      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      final exception = error is Exception ? error : AppException(error.toString());
      return Result.error(exception, stackTrace);
    }
  }
}
