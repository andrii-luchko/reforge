import 'package:flutter/material.dart';
import 'package:reforge/shared/calendar/widgets/grid_selection_view.dart';

class CalendarMonthsView extends StatelessWidget {
  const CalendarMonthsView({
    required this.focusedDay,
    required this.onMonthSelected,
    super.key,
  });

  final DateTime focusedDay;
  final ValueChanged<int> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    //TODO provide intl
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return GridSelectionView(
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        return SelectableGridCell(
          text: months[index],
          isSelected: month == focusedDay.month,
          onTap: () => onMonthSelected(month),
        );
      },
    );
  }
}
