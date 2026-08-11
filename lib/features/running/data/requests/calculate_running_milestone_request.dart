import 'package:reforge/features/running/domain/entities/running_milestone.dart';

class CalculateRunningMilestoneRequest {
  const CalculateRunningMilestoneRequest({
    required this.exerciseId,
    required this.workoutSessionId,
    required this.exerciseSessionId,
    required this.durationSec,
    required this.distanceM,
    required this.milestoneKey,
  });

  factory CalculateRunningMilestoneRequest.fromPayload(RunningMilestonePayload payload) {
    return CalculateRunningMilestoneRequest(
      exerciseId: payload.exerciseId,
      workoutSessionId: payload.workoutSessionId,
      exerciseSessionId: payload.exerciseSessionId,
      durationSec: payload.durationSec,
      distanceM: payload.distanceM,
      milestoneKey: payload.milestoneKey.apiValue,
    );
  }

  final int exerciseId;
  final int workoutSessionId;
  final int exerciseSessionId;
  final int durationSec;
  final double distanceM;
  final String milestoneKey;

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'workoutSessionId': workoutSessionId,
      'exerciseSessionId': exerciseSessionId,
      'durationSec': durationSec,
      'distanceM': distanceM,
      'milestoneKey': milestoneKey,
    };
  }
}
