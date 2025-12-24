import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/measure_system.dart';
import 'package:reforge/features/quiz/ui/widgets/measure_switcher.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class MeasurementSystemStep extends StatefulWidget {
  const MeasurementSystemStep({super.key});

  @override
  State<MeasurementSystemStep> createState() => _MeasurementSystemStepState();
}

class _MeasurementSystemStepState extends State<MeasurementSystemStep> {
  MeasurementSystem _selectedMeasure = MeasurementSystem.metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.measurement_system.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),

        MeasureSwitcher(
          selectedMeasure: _selectedMeasure,
          onSelected: (value) {
            setState(() {
              _selectedMeasure = value;
            });
          },
        ),
      ],
    );
  }
}
