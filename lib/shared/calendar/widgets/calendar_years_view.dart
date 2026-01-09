import 'package:flutter/material.dart';
import 'package:reforge/shared/calendar/widgets/grid_selection_view.dart';

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

    return GridSelectionView(
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        return SelectableGridCell(
          text: year.toString(),
          isSelected: year == focusedDay.year,
          onTap: () => onYearSelected(year),
        );
      },
    );
  }
}
