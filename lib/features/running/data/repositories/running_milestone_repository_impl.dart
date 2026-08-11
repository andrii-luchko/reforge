import 'package:injectable/injectable.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/running/data/requests/calculate_running_milestone_request.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_repository.dart';

@LazySingleton(as: RunningMilestoneRepository)
class RunningMilestoneRepositoryImpl implements RunningMilestoneRepository {
  RunningMilestoneRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> calculateRunningMilestone(RunningMilestonePayload payload) {
    return _apiClient.calculateRunningMilestone(
      CalculateRunningMilestoneRequest.fromPayload(payload),
    );
  }
}
