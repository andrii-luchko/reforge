import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

extension RunningSetSyncIssueLocalization on RunningSetSyncIssue {
  String get localizedMessage => switch (this) {
    RunningSetSyncIssue.retryable => t.workout.runningSetSyncFailed,
    RunningSetSyncIssue.inconsistentResponse => t.workout.runningSetSyncInconsistent,
  };
}
