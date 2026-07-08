import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

// ignore: prefer_match_file_name
class MeasurementPage extends StatelessWidget {
  const MeasurementPage({
    required this.system,
    super.key,
  });

  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.read<UserCubit>();

    return BlocProvider(
      create: (context) => GenericValidationCubit<MeasurementSystem>(
        initialValue: system,
        onSave: (value) => onSave(value, userCubit),
      ),
      child: GenericSaveListener<MeasurementSystem>(
        child: BaseSettingsEditPage(
          title: WorkoutSettings.measureSystem.title(t),
          body: const MeasurementContent(),
        ),
      ),
    );
  }

  Future<void> onSave(MeasurementSystem value, UserCubit cubit) async {
    final result = await cubit.updateMeasurementSystem(value);

    if (result case Failure(error: final e)) {
      throw e;
    }
  }
}

class MeasurementContent extends StatelessWidget {
  const MeasurementContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericValidationCubit<MeasurementSystem>, GenericValidationState<MeasurementSystem>>(
      builder: (context, state) {
        final cubit = context.read<GenericValidationCubit<MeasurementSystem>>();
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settings.selectMeasurementSystem,
                    style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
                  ),
                  const SizedBox(height: 16),
                  MultiOptionSwitcher<MeasurementSystem>(
                    selectedValue: state.value,
                    values: MeasurementSystem.values,
                    labelBuilder: (v) => v.title(t),
                    onSelected: cubit.onChanged,
                  ),
                ],
              ),
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
      },
    );
  }
}
