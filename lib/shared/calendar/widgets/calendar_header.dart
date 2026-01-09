import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:reforge/shared/calendar/enum/calendar_view_mode.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    required this.focusedDay,
    required this.viewMode,
    required this.onHeaderTap,
    required this.onPrevious,
    required this.onNext,
    required this.needBottomLine,
    this.headerTitle,
    super.key,
  });

  final DateTime focusedDay;
  final CalendarViewMode viewMode;
  final VoidCallback onHeaderTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool needBottomLine;
  final String? headerTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: needBottomLine ? const EdgeInsets.only(bottom: 16) : const EdgeInsets.only(bottom: 8),
      decoration: needBottomLine
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.appTheme.beige800),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
            child: Column(
              mainAxisAlignment: headerTitle == null ? .center : .start,

              crossAxisAlignment: headerTitle == null ? .center : .start,
              children: [
                if (headerTitle != null)
                  Skeleton.unite(
                    borderRadius: BorderRadius.circular(4),
                    child: Text(
                      headerTitle!,
                      style: subheadH6Regular.copyWith(color: context.appTheme.beige600),
                    ),
                  ),
                GestureDetector(
                  onTap: onHeaderTap,
                  child: _HeaderTitleSelector(
                    focusedDay: focusedDay,
                    viewMode: viewMode,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: headerTitle == null ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
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
          ),
        ],
      ),
    );
  }
}

class _HeaderTitleSelector extends StatelessWidget {
  const _HeaderTitleSelector({
    required this.focusedDay,
    required this.viewMode,
  });

  final DateTime focusedDay;
  final CalendarViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final (month, year, useDecoration) = _getDisplayInfo();

    return Skeleton.unite(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        margin: viewMode == .years ? const EdgeInsets.only(top: 8) : null,
        padding: viewMode != .years ? const EdgeInsets.all(12).copyWith(left: 0) : const EdgeInsets.all(12),
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
                color: viewMode == .years ? context.appTheme.beige100 : context.appTheme.beige600,
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
