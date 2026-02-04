import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/workout_constants.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/pickers/decimal_scroll_piker.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';

class HeightAndWeightPage extends StatelessWidget {
  const HeightAndWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenericValidationCubit<double?>(
        initialValue: null,
        onSave: (_) async {},
      ),
      child: BaseSettingsEditPage(
        title: ProfileSettings.heightAndWeight.title(t),
        body: const HeightAndWeightContent(
          system: MeasurementSystem.imperial,
        ),
      ),
    );
  }
}

class HeightAndWeightContent extends StatelessWidget {
  const HeightAndWeightContent({
    required this.system,
    super.key,
  });

  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        BlocSelector<
          GenericValidationCubit<double?>,
          GenericValidationState<double?>,
          ({double? weight, String? error})
        >(
          selector: (state) => (weight: state.value, error: state.error),
          builder: (context, value) {
            final cubit = context.read<GenericValidationCubit<double?>>();

            return WeightSelectField(
              measurementSystem: system,
              value: value.weight,
              errorText: value.error,
              onChanged: cubit.onChanged,
            );
          },
        ),

        SecondaryButton(text: t.common.save_changes_button),
      ],
    );
  }
}

class WeightSelectField extends StatelessWidget {
  const WeightSelectField({
    required this.value,
    required this.measurementSystem,
    required this.onChanged,
    this.label,
    this.hintText,
    this.errorText,
    super.key,
  });

  final double? value;
  final MeasurementSystem measurementSystem;
  final String? label;
  final String? hintText;
  final String? errorText;
  final ValueChanged<double> onChanged;

  String _formatValue(double val) {
    final unit = measurementSystem.weightSymbol(t);

    final formattedNum = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
    return '$formattedNum $unit';
  }

  @override
  Widget build(BuildContext context) {
    final displayText = value != null ? _formatValue(value!) : '';

    return LabeledAppTextField(
      label: label ?? t.quiz.steps.body_weight.select_body_weight_label,
      field: PortalSelectField(
        initialText: displayText,
        hintText: hintText ?? t.quiz.steps.body_weight.select_body_weight_label,
        errorText: errorText,
        contentBuilder: (context, _) {
          return DecimalScrollPicker(
            initialValue: value ?? 0.0,
            unitSuffix: measurementSystem.weightSymbol(t),
            start: WorkoutConstants.minWeight,
            end: WorkoutConstants.maxWeight(measurementSystem),
            step: WorkoutConstants.weightStep(measurementSystem),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
