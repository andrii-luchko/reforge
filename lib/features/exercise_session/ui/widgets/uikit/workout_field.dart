import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

class WorkoutField extends StatelessWidget {
  const WorkoutField({
    required this.hintText,
    required this.metric,
    required this.isDone,

    this.initialValue,
    this.onChanged,

    super.key,
  });

  final WorkoutMetric metric;
  final String? initialValue;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final contentStyle = subheadH3Medium.copyWith(color: !isDone ? appTheme.beige100 : appTheme.beige700);

    final hintStyle = subheadH3Medium.copyWith(color: context.appTheme.beige700);

    final isInteger = metric == WorkoutMetric.reps;

    final inputFormatters = <TextInputFormatter>[
      if (isInteger) ...[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ] else ...[
        const DecimalTextInputFormatter(),
        LengthLimitingTextInputFormatter(6),
      ],
    ];

    final keyboardType = TextInputType.numberWithOptions(
      decimal: !isInteger,
    );

    return AbsorbPointer(
      absorbing: isDone,
      child: TextFormField(
        initialValue: initialValue,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: contentStyle,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          constraints: appTheme.workoutContainerConstrains,
          contentPadding: const .symmetric(horizontal: 4, vertical: 23),
          filled: true,
          hintText: hintText,
          hintStyle: hintStyle,
          fillColor: context.appTheme.beige900,

          disabledBorder: OutlineInputBorder(
            borderRadius: appTheme.workoutContainerBorderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: appTheme.workoutContainerBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: appTheme.workoutContainerBorderRadius,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter({this.decimalRange = 2});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newText = newValue.text.replaceAll(',', '.');

    final regExp = RegExp('^\\d*\\.?\\d{0,$decimalRange}\$');

    if (regExp.hasMatch(newText)) {
      return newValue.copyWith(
        text: newText,
        selection: newValue.selection,
      );
    }

    return oldValue;
  }
}
