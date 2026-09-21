import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class CoachNoteSection extends StatelessWidget {
  const CoachNoteSection({
    required this.note,
    this.needDecoration = true,
    super.key,
  });

  final String note;
  final bool needDecoration;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final decoration = BoxDecoration(
      color: appTheme.beige900,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: appTheme.strokeCard),
    );

    return Container(
      width: double.infinity,
      padding: needDecoration ? const EdgeInsets.all(16) : null,
      decoration: needDecoration ? decoration : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.workout_instruction.coachNote,
            style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
          ),
          const SizedBox(height: 8),
          Text(
            note.trim(),
            style: subheadH6Regular.copyWith(color: appTheme.beige600),
          ),
        ],
      ),
    );
  }
}
