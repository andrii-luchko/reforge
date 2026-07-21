import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/enums/running_session_status.dart';
import 'package:reforge/features/running/ui/pages/running_laps_summary_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  Future<void> pumpFooter(
    WidgetTester tester,
    RunningTrackerState state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(
          body: RunningSummaryFooter(
            state: state,
            onBackToRunning: () {},
            onFinishExercise: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows Back to Running for a suspended live session', (tester) async {
    await pumpFooter(
      tester,
      const RunningTrackerState(
        phase: RunningPhase.finished,
        sessionStatus: RunningSessionStatus.suspended,
        isPaused: true,
      ),
    );

    expect(find.text(t.running.summary.back_to_running), findsOneWidget);
    expect(find.text(t.running.summary.finish_exercise), findsOneWidget);
    expect(find.byKey(const ValueKey('running_terminal_failure')), findsNothing);
  });

  testWidgets('shows a durable failure and hides Back to Running after termination', (tester) async {
    await pumpFooter(
      tester,
      const RunningTrackerState(
        phase: RunningPhase.finished,
        sessionStatus: RunningSessionStatus.terminated,
        terminalFailure: RunningSessionFailure(
          code: 'location_service_disabled',
          message: 'Location services were turned off. Tracking has stopped.',
        ),
      ),
    );

    expect(find.text(t.running.summary.back_to_running), findsNothing);
    expect(find.text(t.running.summary.finish_exercise), findsOneWidget);
    expect(find.text('Location services were turned off. Tracking has stopped.'), findsOneWidget);
    expect(find.byKey(const ValueKey('running_terminal_failure')), findsOneWidget);
  });
}
