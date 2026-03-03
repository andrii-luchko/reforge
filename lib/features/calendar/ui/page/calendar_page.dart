import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/calendar/controllers/calendar/calendar_cubit.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/activity_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/calendar/calendar_piker.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DefaultBackground(body: CalendarBody()),
    );
  }
}

class CalendarBody extends StatefulWidget {
  const CalendarBody({super.key});

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  State<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<CalendarBody> {
  late final CalendarCubit cubit = context.read<CalendarCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(cubit.initialize());
  }

  void onDayPressed(DateTime date) {
    final day = cubit.navigationCheck(date);

    if (day != null) {
      final sessionId = day.latestSessionId;
      if (sessionId != null) {
        cubit.onTrainingDetailsTap();
        unawaited(
          TrainingDetailsPageRoute(
            date: day.date,
            workoutSessionID: sessionId,
          ).push<void>(context),
        );
        return;
      }

      final scheduledWorkoutDayId = day.scheduledWorkoutDayId;
      if (scheduledWorkoutDayId != null) {
        cubit.onScheduledTrainingDetailsTap();
        unawaited(
          ScheduledWorkoutDetailsPageRoute(
            date: day.date,
            scheduledWorkoutDayId: scheduledWorkoutDayId,
          ).push<void>(context),
        );
        return;
      }

      if (day.isSpecificDay && scheduledWorkoutDayId == null) {
        toastification.showSimpleToast(t.calendar.no_workout_for_this_day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,

      child: BlocConsumer<CalendarCubit, CalendarState>(
        listenWhen: (previous, current) => current.error != null && previous.error != current.error,
        listener: (context, state) {
          final error = state.error;
          if (error != null && context.mounted) {
            toastification.showErrorToast(error, context);
          }
        },
        builder: (context, state) {
          final currentMonth = state.currentMonth;
          final events = state.visibleMonthDays;

          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(
              slivers: [
                DefaultSliverAppBar(
                  onPressed: () => Navigator.of(context).pop(),
                  title: t.calendar.title,
                ),
                SliverPadding(
                  padding: CalendarBody.horizontalPadding.copyWith(bottom: 32, top: 16),

                  sliver: SliverToBoxAdapter(
                    child: Stack(
                      alignment: .center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.appTheme.beige900,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: context.appTheme.beige100.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Container(
                            padding: const .symmetric(horizontal: 8, vertical: 12),

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
                            ),
                            child: Skeleton.shade(
                              child: CalendarPicker(
                                headerTitle: t.calendar.calendar_header,
                                needBottomLine: false,

                                initialDate: DateTime.now(),
                                firstDay: firstDay,
                                lastDay: lastDay,

                                onDateSelected: onDayPressed,
                                onFocusedDayChanged: cubit.changeMonth,
                                events: events,
                              ),
                            ),
                          ).animateEntrance(),
                        ),

                        if (state.isLoading)
                          const Positioned.fill(
                            child: ScreenLoadingIndicator(
                              padding: EdgeInsets.all(12),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: CalendarBody.horizontalPadding.copyWith(bottom: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      t.calendar.workout_details_label,
                      style: subheadH2Medium,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: CalendarBody.horizontalPadding.copyWith(bottom: 16),
                  sliver: SliverToBoxAdapter(
                    child: ActivityTile(
                      activeDays: currentMonth?.totalCompleted ?? 0,
                      totalDays: currentMonth?.totalPlanned ?? 0,
                    ).animateEntrance(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
