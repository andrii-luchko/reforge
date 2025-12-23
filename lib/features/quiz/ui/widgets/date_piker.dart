// field_date_picker.dart
import 'package:flutter/material.dart';
import 'package:reforge/shared/calendar/calendar_piker.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';

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

class _FieldDatePickerState extends State<FieldDatePicker> {
  late final TextEditingController _textController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _textController = TextEditingController(
      text: widget.initialDate != null ? _formatDate(widget.initialDate!) : '',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  void _onDateSelected(DateTime date, VoidCallback closePortal) {
    setState(() {
      _selectedDate = date;
      _textController.text = _formatDate(date);
    });
    widget.onDateSelected(date);
    // Опционально: можно закрывать календарь сразу после выбора
    // closePortal();
  }

  @override
  Widget build(BuildContext context) {
    return PortalSelectField(
      controller: _textController,
      hintText: widget.hintText,
      errorText: widget.errorText,
      contentBuilder: (context, closePortal) {
        return CalendarPicker(
          initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
          firstDay: widget.firstDay ?? DateTime(1950),
          lastDay: widget.lastDay ?? DateTime(2030),
          onDateSelected: (date) => _onDateSelected(date, closePortal),
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
