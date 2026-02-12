import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/logger/logger.dart';
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
  late final cubit = context.read<CalendarCubit>();

  @override
  void initState() {
    super.initState();
    cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,

      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final event = state.currentMonthDays;
          return CustomScrollView(
            slivers: [
              DefaultSliverAppBar(
                onPressed: Navigator.of(context).pop,
                title: 'Forge Calendar',
              ),
              SliverPadding(
                padding: CalendarBody.horizontalPadding.copyWith(bottom: 32, top: 16),
                sliver: SliverToBoxAdapter(
                  child: ColoredBox(
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
                        firstDay: firstDay,
                        lastDay: lastDay,

                        onDateSelected: (date) {
                          final day = cubit.navigationCheck(date);

                          logger.d('Selected date: $date, Day entity: $day');
                        },
                        onFocusedDayChanged: cubit.changeMonth,
                        events: event,
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: CalendarBody.horizontalPadding.copyWith(bottom: 16),
                sliver: SliverToBoxAdapter(
                  child: const Text(
                    'Workout days',
                    style: subheadH2Medium,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const ActivityTile(
                  showBorder: false,
                  activeDays: 0,
                  totalDays: 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
