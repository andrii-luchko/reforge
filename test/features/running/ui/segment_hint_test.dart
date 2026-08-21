import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/ui/widgets/audio_hint_dialog.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

import '../../../helpers/test_setup.dart';

void main() {
  setUpAll(initTestTranslations);

  testWidgets('shows activity and target for every supported segment combination', (tester) async {
    final cases = [
      (_segment(activity: .walk, metric: .time, durationSec: 60), 'Recovery Walk · 01:00'),
      (_segment(activity: .run, metric: .time, durationSec: 120), 'Run · 02:00'),
      (_segment(activity: .run, metric: .distance, distanceM: 400), 'Run · 400 m'),
      (_segment(activity: .walk, metric: .distance, distanceM: 400), 'Walk · 400 m'),
    ];

    for (final (segment, expectedText) in cases) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeDataValues.darkThemeData,
          home: Scaffold(
            body: SegmentHint(
              segment: segment,
              measureSystem: MeasurementSystem.metric,
            ),
          ),
        ),
      );

      expect(find.text(expectedText, findRichText: true), findsOneWidget);
    }
  });

  testWidgets('formats long distances in kilometers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(
          body: SegmentHint(
            segment: _segment(activity: .run, metric: .distance, distanceM: 1250),
            measureSystem: MeasurementSystem.metric,
          ),
        ),
      ),
    );

    expect(find.text('Run · 1.3 km', findRichText: true), findsOneWidget);
  });

  testWidgets('formats distance in miles for the imperial system', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(
          body: SegmentHint(
            segment: _segment(activity: .run, metric: .distance, distanceM: 400),
            measureSystem: MeasurementSystem.imperial,
          ),
        ),
      ),
    );

    expect(find.text('Run · 0.25 mi', findRichText: true), findsOneWidget);
  });
}

ExerciseSegmentEntity _segment({
  required SegmentActivity activity,
  required WorkoutMetric metric,
  double distanceM = 0,
  int durationSec = 0,
}) {
  return ExerciseSegmentEntity(
    id: 1,
    order: 1,
    activity: activity,
    targetMetric: metric,
    distanceM: distanceM,
    durationSec: durationSec,
    recommendedSpeed: null,
  );
}
