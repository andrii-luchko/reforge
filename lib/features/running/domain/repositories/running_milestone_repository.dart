// ignore_for_file: one_member_abstracts

import 'package:reforge/features/running/domain/entities/running_milestone.dart';

abstract interface class RunningMilestoneRepository {
  Future<void> calculateRunningMilestone(RunningMilestonePayload payload);
}
