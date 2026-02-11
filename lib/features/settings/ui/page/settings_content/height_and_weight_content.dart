import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/constants/workout_constants.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/pickers/decimal_scroll_piker.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';

class HeightAndWeightPage extends StatelessWidget {
  const HeightAndWeightPage({
    required this.weight,
    required this.system,
    super.key,
  });

  final MeasurementSystem system;
  final double? weight;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.read<UserCubit>();

    return BlocProvider(
      create: (context) => GenericValidationCubit<double?>(
        initialValue: weight,
        validator: (w) {
          if (w == null) return 'Weight cant be null';
          return null;
        },
        onSave: (value) => onSave(value, userCubit),
      ),
      child: GenericSaveListener<double?>(
        child: BaseSettingsEditPage(
          title: ProfileSettings.heightAndWeight.title(t),
          body: HeightAndWeightContent(
            system: system,
          ),
        ),
      ),
    );
  }

  Future<void> onSave(double? value, UserCubit cubit) async {
    final result = await cubit.updateProfile(
      PatchProfileRequest(bodyWeight: value?.toStorageWeight(system).toInt()),
    );

    if (result case ErrorR(error: final e)) {
      throw e;
    }
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
    final cubit = context.read<GenericValidationCubit<double?>>();

    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        BlocSelector<
          GenericValidationCubit<double?>,
          GenericValidationState<double?>,
          ({double? weight, String? error})
        >(
          selector: (state) {
            final error = state is GenericValidationError ? state.error : null;

            return (weight: state.value, error: error);
          },
          builder: (context, value) {
            return WeightSelectField(
              measurementSystem: system,
              value: value.weight,
              errorText: value.error,
              onChanged: cubit.onChanged,
            );
          },
        ),

        SecondaryButton(
          text: t.common.save_changes_button,
          onPressed: cubit.save,
        ),
      ],
    );
  }
}

class WeightSelectField extends StatefulWidget {
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

  @override
  State<WeightSelectField> createState() => _WeightSelectFieldState();
}

class _WeightSelectFieldState extends State<WeightSelectField> {
  late TextEditingController _controller;

  String _formatValue(double val) {
    final unit = widget.measurementSystem.weightSymbol(t);

    final formattedNum = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
    return '$formattedNum $unit';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value != null ? _formatValue(widget.value!) : '');
  }

  @override
  void didUpdateWidget(WeightSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      final newText = widget.value != null ? _formatValue(widget.value!) : '';
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledAppTextField(
      label: widget.label ?? t.quiz.steps.body_weight.select_body_weight_label,
      field: PortalSelectField(
        controller: _controller,

        hintText: widget.hintText ?? t.quiz.steps.body_weight.select_body_weight_label,
        errorText: widget.errorText,
        contentBuilder: (context, _) {
          return DecimalScrollPicker(
            initialValue: widget.value ?? 0.0,
            unitSuffix: widget.measurementSystem.weightSymbol(t),
            start: WorkoutConstants.minWeight,
            end: WorkoutConstants.maxWeight(widget.measurementSystem),
            step: WorkoutConstants.weightStep(widget.measurementSystem),
            onChanged: widget.onChanged,
          );
        },
      ),
    );
  }
}
