import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class BodyWeightStep extends StatefulWidget {
  const BodyWeightStep({super.key});

  @override
  State<BodyWeightStep> createState() => _BodyWeightStepState();
}

class _BodyWeightStepState extends State<BodyWeightStep> {
  QuizCubit get _cubit => context.read<QuizCubit>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final weight = _cubit.state.bodyWeight;
    if (weight != null) {
      _controller.text = _formatWeight(weight);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatWeight(int weight) {
    final unit = _cubit.state.measurementSystem.weight(t);
    return '$weight $unit';
  }

  @override
  Widget build(BuildContext context) {
    final weightOptions = List.generate(
      300,
      (index) => Text(
        _formatWeight(index + 1),
        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.body_weight.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        BlocSelector<QuizCubit, QuizState, int?>(
          selector: (state) => state.bodyWeight,
          builder: (context, bodyWeight) {
            return LabeledAppTextField(
              label: t.quiz.steps.body_weight.select_body_weight_label,
              field: PortalSelectField(
                controller: _controller,
                hintText: t.quiz.steps.body_weight.select_body_weight_label,
                contentBuilder: (_, _) {
                  final weight = bodyWeight ?? 0;
                  final initialItem = weight > 0 ? weight : 0;

                  return ValueScrollPicker(
                    initialItem: initialItem,
                    onSelectedItemChanged: (index) {
                      final weight = index + 1;
                      _controller.text = _formatWeight(weight);
                      _cubit.setBodyWeight(weight);
                    },
                    children: weightOptions,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
