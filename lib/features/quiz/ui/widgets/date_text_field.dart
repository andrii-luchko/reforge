import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/utils/helpers/date_locale_helper.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';

// ignore: prefer_match_file_name
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
  late final FocusNode _focusNode;

  late String _separator;
  late bool _isDayFirst;
  late String _hintText;

  late _DateInputStatus _lastReportedStatus;
  DateTime? _lastReportedDate;
  String? _inputErrorText;

  @override
  void initState() {
    super.initState();
    _initLocaleParams();

    final text = widget.initialDate != null ? _formatDate(widget.initialDate!) : '';
    _controller = TextEditingController(text: text);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _lastReportedStatus = widget.initialDate == null ? _DateInputStatus.empty : _DateInputStatus.valid;
    _lastReportedDate = widget.initialDate;
  }

  void _initLocaleParams() {
    final locale = LocaleSettings.currentLocale.languageTag;

    _separator = DateLocaleHelper.getSeparator(locale);
    _isDayFirst = DateLocaleHelper.isDayFirst(locale);
    _hintText = DateLocaleHelper.getHintText(locale);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateLocaleHelper.formatDate(
      date,
      isDayFirst: _isDayFirst,
      separator: _separator,
    );
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) return;

    final digits = _digitsFrom(_controller.text);
    if (digits.isNotEmpty && digits.length < 8) {
      _setInputError(t.validation.date_of_birth_invalid);
    }
  }

  void _handleChanged(String value) {
    final digits = _digitsFrom(value);

    if (digits.isEmpty) {
      _setInputError(null);
      _reportInput(_DateInputStatus.empty, null);
      return;
    }

    if (digits.length < 8) {
      _setInputError(null);
      _reportInput(_DateInputStatus.incomplete, null);
      return;
    }

    final date = _parseDate(digits);
    if (date == null) {
      _setInputError(t.validation.date_of_birth_invalid);
      _reportInput(_DateInputStatus.invalid, null);
      return;
    }

    _setInputError(null);
    _reportInput(_DateInputStatus.valid, date);
  }

  DateTime? _parseDate(String digits) {
    final firstPart = int.parse(digits.substring(0, 2));
    final secondPart = int.parse(digits.substring(2, 4));
    final year = int.parse(digits.substring(4, 8));
    final day = _isDayFirst ? firstPart : secondPart;
    final month = _isDayFirst ? secondPart : firstPart;

    if (year < 1) return null;

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    return date;
  }

  void _reportInput(_DateInputStatus status, DateTime? date) {
    if (_lastReportedStatus == status && _lastReportedDate == date) {
      return;
    }

    _lastReportedStatus = status;
    _lastReportedDate = date;
    widget.onDateSelected(date);
  }

  void _setInputError(String? error) {
    if (_inputErrorText == error) return;
    setState(() => _inputErrorText = error);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      focusNode: _focusNode,
      hintText: _hintText,
      errorText: _inputErrorText ?? widget.errorText,
      keyboardType: TextInputType.number,
      onChanged: _handleChanged,
      inputFormatters: [
        _DateTextFormatter(separator: _separator),
      ],
    );
  }
}

class _DateTextFormatter extends TextInputFormatter {
  const _DateTextFormatter({required this.separator});

  final String separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    var digitsOnly = _digitsFrom(newValue.text);

    if (digitsOnly.length > 8) {
      return oldValue;
    }

    var baseDigitOffset = _digitOffsetAt(newValue.text, newValue.selection.baseOffset);
    var extentDigitOffset = _digitOffsetAt(newValue.text, newValue.selection.extentOffset);

    if (_isSeparatorBackspace(oldValue, newValue)) {
      final removedDigitIndex = _digitOffsetAt(oldValue.text, oldValue.selection.baseOffset) - 1;
      if (removedDigitIndex >= 0) {
        digitsOnly = digitsOnly.replaceRange(removedDigitIndex, removedDigitIndex + 1, '');
        baseDigitOffset = removedDigitIndex;
        extentDigitOffset = removedDigitIndex;
      }
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write(separator);
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection(
        baseOffset: _textOffsetForDigits(formatted, baseDigitOffset),
        extentOffset: _textOffsetForDigits(formatted, extentDigitOffset),
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
    );
  }

  bool _isSeparatorBackspace(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldSelection = oldValue.selection;
    final newSelection = newValue.selection;
    if (!oldSelection.isValid ||
        !newSelection.isValid ||
        !oldSelection.isCollapsed ||
        !newSelection.isCollapsed ||
        oldValue.text.length != newValue.text.length + 1 ||
        oldSelection.baseOffset != newSelection.baseOffset + 1 ||
        oldSelection.baseOffset == 0 ||
        _digitsFrom(oldValue.text) != _digitsFrom(newValue.text)) {
      return false;
    }

    return !_isDigit(oldValue.text[oldSelection.baseOffset - 1]);
  }
}

enum _DateInputStatus { empty, incomplete, invalid, valid }

String _digitsFrom(String value) => value.replaceAll(RegExp(r'\D'), '');

bool _isDigit(String character) {
  final codeUnit = character.codeUnitAt(0);
  return codeUnit >= 48 && codeUnit <= 57;
}

int _digitOffsetAt(String text, int textOffset) {
  if (textOffset < 0) return 0;

  var count = 0;
  final end = textOffset.clamp(0, text.length);
  for (var i = 0; i < end; i++) {
    if (_isDigit(text[i])) count++;
  }
  return count;
}

int _textOffsetForDigits(String text, int digitOffset) {
  if (digitOffset <= 0) return 0;

  var count = 0;
  for (var i = 0; i < text.length; i++) {
    if (!_isDigit(text[i])) continue;
    count++;
    if (count == digitOffset) return i + 1;
  }
  return text.length;
}
