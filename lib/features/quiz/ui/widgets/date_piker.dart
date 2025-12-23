// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';

class FieldDatePicker extends StatefulWidget {
  const FieldDatePicker({
    required this.onDateSelected,
    this.initialDate,
    this.hintText = 'Select date',
    this.errorText,
    this.firstDay,
    this.lastDay,
    super.key,
  });

  final DateTime? initialDate;
  final String hintText;
  final String? errorText;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<FieldDatePicker> createState() => _FieldDatePickerState();
}

class _FieldDatePickerState extends State<FieldDatePicker> with SingleTickerProviderStateMixin {
  static const _borderRadius = 12.0;
  static const _pickerWidth = 340.0;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final TextEditingController _textController;

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = widget.initialDate;
    _textController = TextEditingController(
      text: widget.initialDate != null ? _formatDate(widget.initialDate!) : '',
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _toggleDropdown() async {
    if (_isOpen) {
      await _close();
    } else {
      setState(() => _isOpen = true);
      await _controller.forward();
    }
  }

  Future<void> _close() async {
    await _controller.reverse();
    setState(() => _isOpen = false);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _textController.text = _formatDate(selectedDay);
    });

    widget.onDateSelected(selectedDay);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _isOpen,
      anchor: const Aligned(follower: .topCenter, target: .bottomCenter, portal: .center, heightFactor: 9),
      portalFollower: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FadeTransition(
          opacity: _expandAnimation,
          child: SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: _buildCalendar(context),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AbsorbPointer(
          child: AppTextfield(
            controller: _textController,
            hintText: widget.hintText,
            errorText: widget.errorText,
            suffixIcon: _buildSuffixIcon(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: context.appTheme.beige100,
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final primaryColor = context.appTheme.orange500;
    final backgroundColor = context.appTheme.beige900;
    final textColor = context.appTheme.beige100;
    final mutedColor = context.appTheme.beige600;
    final borderColor = context.appTheme.strokeCard;

    return Material(
      borderRadius: BorderRadius.circular(_borderRadius),
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        width: _pickerWidth,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: TableCalendar(
          firstDay: widget.firstDay ?? DateTime(1950),
          lastDay: widget.lastDay ?? DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: _onDaySelected,
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) => Container(
              padding: .symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.appTheme.beige800)),
              ),
              child: Row(
                children: [
                  ClicableHeader(
                    month: 'Now',
                    year: '2025',
                  ),
                  Spacer(),
                  AppIconButton.icon(
                    iconData: Icons.chevron_left_rounded,
                    width: 44,
                    height: 44,
                    iconSize: 18,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  AppIconButton.icon(
                    iconData: Icons.chevron_right_rounded,
                    width: 44,
                    height: 44,
                    iconSize: 18,
                  ),
                ],
              ),
            ),
          ),
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            leftChevronVisible: false,
            rightChevronVisible: false,
            titleTextStyle: bodyLRegular.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: bodySRegular.copyWith(color: mutedColor),
            weekendStyle: bodySRegular.copyWith(color: mutedColor),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: bodySRegular.copyWith(color: textColor),
            weekendTextStyle: bodySRegular.copyWith(color: textColor),
            todayDecoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 1.5),
              shape: BoxShape.circle,
            ),
            todayTextStyle: bodySRegular.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: bodySRegular.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }
}

class ClicableHeader extends StatelessWidget {
  const ClicableHeader({
    required this.month,
    required this.year,
    super.key,
    this.title,
  });

  final String? title;
  final String month;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          if (title != null) ...[
            Text.rich(
              TextSpan(
                text: title,
                style: subheadH6Regular.copyWith(color: context.appTheme.beige600),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: month,
                        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: year,
                        style: subheadH2Medium.copyWith(color: context.appTheme.beige600),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.appTheme.beige100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
