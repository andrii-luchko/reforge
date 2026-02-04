import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/binary_option_switcher.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class MeasurementPage extends StatelessWidget {
  const MeasurementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenericValidationCubit<MeasurementSystem>(
        initialValue: MeasurementSystem.metric,
        onSave: (m) async {},
      ),
      child: BaseSettingsEditPage(
        title: WorkoutSettings.measureSystem.title(t),
        body: const MeasurementContent(),
      ),
    );
  }
}

class MeasurementContent extends StatelessWidget {
  const MeasurementContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericValidationCubit<MeasurementSystem>, GenericValidationState<MeasurementSystem>>(
      builder: (context, state) {
        final cubit = context.read<GenericValidationCubit<MeasurementSystem>>();
        return Column(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .start,
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Select a measurement System',
                  style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
                ),
                const SizedBox(height: 16),

                BinaryOptionSwitcher<MeasurementSystem>(
                  selectedValue: state.value,
                  firstValue: MeasurementSystem.metric,
                  secondValue: MeasurementSystem.imperial,
                  labelBuilder: (v) => v.weightSymbol(t),
                  onSelected: cubit.onChanged,
                ),
              ],
            ),
            SecondaryButton(
              text: t.common.save_changes_button,
              onPressed: cubit.save,
            ),
          ],
        );
      },
    );
  }
}
