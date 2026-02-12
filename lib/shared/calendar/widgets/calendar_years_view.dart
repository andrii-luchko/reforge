import 'package:flutter/material.dart';
import 'package:reforge/shared/calendar/widgets/grid_selection_view.dart';

class CalendarYearsView extends StatelessWidget {
  const CalendarYearsView({
    required this.focusedDay,
    required this.firstDay,
    required this.lastDay,
    required this.onYearSelected,
    super.key,
  });

  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final firstYear = firstDay.year;
    final lastYear = lastDay.year;
    final decadeStart = (focusedDay.year.clamp(firstYear, lastYear) ~/ 10) * 10;
    final startYear = decadeStart < firstYear ? firstYear : decadeStart;
    final endYear = (startYear + 11).clamp(firstYear, lastYear);
    final years = [for (var y = startYear; y <= endYear; y++) y];

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
