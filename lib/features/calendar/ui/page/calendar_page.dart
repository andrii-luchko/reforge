import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/home/ui/widgets/activity_tile.dart';
import 'package:reforge/shared/calendar/calendar_piker.dart';
import 'package:reforge/shared/calendar/widgets/calendar_days_view.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      appBar: AppAppBar(
        onPressed: () {
          Navigator.of(context).pop();
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Forge Calendar',
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(body: CalendarBody()),
    );
  }
}

class CalendarBody extends StatelessWidget {
  const CalendarBody({super.key});
  Map<DateTime, CalendarEvent> getMockEventsMap() {
    final rawList = [
      (dateTime: DateTime(2026, 1, 6), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 8), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 10), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 13), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 15), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 17), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 20), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 22), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 24), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 27), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 29), hasWorkout: true),

      (dateTime: DateTime(2026, 1, 31), hasWorkout: true),
    ];

    return {for (final event in rawList) DateUtils.dateOnly(event.dateTime): event};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const .all(16),

        child: Column(
          crossAxisAlignment: .start,
          children: [
            ColoredBox(
              color: context.appTheme.beige900,

              child: Container(
                padding: const .symmetric(horizontal: 0, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const RadialGradient(
                    center: .topLeft,
                    radius: 1,
                    colors: [
                      Color(0x994A2105),
                      Color(0x004A2105),
                    ],
                  ),
                  border: Border.all(
                    color: context.appTheme.beige100.withValues(alpha: 0.1),
                  ),
                ),
                child: CalendarPicker(
                  headerTitle: 'Your Forge Rhythm',
                  needBottomLine: false,

                  initialDate: DateTime.now(),
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  onDateSelected: (date) {
                    final map = getMockEventsMap();
                    if (map.containsKey(DateUtils.dateOnly(date))) {}
                  },
                  events: getMockEventsMap(),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Workout days',
              style: subheadH2Medium,
            ),
            const SizedBox(height: 16),
            const ActivityTile(
              showBorder: false,
            ),
          ],
        ),
      ),
    );
  }
}
