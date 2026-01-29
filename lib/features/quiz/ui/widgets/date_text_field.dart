import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/utils/helpers/date_locale_helper.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';

class DateInputField extends StatefulWidget {
  const DateInputField({
    required this.onDateSelected,
    this.initialDate,
    this.errorText,
    super.key,
  });

  final DateTime? initialDate;
  final String? errorText;
  final ValueChanged<DateTime?> onDateSelected;

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  late final TextEditingController _controller;

  late String _separator;
  late bool _isDayFirst;
  late String _hintText;

  @override
  void initState() {
    super.initState();
    _initLocaleParams();

    final text = widget.initialDate != null ? _formatDate(widget.initialDate!) : '';
    _controller = TextEditingController(text: text);
  }

  void _initLocaleParams() {
    final locale = LocaleSettings.currentLocale.languageTag;

    _separator = DateLocaleHelper.getSeparator(locale);
    _isDayFirst = DateLocaleHelper.isDayFirst(locale);
    _hintText = DateLocaleHelper.getHintText(locale);
  }

  @override
  void didUpdateWidget(covariant DateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialDate != oldWidget.initialDate) {
      final newText = widget.initialDate != null ? _formatDate(widget.initialDate!) : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return _isDayFirst ? '$day$_separator$month$_separator$year' : '$month$_separator$day$_separator$year';
  }

  void _parseAndEmitDate(String value) {
    if (value.length != 10) {
      widget.onDateSelected(null);
      return;
    }

    final escapedSeparator = RegExp.escape(_separator);
    final parts = value.split(RegExp(escapedSeparator));

    if (parts.length != 3) {
      widget.onDateSelected(null);
      return;
    }

    int? day;
    int? month;
    int? year;

    if (_isDayFirst) {
      day = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
      year = int.tryParse(parts[2]);
    } else {
      month = int.tryParse(parts[0]);
      day = int.tryParse(parts[1]);
      year = int.tryParse(parts[2]);
    }

    if (day == null || month == null || year == null) {
      widget.onDateSelected(null);
      return;
    }

    try {
      final date = DateTime(year, month, day);

      if (date.year == year && date.month == month && date.day == day) {
        widget.onDateSelected(date);
      } else {
        widget.onDateSelected(null);
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      widget.onDateSelected(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hintText: _hintText,
      errorText: widget.errorText,
      keyboardType: TextInputType.number,
      onChanged: _parseAndEmitDate,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,

        _DateTextFormatter(separator: _separator),
      ],
    );
  }
}

class _DateTextFormatter extends TextInputFormatter {
  const _DateTextFormatter({required this.separator});
  final String separator;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.length > 10) return oldValue;

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;

      if ((nonZeroIndex == 2 || nonZeroIndex == 4) && nonZeroIndex != text.length) {
        buffer.write(separator);
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
