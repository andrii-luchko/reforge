import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/constants/workout_constants.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/features/workout_common/ui/widgets/uikit/workout_field.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

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
          if (w == null) return t.settings.weightCantBeNull;
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
    if (value == null) return;
    final result = await cubit.updateBodyWeight(
      value.roundWeight(),
    );

    if (result case Failure(error: final e)) {
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

    return SliverMainAxisGroup(
      slivers: [
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
            return SliverToBoxAdapter(
              child: WeightInputField(
                measurementSystem: system,
                weightKg: value.weight,
                errorText: value.error,
                onChanged: cubit.onChanged,
              ),
            );
          },
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SecondaryButton(
              text: t.common.save_changes_button,
              onPressed: cubit.save,
            ),
          ),
        ),
      ],
    );
  }
}

class WeightInputField extends StatefulWidget {
  const WeightInputField({
    required this.weightKg,
    required this.measurementSystem,
    required this.onChanged,
    this.label,
    this.hintText,
    this.errorText,
    super.key,
  });

  final double? weightKg;
  final MeasurementSystem measurementSystem;
  final String? label;
  final String? hintText;
  final String? errorText;
  final ValueChanged<double?> onChanged;

  @override
  State<WeightInputField> createState() => _WeightInputFieldState();
}

class _WeightInputFieldState extends State<WeightInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  double? _lastEmittedWeightKg;

  String _formatValue(double weightKg) {
    return weightKg.toDisplayWeight(widget.measurementSystem).formatWeight();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.weightKg != null ? _formatValue(widget.weightKg!) : '',
    );
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(WeightInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final systemChanged = widget.measurementSystem != oldWidget.measurementSystem;
    final weightChanged = widget.weightKg != oldWidget.weightKg;
    final isExternalWeightChange = weightChanged && widget.weightKg != _lastEmittedWeightKg;

    if (systemChanged || (isExternalWeightChange && !_focusNode.hasFocus)) {
      _syncController();
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _syncController();
    }
  }

  void _syncController() {
    final text = widget.weightKg != null ? _formatValue(widget.weightKg!) : '';
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _lastEmittedWeightKg = null;
  }

  void _handleChanged(String text) {
    final displayWeight = double.tryParse(text);
    if (displayWeight == null) {
      _lastEmittedWeightKg = null;
      widget.onChanged(null);
      return;
    }

    final weightKg = displayWeight.toStorageWeight(widget.measurementSystem);
    _lastEmittedWeightKg = weightKg;
    widget.onChanged(weightKg);
  }

  @override
  Widget build(BuildContext context) {
    final maxWeight = WorkoutConstants.maxWeight(widget.measurementSystem);
    final maxLength = maxWeight.toInt().toString().length + 3;
    final unit = widget.measurementSystem.weightSymbol(t);

    return LabeledAppTextField(
      label: widget.label ?? t.quiz.steps.body_weight.select_body_weight_label,
      field: AppTextField(
        controller: _controller,
        focusNode: _focusNode,
        hintText: widget.hintText ?? t.quiz.steps.body_weight.select_body_weight_label,
        errorText: widget.errorText,
        onChanged: _handleChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          const DecimalTextInputFormatter(),
          LengthLimitingTextInputFormatter(maxLength),
          _MaxValueTextInputFormatter(maxWeight),
        ],
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            widthFactor: 1,
            child: Text(
              unit,
              style: bodyLRegular.copyWith(color: context.appTheme.beige600),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaxValueTextInputFormatter extends TextInputFormatter {
  const _MaxValueTextInputFormatter(this.maxValue);

  final double maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || newValue.text == '.') return newValue;

    final value = double.tryParse(newValue.text);
    return value != null && value >= WorkoutConstants.minWeight && value <= maxValue ? newValue : oldValue;
  }
}
