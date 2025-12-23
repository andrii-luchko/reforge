// field_date_picker.dart
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:table_calendar/table_calendar.dart';

enum CalendarViewMode {
  days,
  months,
  years,
}

class CalendarPicker extends StatefulWidget {
  const CalendarPicker({
    required this.initialDate,
    required this.firstDay,
    required this.lastDay,
    required this.onDateSelected,
    super.key,
  });

  final DateTime initialDate;
  final DateTime firstDay;
  final DateTime lastDay;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarViewMode _viewMode = CalendarViewMode.days;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    widget.onDateSelected(selectedDay);
  }

  void _onPrevious() {
    setState(() {
      _focusedDay = switch (_viewMode) {
        CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month - 1),
        CalendarViewMode.months => DateTime(_focusedDay.year - 1, _focusedDay.month),
        CalendarViewMode.years => DateTime(_focusedDay.year - 10, _focusedDay.month),
      };
    });
  }

  void _onNext() {
    setState(() {
      _focusedDay = switch (_viewMode) {
        CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month + 1),
        CalendarViewMode.months => DateTime(_focusedDay.year + 1, _focusedDay.month),
        CalendarViewMode.years => DateTime(_focusedDay.year + 10, _focusedDay.month),
      };
    });
  }

  void _onHeaderTap() {
    setState(() {
      _viewMode = switch (_viewMode) {
        CalendarViewMode.days => CalendarViewMode.months,
        CalendarViewMode.months => CalendarViewMode.years,
        CalendarViewMode.years => CalendarViewMode.days,
      };
    });
  }

  void _onMonthSelected(int month) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, month);
    });
  }

  void _onYearSelected(int year) {
    setState(() {
      _focusedDay = DateTime(year, _focusedDay.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarHeader(
          focusedDay: _focusedDay,
          viewMode: _viewMode,
          onHeaderTap: _onHeaderTap,
          onPrevious: _onPrevious,
          onNext: _onNext,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: switch (_viewMode) {
            CalendarViewMode.days => CalendarDaysView(
              key: const ValueKey('days_view'),
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
            CalendarViewMode.months => CalendarMonthsView(
              key: const ValueKey('months_view'),
              focusedDay: _focusedDay,
              onMonthSelected: _onMonthSelected,
            ),
            CalendarViewMode.years => CalendarYearsView(
              key: const ValueKey('years_view'),
              focusedDay: _focusedDay,
              onYearSelected: _onYearSelected,
            ),
          },
        ),
      ],
    );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    required this.focusedDay,
    required this.viewMode,
    required this.onHeaderTap,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final DateTime focusedDay;
  final CalendarViewMode viewMode;
  final VoidCallback onHeaderTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appTheme.beige800),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onHeaderTap,
            child: CalendarHeaderTitle(
              focusedDay: focusedDay,
              viewMode: viewMode,
            ),
          ),
          const Spacer(),
          AppIconButton.icon(
            iconData: Icons.chevron_left_rounded,
            width: 44,
            height: 44,
            iconSize: 22,
            onPressed: onPrevious,
          ),
          const SizedBox(width: 8),
          AppIconButton.icon(
            iconData: Icons.chevron_right_rounded,
            width: 44,
            height: 44,
            iconSize: 22,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class CalendarHeaderTitle extends StatelessWidget {
  const CalendarHeaderTitle({
    required this.focusedDay,
    required this.viewMode,
    super.key,
  });

  final DateTime focusedDay;
  final CalendarViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final (month, year, useDecoration) = _getDisplayInfo();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: useDecoration
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: context.appTheme.orange500,
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (month.isNotEmpty) ...[
            Text(
              month,
              style: subheadH2Medium.copyWith(
                color: context.appTheme.beige100,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            year,
            style: subheadH2Medium.copyWith(
              color: month.isNotEmpty ? context.appTheme.beige600 : context.appTheme.beige100,
            ),
          ),

          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.appTheme.beige100,
            size: 22,
          ),
        ],
      ),
    );
  }

  (String month, String year, bool useDecoration) _getDisplayInfo() {
    return switch (viewMode) {
      CalendarViewMode.days => (
        _getMonthName(focusedDay.month),
        focusedDay.year.toString(),
        false,
      ),
      CalendarViewMode.months => (
        '',
        focusedDay.year.toString(),
        false,
      ),
      CalendarViewMode.years => () {
        return ('', '${focusedDay.year}', true);
      }(),
    };
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }
}

class CalendarDaysView extends StatefulWidget {
  const CalendarDaysView({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    super.key,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  @override
  State<CalendarDaysView> createState() => _CalendarDaysViewState();
}

class _CalendarDaysViewState extends State<CalendarDaysView> {
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(CalendarDaysView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: widget.onDaySelected,
      headerVisible: false,
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: subheadH7Medium.copyWith(
          color: context.appTheme.beige700,
        ),
        weekendStyle: subheadH7Medium.copyWith(
          color: context.appTheme.beige700,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        todayBuilder: (context, day, focusedDay) => Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: context.appTheme.orange500, width: 0.5),

            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            day.day.toString(),
            style: subheadH7Medium.copyWith(
              color: context.appTheme.beige100,
            ),
          ),
        ),
        defaultBuilder: (context, day, focusedDay) {
          final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
          return Container(
            margin: const EdgeInsets.all(4),
            alignment: Alignment.center,
            child: Text(
              day.day.toString(),
              style: subheadH7Medium.copyWith(
                color: isWeekend ? context.appTheme.beige600 : context.appTheme.beige100,
              ),
            ),
          );
        },
        outsideBuilder: (context, day, focusedDay) {
          final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
          return Container(
            margin: const EdgeInsets.all(4),
            alignment: Alignment.center,
            child: Text(
              day.day.toString(),
              style: subheadH7Medium.copyWith(
                color: isWeekend ? context.appTheme.beige600 : context.appTheme.beige100,
              ),
            ),
          );
        },
        selectedBuilder: (context, day, focusedDay) => Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.appTheme.orange500,
            border: GradientBoxBorder(
              gradient: LinearGradient(colors: [context.appTheme.strokeCalendar, Colors.transparent]),
            ),

            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            day.day.toString(),
            style: subheadH7Medium.copyWith(
              color: context.appTheme.beige100,
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarMonthsView extends StatelessWidget {
  const CalendarMonthsView({
    required this.focusedDay,
    required this.onMonthSelected,
    super.key,
  });

  final DateTime focusedDay;
  final ValueChanged<int> onMonthSelected;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 8, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          return _SelectableCell(
            text: _months[index],
            isSelected: month == focusedDay.month,
            onTap: () => onMonthSelected(month),
          );
        },
      ),
    );
  }
}

class CalendarYearsView extends StatelessWidget {
  const CalendarYearsView({
    required this.focusedDay,
    required this.onYearSelected,
    super.key,
  });

  final DateTime focusedDay;
  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final startYear = (focusedDay.year ~/ 10) * 10;
    final years = List.generate(12, (index) => startYear - 1 + index);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          return _SelectableCell(
            text: year.toString(),
            isSelected: year == focusedDay.year,
            onTap: () => onYearSelected(year),
          );
        },
      ),
    );
  }
}

class _SelectableCell extends StatelessWidget {
  const _SelectableCell({
    required this.text,

    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? context.appTheme.orange500 : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: bodyLRegular.copyWith(
            color: isSelected ? context.appTheme.beige100 : context.appTheme.beige600,
          ),
        ),
      ),
    );
  }
}
