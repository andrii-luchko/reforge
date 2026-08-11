import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/data/requests/calculate_running_milestone_request.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_key.dart';

void main() {
  test('serializes the request-ready candidate with both metrics', () {
    final request = CalculateRunningMilestoneRequest.fromPayload(
      const RunningMilestonePayload(
        runningSetId: 7,
        exerciseId: 4,
        workoutSessionId: 42,
        exerciseSessionId: 101,
        durationSec: 560,
        distanceM: 1612.7,
        milestoneKey: RunningMilestoneKey.oneMile,
      ),
    );

    expect(request.toJson(), {
      'exerciseId': 4,
      'workoutSessionId': 42,
      'exerciseSessionId': 101,
      'durationSec': 560,
      'distanceM': 1612.7,
      'milestoneKey': '1mile',
    });
  });
}
