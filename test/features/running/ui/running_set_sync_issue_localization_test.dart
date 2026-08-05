import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/ui/running_set_sync_issue_localization.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  test('sync issues expose user-facing messages without operational data', () {
    final messages = RunningSetSyncIssue.values.map((issue) => issue.localizedMessage);

    for (final message in messages) {
      expect(message, isNotEmpty);
      expect(message, isNot(contains('Backend')));
      expect(message, isNot(contains('idempotency')));
      expect(message, isNot(contains('clientSetId')));
      expect(
        message,
        isNot(matches(RegExp('[0-9a-f]{8}-[0-9a-f-]{27,}'))),
      );
    }
  });
}
