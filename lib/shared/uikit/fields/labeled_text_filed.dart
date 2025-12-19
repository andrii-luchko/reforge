import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class LabeledAppTextField extends StatelessWidget {
  const LabeledAppTextField({
    required this.label,
    required this.field,
    this.labelTextStyle,
    super.key,
  });

  final String label;
  final TextStyle? labelTextStyle;

  final Widget field;

  @override
  Widget build(BuildContext context) {
    final labelStyle = labelTextStyle ?? subheadH5Medium.copyWith(color: context.appTheme.beige100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: labelStyle,
          ),
        ),
        Padding(padding: const EdgeInsets.only(top: 10), child: field),
      ],
    );
  }
}
