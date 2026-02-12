import 'package:flutter/material.dart';
import 'package:reforge/shared/calendar/widgets/grid_selection_view.dart';

class CalendarMonthsView extends StatelessWidget {
  const CalendarMonthsView({
    required this.focusedDay,
    required this.firstDay,
    required this.lastDay,
    required this.onMonthSelected,
    super.key,
  });

  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final ValueChanged<int> onMonthSelected;

  bool _isMonthInRange(int month) {
    final firstOfMonth = DateTime(focusedDay.year, month);
    final lastOfMonth = DateTime(focusedDay.year, month + 1).subtract(const Duration(days: 1));
    final first = DateUtils.dateOnly(firstDay);
    final last = DateUtils.dateOnly(lastDay);
    return !firstOfMonth.isAfter(last) && !lastOfMonth.isBefore(first);
  }

  @override
  Widget build(BuildContext context) {
    //TODO(Masayoshi): provide intl
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return GridSelectionView(
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final inRange = _isMonthInRange(month);
        return SelectableGridCell(
          text: months[index],
          isSelected: month == focusedDay.month,
          onTap: inRange ? () => onMonthSelected(month) : null,
        );
      },
    );
  }
}
