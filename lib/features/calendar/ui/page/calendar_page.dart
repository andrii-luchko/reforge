import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/calendar/controllers/calendar/calendar_cubit.dart';
import 'package:reforge/features/home/ui/widgets/workout_result/activity_tile.dart';
import 'package:reforge/shared/calendar/calendar_piker.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,

      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final currentMonth = state.currentMonth;

          final event = state.currentMonthDays;
          return RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            child: CustomScrollView(
            slivers: [
              DefaultSliverAppBar(
                onPressed: () => Navigator.of(context).pop(),
                title: 'Forge Calendar',
              ),
              SliverPadding(
                padding: CalendarBody.horizontalPadding.copyWith(bottom: 32, top: 16),

                sliver: SliverToBoxAdapter(
                  child: DecoratedBox(
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
                      child: CalendarPicker(
                        headerTitle: 'Your Forge Rhythm',
                        needBottomLine: false,

                        initialDate: DateTime.now(),
                        firstDay: firstDay,
                        lastDay: lastDay,

                        onDateSelected: (date) {
                          final day = cubit.navigationCheck(date);
                          final sessionId = day?.latestSessionId;

                          if (day != null && sessionId != null) {
                            TrainingDetailsPageRoute(
                              date: day.date,
                              workoutSessionID: sessionId,
                            ).push<void>(context);
                          }
                        },
                        onFocusedDayChanged: cubit.changeMonth,
                        events: event,
                      ),
                    ).animateEntrance(),
                  ),
                ),
              ),

              SliverPadding(
                padding: CalendarBody.horizontalPadding.copyWith(bottom: 16),
                sliver: const SliverToBoxAdapter(
                  child: const Text(
                    'Workout days',
                    style: subheadH2Medium,
                  ),
                ),
              ),

              SliverPadding(
                padding: CalendarBody.horizontalPadding.copyWith(bottom: 16),
                sliver: SliverToBoxAdapter(
                  child: ActivityTile(
                    showBorder: false,
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
